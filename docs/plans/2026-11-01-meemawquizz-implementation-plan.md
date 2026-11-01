# MeemawQuizz Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the `MeemawQuizz` AirPlay multiplayer party quiz show app (iOS native host/client with automatic Bonjour discovery + embedded LAN HTTP/WebSocket controller with QR code for Android + Meemaw Pop-Art TV show stage, Audrey Premium voice `.m4a` audio & 6 original question packs).

**Architecture:** A modular Swift 6 package (`MeemawQuizzCore`) containing pure, testable models, scoring, question banks, WebSocket RFC 6455 frame/handshake codec, and state machine logic, paired with an iOS SwiftUI app target (`MeemawQuizz`) featuring `ExternalDisplayManager` (AirPlay 16:9 TV scene + iOS 27 `UISceneAccessory`), `QuizLANServer` (`NWListener` serving both Bonjour `_meemawquizz._tcp` and HTTP/WebSocket for Android), `QuizBonjourClient` (`NWBrowser`), and `MeemawShowAudioEngine` (2-tier pre-rendered Audrey `.m4a` + dynamic `AVSpeechSynthesizer` + TV jingles).

**Tech Stack:** Swift 6, SwiftUI, Network.framework (`NWListener`, `NWBrowser`, `NWConnection`), AVFoundation (`AVAudioPlayer`, `AVSpeechSynthesizer`), CryptoKit (SHA-1 WebSocket handshake), CoreImage (QR Code generator), XCTest.

---

### Task 1: Swift Package & Core Domain Models (`MeemawQuizzCore`)

**Files:**
- Create: `Package.swift`
- Create: `Sources/MeemawQuizzCore/QuizModels.swift`
- Create: `Sources/MeemawQuizzCore/QuizScoringEngine.swift`
- Test: `Tests/MeemawQuizzCoreTests/MeemawQuizzCoreTests.swift`

**Step 1: Write unit tests for player color locking, speed scoring, SOLO buzzer scoring, and DisOrDat scoring**
- Test that 8 Pop-Art colors lock uniquely per player and release when a player disconnects or changes color.
- Test `QuizScoringEngine.scoreCashAnswer(...)` (fastest correct gets full value + speed bonus, subsequent correct answers get degressive points, wrong answer loses 50%).
- Test `QuizScoringEngine.scoreSoloAnswer(...)` (correct SOLO answer yields `2x` value, wrong/timeout yields `-1x` value).
- Test `QuizScoringEngine.scoreDisOrDatAnswer(...)` (`+500` for correct binary choice, `0` or `-250` for wrong).

**Step 2: Implement `QuizModels.swift` and `QuizScoringEngine.swift` and verify `swift test` passes.**

---

### Task 2: RFC 6455 WebSocket Codec & Embedded Android/Web HTML5 Controller

**Files:**
- Create: `Sources/MeemawQuizzCore/WebSocketFrameCodec.swift`
- Create: `Sources/MeemawQuizzCore/WebControllerHTML.swift`
- Test: `Tests/MeemawQuizzCoreTests/WebSocketCodecTests.swift`

**Step 1: Write unit tests for HTTP request parsing, RFC 6455 `Sec-WebSocket-Accept` computation, masked client frame decoding, and server text frame encoding.**
**Step 2: Implement `WebSocketFrameCodec.swift` and `WebControllerHTML.swift` (responsive Pop-Art mobile web controller for Android & guests scanning the QR code).**
**Step 3: Run `swift test` and verify all tests pass.**

---

### Task 3: The 6 Original Question Packs & Meemaw Punchlines (`QuestionBankLoader`)

**Files:**
- Create: `Sources/MeemawQuizzCore/QuestionBank.swift`
- Create: `Sources/MeemawQuizzCore/MeemawPunchlines.swift`
- Test: `Tests/MeemawQuizzCoreTests/QuestionBankTests.swift`

**Step 1: Write tests verifying that all 6 packs (`francaisMeemaw`, `mathMeemaw`, `seriesCinema`, `musiqueTubes`, `cultureGInsolite`, `ecoCash`, plus `grandMix`) contain valid MCQ questions, SOLO questions, and `DisOrDat` Couci-Couça rounds with non-empty choices and valid `correctIndex`.**
**Step 2: Populate rich, hilarious, 100% IP-free questions across all 6 themes (reusing and adapting the best of `meemaw`, `meemawMath`, and `RushTiVi` plus original Series/Movies, Music, and General Knowledge questions).**
**Step 3: Run `swift test` and verify all tests pass.**

---

### Task 4: Audio Generation Pipeline (Meemaw Voice `.m4a` + TV Show Jingles) & Mascot Assets

**Files:**
- Create: `Scripts/generate_meemaw_quizz_audio.swift`
- Create: `App/Resources/MeemawQuizzAudio/` (generated `.m4a` voice cues & `.wav`/`.m4a` TV show jingles)
- Copy mascot assets from `/Users/xabi/DEV/meemaw/Meemaw/BundleResources/` (`meemaw_dictation_talk_384.webp`, `meemaw_celebrate_idle.mov`, `meemaw_giggle_idle.mov`, `meemaw_thumbs_up_384.webp`, `meemaw_result_success_384.webp`, `meemaw_detective_384.webp`, etc.)

**Step 1: Run `Scripts/generate_meemaw_quizz_audio.swift` using `com.apple.voice.premium.fr-FR.Audrey` to pre-render all show intros, round announcements, question prompts, and Meemaw punchlines into `App/Resources/MeemawQuizzAudio/` + generate the retro-pop TV jingles.**

---

### Task 5: Network Engine (`QuizLANServer` + `QuizBonjourClient`) & `ExternalDisplayManager`

**Files:**
- Create: `App/QuizLANServer.swift`
- Create: `App/QuizBonjourClient.swift`
- Create: `App/ExternalDisplayManager.swift`
- Create: `App/AirPlayRoutePickerButton.swift`
- Create: `App/MeemawShowAudioEngine.swift`
- Create: `App/GameSessionController.swift`

**Step 1: Implement the unified `NWListener` LAN server (advertising `_meemawquizz._tcp` via Bonjour AND serving HTTP `/` + WebSocket `/ws` on the local Wi-Fi IP for Android QR code clients).**
**Step 2: Implement `QuizBonjourClient` (`NWBrowser` auto-discovery + automatic connection to the host session).**
**Step 3: Implement `GameSessionController` orchestrating the Lobby, Round 1 (Cash Speed QCM + Bisou de Meemaw trap), Round 2 (LE SOLO Buzzer), Round 3 (Couci-Couça Binary), Round 4 (Finale Points ×2), and Final Podium.**

---

### Task 6: Giant AirPlay TV Stage View & Tactile Player/Host Views

**Files:**
- Create: `App/MeemawPopArtTheme.swift`
- Create: `App/MeemawTVStageView.swift`
- Create: `App/PlayerControllerView.swift`
- Create: `App/MeemawQuizzApp.swift`
- Create: `App/Info.plist`
- Create: `App/MeemawQuizz.entitlements`
- Create: `project.yml`

**Step 1: Build the giant 16:9 AirPlay TV stage (`MeemawTVStageView`) in Pop-Art comic style with animated Meemaw Guest Star, QR code + Bonjour badge in Lobby, giant readable question cards, SOLO siren spotlight, Couci-Couça split screen, live player dock at bottom, and final TV podium.**
**Step 2: Build the tactile iPhone controller (`PlayerControllerView`) with automatic Bonjour join, real-time color picker, Host mini-control bar (for Player 1), giant A/B/C/D buttons, giant red SOLO buzzer, Bisou de Meemaw screen-wipe mini-game, and haptic feedback.**
**Step 3: Generate `MeemawQuizz.xcodeproj` via `xcodegen`, run `swift test` and `xcodebuild` for iOS Simulator / generic iOS device, and verify zero warnings/errors.**
