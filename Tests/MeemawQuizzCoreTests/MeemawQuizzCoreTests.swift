import XCTest
@testable import MeemawQuizzCore

final class MeemawQuizzCoreTests: XCTestCase {

    func testPlayerColorAllocationLocksAndReleasesUniquely() {
        var registry = PlayerLobbyRegistry()
        let p1 = registry.upsertPlayer(id: "p1", name: "Xabi", requestedColor: .meemawOrange, avatarEmoji: "🦊", isHost: true)
        XCTAssertEqual(p1.color, .meemawOrange)
        XCTAssertFalse(registry.availableColors(excludingPlayerID: nil).contains(.meemawOrange))

        // Second player requesting an already taken color gets assigned the first free color
        let p2 = registry.upsertPlayer(id: "p2", name: "Léa", requestedColor: .meemawOrange, avatarEmoji: "🐱", isHost: false)
        XCTAssertNotEqual(p2.color, .meemawOrange)
        XCTAssertEqual(p2.color, .electricBlue)

        // When p1 changes color to mintGreen, meemawOrange becomes free again
        let updatedP1 = registry.upsertPlayer(id: "p1", name: "Xabi", requestedColor: .mintGreen, avatarEmoji: "🦊", isHost: true)
        XCTAssertEqual(updatedP1.color, .mintGreen)
        XCTAssertTrue(registry.availableColors(excludingPlayerID: nil).contains(.meemawOrange))
    }

    func testCashSpeedScoringRewardsFastestAndPenalizesWrong() {
        // Question worth 2000 pts
        // Fastest correct answer (1st place, 1.8s out of 12s)
        let firstScore = QuizScoringEngine.scoreCashAnswer(
            baseValue: 2000,
            isCorrect: true,
            correctRankIndex: 0,
            reactionTimeMs: 1800,
            totalTimeMs: 12000,
            isDoubleFinale: false
        )
        // Base 2000 + speed bonus (> 400)
        XCTAssertGreaterThan(firstScore, 2400)

        // Second correct answer (2nd place, 5.0s out of 12s) gets less than first
        let secondScore = QuizScoringEngine.scoreCashAnswer(
            baseValue: 2000,
            isCorrect: true,
            correctRankIndex: 1,
            reactionTimeMs: 5000,
            totalTimeMs: 12000,
            isDoubleFinale: false
        )
        XCTAssertGreaterThan(secondScore, 1000)
        XCTAssertLessThan(secondScore, firstScore)

        // Wrong answer loses 50% of base value (-1000)
        let wrongScore = QuizScoringEngine.scoreCashAnswer(
            baseValue: 2000,
            isCorrect: false,
            correctRankIndex: nil,
            reactionTimeMs: 3000,
            totalTimeMs: 12000,
            isDoubleFinale: false
        )
        XCTAssertEqual(wrongScore, -1000)
    }

    func testSoloBuzzerScoringDoublesWinAndPenalizesLoss() {
        let soloWin = QuizScoringEngine.scoreSoloAnswer(baseValue: 2000, isCorrect: true)
        XCTAssertEqual(soloWin, 4000)

        let soloLoss = QuizScoringEngine.scoreSoloAnswer(baseValue: 2000, isCorrect: false)
        XCTAssertEqual(soloLoss, -2000)
    }

    func testDisOrDatScoringWithStreakBonus() {
        let right1 = QuizScoringEngine.scoreDisOrDatAnswer(valuePerItem: 500, isCorrect: true, currentStreak: 1)
        XCTAssertEqual(right1, 500)

        let rightStreak3 = QuizScoringEngine.scoreDisOrDatAnswer(valuePerItem: 500, isCorrect: true, currentStreak: 3)
        XCTAssertEqual(rightStreak3, 700) // +200 streak bonus at 3+

        let wrong = QuizScoringEngine.scoreDisOrDatAnswer(valuePerItem: 500, isCorrect: false, currentStreak: 0)
        XCTAssertEqual(wrong, -250)
    }

    func testDrawingBankScrambledTilesContainsAllWordLetters() {
        let options = DrawingBank.pickThreeWordOptions()
        XCTAssertEqual(options.count, 3)
        XCTAssertEqual(options.map(\.stars), [1, 2, 3])

        for opt in options {
            var remainingTiles = opt.scrambledTiles
            for ch in opt.word {
                let s = String(ch)
                if let idx = remainingTiles.firstIndex(of: s) {
                    remainingTiles.remove(at: idx)
                } else {
                    XCTFail("Missing letter \(s) in scrambledTiles for \(opt.word)")
                }
            }
            XCTAssertGreaterThanOrEqual(opt.scrambledTiles.count, 12)
        }
    }

    func testDrawSomethingScoringRewardsGuesserAndArtist() {
        let g1 = QuizScoringEngine.scoreDrawGuesser(wordPoints: 2000, rankIndex: 0, reactionTimeMs: 5000, totalTimeMs: 45000)
        let g2 = QuizScoringEngine.scoreDrawGuesser(wordPoints: 2000, rankIndex: 1, reactionTimeMs: 12000, totalTimeMs: 45000)
        let gWith2Hints = QuizScoringEngine.scoreDrawGuesser(wordPoints: 2000, rankIndex: 0, reactionTimeMs: 5000, totalTimeMs: 45000, hintsUsed: 2)
        XCTAssertGreaterThan(g1, 2300)
        XCTAssertGreaterThan(g1, g2)
        XCTAssertEqual(gWith2Hints, g1 - (2 * QuizScoringEngine.drawHintPenaltyPoints))

        let artistScore = QuizScoringEngine.scoreDrawArtist(wordPoints: 2000, foundCount: 2)
        XCTAssertEqual(artistScore, 2000)
        XCTAssertEqual(DrawingCanvasData.portraitAspectRatio, 0.75, accuracy: 0.001)

        let stickmanStrokes = DrawingBank.makeShapeStrokes(
            tool: .stickman,
            start: NormalizedPoint(x: 0.2, y: 0.2),
            end: NormalizedPoint(x: 0.6, y: 0.8),
            colorHex: "#111827",
            lineWidth: 7.5
        )
        XCTAssertEqual(stickmanStrokes.count, 4)
        XCTAssertEqual(DrawingBank.pickThreeEsquissePrompts().count, 3)

        // Ensure every Esquissé prompt and QCM confusion suggestion is strictly 1 single word (no spaces!)
        for word in DrawingBank.esquisseStarterPrompts {
            XCTAssertFalse(word.contains(" "), "Esquissé prompt must be a single word: \(word)")
            let choices = DrawingBank.quickGuessSuggestions(from: word)
            XCTAssertEqual(choices.count, 4)
            for choice in choices {
                XCTAssertFalse(choice.contains(" "), "Esquissé choice must be a single word: \(choice)")
            }
        }
    }

    func testEnglishQuestionBankAndMechanicsAreComplete() {
        XCTAssertGreaterThanOrEqual(QuestionBank.allEnglishQuestions.count, 40)
        XCTAssertGreaterThanOrEqual(QuestionBank.englishDisOrDatRounds.count, 4)
        XCTAssertGreaterThanOrEqual(QuestionBank.englishSponsors.count, 4)
        XCTAssertGreaterThanOrEqual(QuestionBank.englishJustePifQuestions.count, 6)
        XCTAssertGreaterThanOrEqual(QuestionBank.englishJackAttackRounds.count, 2)
        XCTAssertEqual(DrawingBank.englishEsquisseStarterPrompts.count, 30)

        for q in QuestionBank.allEnglishQuestions {
            XCTAssertEqual(q.choices.count, 4, "Question \(q.id) must have 4 choices")
            XCTAssertTrue((0..<4).contains(q.correctIndex))
            XCTAssertNotNil(q.audioCueID)
        }
    }
}
