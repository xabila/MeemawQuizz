# YDKJ & Party Game Mechanics (#2 Jack Attack, #3 Le Juste Pif, #4 Réponse Sponsorisée) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add the 3 approved YDKJ/Party Game mechanics (`MeemawSponsor` Wrong Answer of the Game, `Le Juste Pif` numeric estimation round, and `Le Jack Attack de Meemaw` rapid-fire buzzer finale) to the Grand Show TV across Core models, Scoring engine, Question bank, Host session controller, iOS controller, Apple TV stage, and Web QR controller.

**Architecture:** Extend `MeemawQuizzCore` models (`QuizModels.swift`, `QuizScoringEngine.swift`, `QuestionBankExpansion.swift`, `QuestionBank.swift`) with strongly typed structs (`MeemawSponsor`, `QuizJustePifQuestion`, `QuizJackAttackWave`, `QuizJackAttackRound`), wire their state transitions and timers into `GameSessionController.swift`, and render dedicated pop-art studio screens in `PlayerControllerView.swift`, `MeemawTVStageView.swift`, and `WebControllerHTML.swift`.

**Tech Stack:** Swift 6 (`MeemawQuizzCore` SPM package + iOS SwiftUI app), HTML5/Vanilla JS WebSocket controller (`WebControllerHTML.swift`), XCTest.

---

### Task 1: Core Models & Scoring Engine (`QuizModels.swift` & `QuizScoringEngine.swift`)

**Files:**
- Modify: `Sources/MeemawQuizzCore/QuizModels.swift`
- Modify: `Sources/MeemawQuizzCore/QuizScoringEngine.swift`
- Test: `Tests/MeemawQuizzCoreTests/QuestionBankTests.swift`

**Step 1: Add models & scoring functions**
- In `QuizModels.swift`:
  - Add `lockedNumericEstimate: Int?` and `isJackAttackFrozen: Bool` to `QuizPlayer` (reset in `resetRoundLocks()`).
  - Add `.leJustePif` and `.jackAttack` to `QuizRoundKind`.
  - Add `sponsoredChoiceIndex: Int?` to `QuizMCQQuestion`.
  - Define `MeemawSponsor`, `QuizJustePifQuestion`, `QuizJackAttackWave`, and `QuizJackAttackRound`.
  - Add `.justePifAnswering`, `.justePifReveal`, `.jackAttackActive`, `.jackAttackWaveReveal` to `ShowStageState`.
  - Add `.submitNumericEstimate` and `.buzzJackAttack` (plus `numericEstimate: Int?`) to `ClientToHostMessage`.
  - Add `activeSponsor: MeemawSponsor?`, `activeJustePif: QuizJustePifQuestion?`, `activeJackAttack: QuizJackAttackRound?`, `activeJackAttackWaveIndex: Int?`, `activeJackAttackOptionIndex: Int?`, `jackAttackWinnerName: String?` to `HostToClientStateSnapshot`.
- In `QuizScoringEngine.swift`:
  - Add `scoreSponsorJackpot() -> Int` (`+3500`).
  - Add `scoreJustePifEstimates(correctValue: Int, estimatesByPlayerID: [String: Int]) -> [String: Int]` (`+5000` exact, `+3000` closest, `+1500` 2nd closest, `-500` furthest if >1 player).
  - Add `scoreJackAttackBuzz(isCorrect: Bool) -> Int` (`+3000` if correct, `-1500` if wrong).

---

### Task 2: Humorous Content Bank (`QuestionBankExpansion.swift` & `QuestionBank.swift`)

**Files:**
- Modify: `Sources/MeemawQuizzCore/QuestionBankExpansion.swift`
- Modify: `Sources/MeemawQuizzCore/QuestionBank.swift`
- Test: `Tests/MeemawQuizzCoreTests/QuestionBankTests.swift`

**Step 1: Add sponsors, Juste Pif questions, and Jack Attack rounds**
- Add 10 hilarious `MeemawSponsor` items in `QuestionBankExpansion.swift`.
- Add 18 hilarious `QuizJustePifQuestion` items across all themes in `QuestionBankExpansion.swift`.
- Add 6 `QuizJackAttackRound` rounds (each with 5 waves of 4 cycling options) in `QuestionBankExpansion.swift`.
- Update `QuestionBank.buildShowDeck` to also pick 1 `MeemawSponsor` (injecting its `trapChoiceText` into one MCQ question's wrong answer slot), 3 `QuizJustePifQuestion` items, and 1 `QuizJackAttackRound` (5 waves).

---

### Task 3: Host State Machine (`GameSessionController.swift`)

**Files:**
- Modify: `App/GameSessionController.swift`

**Step 1: Wire Sponsor, Le Juste Pif, and Jack Attack into `GameSessionController`**
- Announce the sponsor at the start of the show and reward `+3500` pts when a player picks `q.sponsoredChoiceIndex`.
- Add `.justePif(QuizJustePifQuestion)` (3 questions) and `.jackAttack(QuizJackAttackRound)` (finale) to `ShowPhaseStep` and `phaseQueue`.
- Implement `submitNumericEstimate(_ value: Int)` and `evaluateJustePifAnswers()`.
- Implement `buzzJackAttack()` and the `1.6s` option-cycling timer for `jackAttackActive`.

---

### Task 4: iOS Controller, Apple TV Stage, and Web QR Controller UI

**Files:**
- Modify: `App/PlayerControllerView.swift`
- Modify: `App/MeemawTVStageView.swift`
- Modify: `Sources/MeemawQuizzCore/WebControllerHTML.swift`

**Step 1: Add UI views for Sponsor Banner, Le Juste Pif keypad/reveal, and Jack Attack buzzer**
- Display the Sponsor of the Day badge in the lobby/intro and celebrate Sponsor Jackpots.
- Render a tactile numeric keypad for `.justePifAnswering` and a ranked proximity reveal for `.justePifReveal` on iOS, TV, and Web QR.
- Render the cycling clue + giant red/gold BUZZER for `.jackAttackActive` and `.jackAttackWaveReveal` on iOS, TV, and Web QR.
