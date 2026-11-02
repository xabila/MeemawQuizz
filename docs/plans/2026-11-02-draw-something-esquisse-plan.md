# Draw Something & Esquissé Party Modes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add real-time Draw Something (Pictionary + scrambled letter tiles) both as a round inside the Grand Quiz Show and as a dedicated 100% Drawing Party Mode, plus a dedicated Esquissé! (Gartic Phone / Téléphone Arabe Dessiné) mode with free-text keyboard guessing and AirPlay TV album showcase.

**Architecture:** We extend `MeemawQuizzCore` with normalized vector stroke models (`DrawingStroke`, `DrawingCanvasData`), a curated French drawing word & bot-sketch bank (`DrawingBank`), and Esquissé notebook chains (`EsquisseNotebook`, `EsquisseStep`). `GameSessionController` orchestrates live stroke synchronization over Bonjour and WebSockets, while `PlayerControllerView`, `MeemawTVStageView`, and `WebControllerHTML` render interactive vector canvases, Draw Something letter tiles, and the Esquissé notebook showcase.

**Tech Stack:** Swift 6 (`MeemawQuizzCore`), SwiftUI `Canvas` + `DragGesture`, HTML5 `<canvas>` + WebSocket JSON protocol, `AVSpeechSynthesizer` (`com.apple.voice.premium.fr-FR.Audrey` offline `.m4a` studio voice generation).

---

### Task 1: Core Models & Drawing/Esquissé Bank in `MeemawQuizzCore`

**Files:**
- Modify: `Sources/MeemawQuizzCore/QuizModels.swift`
- Create: `Sources/MeemawQuizzCore/DrawingBank.swift`
- Modify: `Sources/MeemawQuizzCore/QuizScoringEngine.swift`
- Modify: `Tests/MeemawQuizzCoreTests/MeemawQuizzCoreTests.swift`

**Step 1: Add models & bank**
- Add `ShowGameMode` (`.fullQuizShow`, `.drawSomethingOnly`, `.esquisseParty`).
- Add `.drawSomething` and `.esquisseTeleArabe` to `QuizRoundKind`.
- Add `NormalizedPoint`, `DrawingStroke`, `DrawingCanvasData`, `DrawWordOption`, `DrawRoundState`, `EsquisseEntry`, `EsquisseNotebook` to `QuizModels.swift`.
- Add new `ShowStageState` cases: `.drawWordChoice`, `.drawLiveGuessing`, `.drawReveal`, `.esquissePromptEntry`, `.esquisseDrawing`, `.esquisseGuessing`, `.esquisseShowcase`.
- Add new `ClientToHostMessage.ActionKind` cases: `.selectGameMode`, `.selectDrawWord`, `.updateDrawingCanvas`, `.submitDrawGuessWord`, `.submitEsquisseText`, `.submitEsquisseDrawing`, `.voteEsquisseAlbum`.
- Create `DrawingBank.swift` with:
  - 60 French words across 3 star difficulties (⭐ 1000 pts, ⭐⭐ 2000 pts, ⭐⭐⭐ 3000 pts) with deterministic 12-letter scrambled tile generator (`scrambledTiles(for:)`).
  - Pre-recorded vector sketches (`botVectorSketches`) so Solo mode ("Le Pinceau Magique de Meemaw") and Demo Bots can draw recognizable vector objects stroke-by-stroke!
  - 30 hilarious French starter prompts for Esquissé (`esquisseStarterPrompts`).

**Step 2: Run `swift test` to verify core models and scoring**
Run: `swift test`
Expected: PASS

---

### Task 2: GameSessionController Orchestration for Draw Something & Esquissé

**Files:**
- Modify: `App/GameSessionController.swift`
- Modify: `Sources/MeemawQuizzCore/MeemawPunchlines.swift`
- Modify: `Scripts/generate_meemaw_quizz_audio.swift`

**Step 1: Implement Draw Something & Esquissé state machines**
- Support `selectedGameMode: ShowGameMode` in lobby (`selectGameMode(_:)`).
- In `.fullQuizShow`, include a `.drawSomethingRound` right after Jukebox Express!
- In `.drawSomethingOnly`, build a 6-round drawing rotation where every connected player (and/or Meemaw's Magic Brush in solo) takes turns drawing.
- In `.esquisseParty`, create one `EsquisseNotebook` per player (minimum 3 notebooks using virtual Meemaw/Tonton/Tata notebooks if fewer than 3 human players), rotate notebooks across 4 steps (Prompt -> Draw 1 -> Free-Text Guess -> Draw 2), and run the `.esquisseShowcase` album reveal on TV & phones with `+1000 pts` heart/laugh voting!
- Generate studio `.m4a` voice cues with `Audrey Premium` (`mq_round_draw.m4a`, `mq_round_esquisse.m4a`, `mq_draw_word_pick.m4a`, `mq_draw_found.m4a`, `mq_esquisse_draw.m4a`, `mq_esquisse_guess.m4a`, `mq_esquisse_showcase.m4a`).

---

### Task 3: iOS Native Views (`PlayerControllerView.swift` & `MeemawTVStageView.swift`) + Web Controller (`WebControllerHTML.swift`)

**Files:**
- Modify: `App/PlayerControllerView.swift`
- Modify: `App/MeemawTVStageView.swift`
- Modify: `Sources/MeemawQuizzCore/WebControllerHTML.swift`

**Step 1: Add interactive vector drawing pad, Draw Something 12-tile word composer, and Esquissé free-text + album showcase**
- Lobby mode selector (`📺 Show Quizz + Dessin`, `🎨 100% Draw Something`, `📞 Esquissé ! Gartic Phone`).
- Interactive touch canvas (`DrawingPadView` on iOS + `<canvas>` on Web) with 6 Pop-Art colors, 3 brush sizes, Undo last stroke, and Clear canvas.
- Live vector canvas renderer on TV (`MeemawTVStageView`) and guesser phones, plus progressive letter hint reveal and 12-tile *Draw Something* word composer.
- Full Esquissé flow: free-text keyboard input (with optional "🎲 Idée de Meemaw" button on step 1), drawing step, 100% free-text keyboard guessing step while viewing the previous player's drawing, and the hilarious step-by-step Album Showcase + vote button!

---

### Task 4: Build, Install on iPhone, TestFlight Upload & Git Commit

**Files:**
- Modify: `project.yml`

**Step 1: Verify `swift test` and `xcodebuild` for Xabi's iPhone (`00008110-001834420A8BA01E`)**
- Run `swift test`
- Generate new studio `.m4a` audio cues with `Audrey Premium`
- Build & install on `iPhone Xlarrode 14` (`00008110-001834420A8BA01E`) and commit to `main`.
