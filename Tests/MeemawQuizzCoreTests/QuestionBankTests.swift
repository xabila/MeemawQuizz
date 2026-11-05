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
                for choice in q.choices {
                    XCTAssertFalse(choice.contains("(") || choice.contains(")"), "Choice '\(choice)' in \(q.id) must not contain parenthetical hints")
                }
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
                    XCTAssertFalse(item.text.contains("(") || item.text.contains(")"), "DisOrDat item '\(item.text)' in \(round.id) must not contain parenthetical hints")
                    if round.optionBoth != nil {
                        XCTAssertTrue(item.correctSide == "left" || item.correctSide == "right" || item.correctSide == "both")
                    } else {
                        XCTAssertTrue(item.correctSide == "left" || item.correctSide == "right")
                    }
                }
            }
        }
    }

    func testBuildShowDeckProducesBalancedFourRoundShow() {
        let deck = QuestionBank.buildShowDeck(for: .grandMix)
        XCTAssertEqual(deck.cashQuestions.count, 3)
        XCTAssertEqual(deck.ttmcQuestions.count, 3)
        XCTAssertEqual(deck.jukeboxQuestions.count, 3)
        XCTAssertEqual(deck.justePifQuestions.count, 3)
        XCTAssertEqual(deck.soloQuestions.count, 3)
        XCTAssertEqual(deck.finaleDoubleQuestions.count, 3)
        XCTAssertEqual(deck.jackAttackRound.waves.count, 5)
        XCTAssertNotNil(deck.cashQuestions[1].sponsoredChoiceIndex)
        XCTAssertNotEqual(deck.cashQuestions[1].sponsoredChoiceIndex, deck.cashQuestions[1].correctIndex)
        XCTAssertFalse(deck.couciCoucaRound.isPunRound)
        XCTAssertGreaterThanOrEqual(QuestionBank.questions(for: .grandMix).count, 210)
        XCTAssertGreaterThanOrEqual(QuestionBank.combinedDisOrDatRounds.count, 26)
    }

    func testYDKJNewMechanicsScoring() {
        let pifScores = QuizScoringEngine.scoreJustePifEstimates(
            correctValue: 100,
            estimatesByPlayerID: ["p1": 100, "p2": 95, "p3": 200]
        )
        XCTAssertEqual(pifScores["p1"], 5000) // Tout pile
        XCTAssertEqual(pifScores["p2"], 1500) // 2e plus proche
        XCTAssertEqual(pifScores["p3"], -500) // Pif cassé (le plus loin)

        XCTAssertEqual(QuizScoringEngine.scoreJackAttackBuzz(isCorrect: true), 3000)
        XCTAssertEqual(QuizScoringEngine.scoreJackAttackBuzz(isCorrect: false), -1500)
        XCTAssertEqual(QuizScoringEngine.sponsorJackpotPoints, 3500)
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
        XCTAssertEqual(usedMCQs.count, 108) // 12 games * 9 core MCQs
        XCTAssertEqual(usedCouci.count, 12) // 12 games * 1 Couci-Couça round
    }
}
