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
        UserDefaults.standard.string(forKey: "meemawquizz.localPlayerName") ?? "Chef du Salon"
    }() {
        didSet {
            UserDefaults.standard.set(localPlayerName, forKey: "meemawquizz.localPlayerName")
        }
    }

    var localSelectedColor: PlayerColor = .meemawOrange
    var localAvatarEmoji: String = "🦊"

    // MARK: - Synchronized Show State
    var roomCode: String = "MAMIE"
    var selectedPack: QuizThemePack = .grandMix
    var stage: ShowStageState = .lobby
    var roundKind: QuizRoundKind = .cashSpeed
    var questionNumber: Int = 0
    var totalQuestions: Int = 8
    var meemawSpeech: String = "Bienvenue dans le Grand Quizz AirPlay de Meemaw ! Connectez vos téléphones sur le Wi-Fi !"
    var meemawPose: String = "meemaw_salut"
    var timeRemainingSec: Double = 0
    var totalTimerSec: Double = 12

    private var registry = PlayerLobbyRegistry()
    private var connectionToPlayerID: [UUID: String] = [:]
    private var usedQuestionIDs: Set<String> = []
    private var usedDisOrDatIDs: Set<String> = []
    private var activeDeck: ShowGameDeck = QuestionBank.buildShowDeck(for: .grandMix)
    private var phaseQueue: [ShowPhaseStep] = []
    private var currentStepIndex: Int = -1

    var activeQuestion: QuizMCQQuestion?
    var revealedCorrectIndex: Int?
    var soloBuzzerPlayerID: String?
    var soloBuzzerPlayerName: String?
    var activeDisOrDat: QuizDisOrDatRound?
    var activeDisOrDatItemIndex: Int?
    var podiumAwards: [PodiumAward] = []

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
        case soloQuestion(QuizMCQQuestion)
        case couciCouca(QuizDisOrDatRound)
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
        return buildCurrentSnapshot()
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

    func wipeLocalBisouScreen() {
        audio.triggerControllerHaptic(style: .light)
        dispatchAction(ClientToHostMessage(
            playerID: localPlayerID,
            action: .wipeBisouScreen
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

        case .buzzSolo:
            handlePlayerSoloBuzz(playerID: msg.playerID)

        case .selectBinarySide:
            guard let side = msg.binarySide else { return }
            handlePlayerBinarySide(playerID: msg.playerID, side: side)

        case .sendBisouTrap:
            guard let targetID = msg.targetPlayerID else { return }
            handleBisouTrap(fromPlayerID: msg.playerID, toPlayerID: targetID)

        case .wipeBisouScreen:
            registry.updatePlayer(id: msg.playerID) { p in
                p.activeBisouWipesRemaining = max(0, p.activeBisouWipesRemaining - 1)
                if p.activeBisouWipesRemaining == 0 {
                    p.bisouSenderName = nil
                }
            }
            broadcastState()

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

        let totalAvailableInPack = QuestionBank.questions(for: selectedPack).count
        if usedQuestionIDs.count >= max(7, totalAvailableInPack - 6) {
            usedQuestionIDs.removeAll()
        }
        if usedDisOrDatIDs.count >= QuestionBank.allDisOrDatRounds.count {
            usedDisOrDatIDs.removeAll()
        }

        activeDeck = QuestionBank.buildShowDeck(
            for: selectedPack,
            excludingQuestionIDs: usedQuestionIDs,
            excludingDisOrDatIDs: usedDisOrDatIDs
        )
        usedQuestionIDs.formUnion(activeDeck.allMCQIDs)
        usedDisOrDatIDs.insert(activeDeck.couciCoucaRound.id)

        phaseQueue = [
            .roundIntro(.cashSpeed),
            .cashQuestion(activeDeck.cashQuestions[0], isDoubleFinale: false),
            .cashQuestion(activeDeck.cashQuestions[1], isDoubleFinale: false),
            .cashQuestion(activeDeck.cashQuestions[2], isDoubleFinale: false),
            .roundIntro(.leSolo),
            .soloQuestion(activeDeck.soloQuestions[0]),
            .soloQuestion(activeDeck.soloQuestions[1]),
            .roundIntro(.couciCouca),
            .couciCouca(activeDeck.couciCoucaRound),
            .roundIntro(.finaleDouble),
            .cashQuestion(activeDeck.finaleDoubleQuestions[0], isDoubleFinale: true),
            .cashQuestion(activeDeck.finaleDoubleQuestions[1], isDoubleFinale: true),
            .podium
        ]
        totalQuestions = 8
        questionNumber = 0
        currentStepIndex = -1

        audio.playJingle("jingle_intro.wav")
        advanceToNextPhaseStep()
    }

    func returnToLobby() {
        guard role == .hostAndPlayer1 else { return }
        stopTimers()
        audio.stopVoiceOnly()
        registry.resetRoundLocks()
        stage = .lobby
        activeQuestion = nil
        activeDisOrDat = nil
        revealedCorrectIndex = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        podiumAwards = []
        meemawPose = "meemaw_salut"
        meemawSpeech = "Partie arrêtée ! De retour au salon : choisissez votre thème et vos couleurs !"
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
        case .soloQuestion(let q):
            questionNumber += 1
            enterSoloQuestion(q)
        case .couciCouca(let round):
            questionNumber += 1
            enterCouciCoucaRound(round)
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
        revealedCorrectIndex = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil

        let studioFile: String
        let text: String
        switch kind {
        case .cashSpeed:
            studioFile = "mq_round1_cash.m4a"
            text = "Manche 1 : Cash Rapide ! Tout le monde répond sur son téléphone, le plus rapide rafle la mise !"
            meemawPose = "meemaw_vitesse"
            audio.playJingle("jingle_intro.wav")
        case .leSolo:
            studioFile = "mq_round2_solo.m4a"
            text = "Manche 2 : C'est l'heure du SOLO ! Le premier qui écrase le buzzer rouge bloque les autres et joue pour le DOUBLE !"
            meemawPose = "meemaw_boxing_referee"
            audio.playJingle("jingle_solo_siren.wav")
        case .couciCouca:
            studioFile = "mq_round3_couci.m4a"
            text = "Manche 3 : Le Couci-Couça de Meemaw ! 6 affirmations à toute allure, tapez à Gauche ou à Droite !"
            meemawPose = "meemaw_fun"
            audio.playJingle("jingle_couci.wav")
        case .finaleDouble:
            studioFile = "mq_round4_finale.m4a"
            text = "Manche 4 : La Rafale Finale ! Tous les points sont DOUBLÉS, tout peut encore basculer !"
            meemawPose = "meemaw_duel_challenge"
            audio.playJingle("jingle_solo_siren.wav")
        }

        meemawSpeech = text
        broadcastState()

        audio.playMeemawStudioOrFallback(studioFilename: studioFile, fallbackText: text) { [weak self] in
            self?.scheduleDelayed(seconds: 2.2) {
                self?.advanceToNextPhaseStep()
            }
        }
    }

    // MARK: - Manche 1 & 4 : Cash Speed / Finale Double

    private func enterCashQuestion(_ question: QuizMCQQuestion, isDoubleFinale: Bool) {
        registry.resetRoundLocks()
        roundKind = isDoubleFinale ? .finaleDouble : .cashSpeed
        activeQuestion = question
        revealedCorrectIndex = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
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
        if stage == .soloPlayerAnswering {
            guard soloBuzzerPlayerID == playerID, let q = activeQuestion else { return }
            let elapsedMs = max(100, Int(Date().timeIntervalSince(questionOpenedAt) * 1000))
            registry.updatePlayer(id: playerID) { p in
                p.lockedChoiceIndex = choiceIndex
                p.reactionTimeMs = elapsedMs
            }
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
                registry.updatePlayer(id: player.id) { p in
                    p.lastDeltaScore = 0
                    p.streak = 0
                }
                continue
            }
            let isCorrect = (chosen == question.correctIndex)
            let rankIdx = correctPlayerIDs.firstIndex(of: player.id)
            let ms = player.reactionTimeMs ?? 25000
            let delta = QuizScoringEngine.scoreCashAnswer(
                baseValue: question.baseValue,
                isCorrect: isCorrect,
                correctRankIndex: rankIdx,
                reactionTimeMs: ms,
                totalTimeMs: 26000,
                isDoubleFinale: isDoubleFinale
            )
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

            audio.speakDynamicPlayerCallout(praise) { [weak self] in
                self?.scheduleDelayed(seconds: 7.0) {
                    self?.advanceToNextPhaseStep()
                }
            }
        } else {
            audio.playJingle("sfx_wrong.wav")
            meemawPose = "meemaw_worried"
            meemawSpeech = "\(question.meemawRoastOnWrong)\n\(question.explanation)"
            broadcastState()

            let roastFile = question.audioCueID.map { "\($0)_roast.m4a" }
            audio.playMeemawStudioOrFallback(
                studioFilename: roastFile,
                fallbackText: question.meemawRoastOnWrong
            ) { [weak self] in
                self?.scheduleDelayed(seconds: 7.0) {
                    self?.advanceToNextPhaseStep()
                }
            }
        }
    }

    // MARK: - Manche 2 : « LE SOLO » (Mode Buzzer YDKJ 90s)

    private func enterSoloQuestion(_ question: QuizMCQQuestion) {
        registry.resetRoundLocks()
        roundKind = .leSolo
        activeQuestion = question
        revealedCorrectIndex = nil
        soloBuzzerPlayerID = nil
        soloBuzzerPlayerName = nil
        stage = .soloBuzzOpen
        totalTimerSec = 24.0
        timeRemainingSec = 24.0
        questionOpenedAt = Date()
        meemawPose = "meemaw_boxing_referee"
        meemawSpeech = "🚨 LE SOLO ! Le 1er qui buzze prend la main pour \(question.baseValue * 2) PTS : « \(question.funnyTitle) »"
        broadcastState()

        let cueFile = question.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(question.funnyTitle). \(question.prompt)"
        )

        scheduleBotsForSoloBuzz(question)
        startCountdown(duration: 24.0) { [weak self] in
            // Nobody buzzed in time!
            guard let self else { return }
            self.stage = .questionReveal
            self.revealedCorrectIndex = question.correctIndex
            self.meemawSpeech = "Personne n'a osé appuyer sur le buzzer du SOLO ! Bande de poules mouillées ! \(question.explanation)"
            self.broadcastState()
            self.scheduleDelayed(seconds: 7.0) {
                self.advanceToNextPhaseStep()
            }
        }
    }

    private func handlePlayerSoloBuzz(playerID: String) {
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

        audio.speakDynamicPlayerCallout(callout)

        // If a bot buzzed, make the bot answer after 3.2s
        if player.id.hasPrefix("bot_") {
            botActionTask = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(3200))
                guard let self, self.stage == .soloPlayerAnswering else { return }
                let botPick = Bool.random() ? q.correctIndex : Int.random(in: 0..<4)
                self.handlePlayerChoice(playerID: player.id, choiceIndex: botPick)
            }
        }

        startCountdown(duration: 12.0) { [weak self] in
            guard let self, self.stage == .soloPlayerAnswering else { return }
            self.revealSoloQuestionResult(q, buzzerPlayerID: player.id, chosenIndex: nil)
        }
    }

    private func revealSoloQuestionResult(_ question: QuizMCQQuestion, buzzerPlayerID: String, chosenIndex: Int?) {
        stopTimers()
        stage = .questionReveal
        revealedCorrectIndex = question.correctIndex

        let isCorrect = (chosenIndex == question.correctIndex)
        let delta = QuizScoringEngine.scoreSoloAnswer(baseValue: question.baseValue, isCorrect: isCorrect)
        let playerName = registry.players.first(where: { $0.id == buzzerPlayerID })?.name ?? "Le joueur"

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

        audio.speakDynamicPlayerCallout(line) { [weak self] in
            self?.scheduleDelayed(seconds: 7.0) {
                self?.advanceToNextPhaseStep()
            }
        }
    }

    // MARK: - Manche 3 : Couci-Couça Binaire (DisOrDat)

    private func enterCouciCoucaRound(_ round: QuizDisOrDatRound) {
        registry.resetRoundLocks()
        roundKind = .couciCouca
        activeQuestion = nil
        activeDisOrDat = round
        activeDisOrDatItemIndex = nil
        stage = .couciCoucaIntro
        meemawPose = "meemaw_fun"
        meemawSpeech = "⚖️ COUCI-COUÇA : « \(round.funnyTitle) » — \(round.prompt)"
        broadcastState()

        let cueFile = round.audioCueID.map { "\($0).m4a" }
        audio.playMeemawStudioOrFallback(
            studioFilename: cueFile,
            fallbackText: "\(round.funnyTitle). \(round.prompt)"
        ) { [weak self] in
            self?.startCouciCoucaItem(at: 0)
        }
    }

    private func startCouciCoucaItem(at index: Int) {
        stopTimers()
        guard let round = activeDisOrDat, round.items.indices.contains(index) else {
            finishCouciCoucaRound()
            return
        }
        registry.resetRoundLocks()
        activeDisOrDatItemIndex = index
        stage = .couciCoucaItem
        totalTimerSec = 10.0
        timeRemainingSec = 10.0
        let item = round.items[index]
        meemawSpeech = "Item \(index + 1)/\(round.items.count) : « \(item.text) »"
        broadcastState()

        scheduleBotsForCouciItem(item)
        startCountdown(duration: 10.0) { [weak self] in
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

        var anyCorrect = false
        for player in registry.players {
            guard let side = player.lockedSide else { continue }
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
        audio.playJingle(anyCorrect ? "sfx_correct.wav" : "sfx_wrong.wav")
        broadcastState()

        scheduleDelayed(seconds: 2.5) { [weak self] in
            self?.startCouciCoucaItem(at: index + 1)
        }
    }

    private func finishCouciCoucaRound() {
        stage = .couciCoucaSummary
        meemawPose = "meemaw_celebrate"
        meemawSpeech = "Fin du Couci-Couça ! Regardez les scores avant la Rafale Finale à points doublés !"
        broadcastState()
        scheduleDelayed(seconds: 6.0) { [weak self] in
            self?.advanceToNextPhaseStep()
        }
    }

    // MARK: - Bisou Baveux de Meemaw (Trap Mechanic)

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

    // MARK: - Final Podium

    private func enterFinalPodium() {
        stopTimers()
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

        if let champion = podiumAwards.first {
            let text = "Et le grand vainqueur du soir est \(champion.playerName), avec \(champion.score) points ! Félicitations mon chouchou !"
            audio.speakDynamicPlayerCallout(text)
        }
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
            let delayMs = Int.random(in: 8500...16000)
            try? await Task.sleep(for: .milliseconds(delayMs))
            guard let self, !Task.isCancelled, self.stage == .soloBuzzOpen else { return }
            self.handlePlayerSoloBuzz(playerID: randomBot.id)
        }
    }

    private func scheduleBotsForCouciItem(_ item: QuizDisOrDatItem) {
        let bots = registry.players.filter { $0.id.hasPrefix("bot_") }
        guard !bots.isEmpty else { return }
        botActionTask?.cancel()
        botActionTask = Task { @MainActor [weak self] in
            for bot in bots {
                let delayMs = Int.random(in: 2500...6000)
                try? await Task.sleep(for: .milliseconds(delayMs))
                guard let self, !Task.isCancelled, self.stage == .couciCoucaItem else { return }
                let pick = (Int.random(in: 0..<100) < 75) ? item.correctSide : (item.correctSide == "left" ? "right" : "left")
                self.handlePlayerBinarySide(playerID: bot.id, side: pick)
            }
        }
    }

    private func startCountdown(duration: Double, onExpired: @escaping @MainActor () -> Void) {
        countdownTimer?.invalidate()
        totalTimerSec = duration
        timeRemainingSec = duration
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.timeRemainingSec = max(0, self.timeRemainingSec - 0.2)
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
    }

    private func buildCurrentSnapshot() -> HostToClientStateSnapshot {
        HostToClientStateSnapshot(
            roomCode: roomCode,
            joinURL: lanServer.joinURLString,
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
            activeDisOrDat: activeDisOrDat,
            activeDisOrDatItemIndex: activeDisOrDatItemIndex,
            podiumAwards: podiumAwards
        )
    }

    private func broadcastState() {
        let snapshot = buildCurrentSnapshot()
        lanServer.broadcast(snapshot)
    }

    // MARK: - QR Code Generator for TV Lobby

    static func makeQRCodeImage(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let outputImage = filter.outputImage else { return nil }
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
