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
                let ans = q.choices[q.correctIndex]
                let wrongs = q.choices.enumerated().compactMap { $0.offset == q.correctIndex ? nil : $0.element }
                if ans.contains("!") {
                    XCTAssertFalse(wrongs.allSatisfy { !$0.contains("!") }, "Question \(q.id) must not have '!' only on the correct answer")
                }
                if ans.contains(":") {
                    XCTAssertFalse(wrongs.allSatisfy { !$0.contains(":") }, "Question \(q.id) must not have ':' only on the correct answer")
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

    func testDecadeQuestionsCoverAllThemesAndDecadesAndAdaptShowDeck() {
        let singleThemes: [QuizThemePack] = QuizThemePack.allCases.filter { $0 != .grandMix }
        for theme in singleThemes {
            let qs = QuestionBank.questions(for: theme)
            for decade in QuizDecade.allCases {
                let decadeQs = qs.filter { $0.decade == decade }
                XCTAssertEqual(decadeQs.count, 3, "Theme \(theme.rawValue) should have 3 questions for decade \(decade.rawValue)")
                for dq in decadeQs {
                    XCTAssertNotNil(dq.audioCueID, "Question \(dq.id) must have an audioCueID")
                }
            }
        }

        let deck55Plus = QuestionBank.buildShowDeck(
            for: .grandMix,
            preferredDecades: Set(PlayerAgeBracket.age55Plus.preferredDecades)
        )
        let matchedCount = (deck55Plus.cashQuestions + deck55Plus.ttmcQuestions + deck55Plus.soloQuestions)
            .filter { q in
                guard let dec = q.decade else { return false }
                return PlayerAgeBracket.age55Plus.preferredDecades.contains(dec)
            }
            .count
        XCTAssertGreaterThanOrEqual(matchedCount, 4, "Deck adapted for 55+ should prioritize 60s-80s questions")
    }

    func testEveryQuestionAndStudioCueHasMatchingMP3FileOnDisk() {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let audioDir = repoRoot.appendingPathComponent("App/Resources/MeemawQuizzAudio")
        let fm = FileManager.default

        func assertAudioFileExists(_ baseName: String, context: String) {
            let cleanBase = (baseName as NSString).deletingPathExtension
            let mp3Path = audioDir.appendingPathComponent("\(cleanBase).mp3").path
            let m4aPath = audioDir.appendingPathComponent("\(cleanBase).m4a").path
            XCTAssertTrue(
                fm.fileExists(atPath: mp3Path) || fm.fileExists(atPath: m4aPath),
                "Missing studio audio file '\(cleanBase).mp3' for \(context)"
            )
        }

        for cue in MeemawPunchlines.studioCues {
            assertAudioFileExists(cue.filename, context: "studioCue \(cue.id)")
        }

        for q in QuestionBank.questions(for: .grandMix) {
            let cueID = q.audioCueID ?? "q_\(q.id)"
            assertAudioFileExists(cueID, context: "question prompt \(q.id)")
            assertAudioFileExists("\(cueID)_roast", context: "question roast \(q.id)")
            assertAudioFileExists("\(cueID)_win", context: "question win \(q.id)")
            assertAudioFileExists("\(cueID)_ttmc", context: "question ttmc \(q.id)")
        }

        for dod in QuestionBank.allDisOrDatRounds {
            if let cueID = dod.audioCueID {
                assertAudioFileExists(cueID, context: "Couci-Couça \(dod.id)")
            }
        }
    }
}
