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
                    if round.optionBoth != nil {
                        XCTAssertTrue(item.correctSide == "left" || item.correctSide == "right" || item.correctSide == "both")
                    } else {
                        XCTAssertTrue(item.correctSide == "left" || item.correctSide == "right")
                    }
                }
            }
        }
    }

    func testBuildShowDeckProducesBalancedFiveRoundShow() {
        let deck = QuestionBank.buildShowDeck(for: .grandMix)
        XCTAssertEqual(deck.cashQuestions.count, 3)
        XCTAssertEqual(deck.soloQuestions.count, 2)
        XCTAssertEqual(deck.finaleDoubleQuestions.count, 2)
        XCTAssertFalse(deck.couciCoucaRound.isPunRound)
        XCTAssertTrue(deck.quoizziPunRound.isPunRound)
        XCTAssertEqual(QuestionBank.questions(for: .grandMix).count, 112)
        XCTAssertEqual(QuestionBank.allDisOrDatRounds.count, 20)
    }

    func testWholeEveningSessionNeverRepeatsQuestionsAcrossTwelveConsecutiveGames() {
        var usedMCQs: Set<String> = []
        var usedCouci: Set<String> = []

        for _ in 0..<12 {
            let deck = QuestionBank.buildShowDeck(
                for: .grandMix,
                excludingQuestionIDs: usedMCQs,
                excludingDisOrDatIDs: usedCouci
            )
            for qid in deck.allMCQIDs {
                XCTAssertFalse(usedMCQs.contains(qid), "Question \(qid) should not repeat during an evening session")
                usedMCQs.insert(qid)
            }
            XCTAssertFalse(usedCouci.contains(deck.couciCoucaRound.id), "Couci-Couça \(deck.couciCoucaRound.id) should not repeat")
            usedCouci.insert(deck.couciCoucaRound.id)
        }
        XCTAssertEqual(usedMCQs.count, 84) // 12 games * 7 MCQs
        XCTAssertEqual(usedCouci.count, 12) // 12 games * 1 Couci-Couça round
    }
}
