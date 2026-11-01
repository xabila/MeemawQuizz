import MeemawQuizzCore
import SwiftUI

/// Plateau TV Géant 16:9 projeté sur AirPlay / Apple TV :
/// - En-tête Show TV avec manche, thème et compte à rebours géant.
/// - Meemaw en Guest Star avec sa bulle de BD dynamique.
/// - Lobby avec QR Code Android + Auto-Bonjour iOS, Plateau QCM Géant, Alerte Sirène « LE SOLO », Arène Binaire « Couci-Couça » et Podium Final.
/// - Dock des joueurs en bas de l'écran avec leurs couleurs Pop-Art, scores et indicateurs de verrouillage en direct.
struct MeemawTVStageView: View {
    var session: GameSessionController

    private var snap: HostToClientStateSnapshot {
        session.effectiveSnapshot
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let scale = min(w / 1280.0, h / 720.0)

            ZStack {
                PopArtTVBackground(roundKind: snap.roundKind)

                VStack(spacing: 14 * scale) {
                    tvTopHeaderBar(scale: scale)

                    meemawPresenterBanner(scale: scale)

                    ZStack {
                        switch snap.stage {
                        case .lobby:
                            tvLobbyStage(scale: scale)
                        case .roundIntro:
                            tvRoundIntroStage(scale: scale)
                        case .questionReading, .cashAnswering, .soloBuzzOpen, .soloPlayerAnswering, .questionReveal:
                            if let question = snap.activeQuestion {
                                tvMCQQuestionStage(question: question, scale: scale)
                            }
                        case .couciCoucaIntro, .couciCoucaItem, .couciCoucaReveal, .couciCoucaSummary:
                            if let round = snap.activeDisOrDat {
                                tvCouciCoucaStage(round: round, scale: scale)
                            }
                        case .finalPodium:
                            tvFinalPodiumStage(scale: scale)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    tvBottomPlayersDock(scale: scale)
                }
                .padding(.horizontal, 28 * scale)
                .padding(.vertical, 20 * scale)
            }
        }
    }

    // MARK: - 1. Top TV Show Header Bar

    private func tvTopHeaderBar(scale: CGFloat) -> some View {
        HStack(spacing: 14 * scale) {
            HStack(spacing: 10 * scale) {
                Text("👵📺")
                    .font(.system(size: 28 * scale))
                Text("MEEMAW QUIZZ SHOW")
                    .font(.system(size: 24 * scale, weight: .black, design: .rounded))
                    .foregroundStyle(PopArt.ink)
            }
            .padding(.horizontal, 18 * scale)
            .padding(.vertical, 10 * scale)
            .background(PopArt.orange, in: Capsule())
            .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 3.5))

            Text(snap.selectedPack.shortBadge)
                .font(.system(size: 17 * scale, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16 * scale)
                .padding(.vertical, 9 * scale)
                .background(Color(hex: snap.selectedPack.accentHex), in: Capsule())
                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 3))

            if snap.stage != .lobby {
                Text(snap.roundKind.badgeTitle)
                    .font(.system(size: 17 * scale, weight: .black, design: .rounded))
                    .foregroundStyle(PopArt.ink)
                    .padding(.horizontal, 16 * scale)
                    .padding(.vertical, 9 * scale)
                    .background(PopArt.yellow, in: Capsule())
                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 3))
            }

            Spacer()

            if snap.timeRemainingSec > 0 && (snap.stage == .cashAnswering || snap.stage == .soloBuzzOpen || snap.stage == .soloPlayerAnswering || snap.stage == .couciCoucaItem) {
                HStack(spacing: 8 * scale) {
                    Image(systemName: "timer")
                        .font(.system(size: 20 * scale, weight: .black))
                    Text(String(format: "%.1fs", snap.timeRemainingSec))
                        .font(.system(size: 24 * scale, weight: .black, design: .monospaced))
                }
                .foregroundStyle(snap.timeRemainingSec <= 3.5 ? .white : PopArt.ink)
                .padding(.horizontal, 18 * scale)
                .padding(.vertical, 8 * scale)
                .background(snap.timeRemainingSec <= 3.5 ? PopArt.redError : PopArt.white, in: Capsule())
                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 3.5))
            }

            if snap.questionNumber > 0 && snap.stage != .finalPodium {
                Text("Q\(snap.questionNumber)/\(snap.totalQuestions)")
                    .font(.system(size: 19 * scale, weight: .black, design: .rounded))
                    .foregroundStyle(PopArt.ink)
                    .padding(.horizontal, 14 * scale)
                    .padding(.vertical, 9 * scale)
                    .background(PopArt.white, in: Capsule())
                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 3))
            }
        }
    }

    // MARK: - 2. Meemaw Guest Star Speech Bubble Banner

    private func meemawPresenterBanner(scale: CGFloat) -> some View {
        HStack(spacing: 18 * scale) {
            MeemawGuestStarAvatar(
                pose: snap.meemawPose,
                isSpeaking: MeemawShowAudioEngine.shared.isMeemawSpeaking,
                size: 104 * scale
            )

            PopArtCard(
                cornerRadius: 22 * scale,
                borderWidth: 3.5,
                backgroundColor: PopArt.white,
                shadowOffset: 5 * scale
            ) {
                HStack(spacing: 14 * scale) {
                    VStack(alignment: .leading, spacing: 4 * scale) {
                        Text("🎙️ MEEMAW EN DIRECT")
                            .font(.system(size: 13 * scale, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.orange)
                        Text(snap.meemawSpeech)
                            .font(.system(size: 21 * scale, weight: .heavy, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20 * scale)
                .padding(.vertical, 14 * scale)
            }
        }
    }

    // MARK: - 3A. Lobby Stage (iOS Bonjour Auto-Connect + Android QR Code)

    private func tvLobbyStage(scale: CGFloat) -> some View {
        HStack(spacing: 22 * scale) {
            // Left: Selected Theme & Game Rounds Preview
            PopArtCard(
                cornerRadius: 26 * scale,
                borderWidth: 4,
                backgroundColor: PopArt.white,
                shadowOffset: 7 * scale
            ) {
                VStack(alignment: .leading, spacing: 14 * scale) {
                    Text("🎯 AU PROGRAMME CE SOIR")
                        .font(.system(size: 16 * scale, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.orange)

                    Text(snap.selectedPack.title)
                        .font(.system(size: 32 * scale, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.ink)

                    Text(snap.selectedPack.subtitle)
                        .font(.system(size: 18 * scale, weight: .bold, design: .rounded))
                        .foregroundStyle(PopArt.ink.opacity(0.72))

                    Divider()

                    VStack(alignment: .leading, spacing: 8 * scale) {
                        lobbyRoundRow(badge: "MANCHE 1", title: "⚡ Cash Rapide (Tout le monde répond + Bisou Piège)", scale: scale)
                        lobbyRoundRow(badge: "MANCHE 2", title: "🚨 LE SOLO (Le 1er qui répond gagne le DOUBLE ou perd tout !)", scale: scale)
                        lobbyRoundRow(badge: "MANCHE 3", title: "🧀 La Raclette Quizz (Gauche, Droite, ou LES DEUX !)", scale: scale)
                        lobbyRoundRow(badge: "MANCHE 4", title: "🤪 Le Quoizzi-Quoissa (Spécial Jeux de Mots & Calembours)", scale: scale)
                        lobbyRoundRow(badge: "MANCHE 5", title: "🔥 La Rafale Finale (Tous les points ×2 + Podium)", scale: scale)
                    }

                    Spacer()
                }
                .padding(24 * scale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Right: Auto-Bonjour iOS + QR Code Android
            PopArtCard(
                cornerRadius: 26 * scale,
                borderWidth: 4,
                backgroundColor: Color(hex: "#FFF9E6"),
                shadowOffset: 7 * scale
            ) {
                HStack(spacing: 20 * scale) {
                    if let qrImage = GameSessionController.makeQRCodeImage(from: snap.joinURL) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 195 * scale, height: 195 * scale)
                            .padding(12 * scale)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 18 * scale))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18 * scale)
                                    .strokeBorder(PopArt.ink, lineWidth: 3.5)
                            )
                    }

                    VStack(alignment: .leading, spacing: 12 * scale) {
                        Text("📲 REJOINS LA PARTIE !")
                            .font(.system(size: 24 * scale, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)

                        HStack(spacing: 8 * scale) {
                            Text("🍏 iPhone / iPad :")
                                .font(.system(size: 16 * scale, weight: .black))
                            Text("Connexion Bonjour Automatique !")
                                .font(.system(size: 16 * scale, weight: .bold))
                                .foregroundStyle(PopArt.blue)
                        }

                        HStack(spacing: 8 * scale) {
                            Text("🤖 Android / Web :")
                                .font(.system(size: 16 * scale, weight: .black))
                            Text("Scanne le QR Code à l'écran !")
                                .font(.system(size: 16 * scale, weight: .bold))
                                .foregroundStyle(PopArt.greenSuccess)
                        }

                        Text(snap.joinURL)
                            .font(.system(size: 18 * scale, weight: .black, design: .monospaced))
                            .foregroundStyle(PopArt.ink)
                            .padding(.horizontal, 14 * scale)
                            .padding(.vertical, 8 * scale)
                            .background(PopArt.yellow, in: RoundedRectangle(cornerRadius: 12 * scale))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12 * scale)
                                    .strokeBorder(PopArt.ink, lineWidth: 2.5)
                            )

                        Text("Choisis ton pseudo et l'une des \(snap.availableColors.count) couleurs encore disponibles !")
                            .font(.system(size: 15 * scale, weight: .bold))
                            .foregroundStyle(PopArt.ink.opacity(0.75))
                    }
                }
                .padding(22 * scale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func lobbyRoundRow(badge: String, title: String, scale: CGFloat) -> some View {
        HStack(spacing: 10 * scale) {
            Text(badge)
                .font(.system(size: 12 * scale, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 10 * scale)
                .padding(.vertical, 5 * scale)
                .background(PopArt.ink, in: Capsule())

            Text(title)
                .font(.system(size: 16 * scale, weight: .heavy, design: .rounded))
                .foregroundStyle(PopArt.ink)
        }
    }

    // MARK: - 3B. Round Intro Splash

    private func tvRoundIntroStage(scale: CGFloat) -> some View {
        PopArtCard(
            cornerRadius: 30 * scale,
            borderWidth: 5,
            backgroundColor: PopArt.yellow,
            shadowOffset: 9 * scale
        ) {
            VStack(spacing: 18 * scale) {
                Text(snap.roundKind.badgeTitle)
                    .font(.system(size: 44 * scale, weight: .black, design: .rounded))
                    .foregroundStyle(PopArt.ink)
                    .multilineTextAlignment(.center)

                Text(snap.roundKind.ruleSummary)
                    .font(.system(size: 26 * scale, weight: .heavy, design: .rounded))
                    .foregroundStyle(PopArt.ink.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36 * scale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(30 * scale)
        }
    }

    // MARK: - 3C. Giant MCQ Question Stage (Cash Speed, LE SOLO & Finale ×2)

    private func tvMCQQuestionStage(question: QuizMCQQuestion, scale: CGFloat) -> some View {
        VStack(spacing: 14 * scale) {
            // Question Prompt Card
            PopArtCard(
                cornerRadius: 24 * scale,
                borderWidth: 4,
                backgroundColor: snap.stage == .soloBuzzOpen ? Color(hex: "#FFF0F3") : PopArt.white,
                shadowOffset: 6 * scale
            ) {
                VStack(spacing: 8 * scale) {
                    HStack {
                        Text("« \(question.funnyTitle.uppercased()) »")
                            .font(.system(size: 18 * scale, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.orange)
                        Spacer()
                        let pts = (snap.roundKind == .leSolo || snap.roundKind == .finaleDouble)
                            ? question.baseValue * 2
                            : question.baseValue
                        Text("💰 ENJEU : \(pts) PTS")
                            .font(.system(size: 17 * scale, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .padding(.horizontal, 12 * scale)
                            .padding(.vertical, 4 * scale)
                            .background(PopArt.yellow, in: Capsule())
                            .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                    }

                    Text(question.prompt)
                        .font(.system(size: 26 * scale, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.ink)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)
                }
                .padding(.horizontal, 24 * scale)
                .padding(.vertical, 14 * scale)
            }

            if snap.stage == .soloBuzzOpen {
                HStack(spacing: 10 * scale) {
                    Text("🚨 LE SOLO : LE TOUT PREMIER QUI TAPE UNE RÉPONSE SUR SON TÉLÉPHONE PREND +\(question.baseValue * 2) PTS (OU -\(question.baseValue) PTS) !")
                        .font(.system(size: 17 * scale, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8 * scale)
                .padding(.horizontal, 16 * scale)
                .background(PopArt.redError, in: Capsule())
                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 3))
            }

            // 2x2 Giant Choices Grid
            let letters = ["A", "B", "C", "D"]
            VStack(spacing: 12 * scale) {
                HStack(spacing: 14 * scale) {
                    tvChoiceCard(index: 0, letter: letters[0], text: question.choices[0], scale: scale)
                    tvChoiceCard(index: 1, letter: letters[1], text: question.choices[1], scale: scale)
                }
                HStack(spacing: 14 * scale) {
                    tvChoiceCard(index: 2, letter: letters[2], text: question.choices[2], scale: scale)
                    tvChoiceCard(index: 3, letter: letters[3], text: question.choices[3], scale: scale)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }

    private func tvChoiceCard(index: Int, letter: String, text: String, scale: CGFloat) -> some View {
        let isRevealed = (snap.stage == .questionReveal)
        let isCorrect = (snap.revealedCorrectIndex == index)
        let playersWhoPickedThis = snap.players.filter { $0.lockedChoiceIndex == index }

        let bgColor: Color = {
            guard isRevealed else { return PopArt.white }
            return isCorrect ? Color(hex: "#D1FAE5") : Color(hex: "#F3F4F6")
        }()

        let borderColor: Color = {
            guard isRevealed else { return PopArt.ink }
            return isCorrect ? PopArt.greenSuccess : PopArt.ink.opacity(0.45)
        }()

        return PopArtCard(
            cornerRadius: 20 * scale,
            borderWidth: isRevealed && isCorrect ? 5 : 3.5,
            backgroundColor: bgColor,
            shadowOffset: 5 * scale
        ) {
            HStack(spacing: 14 * scale) {
                Text(letter)
                    .font(.system(size: 26 * scale, weight: .black, design: .rounded))
                    .foregroundStyle(isRevealed && isCorrect ? .white : PopArt.ink)
                    .frame(width: 52 * scale, height: 52 * scale)
                    .background(isRevealed && isCorrect ? PopArt.greenSuccess : PopArt.orange, in: RoundedRectangle(cornerRadius: 14 * scale))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14 * scale)
                            .strokeBorder(borderColor, lineWidth: 3)
                    )

                VStack(alignment: .leading, spacing: 6 * scale) {
                    Text(text)
                        .font(.system(size: 21 * scale, weight: .heavy, design: .rounded))
                        .foregroundStyle(PopArt.ink)
                        .minimumScaleFactor(0.75)

                    if isRevealed && !playersWhoPickedThis.isEmpty {
                        HStack(spacing: 6 * scale) {
                            ForEach(playersWhoPickedThis) { p in
                                HStack(spacing: 4 * scale) {
                                    Text(p.avatarEmoji)
                                    Text(p.name)
                                        .font(.system(size: 13 * scale, weight: .black))
                                    if let ms = p.reactionTimeMs {
                                        Text(String(format: "%.1fs", Double(ms) / 1000.0))
                                            .font(.system(size: 11 * scale, weight: .bold, design: .monospaced))
                                    }
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8 * scale)
                                .padding(.vertical, 3 * scale)
                                .background(PopArt.color(for: p.color), in: Capsule())
                                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 1.5))
                            }
                        }
                    }
                }

                Spacer()

                if isRevealed && isCorrect {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 34 * scale, weight: .black))
                        .foregroundStyle(PopArt.greenSuccess)
                }
            }
            .padding(.horizontal, 18 * scale)
            .padding(.vertical, 12 * scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - 3D. Raclette Quizz & Quoizzi-Quoissa Stage (DisOrDat)

    private static let tvItemCardColors: [Color] = [
        Color(hex: "#FFF3E0"),
        Color(hex: "#E0F7FA"),
        Color(hex: "#F3E5F5"),
        Color(hex: "#FFE4E8"),
        Color(hex: "#ECFDF5"),
        Color(hex: "#FEF9C3")
    ]

    private func tvCouciCoucaStage(round: QuizDisOrDatRound, scale: CGFloat) -> some View {
        let activeIdx = snap.activeDisOrDatItemIndex ?? 0
        let currentItem = round.items.indices.contains(activeIdx) ? round.items[activeIdx] : nil
        let isRevealed = (snap.stage == .couciCoucaReveal)
        let correctSide = snap.revealedBinarySide
        let centerBg = Self.tvItemCardColors[activeIdx % Self.tvItemCardColors.count]

        return VStack(spacing: 12 * scale) {
            HStack(spacing: 18 * scale) {
                // Left Option Pillar
                PopArtCard(
                    cornerRadius: 24 * scale,
                    borderWidth: isRevealed && correctSide == "left" ? 6 : 4,
                    backgroundColor: isRevealed ? (correctSide == "left" ? PopArt.greenSuccess : PopArt.blue.opacity(0.35)) : PopArt.blue,
                    shadowOffset: 6 * scale
                ) {
                    VStack(spacing: 10 * scale) {
                        Text(isRevealed && correctSide == "left" ? "✅ BONNE RÉPONSE" : "⬅️ GAUCHE")
                            .font(.system(size: 17 * scale, weight: .black))
                            .foregroundStyle(PopArt.yellow)
                        Text(round.optionLeft)
                            .font(.system(size: 26 * scale, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(16 * scale)
                }
                .frame(width: 280 * scale)

                // Center Item Card (Changes color on every item!)
                PopArtCard(
                    cornerRadius: 28 * scale,
                    borderWidth: 4.5,
                    backgroundColor: centerBg,
                    shadowOffset: 8 * scale
                ) {
                    VStack(spacing: 14 * scale) {
                        Text(round.funnyTitle.uppercased())
                            .font(.system(size: 17 * scale, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.orange)
                            .multilineTextAlignment(.center)

                        if let item = currentItem {
                            Text("QUESTION \(activeIdx + 1) / \(round.items.count)")
                                .font(.system(size: 16 * scale, weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16 * scale)
                                .padding(.vertical, 6 * scale)
                                .background(PopArt.ink, in: Capsule())

                            Text(item.text)
                                .font(.system(size: 30 * scale, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 18 * scale)
                        } else {
                            Text(round.prompt)
                                .font(.system(size: 24 * scale, weight: .heavy, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20 * scale)
                }

                // Right Option Pillar
                PopArtCard(
                    cornerRadius: 24 * scale,
                    borderWidth: isRevealed && correctSide == "right" ? 6 : 4,
                    backgroundColor: isRevealed ? (correctSide == "right" ? PopArt.greenSuccess : PopArt.pink.opacity(0.35)) : PopArt.pink,
                    shadowOffset: 6 * scale
                ) {
                    VStack(spacing: 10 * scale) {
                        Text(isRevealed && correctSide == "right" ? "✅ BONNE RÉPONSE" : "DROITE ➡️")
                            .font(.system(size: 17 * scale, weight: .black))
                            .foregroundStyle(PopArt.yellow)
                        Text(round.optionRight)
                            .font(.system(size: 26 * scale, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(16 * scale)
                }
                .frame(width: 280 * scale)
            }

            if let bothLabel = round.optionBoth {
                PopArtCard(
                    cornerRadius: 20 * scale,
                    borderWidth: isRevealed && correctSide == "both" ? 5.5 : 3.5,
                    backgroundColor: isRevealed ? (correctSide == "both" ? PopArt.greenSuccess : PopArt.purple.opacity(0.35)) : PopArt.purple,
                    shadowOffset: 5 * scale
                ) {
                    HStack(spacing: 12 * scale) {
                        Text(isRevealed && correctSide == "both" ? "✅ BONNE RÉPONSE :" : "🧀 3e OPTION :")
                            .font(.system(size: 18 * scale, weight: .black))
                            .foregroundStyle(PopArt.yellow)
                        Text(bothLabel)
                            .font(.system(size: 22 * scale, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12 * scale)
                }
            }
        }
    }

    // MARK: - 3E. Final TV Podium Stage

    private func tvFinalPodiumStage(scale: CGFloat) -> some View {
        PopArtCard(
            cornerRadius: 28 * scale,
            borderWidth: 4.5,
            backgroundColor: PopArt.white,
            shadowOffset: 8 * scale
        ) {
            VStack(spacing: 14 * scale) {
                Text("🏆 LE GRAND PODIUM DE MEEMAW 🏆")
                    .font(.system(size: 30 * scale, weight: .black, design: .rounded))
                    .foregroundStyle(PopArt.ink)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10 * scale) {
                        ForEach(snap.podiumAwards) { award in
                            HStack(spacing: 16 * scale) {
                                Text("#\(award.rank)")
                                    .font(.system(size: 26 * scale, weight: .black, design: .rounded))
                                    .foregroundStyle(award.rank == 1 ? PopArt.ink : .white)
                                    .frame(width: 58 * scale, height: 58 * scale)
                                    .background(award.rank == 1 ? PopArt.yellow : PopArt.color(for: award.playerColor), in: Circle())
                                    .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 3))

                                Text(award.avatarEmoji)
                                    .font(.system(size: 34 * scale))

                                VStack(alignment: .leading, spacing: 3 * scale) {
                                    Text(award.playerName)
                                        .font(.system(size: 22 * scale, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                    Text(award.funnyTitle)
                                        .font(.system(size: 16 * scale, weight: .heavy, design: .rounded))
                                        .foregroundStyle(PopArt.orange)
                                    Text(award.subtitle)
                                        .font(.system(size: 13 * scale, weight: .bold))
                                        .foregroundStyle(PopArt.ink.opacity(0.6))
                                }

                                Spacer()

                                Text("\(award.score) PTS")
                                    .font(.system(size: 26 * scale, weight: .black, design: .monospaced))
                                    .foregroundStyle(PopArt.ink)
                                    .padding(.horizontal, 18 * scale)
                                    .padding(.vertical, 10 * scale)
                                    .background(PopArt.yellow, in: Capsule())
                                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 3))
                            }
                            .padding(.horizontal, 18 * scale)
                            .padding(.vertical, 10 * scale)
                            .background(Color(hex: "#FFFDF9"), in: RoundedRectangle(cornerRadius: 18 * scale))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18 * scale)
                                    .strokeBorder(PopArt.ink, lineWidth: 2.5)
                            )
                        }
                    }
                }
            }
            .padding(22 * scale)
        }
    }

    // MARK: - 4. Bottom Players Dock (Up to 8 Players in Real Time)

    private func tvBottomPlayersDock(scale: CGFloat) -> some View {
        HStack(spacing: 12 * scale) {
            ForEach(snap.players) { player in
                let hasAnswered = (player.lockedChoiceIndex != nil || player.lockedSide != nil)
                let isSoloHero = (snap.soloBuzzerPlayerID == player.id)

                HStack(spacing: 10 * scale) {
                    ZStack {
                        Circle()
                            .fill(PopArt.color(for: player.color))
                            .frame(width: 44 * scale, height: 44 * scale)
                            .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2.5))
                        Text(player.avatarEmoji)
                            .font(.system(size: 24 * scale))
                    }

                    VStack(alignment: .leading, spacing: 2 * scale) {
                        HStack(spacing: 4 * scale) {
                            Text(player.name)
                                .font(.system(size: 16 * scale, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .lineLimit(1)
                            if player.streak >= 2 {
                                Text("🔥\(player.streak)")
                                    .font(.system(size: 12 * scale, weight: .black))
                            }
                            if player.activeBisouWipesRemaining > 0 {
                                Text("💋")
                                    .font(.system(size: 14 * scale))
                            }
                        }

                        HStack(spacing: 6 * scale) {
                            Text("\(player.score) pts")
                                .font(.system(size: 15 * scale, weight: .black, design: .monospaced))
                                .foregroundStyle(PopArt.color(for: player.color))

                            if (snap.stage == .questionReveal || snap.stage == .couciCoucaReveal), let delta = player.lastDeltaScore, delta != 0 {
                                Text(delta > 0 ? "+\(delta)" : "\(delta)")
                                    .font(.system(size: 12 * scale, weight: .black, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6 * scale)
                                    .padding(.vertical, 2 * scale)
                                    .background(delta > 0 ? PopArt.greenSuccess : PopArt.redError, in: Capsule())
                            } else if isSoloHero {
                                Text("🚨 SOLO")
                                    .font(.system(size: 11 * scale, weight: .black))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6 * scale)
                                    .padding(.vertical, 2 * scale)
                                    .background(PopArt.redError, in: Capsule())
                            } else if hasAnswered {
                                Text("✅ PRÊT")
                                    .font(.system(size: 11 * scale, weight: .black))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6 * scale)
                                    .padding(.vertical, 2 * scale)
                                    .background(PopArt.greenSuccess, in: Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, 14 * scale)
                .padding(.vertical, 8 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 18 * scale, style: .continuous)
                        .fill(hasAnswered ? Color(hex: "#ECFDF5") : PopArt.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18 * scale, style: .continuous)
                        .strokeBorder(
                            isSoloHero ? PopArt.redError : PopArt.color(for: player.color),
                            lineWidth: isSoloHero ? 4 : 3
                        )
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}
