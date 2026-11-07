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
    var localAgeBracket: PlayerAgeBracket = {
        if let raw = UserDefaults.standard.string(forKey: "meemawquizz.localAgeBracket"),
           let parsed = PlayerAgeBracket(rawValue: raw) {
            return parsed
        }
        return .age40to54
    }() {
        didSet {
            UserDefaults.standard.set(localAgeBracket.rawValue, forKey: "meemawquizz.localAgeBracket")
        }
    }

    var activeTableDecades: [QuizDecade] {
        let humans = effectiveSnapshot.players.filter { !$0.id.hasPrefix("bot_") }
        let source = humans.isEmpty ? effectiveSnapshot.players : humans
        var set = Set<QuizDecade>()
        for p in source {
            set.formUnion(p.effectiveAgeBracket.preferredDecades)
        }
        if set.isEmpty {
            set.formUnion(localAgeBracket.preferredDecades)
        }
        return QuizDecade.allCases.filter { set.contains($0) }
    }

    // MARK: - Synchronized Show State
    var roomCode: String = AppLanguage.isEnglish ? "MEEMAW" : "MAMIE"
    var selectedGameMode: ShowGameMode = .fullQuizShow
    var selectedPack: QuizThemePack = .grandMix
    var stage: ShowStageState = .lobby
    var roundKind: QuizRoundKind = .cashSpeed
    var questionNumber: Int = 0
    var totalQuestions: Int = 8
    var meemawSpeech: String = AppLanguage.isEnglish
        ? "Welcome to Meemaw's AirPlay TV Quiz Show! Connect your phones over Wi-Fi or Hotspot!"
        : "Bienvenue dans le Grand Quizz AirPlay de Meemaw ! Connectez vos téléphones sur le Wi-Fi !"
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

    var activeSponsor: MeemawSponsor? = QuestionBank.allSponsors.first
    var sponsorWinnerName: String?
    var activeQuestion: QuizMCQQuestion?
    var revealedCorrectIndex: Int?
    var soloBuzzerPlayerID: String?
    var soloBuzzerPlayerName: String?
    var screwAttackerID: String?
    var screwAttackerName: String?
    var activeJustePif: QuizJustePifQuestion?
    var activeDisOrDat: QuizDisOrDatRound?
    var activeDisOrDatItemIndex: Int?
    var revealedBinarySide: String?
    var activeDrawRound: DrawRoundState?
    var activeEsquisseRound: EsquisseRoundState?
    var activeJackAttack: QuizJackAttackRound?
    var activeJackAttackWaveIndex: Int?
    var activeJackAttackOptionIndex: Int?
    var jackAttackWinnerName: String?
    var podiumAwards: [PodiumAward] = []

    private var usedDrawWords: Set<String> = []
    private var usedEsquissePrompts: Set<String> = []
    private var drawTurnCursor: Int = 0
    private var drawBotStrokeTask: Task<Void, Never>?
    private var jackAttackCycleTimer: Timer?
    private var jackAttackCyclesRemaining: Int = 0

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
        case justePifQuestion(QuizJustePifQuestion)
        case drawSomethingTurn
        case soloQuestion(QuizMCQQuestion)
        case couciCouca(QuizDisOrDatRound, QuizRoundKind)
        case jackAttackRound(QuizJackAttackRound)
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
                if let age = me.ageBracket {
                    self.localAgeBracket = age
                }
            }
        }

        CarPlayNowPlayingManager.shared.onNextStepCommand = { [weak self] in
            guard let self, self.role == .hostAndPlayer1 else { return }
            if self.stage == .lobby || self.stage == .finalPodium {
                self.startNewShow()
            } else {
                self.skipToNextStep()
            }
        }

        CarPlayNowPlayingManager.shared.onPlayOrReplayCommand = { [weak self] in
            guard let self, self.role == .hostAndPlayer1 else { return }
            if self.stage == .lobby || self.stage == .finalPodium {
                self.startNewShow()
            } else if let q = self.activeQuestion {
                let cueID = q.audioCueID ?? "q_\(q.id)"
                self.audio.playMeemawStudioOrFallback(
                    studioFilename: "\(cueID).m4a",
                    fallbackText: "\(q.funnyTitle). \(q.prompt)"
                )
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
            ageBracket: localAgeBracket,
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
        let botCatalog: [(String, String, PlayerColor, String, PlayerAgeBracket)] = AppLanguage.isEnglish
            ? [
                ("bot_tonton", "Uncle Bob", .electricBlue, "🐬", .age55Plus),
                ("bot_tata", "Aunt Brenda", .candyPink, "🦩", .age40to54),
                ("bot_kevin", "Cousin Kyle", .mintGreen, "🐸", .under25)
            ]
            : [
                ("bot_tonton", "Tonton Gérard", .electricBlue, "🐬", .age55Plus),
                ("bot_tata", "Tata Josiane", .candyPink, "🦩", .age40to54),
                ("bot_kevin", "Kévin du 59", .mintGreen, "🐸", .under25)
            ]
        for (id, name, color, emoji, age) in botCatalog {
            if !registry.players.contains(where: { $0.id == id }) {
                registry.upsertPlayer(
                    id: id,
                    name: name,
                    requestedColor: color,
                    avatarEmoji: emoji,
                    ageBracket: age,
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
            ageBracket: localAgeBracket,
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

    func submitNumericEstimate(_ estimate: Int) {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .submitNumericEstimate,
            numericEstimate: estimate
        ))
    }

    func submitJackAttackBuzz() {
        audio.triggerControllerHaptic(style: .heavy)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .buzzJackAttack
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

    func swapSecretPrompt() {
        audio.triggerControllerHaptic(style: .medium)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .swapSecretPrompt
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
                ageBracket: msg.ageBracket,
                isHost: isHostPlayer,
                platform: msg.platform ?? .iosBonjour
            )
            if isHostPlayer {
                localSelectedColor = updated.color
                localAvatarEmoji = updated.avatarEmoji
                if let age = updated.ageBracket {
                    localAgeBracket = age
                }
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

        case .submitNumericEstimate:
            guard let estimate = msg.numericEstimate else { return }
            handleSubmitNumericEstimate(playerID: msg.playerID, estimate: estimate)

        case .buzzJackAttack:
            handleBuzzJackAttack(playerID: msg.playerID)

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

        case .swapSecretPrompt:
            handleSwapSecretPrompt(playerID: msg.playerID)

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
        meemawSpeech = AppLanguage.isEnglish
            ? "Mode selected: \(mode.title) — \(mode.subtitle)"
            : "Mode choisi : \(mode.title) — \(mode.subtitle)"
        audio.triggerControllerHaptic(style: .medium)
        broadcastState()
    }

    func selectThemePack(_ pack: QuizThemePack) {
        guard role == .hostAndPlayer1 else { return }
        selectedPack = pack
        meemawSpeech = AppLanguage.isEnglish
            ? "Theme selected: \(pack.title)! \(pack.subtitle)"
            : "Thème sélectionné : \(pack.title) ! \(pack.subtitle)"
        broadcastState()
    }

    func startNewShow() {
        guard role == .hostAndPlayer1 else { return }
        stopTimers()
        registry.resetForNewShow()
        activeDrawRound = nil
        activeEsquisseRound = nil
        activeJustePif = nil
        activeJackAttack = nil
        activeJackAttackWaveIndex = nil
        activeJackAttackOptionIndex = nil
        jackAttackWinnerName = nil
        sponsorWinnerName = nil
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
                .esquisseStep(1),
                .esquisseStep(2),
                .esquisseStep(3),
                .esquisseShowcase,
                .podium
            ]
            totalQuestions = 3
            questionNumber = 0
            currentStepIndex = -1
            audio.playJingle("jingle_intro.wav")
            advanceToNextPhaseStep()
            return

        case .fullQuizShow, .carPlayRoadTrip:
            break
        }

        let packQuestions = QuestionBank.questions(for: selectedPack)
        let unseenInPack = packQuestions.filter { !usedQuestionIDs.contains($0.id) }
        if unseenInPack.count < 15 {
            usedQuestionIDs.subtract(packQuestions.map(\.id))
        }

        // Assure aussi que les questions Jukebox (JUK_) tournent sur toute la banque sans jamais se bloquer
        let allJukeboxIDs = QuestionBank.allMusiqueAndJukeboxQuestions
            .filter { $0.id.hasPrefix("JUK_") }
            .map(\.id)
        let unseenJukeboxCount = allJukeboxIDs.filter { !usedQuestionIDs.contains($0) }.count
        if unseenJukeboxCount < 4 {
            usedQuestionIDs.subtract(allJukeboxIDs)
        }

        let packCouci = QuestionBank.disOrDatRounds(for: selectedPack)
        if packCouci.filter({ !usedDisOrDatIDs.contains($0.id) }).isEmpty {
            usedDisOrDatIDs.subtract(packCouci.map(\.id))
        }

        activeDeck = QuestionBank.buildShowDeck(
            for: selectedPack,
            preferredDecades: Set(activeTableDecades),
            excludingQuestionIDs: usedQuestionIDs,
            excludingDisOrDatIDs: usedDisOrDatIDs
        )
        activeSponsor = activeDeck.sponsor
        usedQuestionIDs.formUnion(activeDeck.allExtendedMCQIDs)
        usedQuestionIDs.formUnion(activeDeck.justePifQuestions.map(\.id))
        usedDisOrDatIDs.insert(activeDeck.couciCoucaRound.id)
        usedDisOrDatIDs.insert(activeDeck.jackAttackRound.id)

        if selectedGameMode == .carPlayRoadTrip {
            phaseQueue = [
                // Manche 1 : 3 questions Cash Rapide (+ Sponsor caché !)
                .roundIntro(.cashSpeed),
                .cashQuestion(activeDeck.cashQuestions[0], isDoubleFinale: false),
                .cashQuestion(activeDeck.cashQuestions[1], isDoubleFinale: false),
                .cashQuestion(activeDeck.cashQuestions[2], isDoubleFinale: false),
                // Manche 2 : 3 questions Tu Te Mets Combien ?
                .roundIntro(.tuTeMetsCombien),
                .ttmcQuestion(activeDeck.ttmcQuestions[0]),
                .ttmcQuestion(activeDeck.ttmcQuestions[1]),
                .ttmcQuestion(activeDeck.ttmcQuestions[2]),
                // Manche 3 : 3 questions Jukebox Express
                .roundIntro(.jukeboxExpress),
                .jukeboxQuestion(activeDeck.jukeboxQuestions[0]),
                .jukeboxQuestion(activeDeck.jukeboxQuestions[1]),
                .jukeboxQuestion(activeDeck.jukeboxQuestions[2]),
                // Manche 4 : 3 questions Le Juste Pif
                .roundIntro(.leJustePif),
                .justePifQuestion(activeDeck.justePifQuestions[0]),
                .justePifQuestion(activeDeck.justePifQuestions[1]),
                .justePifQuestion(activeDeck.justePifQuestions[2]),
                // Manche 5 : 3 questions LE SOLO
                .roundIntro(.leSolo),
                .soloQuestion(activeDeck.soloQuestions[0]),
                .soloQuestion(activeDeck.soloQuestions[1]),
                .soloQuestion(activeDeck.soloQuestions[2]),
                // Manche 6 : La Raclette Quizz
                .roundIntro(.couciCouca),
                .couciCouca(activeDeck.couciCoucaRound, .couciCouca),
                // Grande Finale Voiture : 3 questions La Rafale Finale (Points ×2)
                .roundIntro(.finaleDouble),
                .cashQuestion(activeDeck.finaleDoubleQuestions[0], isDoubleFinale: true),
                .cashQuestion(activeDeck.finaleDoubleQuestions[1], isDoubleFinale: true),
                .cashQuestion(activeDeck.finaleDoubleQuestions[2], isDoubleFinale: true),
                .podium
            ]
            totalQuestions = 19
        } else {
            phaseQueue = [
                // Manche 1 : 3 questions Cash Rapide (+ Sponsor caché !)
                .roundIntro(.cashSpeed),
                .cashQuestion(activeDeck.cashQuestions[0], isDoubleFinale: false),
                .cashQuestion(activeDeck.cashQuestions[1], isDoubleFinale: false),
                .cashQuestion(activeDeck.cashQuestions[2], isDoubleFinale: false),
                // Manche 2 : 3 questions Tu Te Mets Combien ?
                .roundIntro(.tuTeMetsCombien),
                .ttmcQuestion(activeDeck.ttmcQuestions[0]),
                .ttmcQuestion(activeDeck.ttmcQuestions[1]),
                .ttmcQuestion(activeDeck.ttmcQuestions[2]),
                // Manche 3 : 3 questions Jukebox Express
                .roundIntro(.jukeboxExpress),
                .jukeboxQuestion(activeDeck.jukeboxQuestions[0]),
                .jukeboxQuestion(activeDeck.jukeboxQuestions[1]),
                .jukeboxQuestion(activeDeck.jukeboxQuestions[2]),
                // Manche 4 : 3 questions Le Juste Pif (Estimation numérique au plus proche)
                .roundIntro(.leJustePif),
                .justePifQuestion(activeDeck.justePifQuestions[0]),
                .justePifQuestion(activeDeck.justePifQuestions[1]),
                .justePifQuestion(activeDeck.justePifQuestions[2]),
                // Manche 5 : 2 tours de Draw Something
                .roundIntro(.drawSomething),
                .drawSomethingTurn,
                .drawSomethingTurn,
                // Manche 6 : 3 questions LE SOLO
                .roundIntro(.leSolo),
                .soloQuestion(activeDeck.soloQuestions[0]),
                .soloQuestion(activeDeck.soloQuestions[1]),
                .soloQuestion(activeDeck.soloQuestions[2]),
                // Manche 7 : La Raclette Quizz (6 questions rapides Gauche / Droite / Les Deux)
                .roundIntro(.couciCouca),
                .couciCouca(activeDeck.couciCoucaRound, .couciCouca),
                // Grande Finale : Le Jack Attack de Meemaw (5 vagues d'associations au buzzer)
                .roundIntro(.jackAttack),
                .jackAttackRound(activeDeck.jackAttackRound),
                .podium
            ]
            totalQuestions = 19
        }
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
        activeJustePif = nil
        activeDisOrDat = nil
        activeDrawRound = nil
        activeEsquisseRound = nil
        activeJackAttack = nil
        activeJackAttackWaveIndex = nil
        activeJackAttackOptionIndex = nil
        jackAttackWinnerName = nil
        sponsorWinnerName = nil
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
        if stage == .justePifAnswering, let pif = activeJustePif {
            revealJustePifResult(pif)
            return
        }
        if stage == .jackAttackActive, let wIdx = activeJackAttackWaveIndex {
            revealJackAttackWave(at: wIdx, winnerName: nil)
            return
        }
        if stage == .jackAttackWaveReveal, let wIdx = activeJackAttackWaveIndex {
            startJackAttackWave(at: wIdx + 1)
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
        case .justePifQuestion(let pif):
            questionNumber += 1
            enterJustePifQuestion(pif)
        case .drawSomethingTurn:
            questionNumber += 1
            enterDrawSomethingTurn()
        case .soloQuestion(let q):
            questionNumber += 1
            enterSoloQuestion(q)
        case .couciCouca(let round, let kind):
            questionNumber += 1
            enterCouciCoucaRound(round, kind: kind)
        case .jackAttackRound(let round):
            questionNumber += 1
            enterJackAttackRound(round)
        case .esquisseStep(let stepIdx):
            questionNumber = max(1, stepIdx)
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
        activeJustePif = nil
        activeDisOrDat = nil
        activeDrawRound = nil
        activeJackAttack = nil
        activeJackAttackWaveIndex = nil
        activeJackAttackOptionIndex = nil
        jackAttackWinnerName = nil
        revealedCorrectIndex = nil
        revealedBinarySide = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        screwAttackerID = nil
        screwAttackerName = nil

        let studioFile: String
        let text: String
        let isEN = AppLanguage.isEnglish
        switch kind {
        case .cashSpeed:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round1_cash.m4a"
            if isEN {
                let sponsorNote = activeSponsor.map { " 🪤 TODAY'S SPONSOR: '\($0.name)' (+3,500 pts if you dare tap their hidden answer)!" } ?? ""
                text = "Round 1: Speed Cash! Everyone answers on their phone, and you have 1 SCREW to trap an opponent!\(sponsorNote)"
            } else {
                let sponsorNote = activeSponsor.map { " 🪤 SPONSOR DU JOUR : « \($0.name) » (+3 500 pts si vous osez cliquer sur sa réponse cachée) !" } ?? ""
                text = "Manche 1 : Cash Rapide ! Tout le monde répond sur son téléphone, et vous avez le bouton « Clouer le Bec » pour piéger un adversaire !\(sponsorNote)"
            }
            meemawPose = "meemaw_vitesse"
            audio.playJingle("jingle_intro.wav")
        case .tuTeMetsCombien:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round_ttmc.m4a"
            text = isEN
                ? "Round 2: Bet Your Brain! Before seeing the question, bet from 1 to 4 stars on Meemaw's topic: 4 stars is 5,000 points or a wipeout!"
                : "Manche 2 : Tu Te Mets Combien ? Avant de voir la question, misez de 1 à 4 étoiles sur le sujet annoncé par Meemaw : 4 étoiles, c'est 5 000 points ou la gamelle !"
            meemawPose = "meemaw_duel_challenge"
            audio.playJingle("jingle_couci.wav")
        case .jukeboxExpress:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round_jukebox.m4a"
            text = isEN
                ? "Round 3: Meemaw's Jukebox Express! Complete the exact chorus lyrics right when the music stops!"
                : "Manche 3 : Le Jukebox Express de Meemaw ! Complétez les paroles exactes au moment où la musique coupe !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_intro.wav")
        case .leJustePif:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round_juste_pif.m4a"
            text = isEN
                ? "🔢 Closest Guess Round! Type your best numeric estimate on your keypad: +3,000 pts to the closest player, and +5,000 pts for an exact Bullseye!"
                : "🔢 Manche : Le Juste Pif ! Tapez votre estimation chiffrée sur le clavier numérique : +3 000 pts au plus proche, et +5 000 pts en Tout Pile !"
            meemawPose = "meemaw_duel_challenge"
            audio.playJingle("jingle_couci.wav")
        case .drawSomething:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round_draw.m4a"
            text = isEN
                ? "🎨 Draw Something Live! One artist draws live on the TV while everyone else unscrambles the secret word on their phone!"
                : "🎨 Manche Pinceau Draw Something ! Un artiste dessine en direct sur la TV, et les autres composent le mot avec les lettres mélangées sur leur téléphone !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_couci.wav")
        case .leSolo:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round2_solo_fast.m4a"
            text = isEN
                ? "SOLO Time! No separate buzzer needed: the very first player to tap an answer wins DOUBLE... or loses it all if they miss!"
                : "C'est l'heure du SOLO ! Pas besoin de buzzer : le tout premier qui tape une réponse sur son téléphone gagne le DOUBLE... ou perd tout s'il se plante !"
            meemawPose = "meemaw_boxing_referee"
            audio.playJingle("jingle_solo_siren.wav")
        case .couciCouca, .quoizziQuoissa:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round3_raclette.m4a"
            text = isEN
                ? "Meemaw's Cheesy Quizz! 6 rapid-fire binary questions: Option A, Option B, or BOTH!"
                : "La Raclette Quizz de Meemaw ! 6 questions qui fondent dans le poêlon : Gauche, Droite, ou LES DEUX !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_couci.wav")
        case .esquisseTeleArabe:
            audio.setMusicMood(.chillLobby)
            studioFile = "mq_round_esquisse.m4a"
            text = isEN
                ? "📞 Welcome to SKETCH RELAY! 1 easy word to draw with your finger, 1 drawing, and your neighbor guesses what it is!"
                : "📞 Bienvenue dans ESQUISSÉ ! 1 seul mot ultra-facile à dessiner au doigt, 1 dessin, et votre voisin devine quel est ce mot !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_couci.wav")
        case .finaleDouble:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round4_finale.m4a"
            text = isEN
                ? "Final Round! All points and penalties are DOUBLED, anyone can still steal the crown!"
                : "La Rafale Finale ! Tous les points sont DOUBLÉS, tout peut encore basculer !"
            meemawPose = "meemaw_duel_challenge"
            audio.playJingle("jingle_solo_siren.wav")
        case .jackAttack:
            audio.setMusicMood(.fastAction)
            studioFile = "mq_round_jack_attack.m4a"
            text = isEN
                ? "⚡ GRAND FINALE: MEEMAW'S JACK ATTACK! 5 rapid-fire association waves: hit your buzzer ONLY when the matching pair appears (+3,000 pts, or -1,500 pts if it's a trap)!"
                : "⚡ GRANDE FINALE : LE JACK ATTACK DE MEEMAW ! 5 vagues d'associations : buzzez UNIQUEMENT quand la bonne réponse s'affiche (+3 000 pts, ou -1 500 pts si piège) !"
            meemawPose = "meemaw_duel_challenge"
            audio.playJingle("jingle_solo_siren.wav")
        }

        meemawSpeech = text
        audio.playMeemawStudioOrFallback(studioFilename: studioFile, fallbackText: text)

        // Guaranteed auto-advance countdown that always waits for Meemaw to finish her intro + 1.5s breathing room
        let introDuration = max(8.0, ceil(audio.currentVoiceDuration + 1.5))
        startCountdown(duration: introDuration) { [weak self] in
            self?.advanceToNextPhaseStep()
        }
        broadcastState()
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
        meemawPose = "meemaw_duel_challenge"
        let betPrompt = "🎯 TU TE METS COMBIEN (de ⭐ à ⭐⭐⭐⭐) sur : « \(question.funnyTitle) » (\(question.theme.shortBadge)) ?"
        meemawSpeech = betPrompt

        let ttmcCue = question.audioCueID.map { "\($0)_ttmc.m4a" } ?? "mq_round_ttmc.m4a"
        audio.playMeemawStudioOrFallback(
            studioFilename: ttmcCue,
            fallbackText: "Tu te mets combien de une à quatre étoiles sur : \(question.funnyTitle) ?"
        )

        let voiceDur = audio.currentVoiceDuration
        let betDuration = max(16.0, ceil(voiceDur + 8.0))

        // Schedule bots to lock their bet stars AFTER Meemaw finishes introducing the topic
        let bots = registry.players.filter { $0.id.hasPrefix("bot_") }
        if !bots.isEmpty {
            botActionTask?.cancel()
            let firstBotWaitMs = Int(max(4.5, voiceDur + 0.4) * 1000)
            botActionTask = Task { @MainActor [weak self] in
                for (idx, bot) in bots.enumerated() {
                    let delayMs = idx == 0 ? firstBotWaitMs : Int.random(in: 900...2000)
                    try? await Task.sleep(for: .milliseconds(delayMs))
                    guard let self, !Task.isCancelled, self.stage == .ttmcBetting else { return }
                    let stars = [2, 2, 3, 3, 4, 1].randomElement() ?? 2
                    self.handlePlayerBetStars(playerID: bot.id, stars: stars)
                }
            }
        }

        startCountdown(duration: betDuration) { [weak self] in
            self?.openTTMCAnsweringPhase(question)
        }
        broadcastState()
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
            let remainingVoice = audio.remainingVoiceTime
            if remainingVoice > 0.25 {
                scheduleDelayed(seconds: remainingVoice + 0.4) { [weak self] in
                    guard let self, self.stage == .ttmcBetting else { return }
                    self.openTTMCAnsweringPhase(q)
                }
            } else {
                openTTMCAnsweringPhase(q)
            }
        }
    }

    private func openTTMCAnsweringPhase(_ question: QuizMCQQuestion) {
        stopTimers()
        // Default any player who didn't pick a star level to 2 stars
        for p in registry.players where p.lockedBetStars == nil {
            registry.updatePlayer(id: p.id) { $0.lockedBetStars = 2 }
        }
        stage = .cashAnswering
        questionOpenedAt = Date()
        meemawPose = "meemaw_dictation_talk"
        meemawSpeech = "Les paris sont fermés ! Voici la question : \(question.prompt)"

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        let answerDuration = max(26.0, ceil(audio.currentVoiceDuration + 14.0))
        scheduleBotsForCashQuestion(question)
        startCountdown(duration: answerDuration) { [weak self] in
            self?.revealCashQuestionResult(question, isDoubleFinale: false)
        }
        broadcastState()
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
        questionOpenedAt = Date()
        meemawPose = "meemaw_fun"
        meemawSpeech = "🎧 \(question.funnyTitle) — \(question.prompt)"

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        let answerDuration = max(26.0, ceil(audio.currentVoiceDuration + 14.0))
        scheduleBotsForCashQuestion(question)
        startCountdown(duration: answerDuration) { [weak self] in
            self?.revealCashQuestionResult(question, isDoubleFinale: false)
        }
        broadcastState()
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
        questionOpenedAt = Date()
        meemawPose = "meemaw_dictation_talk"
        meemawSpeech = "« \(question.funnyTitle) » — \(question.prompt)"

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        let answerDuration = max(28.0, ceil(audio.currentVoiceDuration + 14.0))
        scheduleBotsForCashQuestion(question)
        startCountdown(duration: answerDuration) { [weak self] in
            self?.revealCashQuestionResult(question, isDoubleFinale: isDoubleFinale)
        }
        broadcastState()
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
        var triggeredSponsorWinner: String?

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

            // Check if the player clicked the hidden YDKJ Sponsor Trap ("Wrong Answer of the Game")!
            if let sponsorIdx = question.sponsoredChoiceIndex, chosen == sponsorIdx {
                let jackpot = activeSponsor?.jackpotReward ?? QuizScoringEngine.sponsorJackpotPoints
                triggeredSponsorWinner = player.name
                sponsorWinnerName = player.name
                registry.updatePlayer(id: player.id) { p in
                    p.score += jackpot
                    p.lastDeltaScore = jackpot
                    p.streak += 1
                    p.correctAnswersCount += 1
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

        if let spWinner = triggeredSponsorWinner, let sp = activeSponsor {
            audio.playJingle("jingle_victory.wav")
            meemawPose = "meemaw_celebrate"
            meemawSpeech = "🎁 JACKPOT SPONSOR DE MAMIE ! \(spWinner) a osé cliquer sur la réponse sponsorisée « \(sp.name) » et rafle +\(sp.jackpotReward) PTS !\n\(question.explanation)"
            audio.playMeemawStudioOrFallback(
                studioFilename: "mq_react_all_correct.m4a",
                fallbackText: meemawSpeech
            )
        } else if let winner = fastestWinner {
            audio.playJingle("sfx_correct.wav")
            let praise = MeemawPunchlines.dynamicFastestPraise(
                playerName: winner.name,
                delta: winner.delta,
                reactionMs: winner.ms
            )
            meemawPose = "meemaw_celebrate"
            meemawSpeech = "\(praise)\n\(question.explanation)"

            let winFile = question.audioCueID.map { "\($0)_win.m4a" } ?? "mq_react_all_correct.m4a"
            audio.playMeemawStudioOrFallback(
                studioFilename: winFile,
                fallbackText: "\(praise) \(question.explanation)"
            )
        } else {
            audio.playJingle("sfx_wrong.wav")
            meemawPose = "meemaw_worried"
            meemawSpeech = "\(question.meemawRoastOnWrong)\n\(question.explanation)"

            let roastFile = question.audioCueID.map { "\($0)_roast.m4a" } ?? "mq_react_nobody_correct.m4a"
            audio.playMeemawStudioOrFallback(
                studioFilename: roastFile,
                fallbackText: question.meemawRoastOnWrong
            )
        }

        // Guaranteed auto-advance AFTER Meemaw finishes her reaction & explanation + 1.5s breathing room
        let revealDuration = max(9.5, ceil(audio.currentVoiceDuration + 1.5))
        startCountdown(duration: revealDuration) { [weak self] in
            self?.advanceToNextPhaseStep()
        }
        broadcastState()
    }

    // MARK: - Manche 4 : 🔢 « Le Juste Pif » (Estimation Numérique au Plus Proche)

    private func enterJustePifQuestion(_ pif: QuizJustePifQuestion) {
        registry.resetRoundLocks()
        roundKind = .leJustePif
        activeQuestion = nil
        activeJustePif = pif
        revealedCorrectIndex = nil
        stage = .justePifAnswering
        questionOpenedAt = Date()
        meemawPose = "meemaw_duel_challenge"
        meemawSpeech = "🔢 LE JUSTE PIF : « \(pif.funnyTitle) » — \(pif.prompt) (\(pif.unitLabel))"

        let pifCue = pif.id.hasPrefix("EN_") ? "en_pif_\(pif.id).m4a" : "pif_\(pif.id).m4a"
        audio.playMeemawStudioOrFallback(
            studioFilename: pifCue,
            fallbackText: "\(pif.funnyTitle). \(pif.prompt)"
        )

        let voiceDur = audio.currentVoiceDuration
        let pifDuration = max(22.0, ceil(voiceDur + 12.0))

        // Schedule bots to submit plausible estimates AFTER Meemaw reads the question
        let bots = registry.players.filter { $0.id.hasPrefix("bot_") }
        if !bots.isEmpty {
            botActionTask?.cancel()
            let firstBotWaitMs = Int(max(5.5, voiceDur + 0.8) * 1000)
            botActionTask = Task { @MainActor [weak self] in
                for (idx, bot) in bots.enumerated() {
                    let delayMs = idx == 0 ? firstBotWaitMs : Int.random(in: 1200...3200)
                    try? await Task.sleep(for: .milliseconds(delayMs))
                    guard let self, !Task.isCancelled, self.stage == .justePifAnswering else { return }
                    let spread = max(5, Int(Double(pif.correctValue) * 0.35))
                    let estimate = max(1, pif.correctValue + Int.random(in: -spread...spread))
                    self.handleSubmitNumericEstimate(playerID: bot.id, estimate: estimate)
                }
            }
        }

        startCountdown(duration: pifDuration) { [weak self] in
            self?.revealJustePifResult(pif)
        }
        broadcastState()
    }

    private func handleSubmitNumericEstimate(playerID: String, estimate: Int) {
        guard stage == .justePifAnswering, let pif = activeJustePif else { return }
        guard let player = registry.players.first(where: { $0.id == playerID }),
              player.lockedNumericEstimate == nil else { return }

        let elapsedMs = max(150, Int(Date().timeIntervalSince(questionOpenedAt) * 1000))
        registry.updatePlayer(id: playerID) { p in
            p.lockedNumericEstimate = estimate
            p.reactionTimeMs = elapsedMs
        }
        broadcastState()

        if registry.players.allSatisfy({ $0.lockedNumericEstimate != nil }) {
            stopTimers()
            revealJustePifResult(pif)
        }
    }

    private func revealJustePifResult(_ pif: QuizJustePifQuestion) {
        stopTimers()
        stage = .justePifReveal

        var estimates: [String: Int] = [:]
        for p in registry.players {
            if let est = p.lockedNumericEstimate {
                estimates[p.id] = est
            }
        }

        let deltas = QuizScoringEngine.scoreJustePifEstimates(
            correctValue: pif.correctValue,
            estimatesByPlayerID: estimates
        )

        var bestPlayerName: String?
        var bestDelta: Int = -99999
        var bestEstimate: Int = 0

        for p in registry.players {
            let delta = deltas[p.id] ?? 0
            registry.updatePlayer(id: p.id) { player in
                player.score += delta
                player.lastDeltaScore = delta
                if delta > 0 {
                    player.correctAnswersCount += 1
                    player.streak += 1
                } else {
                    player.streak = 0
                }
            }
            if delta > bestDelta, let est = p.lockedNumericEstimate {
                bestDelta = delta
                bestPlayerName = p.name
                bestEstimate = est
            }
        }

        audio.playJingle("sfx_correct.wav")
        meemawPose = "meemaw_celebrate"
        if let winner = bestPlayerName {
            let exactBadge = (bestEstimate == pif.correctValue) ? "🎯 TOUT PILE EXACT !" : "👏 Plus proche : \(winner) (\(bestEstimate) \(pif.unitLabel), +\(bestDelta) pts) !"
            meemawSpeech = "La vraie réponse est \(pif.correctValue) \(pif.unitLabel) ! \(exactBadge)\n\(pif.meemawComment)"
        } else {
            meemawSpeech = "La vraie réponse est \(pif.correctValue) \(pif.unitLabel) !\n\(pif.meemawComment)"
        }

        let pifRevealCue = pif.id.hasPrefix("EN_") ? "en_pif_\(pif.id)_reveal.m4a" : "pif_\(pif.id)_reveal.m4a"
        audio.playMeemawStudioOrFallback(
            studioFilename: pifRevealCue,
            fallbackText: meemawSpeech
        )

        let revealDuration = max(9.5, ceil(audio.currentVoiceDuration + 1.5))
        startCountdown(duration: revealDuration) { [weak self] in
            self?.advanceToNextPhaseStep()
        }
        broadcastState()
    }

    // MARK: - Grande Finale : ⚡ « Le Jack Attack de Meemaw » (5 Vagues au Buzzer)

    private func enterJackAttackRound(_ round: QuizJackAttackRound) {
        roundKind = .jackAttack
        activeJackAttack = round
        activeJackAttackWaveIndex = 0
        activeJackAttackOptionIndex = 0
        jackAttackWinnerName = nil
        startJackAttackWave(at: 0)
    }

    private func startJackAttackWave(at waveIndex: Int) {
        stopTimers()
        guard let round = activeJackAttack, round.waves.indices.contains(waveIndex) else {
            advanceToNextPhaseStep()
            return
        }
        registry.resetRoundLocks()
        let wave = round.waves[waveIndex]
        activeJackAttackWaveIndex = waveIndex
        activeJackAttackOptionIndex = 0
        jackAttackWinnerName = nil
        stage = .jackAttackActive
        totalTimerSec = 13.0
        timeRemainingSec = 13.0
        meemawPose = "meemaw_vitesse"
        meemawSpeech = "⚡ VAGUE \(waveIndex + 1)/\(round.waves.count) • \(wave.clueTitle) : « \(wave.anchorText) »"
        broadcastState()

        // Cycle through the 4 options every 1.6s (8 cycles max = 12.8s)
        jackAttackCyclesRemaining = 8
        jackAttackCycleTimer?.invalidate()
        jackAttackCycleTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.stage == .jackAttackActive else { return }
                self.jackAttackCyclesRemaining -= 1
                if self.jackAttackCyclesRemaining <= 0 {
                    self.revealJackAttackWave(at: waveIndex, winnerName: nil)
                    return
                }
                let nextOpt = ((self.activeJackAttackOptionIndex ?? 0) + 1) % max(1, wave.options.count)
                self.activeJackAttackOptionIndex = nextOpt
                self.broadcastState()

                // Bots have a chance to buzz when the correct option appears
                if nextOpt == wave.correctOptionIndex {
                    let bots = self.registry.players.filter { $0.id.hasPrefix("bot_") && !$0.isJackAttackFrozen }
                    if let randomBot = bots.randomElement(), Int.random(in: 0..<100) < 55 {
                        try? await Task.sleep(for: .milliseconds(Int.random(in: 550...1150)))
                        guard self.stage == .jackAttackActive,
                              self.activeJackAttackWaveIndex == waveIndex,
                              self.activeJackAttackOptionIndex == nextOpt else { return }
                        self.handleBuzzJackAttack(playerID: randomBot.id)
                    }
                }
            }
        }

        startCountdown(duration: 13.0) { [weak self] in
            self?.revealJackAttackWave(at: waveIndex, winnerName: nil)
        }
    }

    private func handleBuzzJackAttack(playerID: String) {
        guard stage == .jackAttackActive,
              let round = activeJackAttack,
              let wIdx = activeJackAttackWaveIndex,
              round.waves.indices.contains(wIdx),
              let optIdx = activeJackAttackOptionIndex else { return }

        guard let player = registry.players.first(where: { $0.id == playerID }),
              !player.isJackAttackFrozen,
              player.activeBisouWipesRemaining == 0 else { return }

        let wave = round.waves[wIdx]
        let isCorrect = (optIdx == wave.correctOptionIndex)
        let delta = QuizScoringEngine.scoreJackAttackBuzz(isCorrect: isCorrect)

        if isCorrect {
            audio.playJingle("sfx_correct.wav")
            for p in registry.players {
                registry.updatePlayer(id: p.id) {
                    if $0.id == playerID {
                        $0.score += delta
                        $0.lastDeltaScore = delta
                        $0.correctAnswersCount += 1
                        $0.soloWinsCount += 1
                    } else if $0.lastDeltaScore == nil {
                        $0.lastDeltaScore = 0
                    }
                }
            }
            revealJackAttackWave(at: wIdx, winnerName: player.name)
        } else {
            // Wrong buzz! Freeze this player's buzzer for the rest of this wave and deduct 1500 pts!
            audio.playJingle("sfx_wrong.wav")
            registry.updatePlayer(id: playerID) { p in
                p.score += delta
                p.lastDeltaScore = delta
                p.isJackAttackFrozen = true
                p.streak = 0
            }
            let wrongText = wave.options.indices.contains(optIdx) ? wave.options[optIdx] : "Piège"
            meemawSpeech = "💥 AÏE ! \(player.name) a buzzé trop tôt sur « \(wrongText) » (-1 500 pts) ! Aux autres de jouer !"
            broadcastState()

            // If all players are now frozen, reveal the wave immediately
            if registry.players.allSatisfy(\.isJackAttackFrozen) {
                revealJackAttackWave(at: wIdx, winnerName: nil)
            }
        }
    }

    private func revealJackAttackWave(at waveIndex: Int, winnerName: String?) {
        stopTimers()
        guard let round = activeJackAttack, round.waves.indices.contains(waveIndex) else {
            advanceToNextPhaseStep()
            return
        }
        let wave = round.waves[waveIndex]
        stage = .jackAttackWaveReveal
        activeJackAttackOptionIndex = wave.correctOptionIndex
        jackAttackWinnerName = winnerName
        let correctText = wave.options[wave.correctOptionIndex]

        if let winnerName {
            meemawPose = "meemaw_celebrate"
            meemawSpeech = "⚡ \(winnerName.uppercased()) RAFLE +3 000 PTS ! « \(wave.anchorText) \(correctText) » — \(wave.explanation)"
        } else {
            meemawPose = "meemaw_worried"
            meemawSpeech = "⏰ Personne n'a attrapé « \(wave.anchorText) \(correctText) » ! \(wave.explanation)"
        }
        broadcastState()

        startCountdown(duration: 5.5) { [weak self] in
            guard let self else { return }
            if waveIndex + 1 < round.waves.count {
                self.startJackAttackWave(at: waveIndex + 1)
            } else {
                self.advanceToNextPhaseStep()
            }
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
        questionOpenedAt = Date()
        meemawPose = "meemaw_boxing_referee"
        meemawSpeech = "🚨 LE SOLO (\(question.baseValue * 2) PTS) : Le 1er qui tape une réponse prend tout ou perd tout ! « \(question.funnyTitle) »"

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        let soloDuration = max(28.0, ceil(audio.currentVoiceDuration + 14.0))
        scheduleBotsForSoloBuzz(question)
        startCountdown(duration: soloDuration) { [weak self] in
            // Nobody answered in time!
            guard let self else { return }
            self.stage = .questionReveal
            self.revealedCorrectIndex = question.correctIndex
            self.meemawSpeech = "Personne n'a osé tenter le SOLO ! Bande de poules mouillées ! \(question.explanation)"
            self.broadcastState()
            self.startCountdown(duration: 8.5) { [weak self] in
                self?.advanceToNextPhaseStep()
            }
        }
        broadcastState()
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
        questionOpenedAt = Date()

        let callout = MeemawPunchlines.dynamicSoloBuzzCallout(playerName: player.name)
        meemawPose = "meemaw_duel_challenge"
        meemawSpeech = callout

        audio.playMeemawStudioOrFallback(
            studioFilename: "mq_solo_buzz.m4a",
            fallbackText: callout
        )

        let answerDur = max(14.0, ceil(audio.currentVoiceDuration + 8.0))
        startCountdown(duration: answerDur) { [weak self] in
            guard let self, self.stage == .soloPlayerAnswering else { return }
            self.revealSoloQuestionResult(q, buzzerPlayerID: player.id, chosenIndex: nil)
        }
        broadcastState()
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
                audio.playMeemawStudioOrFallback(
                    studioFilename: "mq_screw_backfire.m4a",
                    fallbackText: line
                )
                let revealDuration = max(9.5, ceil(audio.currentVoiceDuration + 1.5))
                startCountdown(duration: revealDuration) { [weak self] in
                    self?.advanceToNextPhaseStep()
                }
                broadcastState()
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
                audio.playMeemawStudioOrFallback(
                    studioFilename: "mq_screw_success.m4a",
                    fallbackText: line
                )
                let revealDuration = max(9.5, ceil(audio.currentVoiceDuration + 1.5))
                startCountdown(duration: revealDuration) { [weak self] in
                    self?.advanceToNextPhaseStep()
                }
                broadcastState()
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

        // Guaranteed auto-advance AFTER Meemaw finishes her reaction & explanation + 1.5s breathing room
        let revealDuration = max(9.5, ceil(audio.currentVoiceDuration + 1.5))
        startCountdown(duration: revealDuration) { [weak self] in
            self?.advanceToNextPhaseStep()
        }
        broadcastState()
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

        let cueFile = round.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(round.funnyTitle). \(round.prompt)"
        )

        // Start Item 0 after starting the intro voice so `audio.currentVoiceDuration` is known
        startCouciCoucaItem(at: 0, isFirstItemWithIntroVoice: true)
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
        let duration: Double = isFirstItemWithIntroVoice
            ? max(18.0, ceil(audio.currentVoiceDuration + 9.0))
            : 10.0
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
            if idx == 0, audio.remainingVoiceTime > 0.25 {
                scheduleDelayed(seconds: audio.remainingVoiceTime + 0.35) { [weak self] in
                    guard let self, self.stage == .couciCoucaItem else { return }
                    self.scoreAndAdvanceCouciItem(at: idx)
                }
            } else {
                scoreAndAdvanceCouciItem(at: idx)
            }
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

        audio.playMeemawStudioOrFallback(
            studioFilename: "mq_draw_word_pick.m4a",
            fallbackText: meemawSpeech
        )

        let voiceDur = audio.currentVoiceDuration
        let pickDur = max(15.0, ceil(voiceDur + 7.0))

        if drawer.id.hasPrefix("bot_") {
            botActionTask?.cancel()
            let waitMs = Int(max(6.0, voiceDur + 0.6) * 1000)
            botActionTask = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(waitMs))
                guard let self, !Task.isCancelled, self.stage == .drawWordChoice else { return }
                let preferred = options.first(where: { ["SOLEIL", "MAISON", "POISSON", "FUSEE", "SAPIN", "LUNETTES", "COURONNE"].contains($0.word) }) ?? options.randomElement()!
                self.handleSelectDrawWord(playerID: drawer.id, word: preferred.word)
            }
        }

        startCountdown(duration: pickDur) { [weak self] in
            guard let self, self.stage == .drawWordChoice, let first = self.activeDrawRound?.wordOptions.first else { return }
            self.handleSelectDrawWord(playerID: drawer.id, word: first.word)
        }
        broadcastState()
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

        let revealDur = max(8.5, ceil(audio.currentVoiceDuration + 1.5))
        startCountdown(duration: revealDur) { [weak self] in
            self?.advanceToNextPhaseStep()
        }
        broadcastState()
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

        // Auto-seed Step 0 with an ultra-simple 2-3 word expression so players jump straight into Drawing (Step 1) with a 1-tap 🔄 CHANGER button!
        let notebooks = participants.enumerated().map { idx, part in
            let initialPrompt = DrawingBank.randomEsquissePrompt(excluding: usedEsquissePrompts)
            usedEsquissePrompts.insert(initialPrompt)
            let seedEntry = EsquisseEntry(
                stepIndex: 0,
                authorPlayerID: part.id,
                authorName: part.name,
                authorEmoji: part.emoji,
                promptText: initialPrompt,
                drawing: nil
            )
            return EsquisseNotebook(
                id: "nb_\(idx)_\(part.id)",
                ownerPlayerID: part.id,
                ownerName: part.name,
                ownerEmoji: part.emoji,
                entries: [seedEntry],
                voteVoterIDs: []
            )
        }

        activeEsquisseRound = EsquisseRoundState(
            stepIndex: 1,
            totalSteps: 3,
            notebooks: notebooks,
            activeAssignmentByPlayerID: [:],
            showcaseNotebookIndex: 0,
            showcaseEntryCount: 1
        )
    }

    private func handleSwapSecretPrompt(playerID: String) {
        if stage == .drawLiveGuessing,
           var drawState = activeDrawRound,
           drawState.drawerPlayerID == playerID,
           drawState.foundPlayerIDs.isEmpty {
            let candidates = DrawingBank.allWords.filter { $0.stars <= 2 && !usedDrawWords.contains($0.word) }
            let pool = candidates.isEmpty ? DrawingBank.allWords.filter { $0.stars <= 2 } : candidates
            if let entry = pool.randomElement() {
                let newWord = DrawingBank.makeWordOption(from: entry)
                usedDrawWords.insert(newWord.word)
                drawState.chosenWord = newWord
                drawState.maskedWordPattern = DrawingBank.maskedPattern(for: newWord.word)
                drawState.wordLength = newWord.word.count
                drawState.scrambledTiles = newWord.scrambledTiles
                drawState.canvas = DrawingCanvasData()
                activeDrawRound = drawState
                broadcastState()
            }
            return
        }

        if stage == .esquisseDrawing,
           var esq = activeEsquisseRound,
           let nbID = esq.activeAssignmentByPlayerID[playerID],
           let nbIdx = esq.notebooks.firstIndex(where: { $0.id == nbID }),
           !esq.notebooks[nbIdx].entries.isEmpty {
            let newPrompt = DrawingBank.randomEsquissePrompt(excluding: usedEsquissePrompts)
            usedEsquissePrompts.insert(newPrompt)
            let lastEntryIdx = esq.notebooks[nbIdx].entries.count - 1
            esq.notebooks[nbIdx].entries[lastEntryIdx].promptText = newPrompt
            activeEsquisseRound = esq
            broadcastState()
        }
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
            // Step 0: Pick 1 simple word!
            stage = .esquissePromptEntry
            meemawPose = "meemaw_fun"
            meemawSpeech = "📞 ESQUISSÉ : Choisissez 1 mot facile à faire dessiner à votre voisin !"
            audio.setMusicMood(.chillLobby)
            audio.playMeemawStudioOrFallback(studioFilename: "mq_esquisse_prompt.m4a", fallbackText: meemawSpeech)
            broadcastState()
            startCountdown(duration: 30.0) { [weak self] in
                self?.finalizeCurrentEsquisseStepAndAdvance()
            }

        case 1, 3:
            // Step 1 or 3: Draw the 1 simple word with finger!
            stage = .esquisseDrawing
            meemawPose = "meemaw_dictation_talk"
            let displayStep = (stepIndex == 1) ? "1/3" : "3/3"
            meemawSpeech = "🎨 ESQUISSÉ (Manche \(displayStep)) : Dessinez ce MOT SIMPLE au doigt ! Touchez 🔄 si vous voulez un autre mot !"
            audio.setMusicMood(.fastAction)
            audio.playMeemawStudioOrFallback(studioFilename: "mq_esquisse_draw.m4a", fallbackText: meemawSpeech)
            broadcastState()
            startCountdown(duration: 50.0) { [weak self] in
                self?.finalizeCurrentEsquisseStepAndAdvance()
            }

        default:
            // Step 2: Guess the 1 word in 1 tap from 4 choices or type a single word!
            stage = .esquisseGuessing
            meemawPose = "meemaw_duel_challenge"
            meemawSpeech = "🕵️ ESQUISSÉ (Manche 2/3) : Quel MOT votre voisin a-t-il dessiné ? Touchez 1 des 4 mots en un clic ou tapez un mot !"
            audio.setMusicMood(.chillLobby)
            audio.playMeemawStudioOrFallback(studioFilename: "mq_esquisse_guess.m4a", fallbackText: meemawSpeech)
            broadcastState()
            startCountdown(duration: 32.0) { [weak self] in
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
                    esq.notebooks[nbIdx].entries.append(EsquisseEntry(
                        stepIndex: step,
                        authorPlayerID: assigneeID,
                        authorName: assigneeName,
                        authorEmoji: assigneeEmoji,
                        drawing: DrawingBank.botSketch(for: prevPrompt)
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

        let voiceDur = audio.currentVoiceDuration
        let screwDur = max(15.0, ceil(voiceDur + 8.0))

        if target.id.hasPrefix("bot_") {
            botActionTask?.cancel()
            let botWaitMs = Int(max(5.5, voiceDur + 1.2) * 1000)
            botActionTask = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(botWaitMs))
                guard let self, !Task.isCancelled, self.stage == .soloPlayerAnswering else { return }
                let botPick = (Int.random(in: 0..<100) < 50) ? q.correctIndex : Int.random(in: 0..<4)
                self.handlePlayerChoice(playerID: target.id, choiceIndex: botPick)
            }
        }

        startCountdown(duration: screwDur) { [weak self] in
            guard let self, self.stage == .soloPlayerAnswering else { return }
            self.revealSoloQuestionResult(q, buzzerPlayerID: target.id, chosenIndex: nil)
        }
        broadcastState()
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
        let firstWaitMs = Int(max(6.5, audio.currentVoiceDuration + 0.8) * 1000)
        botActionTask = Task { @MainActor [weak self] in
            for (idx, bot) in bots.enumerated() {
                let delayMs = idx == 0 ? firstWaitMs : Int.random(in: 1800...4500)
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
        let minBuzzMs = Int(max(11.5, audio.currentVoiceDuration + 2.0) * 1000)
        botActionTask = Task { @MainActor [weak self] in
            let delayMs = Int.random(in: minBuzzMs...(minBuzzMs + 5500))
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
        let isFirstItem = (activeDisOrDatItemIndex ?? 0) == 0
        let firstBotWaitMs = isFirstItem
            ? Int(max(4.5, audio.currentVoiceDuration + 0.8) * 1000)
            : Int.random(in: 2800...5200)
        botActionTask = Task { @MainActor [weak self] in
            for (idx, bot) in bots.enumerated() {
                let delayMs = idx == 0 ? firstBotWaitMs : Int.random(in: 1200...2800)
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
        jackAttackCycleTimer?.invalidate()
        jackAttackCycleTimer = nil
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
            activeSponsor: activeSponsor,
            sponsorWinnerName: sponsorWinnerName,
            activeQuestion: activeQuestion,
            revealedCorrectIndex: revealedCorrectIndex,
            soloBuzzerPlayerID: soloBuzzerPlayerID,
            soloBuzzerPlayerName: soloBuzzerPlayerName,
            screwAttackerName: screwAttackerName,
            activeJustePif: activeJustePif,
            activeDisOrDat: activeDisOrDat,
            activeDisOrDatItemIndex: activeDisOrDatItemIndex,
            revealedBinarySide: revealedBinarySide,
            activeDrawRound: activeDrawRound,
            activeEsquisseRound: activeEsquisseRound,
            activeJackAttack: activeJackAttack,
            activeJackAttackWaveIndex: activeJackAttackWaveIndex,
            activeJackAttackOptionIndex: activeJackAttackOptionIndex,
            jackAttackWinnerName: jackAttackWinnerName,
            podiumAwards: podiumAwards
        )
    }

    private func broadcastState() {
        let snapshot = buildCurrentSnapshot()
        cachedHostSnapshot = snapshot
        lanServer.broadcast(snapshot)
        CarPlayNowPlayingManager.shared.update(with: snapshot)
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
