import CoreImage.CIFilterBuiltins
import Foundation
import MeemawQuizzCore
import Observation
import SwiftUI
import UIKit

enum DeviceSessionRole: String, Sendable {
    case hostAndPlayer1
    case bonjourClient
}

@Observable
@MainActor
final class GameSessionController {
    static let shared = GameSessionController()

    // MARK: - Role & Network
    var role: DeviceSessionRole = .hostAndPlayer1
    let lanServer = QuizLANServer()
    let bonjourClient = QuizBonjourClient()
    let audio = MeemawShowAudioEngine.shared

    // Local Player Identity (for this iPhone, whether Host J1 or Bonjour Client)
    let localPlayerID: String = {
        if let saved = UserDefaults.standard.string(forKey: "meemawquizz.localPlayerID") {
            return saved
        }
        let created = "ios_" + UUID().uuidString.prefix(8).lowercased()
        UserDefaults.standard.set(created, forKey: "meemawquizz.localPlayerID")
        return created
    }()

    var localPlayerName: String = {
        let saved = UserDefaults.standard.string(forKey: "meemawquizz.localPlayerName")
        if let saved, !saved.isEmpty, saved != "Chef du Salon" {
            return saved
        }
        return "Xabi"
    }() {
        didSet {
            UserDefaults.standard.set(localPlayerName, forKey: "meemawquizz.localPlayerName")
        }
    }

    var localSelectedColor: PlayerColor = .meemawOrange
    var localAvatarEmoji: String = "🦊"

    // MARK: - Synchronized Show State
    var roomCode: String = "MAMIE"
    var selectedGameMode: ShowGameMode = .fullQuizShow
    var selectedPack: QuizThemePack = .grandMix
    var stage: ShowStageState = .lobby
    var roundKind: QuizRoundKind = .cashSpeed
    var questionNumber: Int = 0
    var totalQuestions: Int = 8
    var meemawSpeech: String = "Bienvenue dans le Grand Quizz AirPlay de Meemaw ! Connectez vos téléphones sur le Wi-Fi !"
    var meemawPose: String = "meemaw_salut"
    var timeRemainingSec: Double = 0
    var totalTimerSec: Double = 12

    private static let usedQuestionsKey = "meemawquizz.persistedUsedQuestionIDs"
    private static let usedDisOrDatKey = "meemawquizz.persistedUsedDisOrDatIDs"

    private var registry = PlayerLobbyRegistry()
    private var connectionToPlayerID: [UUID: String] = [:]
    private var usedQuestionIDs: Set<String> = {
        let saved = UserDefaults.standard.stringArray(forKey: "meemawquizz.persistedUsedQuestionIDs") ?? []
        return Set(saved)
    }() {
        didSet {
            UserDefaults.standard.set(Array(usedQuestionIDs), forKey: Self.usedQuestionsKey)
        }
    }
    private var usedDisOrDatIDs: Set<String> = {
        let saved = UserDefaults.standard.stringArray(forKey: "meemawquizz.persistedUsedDisOrDatIDs") ?? []
        return Set(saved)
    }() {
        didSet {
            UserDefaults.standard.set(Array(usedDisOrDatIDs), forKey: Self.usedDisOrDatKey)
        }
    }
    private var activeDeck: ShowGameDeck = QuestionBank.buildShowDeck(for: .grandMix)
    private var phaseQueue: [ShowPhaseStep] = []
    private var currentStepIndex: Int = -1
    private var cachedHostSnapshot: HostToClientStateSnapshot?

    var activeQuestion: QuizMCQQuestion?
    var revealedCorrectIndex: Int?
    var soloBuzzerPlayerID: String?
    var soloBuzzerPlayerName: String?
    var screwAttackerID: String?
    var screwAttackerName: String?
    var activeDisOrDat: QuizDisOrDatRound?
    var activeDisOrDatItemIndex: Int?
    var revealedBinarySide: String?
    var activeDrawRound: DrawRoundState?
    var activeEsquisseRound: EsquisseRoundState?
    var podiumAwards: [PodiumAward] = []

    private var usedDrawWords: Set<String> = []
    private var usedEsquissePrompts: Set<String> = []
    private var drawTurnCursor: Int = 0
    private var drawBotStrokeTask: Task<Void, Never>?

    // Remote state when acting as a Bonjour Client
    var clientSnapshot: HostToClientStateSnapshot?
    var isBonjourConnectedToRemoteHost: Bool = false

    private var questionOpenedAt: Date = Date()
    private var countdownTimer: Timer?
    private var stageAdvanceTask: Task<Void, Never>?
    private var botActionTask: Task<Void, Never>?

    private enum ShowPhaseStep {
        case roundIntro(QuizRoundKind)
        case cashQuestion(QuizMCQQuestion, isDoubleFinale: Bool)
        case ttmcQuestion(QuizMCQQuestion)
        case jukeboxQuestion(QuizMCQQuestion)
        case drawSomethingTurn
        case soloQuestion(QuizMCQQuestion)
        case couciCouca(QuizDisOrDatRound, QuizRoundKind)
        case esquisseStep(Int)
        case esquisseShowcase
        case podium
    }

    private init() {
        setupNetworkingCallbacks()
        startHostingSession()
    }

    // MARK: - Computed Unified Accessors (Works for both Host J1 and Bonjour Client)

    var effectiveSnapshot: HostToClientStateSnapshot {
        if role == .bonjourClient, let snap = clientSnapshot {
            return snap
        }
        if let cached = cachedHostSnapshot {
            return cached
        }
        return buildCurrentSnapshot()
    }

    func unseenQuestionsCount(for pack: QuizThemePack) -> (unseen: Int, total: Int) {
        let all = QuestionBank.questions(for: pack)
        let unseen = all.filter { !usedQuestionIDs.contains($0.id) }.count
        return (unseen, all.count)
    }

    func resetSeenQuestionsHistory() {
        usedQuestionIDs.removeAll()
        usedDisOrDatIDs.removeAll()
        audio.triggerControllerHaptic(style: .medium)
        broadcastState()
    }

    var localPlayer: QuizPlayer? {
        effectiveSnapshot.players.first(where: { $0.id == localPlayerID })
    }

    var joinURLString: String {
        lanServer.joinURLString
    }

    // MARK: - Networking Setup

    private func setupNetworkingCallbacks() {
        lanServer.snapshotProvider = { [weak self] in
            self?.buildCurrentSnapshot() ?? HostToClientStateSnapshot(
                roomCode: "MAMIE",
                joinURL: "",
                selectedPack: .grandMix,
                stage: .lobby,
                roundKind: .cashSpeed,
                questionNumber: 0,
                totalQuestions: 8,
                meemawSpeech: "",
                meemawPose: "meemaw_salut",
                timeRemainingSec: 0,
                totalTimerSec: 12,
                players: [],
                availableColors: PlayerColor.allCases
            )
        }

        lanServer.onClientMessage = { [weak self] connID, message in
            guard let self else { return }
            self.connectionToPlayerID[connID] = message.playerID
            self.handleIncomingPlayerMessage(message, isHostPlayer: false)
        }

        lanServer.onServerStateChanged = { [weak self] in
            self?.broadcastState()
        }

        lanServer.onClientDisconnected = { [weak self] connID in
            guard let self else { return }
            if let pid = self.connectionToPlayerID.removeValue(forKey: connID),
               self.stage == .lobby {
                self.registry.removePlayer(id: pid)
                self.broadcastState()
            }
        }

        bonjourClient.onConnectionStateChanged = { [weak self] connected in
            guard let self else { return }
            self.isBonjourConnectedToRemoteHost = connected
            if connected {
                self.sendLocalProfileUpdate()
            }
        }

        bonjourClient.onSnapshotReceived = { [weak self] snapshot in
            guard let self else { return }
            self.clientSnapshot = snapshot
            if let me = snapshot.players.first(where: { $0.id == self.localPlayerID }) {
                self.localSelectedColor = me.color
                self.localAvatarEmoji = me.avatarEmoji
            }
        }
    }

    func startHostingSession() {
        bonjourClient.stop()
        role = .hostAndPlayer1
        lanServer.start(preferredPort: 8420)
        audio.startBackgroundGroove(ducked: false)
        let hostPlayer = registry.upsertPlayer(
            id: localPlayerID,
            name: localPlayerName,
            requestedColor: localSelectedColor,
            avatarEmoji: localAvatarEmoji,
            isHost: true,
            platform: .iosHost
        )
        localSelectedColor = hostPlayer.color
        localAvatarEmoji = hostPlayer.avatarEmoji
        broadcastState()
    }

    func switchToBonjourClientMode() {
        stopTimers()
        lanServer.stop()
        role = .bonjourClient
        bonjourClient.startAutoDiscovery()
    }

    func removeAllBots() {
        guard role == .hostAndPlayer1 else { return }
        for botID in ["bot_tonton", "bot_tata", "bot_kevin"] {
            registry.removePlayer(id: botID)
        }
        audio.triggerControllerHaptic(style: .light)
        broadcastState()
    }

    func leaveRemoteSession() {
        if role == .bonjourClient {
            bonjourClient.send(ClientToHostMessage(
                playerID: localPlayerID,
                action: .leaveGame
            ))
            bonjourClient.stop()
            clientSnapshot = nil
            isBonjourConnectedToRemoteHost = false
            startHostingSession()
        } else {
            returnToLobby()
        }
    }

    func addDemoBotPlayers() {
        guard role == .hostAndPlayer1 else { return }
        let botCatalog: [(String, String, PlayerColor, String)] = [
            ("bot_tonton", "Tonton Gérard", .electricBlue, "🐬"),
            ("bot_tata", "Tata Josiane", .candyPink, "🦩"),
            ("bot_kevin", "Kévin du 59", .mintGreen, "🐸")
        ]
        for (id, name, color, emoji) in botCatalog {
            if !registry.players.contains(where: { $0.id == id }) {
                registry.upsertPlayer(
                    id: id,
                    name: name,
                    requestedColor: color,
                    avatarEmoji: emoji,
                    isHost: false,
                    platform: .iosBonjour
                )
                break
            }
        }
        audio.triggerControllerHaptic(style: .medium)
        broadcastState()
    }

    // MARK: - Player Actions (Called from Local UI or Remote WebSocket)

    func sendLocalProfileUpdate() {
        let msg = ClientToHostMessage(
            playerID: localPlayerID,
            action: .joinOrUpdateProfile,
            playerName: localPlayerName,
            requestedColor: localSelectedColor,
            avatarEmoji: localAvatarEmoji,
            platform: role == .hostAndPlayer1 ? .iosHost : .iosBonjour
        )
        dispatchAction(msg)
    }

    func submitChoice(_ index: Int) {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .selectChoice,
            choiceIndex: index
        ))
    }

    func submitBetStars(_ stars: Int) {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .selectBetStars,
            betStars: stars
        ))
    }

    func submitSoloBuzz() {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .buzzSolo
        ))
    }

    func submitBinarySide(_ side: String) {
        audio.triggerControllerHaptic(style: .medium)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .selectBinarySide,
            binarySide: side
        ))
    }

    func sendBisouTrap(to targetPlayerID: String) {
        audio.triggerControllerHaptic(style: .rigid)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .sendBisouTrap,
            targetPlayerID: targetPlayerID
        ))
    }

    func sendScrewOpponent(to targetPlayerID: String) {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .screwOpponent,
            targetPlayerID: targetPlayerID
        ))
    }

    func wipeLocalBisouScreen() {
        audio.triggerControllerHaptic(style: .light)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .wipeBisouScreen
        ))
    }

    func selectDrawWord(_ word: String) {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .selectDrawWord,
            textPayload: word
        ))
    }

    func sendDrawingCanvasUpdate(_ canvas: DrawingCanvasData) {
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .updateDrawingCanvas,
            drawingCanvas: canvas
        ))
    }

    func submitDrawGuessWord(_ guess: String) {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .submitDrawGuessWord,
            textPayload: guess
        ))
    }

    func requestDrawHint() {
        audio.triggerControllerHaptic(style: .medium)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .requestDrawHint
        ))
    }

    func submitEsquisseText(_ text: String) {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .submitEsquisseText,
            textPayload: text
        ))
    }

    func submitEsquisseDrawing(_ canvas: DrawingCanvasData) {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .submitEsquisseDrawing,
            drawingCanvas: canvas
        ))
    }

    func voteEsquisseAlbum(_ notebookID: String) {
        audio.triggerControllerHaptic(style: .medium)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .voteEsquisseAlbum,
            textPayload: notebookID
        ))
    }

    private func dispatchAction(_ message: ClientToHostMessage) {
        if role == .hostAndPlayer1 {
            handleIncomingPlayerMessage(message, isHostPlayer: message.playerID == localPlayerID)
        } else {
            bonjourClient.send(message)
        }
    }

    // MARK: - Server-Side Message Processing

    private func handleIncomingPlayerMessage(_ msg: ClientToHostMessage, isHostPlayer: Bool) {
        switch msg.action {
        case .joinOrUpdateProfile:
            let updated = registry.upsertPlayer(
                id: msg.playerID,
                name: msg.playerName ?? "Invité",
                requestedColor: msg.requestedColor,
                avatarEmoji: msg.avatarEmoji,
                isHost: isHostPlayer,
                platform: msg.platform ?? .iosBonjour
            )
            if isHostPlayer {
                localSelectedColor = updated.color
                localAvatarEmoji = updated.avatarEmoji
            }
            broadcastState()

        case .selectChoice:
            guard let choice = msg.choiceIndex else { return }
            handlePlayerChoice(playerID: msg.playerID, choiceIndex: choice)

        case .selectBetStars:
            guard let stars = msg.betStars else { return }
            handlePlayerBetStars(playerID: msg.playerID, stars: stars)

        case .buzzSolo:
            handlePlayerSoloBuzz(playerID: msg.playerID)

        case .selectBinarySide:
            guard let side = msg.binarySide else { return }
            handlePlayerBinarySide(playerID: msg.playerID, side: side)

        case .sendBisouTrap:
            guard let targetID = msg.targetPlayerID else { return }
            handleBisouTrap(fromPlayerID: msg.playerID, toPlayerID: targetID)

        case .screwOpponent:
            guard let targetID = msg.targetPlayerID else { return }
            handleScrewOpponent(fromPlayerID: msg.playerID, toPlayerID: targetID)

        case .wipeBisouScreen:
            registry.updatePlayer(id: msg.playerID) { p in
                p.activeBisouWipesRemaining = max(0, p.activeBisouWipesRemaining - 1)
                if p.activeBisouWipesRemaining == 0 {
                    p.bisouSenderName = nil
                }
            }
            broadcastState()

        case .selectDrawWord:
            guard let word = msg.textPayload else { return }
            handleSelectDrawWord(playerID: msg.playerID, word: word)

        case .updateDrawingCanvas:
            guard let canvas = msg.drawingCanvas else { return }
            handleUpdateDrawingCanvas(playerID: msg.playerID, canvas: canvas)

        case .submitDrawGuessWord:
            guard let guess = msg.textPayload else { return }
            handleSubmitDrawGuessWord(playerID: msg.playerID, guess: guess)

        case .requestDrawHint:
            handleRequestDrawHint(playerID: msg.playerID)

        case .submitEsquisseText:
            guard let text = msg.textPayload else { return }
            handleSubmitEsquisseText(playerID: msg.playerID, text: text)

        case .submitEsquisseDrawing:
            guard let canvas = msg.drawingCanvas else { return }
            handleSubmitEsquisseDrawing(playerID: msg.playerID, canvas: canvas)

        case .voteEsquisseAlbum:
            guard let notebookID = msg.textPayload else { return }
            handleVoteEsquisseAlbum(playerID: msg.playerID, notebookID: notebookID)

        case .leaveGame:
            if !isHostPlayer {
                registry.removePlayer(id: msg.playerID)
                broadcastState()
            }

        case .ping:
            broadcastState()
        }
    }

    // MARK: - Show Flow Orchestration (Host Only)

    func startSoloTestShow(withBots: Bool = false) {
        guard role == .hostAndPlayer1 else { return }
        // Remove bots if solo pure, or add 2 bots if requested
        for botID in ["bot_tonton", "bot_tata", "bot_kevin"] {
            registry.removePlayer(id: botID)
        }
        if withBots {
            addDemoBotPlayers()
            addDemoBotPlayers()
        }
        startNewShow()
    }

    func selectGameMode(_ mode: ShowGameMode) {
        guard role == .hostAndPlayer1 else { return }
        selectedGameMode = mode
        meemawSpeech = "Mode choisi : \(mode.title) — \(mode.subtitle)"
        audio.triggerControllerHaptic(style: .medium)
        broadcastState()
    }

    func selectThemePack(_ pack: QuizThemePack) {
        guard role == .hostAndPlayer1 else { return }
        selectedPack = pack
        meemawSpeech = "Thème sélectionné : \(pack.title) ! \(pack.subtitle)"
        broadcastState()
    }

    func startNewShow() {
        guard role == .hostAndPlayer1 else { return }
        stopTimers()
        registry.resetForNewShow()
        activeDrawRound = nil
        activeEsquisseRound = nil
        drawTurnCursor = 0

        switch selectedGameMode {
        case .drawSomethingOnly:
            phaseQueue = [
                .roundIntro(.drawSomething),
                .drawSomethingTurn,
                .drawSomethingTurn,
                .drawSomethingTurn,
                .drawSomethingTurn,
                .drawSomethingTurn,
                .drawSomethingTurn,
                .podium
            ]
            totalQuestions = 6
            questionNumber = 0
            currentStepIndex = -1
            audio.playJingle("jingle_intro.wav")
            advanceToNextPhaseStep()
            return

        case .esquisseParty:
            setupEsquisseNotebooks()
            phaseQueue = [
                .roundIntro(.esquisseTeleArabe),
                .esquisseStep(0),
                .esquisseStep(1),
                .esquisseStep(2),
                .esquisseStep(3),
                .esquisseShowcase,
                .podium
            ]
            totalQuestions = 4
            questionNumber = 0
            currentStepIndex = -1
            audio.playJingle("jingle_intro.wav")
            advanceToNextPhaseStep()
            return

        case .fullQuizShow:
            break
        }

        let packQuestions = QuestionBank.questions(for: selectedPack)
        let unseenInPack = packQuestions.filter { !usedQuestionIDs.contains($0.id) }
        if unseenInPack.count < 11 {
            usedQuestionIDs.subtract(packQuestions.map(\.id))
        }
        let packCouci = QuestionBank.disOrDatRounds(for: selectedPack)
        if packCouci.filter({ !usedDisOrDatIDs.contains($0.id) }).isEmpty {
            usedDisOrDatIDs.subtract(packCouci.map(\.id))
        }

        activeDeck = QuestionBank.buildShowDeck(
            for: selectedPack,
            excludingQuestionIDs: usedQuestionIDs,
            excludingDisOrDatIDs: usedDisOrDatIDs
        )
        usedQuestionIDs.formUnion(activeDeck.allExtendedMCQIDs)
        usedDisOrDatIDs.insert(activeDeck.couciCoucaRound.id)

        phaseQueue = [
            .roundIntro(.cashSpeed),
            .cashQuestion(activeDeck.cashQuestions[0], isDoubleFinale: false),
            .cashQuestion(activeDeck.cashQuestions[1], isDoubleFinale: false),
            .roundIntro(.tuTeMetsCombien),
            .ttmcQuestion(activeDeck.ttmcQuestions[0]),
            .ttmcQuestion(activeDeck.ttmcQuestions[1]),
            .roundIntro(.jukeboxExpress),
            .jukeboxQuestion(activeDeck.jukeboxQuestions[0]),
            .jukeboxQuestion(activeDeck.jukeboxQuestions[1]),
            .roundIntro(.drawSomething),
            .drawSomethingTurn,
            .roundIntro(.leSolo),
            .soloQuestion(activeDeck.soloQuestions[0]),
            .roundIntro(.couciCouca),
            .couciCouca(activeDeck.couciCoucaRound, .couciCouca),
            .roundIntro(.finaleDouble),
            .cashQuestion(activeDeck.finaleDoubleQuestions[0], isDoubleFinale: true),
            .cashQuestion(activeDeck.finaleDoubleQuestions[1], isDoubleFinale: true),
            .podium
        ]
        totalQuestions = 11
        questionNumber = 0
        currentStepIndex = -1

        audio.playJingle("jingle_intro.wav")
        advanceToNextPhaseStep()
    }

    func returnToLobby() {
        guard role == .hostAndPlayer1 else { return }
        stopTimers()
        audio.stopVoiceOnly()
        audio.setMusicMood(.chillLobby)
        registry.resetRoundLocks()
        stage = .lobby
        activeQuestion = nil
        activeDisOrDat = nil
        activeDrawRound = nil
        activeEsquisseRound = nil
        revealedCorrectIndex = nil
        revealedBinarySide = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        screwAttackerID = nil
        screwAttackerName = nil
        podiumAwards = []
        meemawPose = "meemaw_salut"
        meemawSpeech = "Partie arrêtée ! De retour au salon : choisissez votre mode de jeu et vos couleurs !"
        broadcastState()
    }

    func finishGameToPodiumNow() {
        guard role == .hostAndPlayer1 else { return }
        stopTimers()
        audio.stopVoiceOnly()
        enterFinalPodium()
    }

    func skipToNextStep() {
        guard role == .hostAndPlayer1 else { return }
        stopTimers()
        if stage == .ttmcBetting, let q = activeQuestion {
            openTTMCAnsweringPhase(q)
            return
        }
        if stage == .drawWordChoice, let firstOpt = activeDrawRound?.wordOptions.first {
            handleSelectDrawWord(playerID: activeDrawRound?.drawerPlayerID ?? localPlayerID, word: firstOpt.word)
            return
        }
        if stage == .drawLiveGuessing {
            revealDrawRoundResult()
            return
        }
        if stage == .esquissePromptEntry || stage == .esquisseDrawing || stage == .esquisseGuessing {
            finalizeCurrentEsquisseStepAndAdvance()
            return
        }
        if stage == .esquisseShowcase {
            advanceEsquisseShowcaseStep()
            return
        }
        if stage == .couciCoucaItem, let idx = activeDisOrDatItemIndex {
            scoreAndAdvanceCouciItem(at: idx)
            return
        }
        if stage == .couciCoucaReveal, let idx = activeDisOrDatItemIndex {
            startCouciCoucaItem(at: idx + 1)
            return
        }
        advanceToNextPhaseStep()
    }

    private func advanceToNextPhaseStep() {
        stopTimers()
        currentStepIndex += 1
        guard phaseQueue.indices.contains(currentStepIndex) else {
            enterFinalPodium()
            return
        }

        let step = phaseQueue[currentStepIndex]
        switch step {
        case .roundIntro(let kind):
            enterRoundIntro(kind)
        case .cashQuestion(let q, let isDouble):
            questionNumber += 1
            enterCashQuestion(q, isDoubleFinale: isDouble)
        case .ttmcQuestion(let q):
            questionNumber += 1
            enterTTMCQuestion(q)
        case .jukeboxQuestion(let q):
            questionNumber += 1
            enterJukeboxQuestion(q)
        case .drawSomethingTurn:
            questionNumber += 1
            enterDrawSomethingTurn()
        case .soloQuestion(let q):
            questionNumber += 1
            enterSoloQuestion(q)
        case .couciCouca(let round, let kind):
            questionNumber += 1
            enterCouciCoucaRound(round, kind: kind)
        case .esquisseStep(let stepIdx):
            questionNumber = stepIdx + 1
            enterEsquisseStep(stepIdx)
        case .esquisseShowcase:
            enterEsquisseShowcase()
        case .podium:
            enterFinalPodium()
        }
    }

    // MARK: - Round Intro

    private func enterRoundIntro(_ kind: QuizRoundKind) {
        roundKind = kind
        stage = .roundIntro
        activeQuestion = nil
        activeDisOrDat = nil
        activeDrawRound = nil
        revealedCorrectIndex = nil
        revealedBinarySide = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        screwAttackerID = nil
        screwAttackerName = nil

        let studioFile: String
        let text: String
        switch kind {
        case .cashSpeed:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round1_cash.m4a"
            text = "Manche 1 : Cash Rapide ! Tout le monde répond sur son téléphone, et vous avez 1 VIS « Clouer le Bec » façon Jack pour piéger un adversaire !"
            meemawPose = "meemaw_vitesse"
            audio.playJingle("jingle_intro.wav")
        case .tuTeMetsCombien:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round_ttmc.m4a"
            text = "Manche 2 : Tu Te Mets Combien ? Avant de voir la question, misez de 1 à 4 étoiles sur le sujet annoncé par Meemaw : 4 étoiles, c'est 5 000 points ou la gamelle !"
            meemawPose = "meemaw_duel_challenge"
            audio.playJingle("jingle_couci.wav")
        case .jukeboxExpress:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round_jukebox.m4a"
            text = "Manche 3 : Le Jukebox Express de Meemaw ! Complétez les paroles exactes au moment où la musique coupe !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_intro.wav")
        case .drawSomething:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round_draw.m4a"
            text = "🎨 Manche Pinceau Draw Something ! Un artiste dessine en direct sur la TV, et les autres composent le mot avec les lettres mélangées sur leur téléphone !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_couci.wav")
        case .leSolo:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round2_solo_fast.m4a"
            text = "C'est l'heure du SOLO ! Pas besoin de buzzer : le tout premier qui tape une réponse sur son téléphone gagne le DOUBLE... ou perd tout s'il se plante !"
            meemawPose = "meemaw_boxing_referee"
            audio.playJingle("jingle_solo_siren.wav")
        case .couciCouca, .quoizziQuoissa:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round3_raclette.m4a"
            text = "La Raclette Quizz de Meemaw ! 6 questions qui fondent dans le poêlon : Gauche, Droite, ou LES DEUX !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_couci.wav")
        case .esquisseTeleArabe:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round_esquisse.m4a"
            text = "📞 Bienvenue dans ESQUISSÉ ! Écrivez une idée folle, dessinez ce que vous lisez, et devinez librement au clavier ce que le voisin a gribouillé !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_couci.wav")
        case .finaleDouble:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round4_finale.m4a"
            text = "La Rafale Finale ! Tous les points sont DOUBLÉS, tout peut encore basculer !"
            meemawPose = "meemaw_duel_challenge"
            audio.playJingle("jingle_solo_siren.wav")
        }

        meemawSpeech = text
        broadcastState()

        // Guaranteed auto-advance countdown even if the host forgets to press Next or audio callback drops
        startCountdown(duration: 6.5) { [weak self] in
            self?.advanceToNextPhaseStep()
        }

        audio.playMeemawStudioOrFallback(studioFilename: studioFile, fallbackText: text)
    }

    // MARK: - Manche 2 : 🎯 « Tu Te Mets Combien ? » (Bet 1 to 4 stars before seeing the question!)

    private func enterTTMCQuestion(_ question: QuizMCQQuestion) {
        registry.resetRoundLocks()
        roundKind = .tuTeMetsCombien
        activeQuestion = question
        revealedCorrectIndex = nil
        revealedBinarySide = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        screwAttackerID = nil
        screwAttackerName = nil
        stage = .ttmcBetting
        totalTimerSec = 14.0
        timeRemainingSec = 14.0
        meemawPose = "meemaw_duel_challenge"
        let betPrompt = "🎯 TU TE METS COMBIEN (de ⭐ à ⭐⭐⭐⭐) sur : « \(question.funnyTitle) » (\(question.theme.shortBadge)) ?"
        meemawSpeech = betPrompt
        broadcastState()

        let ttmcCue = question.audioCueID.map { "\($0)_ttmc.m4a" } ?? "mq_round_ttmc.m4a"
        audio.playMeemawStudioOrFallback(
            studioFilename: ttmcCue,
            fallbackText: "Tu te mets combien de une à quatre étoiles sur : \(question.funnyTitle) ?"
        )

        // Schedule bots to lock their bet stars
        let bots = registry.players.filter { $0.id.hasPrefix("bot_") }
        if !bots.isEmpty {
            botActionTask?.cancel()
            botActionTask = Task { @MainActor [weak self] in
                for bot in bots {
                    let delayMs = Int.random(in: 1800...4200)
                    try? await Task.sleep(for: .milliseconds(delayMs))
                    guard let self, !Task.isCancelled, self.stage == .ttmcBetting else { return }
                    let stars = [2, 2, 3, 3, 4, 1].randomElement() ?? 2
                    self.handlePlayerBetStars(playerID: bot.id, stars: stars)
                }
            }
        }

        startCountdown(duration: 14.0) { [weak self] in
            self?.openTTMCAnsweringPhase(question)
        }
    }

    private func handlePlayerBetStars(playerID: String, stars: Int) {
        guard stage == .ttmcBetting, let q = activeQuestion else { return }
        let clamped = max(1, min(4, stars))
        registry.updatePlayer(id: playerID) { p in
            p.lockedBetStars = clamped
        }
        broadcastState()

        if registry.players.allSatisfy({ $0.lockedBetStars != nil }) {
            stopTimers()
            openTTMCAnsweringPhase(q)
        }
    }

    private func openTTMCAnsweringPhase(_ question: QuizMCQQuestion) {
        stopTimers()
        // Default any player who didn't pick a star level to 2 stars
        for p in registry.players where p.lockedBetStars == nil {
            registry.updatePlayer(id: p.id) { $0.lockedBetStars = 2 }
        }
        stage = .cashAnswering
        totalTimerSec = 24.0
        timeRemainingSec = 24.0
        questionOpenedAt = Date()
        meemawPose = "meemaw_dictation_talk"
        meemawSpeech = "Les paris sont fermés ! Voici la question : \(question.prompt)"
        broadcastState()

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        scheduleBotsForCashQuestion(question)
        startCountdown(duration: 24.0) { [weak self] in
            self?.revealCashQuestionResult(question, isDoubleFinale: false)
        }
    }

    // MARK: - Manche 3 : 🎧 « Le Jukebox Express » (Paroles Coupées & Tubes)

    private func enterJukeboxQuestion(_ question: QuizMCQQuestion) {
        registry.resetRoundLocks()
        roundKind = .jukeboxExpress
        activeQuestion = question
        revealedCorrectIndex = nil
        revealedBinarySide = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        screwAttackerID = nil
        screwAttackerName = nil
        stage = .cashAnswering
        totalTimerSec = 24.0
        timeRemainingSec = 24.0
        questionOpenedAt = Date()
        meemawPose = "meemaw_fun"
        meemawSpeech = "🎧 \(question.funnyTitle) — \(question.prompt)"
        broadcastState()

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        scheduleBotsForCashQuestion(question)
        startCountdown(duration: 24.0) { [weak self] in
            self?.revealCashQuestionResult(question, isDoubleFinale: false)
        }
    }

    // MARK: - Manche 1 & 6 : Cash Speed / Finale Double

    private func enterCashQuestion(_ question: QuizMCQQuestion, isDoubleFinale: Bool) {
        registry.resetRoundLocks()
        roundKind = isDoubleFinale ? .finaleDouble : .cashSpeed
        activeQuestion = question
        revealedCorrectIndex = nil
        revealedBinarySide = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        screwAttackerID = nil
        screwAttackerName = nil
        stage = .cashAnswering
        totalTimerSec = 26.0
        timeRemainingSec = 26.0
        questionOpenedAt = Date()
        meemawPose = "meemaw_dictation_talk"
        meemawSpeech = "« \(question.funnyTitle) » — \(question.prompt)"
        broadcastState()

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        scheduleBotsForCashQuestion(question)
        startCountdown(duration: 26.0) { [weak self] in
            self?.revealCashQuestionResult(question, isDoubleFinale: isDoubleFinale)
        }
    }

    private func handlePlayerChoice(playerID: String, choiceIndex: Int) {
        // Manche LE SOLO ou VICTIME D'UN « CLOUER LE BEC » (The Screw) :
        if stage == .soloBuzzOpen || stage == .soloPlayerAnswering {
            guard let q = activeQuestion else { return }
            guard let player = registry.players.first(where: { $0.id == playerID }),
                  player.activeBisouWipesRemaining == 0 else { return }
            guard soloBuzzerPlayerID == nil || soloBuzzerPlayerID == playerID else { return }

            let elapsedMs = max(100, Int(Date().timeIntervalSince(questionOpenedAt) * 1000))
            soloBuzzerPlayerID = player.id
            soloBuzzerPlayerName = player.name
            registry.updatePlayer(id: playerID) { p in
                p.lockedChoiceIndex = choiceIndex
                p.reactionTimeMs = elapsedMs
            }
            audio.playJingle("sfx_buzz.wav")
            revealSoloQuestionResult(q, buzzerPlayerID: playerID, chosenIndex: choiceIndex)
            return
        }

        guard stage == .cashAnswering, let q = activeQuestion else { return }
        guard let player = registry.players.first(where: { $0.id == playerID }),
              player.lockedChoiceIndex == nil,
              player.activeBisouWipesRemaining == 0 else { return }

        let elapsedMs = max(150, Int(Date().timeIntervalSince(questionOpenedAt) * 1000))
        registry.updatePlayer(id: playerID) { p in
            p.lockedChoiceIndex = choiceIndex
            p.reactionTimeMs = elapsedMs
        }
        broadcastState()

        // If all players have locked their answer, reveal immediately!
        if registry.players.allSatisfy({ $0.lockedChoiceIndex != nil }) {
            stopTimers()
            revealCashQuestionResult(q, isDoubleFinale: roundKind == .finaleDouble)
        }
    }

    private func revealCashQuestionResult(_ question: QuizMCQQuestion, isDoubleFinale: Bool) {
        stopTimers()
        stage = .questionReveal
        revealedCorrectIndex = question.correctIndex

        // Order correct players by reactionTimeMs
        let correctPlayerIDs = registry.players
            .filter { $0.lockedChoiceIndex == question.correctIndex }
            .sorted { ($0.reactionTimeMs ?? 99999) < ($1.reactionTimeMs ?? 99999) }
            .map(\.id)

        var fastestWinner: (name: String, delta: Int, ms: Int)?

        for player in registry.players {
            guard let chosen = player.lockedChoiceIndex else {
                let timeoutPenalty = (roundKind == .tuTeMetsCombien)
                    ? QuizScoringEngine.ttmcStakes(for: player.lockedBetStars ?? 2).loss
                    : 0
                registry.updatePlayer(id: player.id) { p in
                    p.score += timeoutPenalty
                    p.lastDeltaScore = timeoutPenalty
                    p.streak = 0
                }
                continue
            }
            let isCorrect = (chosen == question.correctIndex)
            let rankIdx = correctPlayerIDs.firstIndex(of: player.id)
            let ms = player.reactionTimeMs ?? 25000
            let delta: Int
            if roundKind == .tuTeMetsCombien {
                delta = QuizScoringEngine.scoreTTMCAnswer(
                    stars: player.lockedBetStars ?? 2,
                    isCorrect: isCorrect,
                    isFastest: rankIdx == 0
                )
            } else {
                delta = QuizScoringEngine.scoreCashAnswer(
                    baseValue: question.baseValue,
                    isCorrect: isCorrect,
                    correctRankIndex: rankIdx,
                    reactionTimeMs: ms,
                    totalTimeMs: 26000,
                    isDoubleFinale: isDoubleFinale
                )
            }
            registry.updatePlayer(id: player.id) { p in
                p.score += delta
                p.lastDeltaScore = delta
                if isCorrect {
                    p.streak += 1
                    p.correctAnswersCount += 1
                    p.totalReactionMsSum += ms
                } else {
                    p.streak = 0
                }
            }
            if rankIdx == 0 {
                fastestWinner = (player.name, delta, ms)
            }
        }

        // Guaranteed auto-advance after 9.5s if the host forgets to press Next
        startCountdown(duration: 9.5) { [weak self] in
            self?.advanceToNextPhaseStep()
        }

        if let winner = fastestWinner {
            audio.playJingle("sfx_correct.wav")
            let praise = MeemawPunchlines.dynamicFastestPraise(
                playerName: winner.name,
                delta: winner.delta,
                reactionMs: winner.ms
            )
            meemawPose = "meemaw_celebrate"
            meemawSpeech = "\(praise)\n\(question.explanation)"
            broadcastState()

            let winFile = question.audioCueID.map { "\($0)_win.m4a" } ?? "mq_react_all_correct.m4a"
            audio.playMeemawStudioOrFallback(
                studioFilename: winFile,
                fallbackText: "\(praise) \(question.explanation)"
            )
        } else {
            audio.playJingle("sfx_wrong.wav")
            meemawPose = "meemaw_worried"
            meemawSpeech = "\(question.meemawRoastOnWrong)\n\(question.explanation)"
            broadcastState()

            let roastFile = question.audioCueID.map { "\($0)_roast.m4a" } ?? "mq_react_nobody_correct.m4a"
            audio.playMeemawStudioOrFallback(
                studioFilename: roastFile,
                fallbackText: question.meemawRoastOnWrong
            )
        }
    }

    // MARK: - Manche 2 : « LE SOLO » (1er qui répond gagne le double ou perd tout !)

    private func enterSoloQuestion(_ question: QuizMCQQuestion) {
        registry.resetRoundLocks()
        roundKind = .leSolo
        activeQuestion = question
        revealedCorrectIndex = nil
        revealedBinarySide = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        screwAttackerID = nil
        screwAttackerName = nil
        stage = .soloBuzzOpen
        totalTimerSec = 24.0
        timeRemainingSec = 24.0
        questionOpenedAt = Date()
        meemawPose = "meemaw_boxing_referee"
        meemawSpeech = "🚨 LE SOLO (\(question.baseValue * 2) PTS) : Le 1er qui tape une réponse prend tout ou perd tout ! « \(question.funnyTitle) »"
        broadcastState()

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        scheduleBotsForSoloBuzz(question)
        startCountdown(duration: 24.0) { [weak self] in
            // Nobody answered in time!
            guard let self else { return }
            self.stage = .questionReveal
            self.revealedCorrectIndex = question.correctIndex
            self.meemawSpeech = "Personne n'a osé tenter le SOLO ! Bande de poules mouillées ! \(question.explanation)"
            self.broadcastState()
            self.startCountdown(duration: 8.0) { [weak self] in
                self?.advanceToNextPhaseStep()
            }
        }
    }

    private func handlePlayerSoloBuzz(playerID: String) {
        // Fallback if an older client sends buzzSolo: pick no choice yet or lock player
        guard stage == .soloBuzzOpen, soloBuzzerPlayerID == nil, let q = activeQuestion else { return }
        guard let player = registry.players.first(where: { $0.id == playerID }) else { return }

        stopTimers()
        audio.playJingle("sfx_buzz.wav")
        soloBuzzerPlayerID = player.id
        soloBuzzerPlayerName = player.name
        stage = .soloPlayerAnswering
        totalTimerSec = 12.0
        timeRemainingSec = 12.0
        questionOpenedAt = Date()

        let callout = MeemawPunchlines.dynamicSoloBuzzCallout(playerName: player.name)
        meemawPose = "meemaw_duel_challenge"
        meemawSpeech = callout
        broadcastState()

        audio.playMeemawStudioOrFallback(
            studioFilename: "mq_solo_buzz.m4a",
            fallbackText: callout
        )

        startCountdown(duration: 12.0) { [weak self] in
            guard let self, self.stage == .soloPlayerAnswering else { return }
            self.revealSoloQuestionResult(q, buzzerPlayerID: player.id, chosenIndex: nil)
        }
    }

    private func revealSoloQuestionResult(_ question: QuizMCQQuestion, buzzerPlayerID: String, chosenIndex: Int?) {
        stopTimers()
        stage = .questionReveal
        revealedCorrectIndex = question.correctIndex

        // Clear all other players' lastDeltaScore first so only involved players show deltas
        for p in registry.players {
            registry.updatePlayer(id: p.id) { $0.lastDeltaScore = 0 }
        }

        let isCorrect = (chosenIndex == question.correctIndex)
        let playerName = registry.players.first(where: { $0.id == buzzerPlayerID })?.name ?? "Le joueur"

        // Check if this Solo spotlight was triggered by a You Don't Know Jack "CLOUER LE BEC" (Screw)!
        if let attackerID = screwAttackerID,
           let attackerName = screwAttackerName {
            let multiplier = (roundKind == .finaleDouble) ? 2 : 1
            let base = question.baseValue * multiplier
            if isCorrect {
                // Victim got it RIGHT! Backfire on the attacker!
                let victimBonus = base * 2
                let attackerPenalty = -(base / 2)
                registry.updatePlayer(id: buzzerPlayerID) { p in
                    p.score += victimBonus
                    p.lastDeltaScore = victimBonus
                    p.streak += 1
                    p.correctAnswersCount += 1
                    p.soloWinsCount += 1
                }
                registry.updatePlayer(id: attackerID) { a in
                    a.score += attackerPenalty
                    a.lastDeltaScore = attackerPenalty
                    a.streak = 0
                }
                audio.playJingle("sfx_correct.wav")
                let line = "🔩💥 RETOUR DE MANIVELLE ! \(playerName) connaissait la réponse et empoche +\(victimBonus) points ! \(attackerName) perd \(abs(attackerPenalty)) points pour avoir voulu lui clouer le bec !"
                meemawPose = "meemaw_celebrate"
                meemawSpeech = "\(line)\n\(question.explanation)"
                broadcastState()
                startCountdown(duration: 9.5) { [weak self] in
                    self?.advanceToNextPhaseStep()
                }
                audio.playMeemawStudioOrFallback(
                    studioFilename: "mq_screw_backfire.m4a",
                    fallbackText: line
                )
            } else {
                // Victim got it WRONG! The Screw succeeded!
                let victimPenalty = -base
                let attackerBonus = base
                registry.updatePlayer(id: buzzerPlayerID) { p in
                    p.score += victimPenalty
                    p.lastDeltaScore = victimPenalty
                    p.streak = 0
                }
                registry.updatePlayer(id: attackerID) { a in
                    a.score += attackerBonus
                    a.lastDeltaScore = attackerBonus
                }
                audio.playJingle("sfx_wrong.wav")
                let line = "🔩🎯 BEC CLOUÉ ! \(playerName) s'est planté en beauté (\(victimPenalty) pts) ! \(attackerName) jubile et rafle +\(attackerBonus) points de coup de Jarnac !"
                meemawPose = "meemaw_giggle"
                meemawSpeech = "\(line)\n\(question.explanation)"
                broadcastState()
                startCountdown(duration: 9.5) { [weak self] in
                    self?.advanceToNextPhaseStep()
                }
                audio.playMeemawStudioOrFallback(
                    studioFilename: "mq_screw_success.m4a",
                    fallbackText: line
                )
            }
            return
        }

        let delta = QuizScoringEngine.scoreSoloAnswer(baseValue: question.baseValue, isCorrect: isCorrect)

        registry.updatePlayer(id: buzzerPlayerID) { p in
            p.score += delta
            p.lastDeltaScore = delta
            if isCorrect {
                p.streak += 1
                p.correctAnswersCount += 1
                p.soloWinsCount += 1
            } else {
                p.streak = 0
            }
        }

        audio.playJingle(isCorrect ? "sfx_correct.wav" : "sfx_wrong.wav")
        let line = MeemawPunchlines.dynamicSoloResult(playerName: playerName, isCorrect: isCorrect, delta: delta)
        meemawPose = isCorrect ? "meemaw_celebrate" : "meemaw_giggle"
        meemawSpeech = "\(line)\n\(question.explanation)"
        broadcastState()

        // Guaranteed auto-advance after 9.5s if the host forgets to press Next
        startCountdown(duration: 9.5) { [weak self] in
            self?.advanceToNextPhaseStep()
        }

        let soloStudioCue: String
        if isCorrect {
            soloStudioCue = question.audioCueID.map { "\($0)_win.m4a" } ?? "mq_solo_success.m4a"
        } else {
            soloStudioCue = question.audioCueID.map { "\($0)_roast.m4a" } ?? "mq_solo_fail.m4a"
        }
        audio.playMeemawStudioOrFallback(
            studioFilename: soloStudioCue,
            fallbackText: line
        )
    }

    // MARK: - Manche 3 : La Raclette Quizz (DisOrDat / 3 choix)

    private func enterCouciCoucaRound(_ round: QuizDisOrDatRound, kind: QuizRoundKind) {
        registry.resetRoundLocks()
        roundKind = kind
        activeQuestion = nil
        activeDisOrDat = round
        revealedCorrectIndex = nil
        revealedBinarySide = nil
        meemawPose = "meemaw_fun"

        // Start Item 0 IMMEDIATELY so players can answer right away without waiting for Meemaw to finish talking!
        startCouciCoucaItem(at: 0, isFirstItemWithIntroVoice: true)

        let cueFile = round.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(round.funnyTitle). \(round.prompt)"
        )
    }

    private func startCouciCoucaItem(at index: Int, isFirstItemWithIntroVoice: Bool = false) {
        stopTimers()
        guard let round = activeDisOrDat, round.items.indices.contains(index) else {
            finishCouciCoucaRound()
            return
        }
        registry.resetRoundLocks()
        activeDisOrDatItemIndex = index
        revealedBinarySide = nil
        stage = .couciCoucaItem
        let duration: Double = isFirstItemWithIntroVoice ? 16.0 : 10.0
        totalTimerSec = duration
        timeRemainingSec = duration
        let item = round.items[index]
        meemawSpeech = "🧀 RACLETTE QUIZZ (\(index + 1)/\(round.items.count)) : « \(item.text) »"
        broadcastState()

        scheduleBotsForCouciItem(item, round: round)
        startCountdown(duration: duration) { [weak self] in
            self?.scoreAndAdvanceCouciItem(at: index)
        }
    }

    private func handlePlayerBinarySide(playerID: String, side: String) {
        guard stage == .couciCoucaItem,
              let round = activeDisOrDat,
              let idx = activeDisOrDatItemIndex,
              round.items.indices.contains(idx) else { return }
        guard let player = registry.players.first(where: { $0.id == playerID }),
              player.lockedSide == nil else { return }

        registry.updatePlayer(id: playerID) { p in
            p.lockedSide = side
        }
        broadcastState()

        if registry.players.allSatisfy({ $0.lockedSide != nil }) {
            stopTimers()
            scoreAndAdvanceCouciItem(at: idx)
        }
    }

    private func scoreAndAdvanceCouciItem(at index: Int) {
        stopTimers()
        guard let round = activeDisOrDat, round.items.indices.contains(index) else { return }
        let item = round.items[index]

        stage = .couciCoucaReveal
        revealedBinarySide = item.correctSide

        var anyCorrect = false
        for player in registry.players {
            guard let side = player.lockedSide else {
                registry.updatePlayer(id: player.id) { p in
                    p.lastDeltaScore = 0
                    p.streak = 0
                }
                continue
            }
            let isCorrect = (side == item.correctSide)
            if isCorrect { anyCorrect = true }
            let newStreak = isCorrect ? (player.streak + 1) : 0
            let delta = QuizScoringEngine.scoreDisOrDatAnswer(
                valuePerItem: round.valuePerItem,
                isCorrect: isCorrect,
                currentStreak: newStreak
            )
            registry.updatePlayer(id: player.id) { p in
                p.score += delta
                p.lastDeltaScore = delta
                p.streak = newStreak
                if isCorrect { p.correctAnswersCount += 1 }
            }
        }

        let correctLabel: String
        switch item.correctSide {
        case "left":
            correctLabel = round.optionLeft
        case "both":
            correctLabel = round.optionBoth ?? "🧀 LES DEUX !"
        default:
            correctLabel = round.optionRight
        }

        meemawPose = anyCorrect ? "meemaw_celebrate" : "meemaw_worried"
        meemawSpeech = "✅ Réponse (\(index + 1)/\(round.items.count)) : \(correctLabel) ! — « \(item.text) »"
        audio.playJingle(anyCorrect ? "sfx_correct.wav" : "sfx_wrong.wav")
        broadcastState()

        startCountdown(duration: 3.5) { [weak self] in
            self?.startCouciCoucaItem(at: index + 1)
        }
    }

    private func finishCouciCoucaRound() {
        stage = .couciCoucaSummary
        revealedBinarySide = nil
        meemawPose = "meemaw_celebrate"
        meemawSpeech = "Fin de la Raclette Quizz ! Place à la Rafale Finale Points ×2 !"
        broadcastState()
        startCountdown(duration: 3.0) { [weak self] in
            self?.advanceToNextPhaseStep()
        }
    }

    // MARK: - 🎨 Manche « DRAW SOMETHING » (Pictionary Live + 12 Tuiles de Lettres)

    private func enterDrawSomethingTurn() {
        stopTimers()
        registry.resetRoundLocks()
        roundKind = .drawSomething
        activeQuestion = nil
        activeDisOrDat = nil
        revealedCorrectIndex = nil
        revealedBinarySide = nil

        let options = DrawingBank.pickThreeWordOptions(excluding: usedDrawWords)
        let allPlayers = registry.players

        // If only 1 player is in the room (Solo mode without bots), use "Le Pinceau Magique de Meemaw" so the solo player can guess with the Draw Something tiles!
        if allPlayers.count <= 1 {
            let chosen = options.first(where: { ["SOLEIL", "MAISON", "POISSON", "FUSEE", "SAPIN", "LUNETTES", "COURONNE"].contains($0.word) })
                ?? DrawingBank.makeWordOption(from: DrawingBank.CatalogEntry(word: "FUSEE", categoryHint: "Espace", stars: 1, points: 1000))
            usedDrawWords.insert(chosen.word)
            activeDrawRound = DrawRoundState(
                drawerPlayerID: "meemaw_magic_brush",
                drawerPlayerName: "Le Pinceau Magique de Meemaw",
                drawerEmoji: "👵🎨",
                wordOptions: options,
                chosenWord: chosen,
                maskedWordPattern: DrawingBank.maskedPattern(for: chosen.word),
                wordLength: chosen.word.count,
                scrambledTiles: chosen.scrambledTiles,
                canvas: DrawingCanvasData(),
                foundPlayerIDs: [],
                isMagicMeemawBrush: true
            )
            openDrawLiveGuessingPhase(isBotOrMagicDrawer: true)
            return
        }

        let drawer = allPlayers[drawTurnCursor % allPlayers.count]
        drawTurnCursor += 1

        activeDrawRound = DrawRoundState(
            drawerPlayerID: drawer.id,
            drawerPlayerName: drawer.name,
            drawerEmoji: drawer.avatarEmoji,
            wordOptions: options,
            chosenWord: nil,
            maskedWordPattern: "",
            wordLength: 0,
            scrambledTiles: [],
            canvas: DrawingCanvasData(),
            foundPlayerIDs: [],
            isMagicMeemawBrush: false
        )
        stage = .drawWordChoice
        meemawPose = "meemaw_fun"
        meemawSpeech = "🎨 C'est au tour de \(drawer.name) de dessiner ! Choisis secrètement ton mot (⭐ à ⭐⭐⭐) sur ton téléphone !"
        broadcastState()

        audio.playMeemawStudioOrFallback(
            studioFilename: "mq_draw_word_pick.m4a",
            fallbackText: meemawSpeech
        )

        if drawer.id.hasPrefix("bot_") {
            botActionTask?.cancel()
            botActionTask = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(2200))
                guard let self, !Task.isCancelled, self.stage == .drawWordChoice else { return }
                let preferred = options.first(where: { ["SOLEIL", "MAISON", "POISSON", "FUSEE", "SAPIN", "LUNETTES", "COURONNE"].contains($0.word) }) ?? options.randomElement()!
                self.handleSelectDrawWord(playerID: drawer.id, word: preferred.word)
            }
        }

        startCountdown(duration: 12.0) { [weak self] in
            guard let self, self.stage == .drawWordChoice, let first = self.activeDrawRound?.wordOptions.first else { return }
            self.handleSelectDrawWord(playerID: drawer.id, word: first.word)
        }
    }

    private func handleSelectDrawWord(playerID: String, word: String) {
        guard stage == .drawWordChoice, var drawState = activeDrawRound else { return }
        guard playerID == drawState.drawerPlayerID || playerID == localPlayerID else { return }
        let chosen = drawState.wordOptions.first(where: { $0.word == word }) ?? drawState.wordOptions.first!
        usedDrawWords.insert(chosen.word)

        drawState.chosenWord = chosen
        drawState.maskedWordPattern = DrawingBank.maskedPattern(for: chosen.word)
        drawState.wordLength = chosen.word.count
        drawState.scrambledTiles = chosen.scrambledTiles
        drawState.canvas = DrawingCanvasData()
        drawState.foundPlayerIDs = []
        activeDrawRound = drawState

        let isBotDrawer = drawState.drawerPlayerID.hasPrefix("bot_") || drawState.isMagicMeemawBrush
        openDrawLiveGuessingPhase(isBotOrMagicDrawer: isBotDrawer)
    }

    private func openDrawLiveGuessingPhase(isBotOrMagicDrawer: Bool) {
        stopTimers()
        guard let drawState = activeDrawRound, let chosen = drawState.chosenWord else { return }
        stage = .drawLiveGuessing
        questionOpenedAt = Date()
        let duration: Double = 45.0
        totalTimerSec = duration
        timeRemainingSec = duration
        audio.setMusicMood(.fastAction)
        meemawPose = "meemaw_dictation_talk"

        if drawState.isMagicMeemawBrush {
            meemawSpeech = "🎨 Le Pinceau Magique de Meemaw dessine un mot mystère de \(chosen.word.count) lettres ! Touchez les tuiles dans l'ordre !"
            audio.playMeemawStudioOrFallback(
                studioFilename: "mq_draw_magic_brush.m4a",
                fallbackText: meemawSpeech
            )
        } else {
            meemawSpeech = "🎨 \(drawState.drawerPlayerName) dessine un mot mystère de \(chosen.word.count) lettres (\(chosen.points) pts) ! Touchez les lettres façon Draw Something !"
            audio.playMeemawStudioOrFallback(
                studioFilename: "mq_draw_live.m4a",
                fallbackText: meemawSpeech
            )
        }
        broadcastState()

        if isBotOrMagicDrawer {
            let sketch = DrawingBank.botSketch(for: chosen.word)
            drawBotStrokeTask?.cancel()
            drawBotStrokeTask = Task { @MainActor [weak self] in
                for strokeIdx in sketch.strokes.indices {
                    try? await Task.sleep(for: .milliseconds(1300))
                    guard let self, !Task.isCancelled, self.stage == .drawLiveGuessing else { return }
                    self.activeDrawRound?.canvas.strokes.append(sketch.strokes[strokeIdx])
                    self.broadcastState()
                }
            }
        }

        // Schedule guesser bots if any
        let guesserBots = registry.players.filter { $0.id.hasPrefix("bot_") && $0.id != drawState.drawerPlayerID }
        if !guesserBots.isEmpty {
            botActionTask?.cancel()
            botActionTask = Task { @MainActor [weak self] in
                for bot in guesserBots {
                    let delayMs = Int.random(in: 8500...22000)
                    try? await Task.sleep(for: .milliseconds(delayMs))
                    guard let self, !Task.isCancelled, self.stage == .drawLiveGuessing else { return }
                    if Int.random(in: 0..<100) < 75 {
                        self.handleSubmitDrawGuessWord(playerID: bot.id, guess: chosen.word)
                    }
                }
            }
        }

        startCountdown(duration: duration) { [weak self] in
            self?.revealDrawRoundResult()
        }
    }

    private func handleUpdateDrawingCanvas(playerID: String, canvas: DrawingCanvasData) {
        if stage == .drawLiveGuessing, var drawState = activeDrawRound, drawState.drawerPlayerID == playerID {
            drawState.canvas = canvas
            activeDrawRound = drawState
            broadcastState()
        }
    }

    private func handleRequestDrawHint(playerID: String) {
        guard stage == .drawLiveGuessing,
              let drawState = activeDrawRound,
              let chosen = drawState.chosenWord else { return }
        guard playerID != drawState.drawerPlayerID else { return }
        guard !drawState.foundPlayerIDs.contains(playerID) else { return }

        let maxHints = max(1, chosen.word.count - 1)
        guard let currentPlayer = registry.players.first(where: { $0.id == playerID }),
              currentPlayer.drawHintsUsedCount < maxHints else { return }

        let penalty = QuizScoringEngine.drawHintPenaltyPoints
        registry.updatePlayer(id: playerID) { p in
            p.drawHintsUsedCount += 1
            p.score -= penalty
            p.lastDeltaScore = -(p.drawHintsUsedCount * penalty)
        }
        broadcastState()
    }

    private func handleSubmitDrawGuessWord(playerID: String, guess: String) {
        guard stage == .drawLiveGuessing,
              var drawState = activeDrawRound,
              let chosen = drawState.chosenWord else { return }
        guard playerID != drawState.drawerPlayerID else { return }
        guard !drawState.foundPlayerIDs.contains(playerID) else { return }

        let normalizedGuess = DrawingBank.normalizeWord(guess)
        let normalizedTarget = DrawingBank.normalizeWord(chosen.word)

        guard normalizedGuess == normalizedTarget else {
            return
        }

        let elapsedMs = max(300, Int(Date().timeIntervalSince(questionOpenedAt) * 1000))
        let rankIdx = drawState.foundPlayerIDs.count
        let grossReward = QuizScoringEngine.scoreDrawGuesser(
            wordPoints: chosen.points,
            rankIndex: rankIdx,
            reactionTimeMs: elapsedMs,
            totalTimeMs: 45000,
            hintsUsed: 0
        )

        drawState.foundPlayerIDs.append(playerID)
        activeDrawRound = drawState

        registry.updatePlayer(id: playerID) { p in
            let netDelta = grossReward - (p.drawHintsUsedCount * QuizScoringEngine.drawHintPenaltyPoints)
            p.lockedDrawGuess = chosen.word
            p.reactionTimeMs = elapsedMs
            p.score += grossReward
            p.lastDeltaScore = netDelta
            p.streak += 1
            p.correctAnswersCount += 1
        }
        audio.playJingle("sfx_correct.wav")
        broadcastState()

        let expectedGuessers = registry.players.filter { $0.id != drawState.drawerPlayerID }
        if !expectedGuessers.isEmpty && expectedGuessers.allSatisfy({ drawState.foundPlayerIDs.contains($0.id) }) {
            stopTimers()
            revealDrawRoundResult()
        }
    }

    private func revealDrawRoundResult() {
        stopTimers()
        guard var drawState = activeDrawRound, let chosen = drawState.chosenWord else {
            advanceToNextPhaseStep()
            return
        }
        stage = .drawReveal
        drawState.maskedWordPattern = Array(chosen.word).map { String($0) }.joined(separator: " ")
        activeDrawRound = drawState

        let foundCount = drawState.foundPlayerIDs.count
        if !drawState.isMagicMeemawBrush {
            let artistBonus = QuizScoringEngine.scoreDrawArtist(wordPoints: chosen.points, foundCount: foundCount)
            registry.updatePlayer(id: drawState.drawerPlayerID) { p in
                p.score += artistBonus
                p.lastDeltaScore = artistBonus
            }
        }

        for p in registry.players where p.id != drawState.drawerPlayerID && !drawState.foundPlayerIDs.contains(p.id) {
            registry.updatePlayer(id: p.id) { player in
                player.lastDeltaScore = -(player.drawHintsUsedCount * QuizScoringEngine.drawHintPenaltyPoints)
                player.streak = 0
            }
        }

        if foundCount > 0 {
            audio.playJingle("sfx_correct.wav")
            meemawPose = "meemaw_celebrate"
            meemawSpeech = "🎨 BRAVO ! Le mot secret de \(drawState.drawerPlayerName) était « \(chosen.word) » ! (\(foundCount) joueur(s) ont trouvé !)"
            audio.playMeemawStudioOrFallback(studioFilename: "mq_draw_found.m4a", fallbackText: meemawSpeech)
        } else {
            audio.playJingle("sfx_wrong.wav")
            meemawPose = "meemaw_worried"
            meemawSpeech = "🎨 Personne n'a déchiffré ce gribouillis ! Le mot était « \(chosen.word) » !"
            audio.playMeemawStudioOrFallback(studioFilename: "mq_react_nobody_correct.m4a", fallbackText: meemawSpeech)
        }
        broadcastState()

        startCountdown(duration: 7.5) { [weak self] in
            self?.advanceToNextPhaseStep()
        }
    }

    // MARK: - 📞 Mode « ESQUISSÉ ! » (Téléphone Arabe Dessiné — façon Gartic Phone)

    private func setupEsquisseNotebooks() {
        var participants: [(id: String, name: String, emoji: String)] = registry.players.map {
            ($0.id, $0.name, $0.avatarEmoji)
        }
        // Ensure at least 3 notebooks so the chain rotates nicely even with 1 or 2 human players
        let virtualFallbacks: [(String, String, String)] = [
            ("bot_tonton", "Tonton Gérard", "🐬"),
            ("bot_tata", "Tata Josiane", "🦩"),
            ("bot_meemaw", "Mamie Meemaw", "👵")
        ]
        for vf in virtualFallbacks where participants.count < 3 {
            if !participants.contains(where: { $0.id == vf.0 }) {
                participants.append(vf)
            }
        }

        let notebooks = participants.enumerated().map { idx, part in
            EsquisseNotebook(
                id: "nb_\(idx)_\(part.id)",
                ownerPlayerID: part.id,
                ownerName: part.name,
                ownerEmoji: part.emoji,
                entries: [],
                voteVoterIDs: []
            )
        }

        activeEsquisseRound = EsquisseRoundState(
            stepIndex: 0,
            totalSteps: 4,
            notebooks: notebooks,
            activeAssignmentByPlayerID: [:],
            showcaseNotebookIndex: 0,
            showcaseEntryCount: 1
        )
    }

    private func enterEsquisseStep(_ stepIndex: Int) {
        stopTimers()
        registry.resetRoundLocks()
        roundKind = .esquisseTeleArabe
        guard var esq = activeEsquisseRound, !esq.notebooks.isEmpty else {
            advanceToNextPhaseStep()
            return
        }

        esq.stepIndex = stepIndex
        let nbCount = esq.notebooks.count
        var assignments: [String: String] = [:]
        for (idx, nb) in esq.notebooks.enumerated() {
            // Which notebook does owner `idx` receive at `stepIndex`?
            let assignedNb = esq.notebooks[(idx + stepIndex) % nbCount]
            assignments[nb.ownerPlayerID] = assignedNb.id
        }
        esq.activeAssignmentByPlayerID = assignments
        activeEsquisseRound = esq

        switch stepIndex {
        case 0:
            // Step 0: Write starting funny prompt!
            stage = .esquissePromptEntry
            meemawPose = "meemaw_fun"
            meemawSpeech = "📞 ESQUISSÉ (Étape 1/4) : Écrivez sur votre téléphone une scène délirante à faire dessiner à votre voisin !"
            audio.setMusicMood(.chillLobby)
            audio.playMeemawStudioOrFallback(studioFilename: "mq_esquisse_prompt.m4a", fallbackText: meemawSpeech)
            broadcastState()
            startCountdown(duration: 38.0) { [weak self] in
                self?.finalizeCurrentEsquisseStepAndAdvance()
            }

        case 1, 3:
            // Step 1 or 3: Draw the previous text prompt!
            stage = .esquisseDrawing
            meemawPose = "meemaw_dictation_talk"
            meemawSpeech = "🎨 ESQUISSÉ (Étape \(stepIndex + 1)/4) : Les carnets ont tourné ! Utilisez les formes rapides (Rond, Triangle, Bonhomme) pour dessiner la phrase !"
            audio.setMusicMood(.fastAction)
            audio.playMeemawStudioOrFallback(studioFilename: "mq_esquisse_draw.m4a", fallbackText: meemawSpeech)
            broadcastState()
            startCountdown(duration: 55.0) { [weak self] in
                self?.finalizeCurrentEsquisseStepAndAdvance()
            }

        default:
            // Step 2: Guess in 100% free text from the previous drawing!
            stage = .esquisseGuessing
            meemawPose = "meemaw_duel_challenge"
            meemawSpeech = "🕵️ ESQUISSÉ (Étape 3/4) : Regardez uniquement le dessin du voisin et tapez librement au clavier ce que vous croyez voir !"
            audio.setMusicMood(.chillLobby)
            audio.playMeemawStudioOrFallback(studioFilename: "mq_esquisse_guess.m4a", fallbackText: meemawSpeech)
            broadcastState()
            startCountdown(duration: 38.0) { [weak self] in
                self?.finalizeCurrentEsquisseStepAndAdvance()
            }
        }
    }

    private func handleSubmitEsquisseText(playerID: String, text: String) {
        guard (stage == .esquissePromptEntry || stage == .esquisseGuessing),
              var esq = activeEsquisseRound,
              let nbID = esq.activeAssignmentByPlayerID[playerID],
              let nbIdx = esq.notebooks.firstIndex(where: { $0.id == nbID }) else { return }

        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalPrompt = cleaned.isEmpty ? DrawingBank.randomEsquissePrompt(excluding: usedEsquissePrompts) : String(cleaned.prefix(90))
        usedEsquissePrompts.insert(finalPrompt)

        let player = registry.players.first(where: { $0.id == playerID })
        let entry = EsquisseEntry(
            stepIndex: esq.stepIndex,
            authorPlayerID: playerID,
            authorName: player?.name ?? "Joueur",
            authorEmoji: player?.avatarEmoji ?? "🎨",
            promptText: finalPrompt,
            drawing: nil
        )
        esq.notebooks[nbIdx].entries.removeAll { $0.stepIndex == esq.stepIndex }
        esq.notebooks[nbIdx].entries.append(entry)
        activeEsquisseRound = esq

        registry.updatePlayer(id: playerID) { $0.hasSubmittedEsquisseStep = true }
        broadcastState()

        let humanPlayers = registry.players.filter { !$0.id.hasPrefix("bot_") }
        if !humanPlayers.isEmpty && humanPlayers.allSatisfy({ $0.hasSubmittedEsquisseStep }) {
            stopTimers()
            finalizeCurrentEsquisseStepAndAdvance()
        }
    }

    private func handleSubmitEsquisseDrawing(playerID: String, canvas: DrawingCanvasData) {
        guard stage == .esquisseDrawing,
              var esq = activeEsquisseRound,
              let nbID = esq.activeAssignmentByPlayerID[playerID],
              let nbIdx = esq.notebooks.firstIndex(where: { $0.id == nbID }) else { return }

        let player = registry.players.first(where: { $0.id == playerID })
        let entry = EsquisseEntry(
            stepIndex: esq.stepIndex,
            authorPlayerID: playerID,
            authorName: player?.name ?? "Joueur",
            authorEmoji: player?.avatarEmoji ?? "🎨",
            promptText: nil,
            drawing: canvas
        )
        esq.notebooks[nbIdx].entries.removeAll { $0.stepIndex == esq.stepIndex }
        esq.notebooks[nbIdx].entries.append(entry)
        activeEsquisseRound = esq

        registry.updatePlayer(id: playerID) { $0.hasSubmittedEsquisseStep = true }
        broadcastState()

        let humanPlayers = registry.players.filter { !$0.id.hasPrefix("bot_") }
        if !humanPlayers.isEmpty && humanPlayers.allSatisfy({ $0.hasSubmittedEsquisseStep }) {
            stopTimers()
            finalizeCurrentEsquisseStepAndAdvance()
        }
    }

    private func finalizeCurrentEsquisseStepAndAdvance() {
        stopTimers()
        guard var esq = activeEsquisseRound else {
            advanceToNextPhaseStep()
            return
        }

        let step = esq.stepIndex
        for nbIdx in esq.notebooks.indices {
            if !esq.notebooks[nbIdx].entries.contains(where: { $0.stepIndex == step }) {
                // Find who was supposed to fill this notebook at this step
                let assigneeID = esq.activeAssignmentByPlayerID.first(where: { $0.value == esq.notebooks[nbIdx].id })?.key ?? esq.notebooks[nbIdx].ownerPlayerID
                let assigneeName = registry.players.first(where: { $0.id == assigneeID })?.name
                    ?? esq.notebooks.first(where: { $0.ownerPlayerID == assigneeID })?.ownerName
                    ?? "Tonton Gérard"
                let assigneeEmoji = registry.players.first(where: { $0.id == assigneeID })?.avatarEmoji
                    ?? esq.notebooks.first(where: { $0.ownerPlayerID == assigneeID })?.ownerEmoji
                    ?? "🐬"

                if step == 0 {
                    let prompt = DrawingBank.randomEsquissePrompt(excluding: usedEsquissePrompts)
                    usedEsquissePrompts.insert(prompt)
                    esq.notebooks[nbIdx].entries.append(EsquisseEntry(
                        stepIndex: step,
                        authorPlayerID: assigneeID,
                        authorName: assigneeName,
                        authorEmoji: assigneeEmoji,
                        promptText: prompt
                    ))
                } else if step == 1 || step == 3 {
                    let prevPrompt = esq.notebooks[nbIdx].entries.last?.promptText ?? "SOLEIL"
                    let sketchKey: String
                    let lower = prevPrompt.lowercased()
                    if lower.contains("requin") || lower.contains("poisson") { sketchKey = "REQUIN" }
                    else if lower.contains("fusée") || lower.contains("espace") { sketchKey = "FUSEE" }
                    else if lower.contains("maison") { sketchKey = "MAISON" }
                    else if lower.contains("sapin") || lower.contains("palmier") { sketchKey = "SAPIN" }
                    else if lower.contains("couronne") || lower.contains("napoléon") { sketchKey = "COURONNE" }
                    else if lower.contains("lunettes") { sketchKey = "LUNETTES" }
                    else { sketchKey = "SOLEIL" }

                    esq.notebooks[nbIdx].entries.append(EsquisseEntry(
                        stepIndex: step,
                        authorPlayerID: assigneeID,
                        authorName: assigneeName,
                        authorEmoji: assigneeEmoji,
                        drawing: DrawingBank.botSketch(for: sketchKey)
                    ))
                } else {
                    let firstPrompt = esq.notebooks[nbIdx].entries.first?.promptText ?? ""
                    let misinterp = DrawingBank.botFunnyMisinterpretation(from: firstPrompt)
                    esq.notebooks[nbIdx].entries.append(EsquisseEntry(
                        stepIndex: step,
                        authorPlayerID: assigneeID,
                        authorName: assigneeName,
                        authorEmoji: assigneeEmoji,
                        promptText: misinterp
                    ))
                }
            }
        }

        activeEsquisseRound = esq
        advanceToNextPhaseStep()
    }

    private func enterEsquisseShowcase() {
        stopTimers()
        guard var esq = activeEsquisseRound, !esq.notebooks.isEmpty else {
            enterFinalPodium()
            return
        }
        stage = .esquisseShowcase
        roundKind = .esquisseTeleArabe
        esq.showcaseNotebookIndex = 0
        esq.showcaseEntryCount = esq.notebooks[0].entries.count
        activeEsquisseRound = esq

        audio.setMusicMood(.chillLobby)
        audio.playJingle("jingle_victory.wav")
        let owner = esq.notebooks[0].ownerName
        meemawPose = "meemaw_celebrate"
        meemawSpeech = "📺 GRAND DÉFILÉ ESQUISSÉ ! Carnet 1/\(esq.notebooks.count) (lancé par \(owner)) : Votez « 😂 Coup de Cœur » sur vos téléphones !"
        audio.playMeemawStudioOrFallback(studioFilename: "mq_esquisse_showcase.m4a", fallbackText: meemawSpeech)
        broadcastState()

        startCountdown(duration: 16.0) { [weak self] in
            self?.advanceEsquisseShowcaseStep()
        }
    }

    private func advanceEsquisseShowcaseStep() {
        stopTimers()
        guard var esq = activeEsquisseRound else {
            enterFinalPodium()
            return
        }
        let nextIdx = esq.showcaseNotebookIndex + 1
        if esq.notebooks.indices.contains(nextIdx) {
            esq.showcaseNotebookIndex = nextIdx
            esq.showcaseEntryCount = esq.notebooks[nextIdx].entries.count
            activeEsquisseRound = esq
            let owner = esq.notebooks[nextIdx].ownerName
            audio.playJingle("jingle_couci.wav")
            meemawPose = "meemaw_giggle"
            meemawSpeech = "📺 Carnet \(nextIdx + 1)/\(esq.notebooks.count) (lancé par \(owner)) ! Regardez comment la phrase a dérapé !"
            broadcastState()
            startCountdown(duration: 16.0) { [weak self] in
                self?.advanceEsquisseShowcaseStep()
            }
        } else {
            advanceToNextPhaseStep()
        }
    }

    private func handleVoteEsquisseAlbum(playerID: String, notebookID: String) {
        guard stage == .esquisseShowcase,
              var esq = activeEsquisseRound,
              let nbIdx = esq.notebooks.firstIndex(where: { $0.id == notebookID }) else { return }
        guard !esq.notebooks[nbIdx].voteVoterIDs.contains(playerID) else { return }

        esq.notebooks[nbIdx].voteVoterIDs.append(playerID)
        activeEsquisseRound = esq

        // Reward all contributors of this notebook with +500 pts (and +1000 pts for the notebook owner)
        let ownerID = esq.notebooks[nbIdx].ownerPlayerID
        registry.updatePlayer(id: ownerID) { p in
            p.score += 1000
            p.lastDeltaScore = 1000
        }
        for entry in esq.notebooks[nbIdx].entries where entry.authorPlayerID != ownerID {
            registry.updatePlayer(id: entry.authorPlayerID) { p in
                p.score += 500
                p.lastDeltaScore = 500
            }
        }
        audio.playJingle("sfx_correct.wav")
        broadcastState()
    }

    // MARK: - Bisou Baveux de Meemaw & 🔩 « Clouer le Bec » (You Don't Know Jack Screw!)

    private func handleBisouTrap(fromPlayerID: String, toPlayerID: String) {
        guard fromPlayerID != toPlayerID else { return }
        guard let sender = registry.players.first(where: { $0.id == fromPlayerID }),
              !sender.hasUsedBisouTrap else { return }

        registry.updatePlayer(id: fromPlayerID) { $0.hasUsedBisouTrap = true }
        registry.updatePlayer(id: toPlayerID) { target in
            target.activeBisouWipesRemaining = 3
            target.bisouSenderName = sender.name
        }
        meemawSpeech = "💋 COUP BAS ! \(sender.name) envoie un gros Bisou Baveux de Meemaw sur l'écran de son adversaire !"
        audio.playMeemawStudioOrFallback(
            studioFilename: "mq_bisou_attack.m4a",
            fallbackText: meemawSpeech
        )
        broadcastState()
    }

    private func handleScrewOpponent(fromPlayerID: String, toPlayerID: String) {
        guard stage == .cashAnswering, let q = activeQuestion else { return }
        guard fromPlayerID != toPlayerID else { return }
        guard let sender = registry.players.first(where: { $0.id == fromPlayerID }),
              !sender.hasUsedScrew,
              let target = registry.players.first(where: { $0.id == toPlayerID }) else { return }

        stopTimers()
        registry.updatePlayer(id: fromPlayerID) { $0.hasUsedScrew = true }
        // Clear any locked choices from this question and put target alone on the spot!
        registry.resetRoundLocks()

        screwAttackerID = sender.id
        screwAttackerName = sender.name
        soloBuzzerPlayerID = target.id
        soloBuzzerPlayerName = target.name
        stage = .soloPlayerAnswering
        totalTimerSec = 12.0
        timeRemainingSec = 12.0
        questionOpenedAt = Date()

        audio.playJingle("jingle_solo_siren.wav")
        let callout = "🔩 COUP DE JARNAC ! \(sender.name) cloue le bec de \(target.name) ! \(target.name), tu es tout seul : 12 secondes pour répondre ou tu perds les points au profit de \(sender.name) !"
        meemawPose = "meemaw_duel_challenge"
        meemawSpeech = callout
        broadcastState()

        audio.playMeemawStudioOrFallback(
            studioFilename: "mq_screw_attack.m4a",
            fallbackText: callout
        )

        if target.id.hasPrefix("bot_") {
            botActionTask?.cancel()
            botActionTask = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(4500))
                guard let self, !Task.isCancelled, self.stage == .soloPlayerAnswering else { return }
                let botPick = (Int.random(in: 0..<100) < 50) ? q.correctIndex : Int.random(in: 0..<4)
                self.handlePlayerChoice(playerID: target.id, choiceIndex: botPick)
            }
        }

        startCountdown(duration: 12.0) { [weak self] in
            guard let self, self.stage == .soloPlayerAnswering else { return }
            self.revealSoloQuestionResult(q, buzzerPlayerID: target.id, chosenIndex: nil)
        }
    }

    // MARK: - Final Podium

    private func enterFinalPodium() {
        stopTimers()
        audio.setMusicMood(.chillLobby)
        stage = .finalPodium
        podiumAwards = QuizScoringEngine.buildPodiumAwards(from: registry.players)
        meemawPose = "meemaw_holding_trophy"
        if let champion = podiumAwards.first {
            meemawSpeech = "🏆 VICTOIRE DE \(champion.playerName.uppercased()) avec \(champion.score) PTS ! (\(champion.funnyTitle))"
        } else {
            meemawSpeech = "Fin du Grand Quizz de Meemaw !"
        }
        audio.playJingle("jingle_victory.wav")
        broadcastState()

        audio.playMeemawStudioOrFallback(
            studioFilename: "mq_podium_outro.m4a",
            fallbackText: meemawSpeech
        )
    }

    // MARK: - Bot Helpers & Timers

    private func scheduleBotsForCashQuestion(_ q: QuizMCQQuestion) {
        let bots = registry.players.filter { $0.id.hasPrefix("bot_") }
        guard !bots.isEmpty else { return }
        botActionTask?.cancel()
        botActionTask = Task { @MainActor [weak self] in
            for bot in bots {
                let delayMs = Int.random(in: 5500...14000)
                try? await Task.sleep(for: .milliseconds(delayMs))
                guard let self, !Task.isCancelled, self.stage == .cashAnswering else { return }
                let pick = (Int.random(in: 0..<100) < 68) ? q.correctIndex : Int.random(in: 0..<4)
                self.handlePlayerChoice(playerID: bot.id, choiceIndex: pick)
            }
        }
    }

    private func scheduleBotsForSoloBuzz(_ q: QuizMCQQuestion) {
        let bots = registry.players.filter { $0.id.hasPrefix("bot_") }
        guard let randomBot = bots.randomElement() else { return }
        botActionTask?.cancel()
        botActionTask = Task { @MainActor [weak self] in
            let delayMs = Int.random(in: 9500...16500)
            try? await Task.sleep(for: .milliseconds(delayMs))
            guard let self, !Task.isCancelled, self.stage == .soloBuzzOpen else { return }
            let botPick = (Int.random(in: 0..<100) < 65) ? q.correctIndex : Int.random(in: 0..<4)
            self.handlePlayerChoice(playerID: randomBot.id, choiceIndex: botPick)
        }
    }

    private func scheduleBotsForCouciItem(_ item: QuizDisOrDatItem, round: QuizDisOrDatRound) {
        let bots = registry.players.filter { $0.id.hasPrefix("bot_") }
        guard !bots.isEmpty else { return }
        let possibleSides = round.optionBoth != nil ? ["left", "right", "both"] : ["left", "right"]
        botActionTask?.cancel()
        botActionTask = Task { @MainActor [weak self] in
            for bot in bots {
                let delayMs = Int.random(in: 3000...6500)
                try? await Task.sleep(for: .milliseconds(delayMs))
                guard let self, !Task.isCancelled, self.stage == .couciCoucaItem else { return }
                let pick = (Int.random(in: 0..<100) < 72) ? item.correctSide : (possibleSides.randomElement() ?? "left")
                self.handlePlayerBinarySide(playerID: bot.id, side: pick)
            }
        }
    }

    private func startCountdown(duration: Double, onExpired: @escaping @MainActor () -> Void) {
        countdownTimer?.invalidate()
        totalTimerSec = duration
        timeRemainingSec = duration
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.timeRemainingSec = max(0, self.timeRemainingSec - 0.5)
                self.broadcastState()
                if self.timeRemainingSec <= 0.001 {
                    self.countdownTimer?.invalidate()
                    self.countdownTimer = nil
                    onExpired()
                }
            }
        }
    }

    private func scheduleDelayed(seconds: Double, action: @escaping @MainActor () -> Void) {
        stageAdvanceTask?.cancel()
        stageAdvanceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(Int(seconds * 1000)))
            guard !Task.isCancelled else { return }
            action()
        }
    }

    private func stopTimers() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        stageAdvanceTask?.cancel()
        stageAdvanceTask = nil
        botActionTask?.cancel()
        botActionTask = nil
        drawBotStrokeTask?.cancel()
        drawBotStrokeTask = nil
    }

    private func buildCurrentSnapshot() -> HostToClientStateSnapshot {
        HostToClientStateSnapshot(
            roomCode: roomCode,
            joinURL: lanServer.joinURLString,
            selectedGameMode: selectedGameMode,
            selectedPack: selectedPack,
            stage: stage,
            roundKind: roundKind,
            questionNumber: questionNumber,
            totalQuestions: totalQuestions,
            meemawSpeech: meemawSpeech,
            meemawPose: meemawPose,
            timeRemainingSec: timeRemainingSec,
            totalTimerSec: totalTimerSec,
            players: registry.players,
            availableColors: registry.availableColors(excludingPlayerID: nil),
            activeQuestion: activeQuestion,
            revealedCorrectIndex: revealedCorrectIndex,
            soloBuzzerPlayerID: soloBuzzerPlayerID,
            soloBuzzerPlayerName: soloBuzzerPlayerName,
            screwAttackerName: screwAttackerName,
            activeDisOrDat: activeDisOrDat,
            activeDisOrDatItemIndex: activeDisOrDatItemIndex,
            revealedBinarySide: revealedBinarySide,
            activeDrawRound: activeDrawRound,
            activeEsquisseRound: activeEsquisseRound,
            podiumAwards: podiumAwards
        )
    }

    private func broadcastState() {
        let snapshot = buildCurrentSnapshot()
        cachedHostSnapshot = snapshot
        lanServer.broadcast(snapshot)
    }

    // MARK: - QR Code Generator for TV Lobby (Cached to avoid CIContext re-creation per frame)

    private static let qrCIContext = CIContext()
    private static var cachedQRImages: [String: UIImage] = [:]

    static func makeQRCodeImage(from string: String) -> UIImage? {
        guard !string.isEmpty else { return nil }
        if let cached = cachedQRImages[string] {
            return cached
        }
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let outputImage = filter.outputImage else { return nil }
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgImage = qrCIContext.createCGImage(scaled, from: scaled.extent) else { return nil }
        let image = UIImage(cgImage: cgImage)
        cachedQRImages[string] = image
        return image
    }
}
