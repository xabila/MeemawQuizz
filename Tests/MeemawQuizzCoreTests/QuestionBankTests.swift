import XCTest
@testable import MeemawQuizzCore

final class QuestionBankTests: XCTestCase {

    func testEveryThemePackHasValidMCQAndDisOrDatQuestions() {
        for pack in QuizThemePack.allCases {
            let mcqs = QuestionBank.questions(for: pack)
            XCTAssertGreaterThanOrEqual(mcqs.count, 6, "Pack \(pack.rawValue) should have at least 6 MCQ questions")

            for q in mcqs {
                XCTAssertEqual(q.choices.count, 4, "Question \(q.id) must have 4 choices")
                XCTAssertTrue((0..<4).contains(q.correctIndex), "Question \(q.id) must have valid correctIndex")
                XCTAssertFalse(q.funnyTitle.isEmpty)
                XCTAssertFalse(q.prompt.isEmpty)
                XCTAssertFalse(q.meemawRoastOnWrong.isEmpty)
                XCTAssertFalse(q.explanation.isEmpty)
            }

            let rounds = QuestionBank.disOrDatRounds(for: pack)
            XCTAssertGreaterThanOrEqual(rounds.count, 1, "Pack \(pack.rawValue) should have at least 1 DisOrDat round")
            for round in rounds {
                XCTAssertEqual(round.items.count, 6, "DisOrDat round \(round.id) must have 6 items")
                for item in round.items {
                    XCTAssertTrue(item.correctSide == "left" || item.correctSide == "right")
                }
            }
        }
    }

    func testBuildShowDeckProducesBalancedFourRoundShow() {
        let deck = QuestionBank.buildShowDeck(for: .grandMix)
        XCTAssertEqual(deck.cashQuestions.count, 3)
        XCTAssertEqual(deck.soloQuestions.count, 2)
        XCTAssertEqual(deck.finaleDoubleQuestions.count, 2)
        XCTAssertNotNil(deck.couciCoucaRound)
    }
}
