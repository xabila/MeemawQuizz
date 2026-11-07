import Foundation
import MeemawQuizzCore
import SwiftUI

extension GameSessionController {
    // MARK: - 🎨 Manche « DRAW SOMETHING » (Pictionary Live + 12 Tuiles de Lettres)

    func enterDrawSomethingTurn() {
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

    func handleSelectDrawWord(playerID: String, word: String) {
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

    func openDrawLiveGuessingPhase(isBotOrMagicDrawer: Bool) {
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

    func handleUpdateDrawingCanvas(playerID: String, canvas: DrawingCanvasData) {
        if stage == .drawLiveGuessing, var drawState = activeDrawRound, drawState.drawerPlayerID == playerID {
            drawState.canvas = canvas
            activeDrawRound = drawState
            broadcastState()
        }
    }

    func handleRequestDrawHint(playerID: String) {
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

    func handleSubmitDrawGuessWord(playerID: String, guess: String) {
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

    func revealDrawRoundResult() {
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

    func setupEsquisseNotebooks() {
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

    func handleSwapSecretPrompt(playerID: String) {
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

    func enterEsquisseStep(_ stepIndex: Int) {
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

    func handleSubmitEsquisseText(playerID: String, text: String) {
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

    func handleSubmitEsquisseDrawing(playerID: String, canvas: DrawingCanvasData) {
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

    func finalizeCurrentEsquisseStepAndAdvance() {
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

    func enterEsquisseShowcase() {
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

    func advanceEsquisseShowcaseStep() {
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

    func handleVoteEsquisseAlbum(playerID: String, notebookID: String) {
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
}
