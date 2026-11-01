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
}
