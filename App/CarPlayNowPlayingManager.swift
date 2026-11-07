import Foundation
import MediaPlayer
import MeemawQuizzCore
import Observation
import UIKit

/// Diffuse le plateau MeemawQuizz en direct sur l'écran « À l'écoute » (Now Playing) de CarPlay
/// et du tableau de bord de la voiture via `MPNowPlayingInfoCenter` + commandes au volant `MPRemoteCommandCenter`.
@Observable
@MainActor
final class CarPlayNowPlayingManager {
    static let shared = CarPlayNowPlayingManager()

    private(set) var latestArtworkImage: UIImage?
    private(set) var latestTitle: String = "👵 Meemaw Quizz • Mode Voiture"
    private(set) var latestSubtitle: String = "Branche CarPlay et ouvre l'écran « À l'écoute » !"
    private(set) var latestScoreboardLine: String = "🎙️ Salon prêt"

    var onNextStepCommand: (() -> Void)?
    var onPlayOrReplayCommand: (() -> Void)?

    private var lastArtworkRenderKey: String = ""
    private var commandsConfigured = false

    private init() {}

    func configureRemoteCommandsIfNeeded() {
        guard !commandsConfigured else { return }
        commandsConfigured = true
        Self.installRemoteCommandHandlers()
    }

    nonisolated private static func installRemoteCommandHandlers() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.playCommand.addTarget { _ in
            Task { @MainActor in
                CarPlayNowPlayingManager.shared.onPlayOrReplayCommand?()
            }
            return .success
        }

        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget { _ in
            Task { @MainActor in
                CarPlayNowPlayingManager.shared.onPlayOrReplayCommand?()
            }
            return .success
        }

        center.togglePlayPauseCommand.isEnabled = true
        center.togglePlayPauseCommand.addTarget { _ in
            Task { @MainActor in
                CarPlayNowPlayingManager.shared.onPlayOrReplayCommand?()
            }
            return .success
        }

        center.nextTrackCommand.isEnabled = true
        center.nextTrackCommand.addTarget { _ in
            Task { @MainActor in
                CarPlayNowPlayingManager.shared.onNextStepCommand?()
            }
            return .success
        }

        center.previousTrackCommand.isEnabled = true
        center.previousTrackCommand.addTarget { _ in
            Task { @MainActor in
                CarPlayNowPlayingManager.shared.onPlayOrReplayCommand?()
            }
            return .success
        }
    }

    nonisolated private static func makeArtwork(from image: UIImage, size: CGSize) -> MPMediaItemArtwork {
        nonisolated(unsafe) let safeImage = image
        return MPMediaItemArtwork(boundsSize: size) { _ in
            safeImage
        }
    }

    func update(with snap: HostToClientStateSnapshot) {
        configureRemoteCommandsIfNeeded()

        let (title, subtitle, albumLine) = buildMetadataStrings(for: snap)
        latestTitle = title
        latestSubtitle = subtitle
        latestScoreboardLine = albumLine

        let answeredCount = snap.players.filter { $0.lockedChoiceIndex != nil || $0.lockedSide != nil || $0.lockedBetStars != nil || $0.lockedNumericEstimate != nil }.count
        let renderKey = [
            snap.stage.rawValue,
            snap.roundKind.rawValue,
            snap.activeQuestion?.id ?? "",
            snap.activeJustePif?.id ?? "",
            snap.activeDisOrDat?.id ?? "",
            "\(snap.activeDisOrDatItemIndex ?? -1)",
            "\(snap.revealedCorrectIndex ?? -1)",
            snap.revealedBinarySide ?? "",
            "\(answeredCount)",
            "\(snap.players.count)",
            snap.selectedPack.rawValue,
            snap.selectedGameMode.rawValue
        ].joined(separator: "|")

        if renderKey != lastArtworkRenderKey || latestArtworkImage == nil {
            lastArtworkRenderKey = renderKey
            latestArtworkImage = renderCarPlayCardImage(for: snap, title: title, subtitle: subtitle, scoreboard: albumLine)
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: subtitle,
            MPMediaItemPropertyAlbumTitle: albumLine,
            MPNowPlayingInfoPropertyIsLiveStream: false,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPMediaItemPropertyPlaybackDuration: max(15.0, snap.timeRemainingSec > 0 ? 15.0 : 30.0),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: max(0.0, 15.0 - snap.timeRemainingSec)
        ]

        if let img = latestArtworkImage {
            info[MPMediaItemPropertyArtwork] = Self.makeArtwork(from: img, size: img.size)
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }

    private func buildMetadataStrings(for snap: HostToClientStateSnapshot) -> (title: String, subtitle: String, album: String) {
        let ranked = snap.players.sorted { $0.score > $1.score }
        let medals = ["🥇", "🥈", "🥉"]
        let scoreSummary: String
        if ranked.isEmpty {
            scoreSummary = "👵 Meemaw Quizz Show"
        } else {
            let top = ranked.prefix(3).enumerated().map { idx, p in
                "\(medals[idx]) \(p.name) \(p.score) pts"
            }.joined(separator: " • ")
            scoreSummary = "\(top) • \(snap.roundKind.badgeTitle)"
        }

        switch snap.stage {
        case .lobby:
            let t = "👵 Salon Meemaw Quizz (\(snap.players.count) joueur\(snap.players.count > 1 ? "s" : ""))"
            let s = "Thème : \(snap.selectedPack.shortBadge) • Appuie sur ⏭️ au volant pour lancer !"
            return (t, s, "🚗 Mode Voiture / CarPlay • Ouvrez « À l'écoute »")

        case .roundIntro:
            return (
                snap.roundKind.badgeTitle,
                snap.roundKind.ruleSummary,
                scoreSummary
            )

        case .ttmcBetting:
            if let q = snap.activeQuestion {
                let decTag = q.decade.map { " (\($0.shortTag))" } ?? ""
                return (
                    "🎯 Mise 1 à 4 ⭐ : « \(q.funnyTitle) »\(decTag)",
                    "⭐ +1000 • ⭐⭐ +2000 • ⭐⭐⭐ +3500 • ⭐⭐⭐⭐ +5000 pts",
                    scoreSummary
                )
            }

        case .questionReading, .cashAnswering, .soloBuzzOpen, .soloPlayerAnswering:
            if let q = snap.activeQuestion {
                let letters = ["A", "B", "C", "D"]
                let choicesLine = q.choices.enumerated().map { idx, c in
                    "\(letters[idx])) \(c)"
                }.joined(separator: " • ")
                let decTag = q.decade.map { "[\($0.shortTag)] " } ?? ""
                return (
                    "Q\(snap.questionNumber)/\(snap.totalQuestions) • \(decTag)\(q.prompt)",
                    choicesLine,
                    scoreSummary
                )
            }

        case .questionReveal:
            if let q = snap.activeQuestion {
                let letters = ["A", "B", "C", "D"]
                let ans = q.choices[q.correctIndex]
                return (
                    "✅ RÉPONSE \(letters[q.correctIndex]) : \(ans)",
                    q.explanation.replacingOccurrences(of: "💡 ", with: ""),
                    scoreSummary
                )
            }

        case .justePifAnswering:
            if let pif = snap.activeJustePif {
                return (
                    "🔢 Juste Pif : \(pif.prompt)",
                    "Unité : \(pif.unitLabel) • Tape ton estimation sur ton iPhone !",
                    scoreSummary
                )
            }

        case .justePifReveal:
            if let pif = snap.activeJustePif {
                return (
                    "🎯 VRAIE VALEUR : \(pif.correctValue) \(pif.unitLabel)",
                    pif.meemawComment,
                    scoreSummary
                )
            }

        case .couciCoucaIntro, .couciCoucaItem, .couciCoucaReveal, .couciCoucaSummary:
            if let round = snap.activeDisOrDat {
                let idx = snap.activeDisOrDatItemIndex ?? 0
                if snap.stage == .couciCoucaReveal, let side = snap.revealedBinarySide {
                    let label: String
                    if side == "left" { label = round.optionLeft }
                    else if side == "right" { label = round.optionRight }
                    else { label = round.optionBoth ?? "🧀 LES DEUX !" }
                    return (
                        "✅ RÉPONSE : \(label)",
                        round.items.indices.contains(idx) ? round.items[idx].text : round.funnyTitle,
                        scoreSummary
                    )
                }
                if round.items.indices.contains(idx) {
                    let item = round.items[idx]
                    let opts = "⬅️ \(round.optionLeft) • ➡️ \(round.optionRight)" + (round.optionBoth != nil ? " • 🧀 Les Deux" : "")
                    return (
                        "🧀 [\(idx + 1)/\(round.items.count)] \(item.text)",
                        opts,
                        scoreSummary
                    )
                }
            }

        case .finalPodium:
            let winner = ranked.first
            let winTitle = winner.map { "🏆 VICTOIRE DE \($0.name.uppercased()) (\($0.score) PTS) !" } ?? "🏆 FIN DE LA PARTIE !"
            return (
                winTitle,
                "Appuie sur ⏭️ au volant pour relancer une partie !",
                scoreSummary
            )

        default:
            break
        }

        return (
            "👵 Meemaw Quizz • \(snap.roundKind.badgeTitle)",
            snap.meemawSpeech,
            scoreSummary
        )
    }

    /// Génère une carte Pop-Art 640×640 ultra-lisible qui s'affiche comme pochette dans l'écran « À l'écoute » de CarPlay.
    private func renderCarPlayCardImage(
        for snap: HostToClientStateSnapshot,
        title: String,
        subtitle: String,
        scoreboard: String
    ) -> UIImage {
        let size = CGSize(width: 640, height: 640)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let cg = ctx.cgContext

            // 1. Cream Pop-Art background
            UIColor(red: 1.0, green: 0.97, blue: 0.94, alpha: 1.0).setFill()
            cg.fill(CGRect(origin: .zero, size: size))

            let ink = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)
            let orange = UIColor(red: 1.0, green: 0.55, blue: 0.26, alpha: 1.0)
            let yellow = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            let green = UIColor(red: 0.06, green: 0.72, blue: 0.51, alpha: 1.0)
            let pink = UIColor(red: 0.93, green: 0.28, blue: 0.60, alpha: 1.0)

            // Outer frame
            let outerRect = CGRect(x: 12, y: 12, width: 616, height: 616)
            let outerPath = UIBezierPath(roundedRect: outerRect, cornerRadius: 34)
            ink.setStroke()
            outerPath.lineWidth = 8
            outerPath.stroke()

            // 2. Top Header Banner
            let headerRect = CGRect(x: 26, y: 26, width: 588, height: 68)
            let headerPath = UIBezierPath(roundedRect: headerRect, cornerRadius: 20)
            orange.setFill()
            headerPath.fill()
            ink.setStroke()
            headerPath.lineWidth = 5
            headerPath.stroke()

            let headerText = snap.stage == .lobby
                ? "🚗 MEEMAW QUIZZ • CARPLAY"
                : "👵 Q\(max(1, snap.questionNumber))/\(max(1, snap.totalQuestions)) • \(snap.roundKind.badgeTitle)"
            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .black),
                .foregroundColor: UIColor.white
            ]
            (headerText as NSString).draw(
                in: CGRect(x: 42, y: 44, width: 556, height: 34),
                withAttributes: headerAttrs
            )

            // 3. Center Question Card
            let qCardRect = CGRect(x: 26, y: 108, width: 588, height: 196)
            let qCardPath = UIBezierPath(roundedRect: qCardRect, cornerRadius: 24)
            let isReveal = (snap.stage == .questionReveal || snap.stage == .justePifReveal || snap.stage == .couciCoucaReveal)
            (isReveal ? green : UIColor.white).setFill()
            qCardPath.fill()
            ink.setStroke()
            qCardPath.lineWidth = 5
            qCardPath.stroke()

            if let dec = snap.activeQuestion?.decade {
                let badgeRect = CGRect(x: 44, y: 120, width: 170, height: 30)
                let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: 15)
                pink.setFill()
                badgePath.fill()
                let decAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .black),
                    .foregroundColor: UIColor.white
                ]
                (dec.badgeLabel as NSString).draw(in: CGRect(x: 54, y: 125, width: 155, height: 22), withAttributes: decAttrs)
            }

            let para = NSMutableParagraphStyle()
            para.alignment = .center
            para.lineBreakMode = .byWordWrapping

            let promptText: String
            if let q = snap.activeQuestion {
                promptText = snap.stage == .ttmcBetting ? "🎯 « \(q.funnyTitle) »" : q.prompt
            } else {
                promptText = title
            }

            let promptFontSize: CGFloat = promptText.count > 110 ? 22 : (promptText.count > 75 ? 25 : 29)
            let promptAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: promptFontSize, weight: .black),
                .foregroundColor: isReveal ? UIColor.white : ink,
                .paragraphStyle: para
            ]
            let promptY: CGFloat = snap.activeQuestion?.decade != nil ? 154 : 128
            (promptText as NSString).draw(
                in: CGRect(x: 42, y: promptY, width: 556, height: 140),
                withAttributes: promptAttrs
            )

            // 4. 2x2 Choices Grid (or Subtitle Card)
            if let q = snap.activeQuestion, snap.stage != .ttmcBetting {
                let letters = ["A", "B", "C", "D"]
                let colW: CGFloat = 286
                let rowH: CGFloat = 96
                for idx in 0..<min(4, q.choices.count) {
                    let col = idx % 2
                    let row = idx / 2
                    let x = 26 + CGFloat(col) * (colW + 16)
                    let y = 318 + CGFloat(row) * (rowH + 12)
                    let rect = CGRect(x: x, y: y, width: colW, height: rowH)
                    let path = UIBezierPath(roundedRect: rect, cornerRadius: 18)

                    let isCorrect = (snap.stage == .questionReveal && snap.revealedCorrectIndex == idx)
                    (isCorrect ? green : yellow).setFill()
                    path.fill()
                    ink.setStroke()
                    path.lineWidth = 4
                    path.stroke()

                    let choiceStr = "\(letters[idx]). \(q.choices[idx])"
                    let cFontSize: CGFloat = choiceStr.count > 28 ? 18 : 21
                    let cAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: cFontSize, weight: .black),
                        .foregroundColor: isCorrect ? UIColor.white : ink
                    ]
                    (choiceStr as NSString).draw(
                        in: rect.insetBy(dx: 14, dy: 14),
                        withAttributes: cAttrs
                    )
                }
            } else {
                let subRect = CGRect(x: 26, y: 318, width: 588, height: 204)
                let subPath = UIBezierPath(roundedRect: subRect, cornerRadius: 22)
                yellow.setFill()
                subPath.fill()
                ink.setStroke()
                subPath.lineWidth = 4.5
                subPath.stroke()

                let subAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 25, weight: .heavy),
                    .foregroundColor: ink,
                    .paragraphStyle: para
                ]
                (subtitle as NSString).draw(
                    in: subRect.insetBy(dx: 22, dy: 28),
                    withAttributes: subAttrs
                )
            }

            // 5. Bottom Scoreboard Bar (+ Meemaw icon)
            let footRect = CGRect(x: 26, y: 538, width: 588, height: 74)
            let footPath = UIBezierPath(roundedRect: footRect, cornerRadius: 18)
            ink.setFill()
            footPath.fill()

            if let meemawImg = UIImage(named: snap.meemawPose) ?? UIImage(named: "meemaw_salut") {
                meemawImg.draw(in: CGRect(x: 36, y: 543, width: 64, height: 64))
            }

            let footAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .black),
                .foregroundColor: yellow
            ]
            (scoreboard as NSString).draw(
                in: CGRect(x: 110, y: 552, width: 490, height: 48),
                withAttributes: footAttrs
            )
        }
    }
}
