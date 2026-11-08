import MeemawQuizzCore
import SwiftUI

struct PlayerControllerView: View {
    @Bindable var session: GameSessionController
    var displayManager = ExternalDisplayManager.shared

    @State private var isShowingSettingsSheet: Bool = false
    @State private var justePifInputString: String = ""

    var snap: HostToClientStateSnapshot {
        session.effectiveSnapshot
    }

    var me: QuizPlayer? {
        session.localPlayer
    }

    var body: some View {
        ZStack {
            PopArtTVBackground(roundKind: snap.roundKind)

            VStack(spacing: 8) {
                topPlayerAndHostBar

                if displayManager.isPreviewTVOnPhoneSelected {
                    MeemawTVStageView(session: session)
                        .aspectRatio(16.0 / 9.0, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(PopArt.ink.opacity(0.8), lineWidth: 2)
                        )
                } else if !displayManager.isExternalTVSceneConnected
                            && snap.stage != .lobby
                            && snap.stage != .drawLiveGuessing
                            && snap.stage != .esquisseDrawing {
                    compactPhoneMeemawBanner
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        switch snap.stage {
                        case .lobby:
                            lobbyControllerSection
                        case .roundIntro:
                            roundIntroControllerSection
                        case .ttmcBetting:
                            ttmcBettingControllerSection
                        case .soloBuzzOpen:
                            soloBuzzerControllerSection
                        case .soloPlayerAnswering:
                            soloAnsweringControllerSection
                        case .questionReading, .cashAnswering, .questionReveal:
                            cashMCQControllerSection
                        case .justePifAnswering, .justePifReveal:
                            justePifControllerSection
                        case .couciCoucaIntro, .couciCoucaItem, .couciCoucaReveal, .couciCoucaSummary:
                            couciCoucaControllerSection
                        case .drawWordChoice, .drawLiveGuessing, .drawReveal:
                            drawSomethingControllerSection
                        case .esquissePromptEntry, .esquisseDrawing, .esquisseGuessing, .esquisseShowcase:
                            esquisseControllerSection
                        case .jackAttackActive, .jackAttackWaveReveal:
                            jackAttackControllerSection
                        case .finalPodium:
                            finalPodiumControllerSection
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)

            // Bisou Baveux Screen Sabotage Overlay
            if let me, me.activeBisouWipesRemaining > 0 {
                bisouSabotageOverlay(wipesRemaining: me.activeBisouWipesRemaining, senderName: me.bisouSenderName ?? "Meemaw")
            }
        }
        .background(SceneAccessoryHostInjector().frame(width: 0, height: 0))
        .sheet(isPresented: $isShowingSettingsSheet) {
            lobbySettingsSheet
        }
        .onChange(of: snap.stage) { _, newStage in
            if newStage == .justePifAnswering {
                justePifInputString = ""
            }
            if newStage == .questionReveal || newStage == .couciCoucaReveal || newStage == .justePifReveal || newStage == .jackAttackWaveReveal {
                let delta = me?.lastDeltaScore ?? 0
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(delta > 0 ? .success : .error)
            }
        }
    }

    // MARK: - 1. iOS Mobile Top Bar & Host Controls (44pt+ Touch Targets, App Icon Royal Blue & Gold)

    private var topPlayerAndHostBar: some View {
        VStack(spacing: 8) {
            // Row 1: Player Profile Pill + Score Badge + TV Preview Button (all >= 44pt height)
            HStack(spacing: 8) {
                Button {
                    isShowingSettingsSheet = true
                } label: {
                    HStack(spacing: 7) {
                        Text(me?.avatarEmoji ?? session.localAvatarEmoji)
                            .font(.system(size: 19))
                        Text(me?.name ?? session.localPlayerName)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .lineLimit(1)
                        Circle()
                            .fill(PopArt.color(for: me?.color ?? session.localSelectedColor))
                            .frame(width: 10, height: 10)
                            .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 1.5))
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(PopArt.blue)
                    }
                    .padding(.horizontal, 13)
                    .frame(minHeight: 44)
                    .background(PopArt.white, in: Capsule())
                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2.2))
                    .shadow(color: PopArt.ink.opacity(0.35), radius: 0, x: 0, y: 2.5)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 4)

                if snap.stage != .lobby {
                    HStack(spacing: 4) {
                        Text("🏆")
                            .font(.system(size: 14))
                        Text("\(me?.score ?? 0) PTS")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundStyle(PopArt.ink)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .frame(minHeight: 44)
                    .background(PopArt.yellow, in: Capsule())
                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2.2))
                    .shadow(color: PopArt.ink.opacity(0.35), radius: 0, x: 0, y: 2.5)
                }

                Button {
                    withAnimation(.easeOut(duration: 0.22)) {
                        displayManager.isPreviewTVOnPhoneSelected.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: displayManager.isPreviewTVOnPhoneSelected ? "tv.fill" : "tv")
                            .font(.system(size: 14, weight: .black))
                        Text(displayManager.isPreviewTVOnPhoneSelected ? "TV ON" : "TV")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(displayManager.isPreviewTVOnPhoneSelected ? PopArt.ink : .white)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(
                        displayManager.isPreviewTVOnPhoneSelected ? PopArt.yellow : PopArt.blue,
                        in: Capsule()
                    )
                    .overlay(Capsule().strokeBorder(PopArt.yellow, lineWidth: 2))
                    .shadow(color: PopArt.ink.opacity(0.35), radius: 0, x: 0, y: 2.5)
                }
                .buttonStyle(.plain)
            }

            // Row 2 (In-Game): Comfortable 44pt Touch Bar for Host / Client Actions
            if snap.stage != .lobby {
                if session.role == .hostAndPlayer1 {
                    HStack(spacing: 7) {
                        Button {
                            session.skipToNextStep()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "forward.end.fill")
                                    .font(.system(size: 12, weight: .black))
                                Text("Suivant")
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, minHeight: 40)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: PopArt.yellow,
                                foregroundColor: PopArt.ink,
                                cornerRadius: 12
                            )
                        )

                        if snap.stage != .finalPodium {
                            Button {
                                session.finishGameToPodiumNow()
                            } label: {
                                HStack(spacing: 4) {
                                    Text("🏆")
                                        .font(.system(size: 13))
                                    Text("Podium")
                                        .font(.system(size: 13, weight: .black, design: .rounded))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, minHeight: 40)
                            }
                            .buttonStyle(
                                PopArtActionButtonStyle(
                                    backgroundColor: PopArt.blue,
                                    foregroundColor: .white,
                                    cornerRadius: 12
                                )
                            )
                        }

                        Button {
                            isShowingSettingsSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 12, weight: .black))
                                Text("Salon")
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, minHeight: 40)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: PopArt.cream,
                                foregroundColor: PopArt.ink,
                                cornerRadius: 12
                            )
                        )

                        Button {
                            session.returnToLobby()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 11, weight: .black))
                                Text("Arrêter")
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, minHeight: 40)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: PopArt.redError,
                                foregroundColor: .white,
                                cornerRadius: 12
                            )
                        )
                    }
                } else {
                    HStack(spacing: 10) {
                        Label(
                            session.isBonjourConnectedToRemoteHost ? "Connecté au salon" : "Recherche du salon...",
                            systemImage: "wifi"
                        )
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                        Spacer()

                        Button {
                            session.leaveRemoteSession()
                        } label: {
                            Text("🚪 Quitter")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .padding(.horizontal, 14)
                                .frame(minHeight: 40)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: PopArt.redError,
                                foregroundColor: .white,
                                cornerRadius: 12
                            )
                        )
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PopArt.studioNavy.opacity(0.9), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.yellow, lineWidth: 1.5))
                }
            }
        }
    }

    // MARK: - 1B. Prominent Meemaw Studio Host Banner on Phone (72pt Golden Marquee Avatar + Speech)

    private var compactPhoneMeemawBanner: some View {
        PopArtCard(cornerRadius: 20, borderWidth: 2.5, backgroundColor: PopArt.cream, shadowOffset: 4) {
            HStack(spacing: 12) {
                MeemawGuestStarAvatar(
                    pose: snap.meemawPose,
                    isSpeaking: MeemawShowAudioEngine.shared.isMeemawSpeaking,
                    size: 70
                )

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(snap.roundKind.badgeTitle)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .background(PopArt.blue, in: Capsule())

                        if snap.questionNumber > 0 && snap.stage != .finalPodium {
                            Text("Q\(snap.questionNumber)/\(snap.totalQuestions)")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundStyle(PopArt.ink)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(PopArt.yellow, in: Capsule())
                        }

                        Spacer(minLength: 2)

                        if snap.timeRemainingSec > 0 {
                            Text(String(format: "⏱️ %.0fs", ceil(snap.timeRemainingSec)))
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .foregroundStyle(snap.timeRemainingSec <= 4.0 ? .white : PopArt.ink)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    snap.timeRemainingSec <= 4.0 ? PopArt.redError : PopArt.yellow.opacity(0.55),
                                    in: Capsule()
                                )
                        }
                    }

                    Text(snap.meemawSpeech)
                        .font(.system(size: 13.5, weight: .heavy, design: .rounded))
                        .foregroundStyle(PopArt.ink)
                        .lineLimit(snap.stage == .questionReveal || snap.stage == .roundIntro ? 3 : 2)
                        .minimumScaleFactor(0.82)
                }
            }
            .padding(10)
        }
    }

    // MARK: - 2. Lobby Screen (App Icon Studio Hero + Royal Blue, Gold & Copper-Orange Palette)

    private var lobbyControllerSection: some View {
        VStack(spacing: 14) {
            // Showstopper Meemaw Studio Hero Card (featuring large 88pt Meemaw + App Icon stage badge)
            if !displayManager.isPreviewTVOnPhoneSelected {
                PopArtCard(cornerRadius: 22, borderWidth: 3, backgroundColor: PopArt.cream, shadowOffset: 5) {
                    HStack(spacing: 14) {
                        MeemawGuestStarAvatar(
                            pose: snap.meemawPose,
                            isSpeaking: MeemawShowAudioEngine.shared.isMeemawSpeaking,
                            size: 86
                        )

                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 6) {
                                Text("🎙️ MEEMAW QUIZZ")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.ink)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(PopArt.yellow, in: Capsule())
                                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 1.5))
                            }

                            Text("Bienvenue sur le plateau ! Choisis ton jeu et prépare ton buzzer !")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)

                        MeemawPoseIllustration(
                            assetName: "meemaw_studio_icon",
                            size: 56,
                            isCircularStage: true
                        )
                    }
                    .padding(12)
                }
            }

            if session.role == .hostAndPlayer1 {
                // Single Cohesive Mode Card (White & Gold — no rainbow clutter)
                PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.white, shadowOffset: 5) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CHOISIS TA PARTIE")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink.opacity(0.55))
                            .padding(.horizontal, 2)

                        ForEach(ShowGameMode.allCases) { mode in
                            lobbyModeRow(for: mode)
                        }
                    }
                    .padding(14)
                }

                // 1-Tap Age Bracket & Generational Mix Card
                lobbyAgeBracketCard

                // Single Primary Launch CTA + Subtle Settings/Players Link
                VStack(spacing: 10) {
                    Button {
                        session.startNewShow()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .black))
                            Text("LANCER LA PARTIE")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(
                        PopArtActionButtonStyle(
                            backgroundColor: PopArt.orange,
                            foregroundColor: .white,
                            cornerRadius: 18
                        )
                    )

                    Button {
                        isShowingSettingsSheet = true
                    } label: {
                        HStack(spacing: 7) {
                            HStack(spacing: -4) {
                                ForEach(snap.players.prefix(4)) { p in
                                    Text(p.avatarEmoji)
                                        .font(.system(size: 15))
                                        .frame(width: 26, height: 26)
                                        .background(PopArt.cream, in: Circle())
                                        .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 1.5))
                                }
                            }
                            Text("\(snap.players.count) joueur\(snap.players.count > 1 ? "s" : "")")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .lineLimit(1)

                            Text("•")
                                .foregroundStyle(PopArt.ink.opacity(0.4))

                            Text("Profil, Bots & Salon Wi-Fi")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.blue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)

                            Spacer(minLength: 2)

                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(PopArt.ink.opacity(0.65))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(PopArt.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(PopArt.ink, lineWidth: 2.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Minimal Client Waiting Card
                PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.white, shadowOffset: 5) {
                    VStack(spacing: 12) {
                        Text(session.isBonjourConnectedToRemoteHost ? "✅ Connecté au Salon" : "📡 Recherche du salon sur le Wi-Fi...")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)

                        Text("Mode choisi : \(snap.selectedGameMode.title)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(PopArt.orange)

                        Text("Dès que l'hôte lance la partie, ta manette s'affichera automatiquement.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(PopArt.ink.opacity(0.75))
                            .multilineTextAlignment(.center)

                        Button {
                            isShowingSettingsSheet = true
                        } label: {
                            Text("⚙️ Mon Profil & Réglages du Salon")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 14))
                    }
                    .padding(16)
                }

                lobbyAgeBracketCard
            }
        }
    }

    private var lobbyAgeBracketCard: some View {
        let currentAge = me?.effectiveAgeBracket ?? session.localAgeBracket
        let activeDecades = session.activeTableDecades.map(\.shortTag).joined(separator: " • ")

        return PopArtCard(cornerRadius: 20, borderWidth: 2.5, backgroundColor: PopArt.cream, shadowOffset: 4) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("🎂 TON ÂGE (QUESTIONS PAR DÉCENNIE)")
                        .font(.system(size: 11.5, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.ink)
                    Spacer()
                    Text("Mix : \(activeDecades)")
                        .font(.system(size: 10.5, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(PopArt.blue, in: Capsule())
                }

                HStack(spacing: 6) {
                    ForEach(PlayerAgeBracket.allCases) { bracket in
                        let isSelected = (currentAge == bracket)
                        Button {
                            session.localAgeBracket = bracket
                            session.sendLocalProfileUpdate()
                        } label: {
                            VStack(spacing: 2) {
                                Text(bracket.shortBadge)
                                    .font(.system(size: 11.5, weight: .black, design: .rounded))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Text(bracket.subtitle)
                                    .font(.system(size: 9.5, weight: .bold, design: .rounded))
                                    .opacity(0.8)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .foregroundStyle(isSelected ? PopArt.ink : PopArt.ink)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                isSelected ? PopArt.yellow : PopArt.white,
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(isSelected ? PopArt.ink : PopArt.ink.opacity(0.35), lineWidth: isSelected ? 2.5 : 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(12)
        }
    }

    private func lobbyModeRow(for mode: ShowGameMode) -> some View {
        let isModeSelected = (snap.selectedGameMode == mode)
        let iconText: String = {
            switch mode {
            case .fullQuizShow: return "📺"
            case .carPlayRoadTrip: return "🚗"
            case .drawSomethingOnly: return "🎨"
            case .esquisseParty: return "✏️"
            }
        }()
        let cleanTitle: String = {
            switch mode {
            case .fullQuizShow: return "Grand Quizz TV (+ Dessin)"
            case .carPlayRoadTrip: return "Mode Voiture / CarPlay (Sans Dessin)"
            case .drawSomethingOnly: return "Draw Something"
            case .esquisseParty: return "Esquissé ! (1 Mot Simple)"
            }
        }()
        let cleanSubtitle: String = {
            switch mode {
            case .fullQuizShow: return "Quizz général, Buzzer, Cash, TTMC et épreuves de dessin"
            case .carPlayRoadTrip: return "Diffuse questions, choix A/B/C/D et scores sur l'écran « À l'écoute » CarPlay !"
            case .drawSomethingOnly: return "Un joueur dessine, les autres tapent le mot avec les lettres"
            case .esquisseParty: return "Téléphone arabe en dessin avec 1 seul mot facile"
            }
        }()

        return VStack(alignment: .leading, spacing: 10) {
            Button {
                session.selectGameMode(mode)
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isModeSelected ? PopArt.yellow : PopArt.cream)
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(PopArt.ink, lineWidth: 2)
                            )
                        Text(iconText)
                            .font(.system(size: 21))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(cleanTitle)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                        Text(cleanSubtitle)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(PopArt.ink.opacity(0.7))
                            .lineLimit(2)
                    }

                    Spacer(minLength: 4)

                    Image(systemName: isModeSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(isModeSelected ? PopArt.orange : PopArt.ink.opacity(0.25))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Single clean Dropdown Menu for Theme Selection (instead of 7 rainbow buttons)
            if (mode == .fullQuizShow || mode == .carPlayRoadTrip) && isModeSelected {
                Divider().overlay(PopArt.ink.opacity(0.15))

                HStack {
                    Text("Thème des questions")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(PopArt.ink.opacity(0.75))

                    Spacer()

                    Menu {
                        ForEach(QuizThemePack.allCases) { pack in
                            Button {
                                session.selectThemePack(pack)
                            } label: {
                                if snap.selectedPack == pack {
                                    Label(pack.title, systemImage: "checkmark")
                                } else {
                                    Text(pack.title)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(snap.selectedPack.title)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(PopArt.ink.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(PopArt.white, in: Capsule())
                        .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                    }
                }

                if mode == .carPlayRoadTrip {
                    HStack(spacing: 10) {
                        if let carCard = CarPlayNowPlayingManager.shared.latestArtworkImage {
                            Image(uiImage: carCard)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 58, height: 58)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(PopArt.ink, lineWidth: 2)
                                )
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(MeemawShowAudioEngine.shared.isCarPlayAudioActive ? "🟢 CarPlay détecté !" : "🚗 Écran « À l'écoute » CarPlay actif")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.blue)
                            Text("Ouvre « À l'écoute » sur l'écran de la voiture : la carte de la question, les choix A/B/C/D et les scores s'y affichent (bouton ⏭️ au volant = étape suivante).")
                                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.78))
                        }
                    }
                    .padding(8)
                    .background(PopArt.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(PopArt.ink.opacity(0.35), lineWidth: 1.5)
                    )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isModeSelected ? Color(hex: "#FEF3C7") : PopArt.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(isModeSelected ? PopArt.ink : PopArt.ink.opacity(0.22), lineWidth: isModeSelected ? 3 : 1.5)
        )
    }

    // MARK: - 2B. Dedicated Sheet: ⚙️ Profil, Salon & Réglages

    private var lobbySettingsSheet: some View {
        NavigationStack {
            ZStack {
                PopArtTVBackground(roundKind: snap.roundKind)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. PROFIL & COULEUR DU JOUEUR
                        PopArtCard(cornerRadius: 20, borderWidth: 3, backgroundColor: PopArt.white, shadowOffset: 4) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("👤 MON PROFIL JOUEUR")
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Text(me?.avatarEmoji ?? session.localAvatarEmoji)
                                        Text(me?.name ?? session.localPlayerName)
                                            .font(.system(size: 13, weight: .black, design: .rounded))
                                            .foregroundStyle(.white)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(PopArt.color(for: me?.color ?? session.localSelectedColor), in: Capsule())
                                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                                }

                                HStack(spacing: 8) {
                                    TextField("Ton pseudo...", text: $session.localPlayerName)
                                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2))
                                        .onSubmit {
                                            session.sendLocalProfileUpdate()
                                        }

                                    Button {
                                        session.sendLocalProfileUpdate()
                                    } label: {
                                        Text("Enregistrer")
                                            .font(.system(size: 13, weight: .black, design: .rounded))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                    }
                                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 12))
                                }

                                Text("Tranche d'âge (adapte les décennies 60s–2020s) :")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(PopArt.ink.opacity(0.7))

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                    ForEach(PlayerAgeBracket.allCases) { bracket in
                                        let currentAge = me?.effectiveAgeBracket ?? session.localAgeBracket
                                        let isSelected = (currentAge == bracket)
                                        Button {
                                            session.localAgeBracket = bracket
                                            session.sendLocalProfileUpdate()
                                        } label: {
                                            HStack(spacing: 6) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(bracket.shortBadge)
                                                        .font(.system(size: 13, weight: .black, design: .rounded))
                                                    Text(bracket.subtitle)
                                                        .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                                        .opacity(0.75)
                                                }
                                                Spacer(minLength: 0)
                                                if isSelected {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 15, weight: .black))
                                                }
                                            }
                                            .foregroundStyle(PopArt.ink)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 9)
                                            .frame(maxWidth: .infinity, minHeight: 44)
                                            .background(isSelected ? PopArt.yellow : PopArt.cream, in: RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(isSelected ? PopArt.ink : PopArt.ink.opacity(0.4), lineWidth: isSelected ? 2.5 : 1.5)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                Text("Couleur de ton buzzer :")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(PopArt.ink.opacity(0.7))

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                    ForEach(PlayerColor.allCases) { colorOption in
                                        let owner = snap.players.first(where: { $0.color == colorOption })
                                        let isMine = (owner?.id == session.localPlayerID) || (me == nil && session.localSelectedColor == colorOption)
                                        let isTakenByOther = (owner != nil && owner?.id != session.localPlayerID)

                                        Button {
                                            guard !isTakenByOther else { return }
                                            session.localSelectedColor = colorOption
                                            session.localAvatarEmoji = colorOption.defaultEmoji
                                            session.sendLocalProfileUpdate()
                                        } label: {
                                            VStack(spacing: 3) {
                                                Text(isTakenByOther ? "🔒" : colorOption.defaultEmoji)
                                                    .font(.system(size: 20))
                                                Text(isTakenByOther ? (owner?.name ?? "Pris") : colorOption.label)
                                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.7)
                                            }
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 9)
                                            .background(PopArt.color(for: colorOption), in: RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(isMine ? PopArt.ink : PopArt.ink.opacity(0.5), lineWidth: isMine ? 3.5 : 1.5)
                                            )
                                            .opacity(isTakenByOther ? 0.35 : 1.0)
                                        }
                                        .disabled(isTakenByOther)
                                    }
                                }
                            }
                            .padding(14)
                        }

                        // 2. JOUEURS, BOTS IA & MODES DE TEST RAPIDE
                        PopArtCard(cornerRadius: 20, borderWidth: 3, backgroundColor: PopArt.white, shadowOffset: 4) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("👥 JOUEURS & BOTS (\(snap.players.count))")
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                    Spacer()
                                    if session.role == .hostAndPlayer1 {
                                        if snap.players.contains(where: { $0.id.hasPrefix("bot_") }) {
                                            Button {
                                                session.removeAllBots()
                                            } label: {
                                                Text("🧹 Vider Bots")
                                                    .font(.system(size: 11, weight: .black))
                                                    .padding(.horizontal, 9)
                                                    .padding(.vertical, 6)
                                            }
                                            .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.cream, cornerRadius: 10))
                                        }

                                        Button {
                                            session.addDemoBotPlayers()
                                        } label: {
                                            Text("+ 🤖 Ajouter un Bot")
                                                .font(.system(size: 11, weight: .black))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                        }
                                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 10))
                                    }
                                }

                                ForEach(snap.players) { p in
                                    HStack(spacing: 8) {
                                        Text(p.avatarEmoji)
                                            .font(.system(size: 18))
                                        Text(p.name)
                                            .font(.system(size: 14, weight: .black, design: .rounded))
                                            .foregroundStyle(PopArt.ink)
                                        Text(p.effectiveAgeBracket.shortBadge)
                                            .font(.system(size: 10.5, weight: .black, design: .rounded))
                                            .foregroundStyle(PopArt.ink)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 3)
                                            .background(PopArt.yellow.opacity(0.75), in: Capsule())
                                        Spacer()
                                        Text(p.id.hasPrefix("bot_") ? "BOT IA" : (p.id == session.localPlayerID ? "MOI" : "INVITÉ"))
                                            .font(.system(size: 10, weight: .black, design: .rounded))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(PopArt.color(for: p.color), in: Capsule())
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink.opacity(0.25), lineWidth: 1.5))
                                }

                                if session.role == .hostAndPlayer1 && snap.stage == .lobby {
                                    Divider().overlay(PopArt.ink.opacity(0.15))

                                    Text("Lancement rapide d'entraînement :")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(PopArt.ink.opacity(0.7))

                                    HStack(spacing: 8) {
                                        Button {
                                            isShowingSettingsSheet = false
                                            session.startSoloTestShow(withBots: false)
                                        } label: {
                                            Text("🕹️ Tester Seul")
                                                .font(.system(size: 13, weight: .black, design: .rounded))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                        }
                                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.cream, cornerRadius: 12))

                                        Button {
                                            isShowingSettingsSheet = false
                                            session.startSoloTestShow(withBots: true)
                                        } label: {
                                            Text("🤖 Solo + 2 Bots")
                                                .font(.system(size: 13, weight: .black, design: .rounded))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                        }
                                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 12))
                                    }
                                }
                            }
                            .padding(14)
                        }

                        // 3. SALON WI-FI, PARTAGE DE CONNEXION & QR CODE D'INVITATION
                        PopArtCard(cornerRadius: 20, borderWidth: 3, backgroundColor: PopArt.white, shadowOffset: 4) {
                            let liveJoinURL = session.role == .hostAndPlayer1 ? session.joinURLString : snap.joinURL
                            let isHotspotURL = liveJoinURL.contains("172.20.10.") || session.lanServer.forceHotspotIP

                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("📲 SALON WI-FI & PARTAGE 4G/5G")
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                    Spacer()
                                    Text(isHotspotURL ? "📶 Partage iPhone" : "🏠 Wi-Fi Local")
                                        .font(.system(size: 11, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 4)
                                        .background(PopArt.yellow, in: Capsule())
                                        .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 1.5))
                                }

                                if session.role == .hostAndPlayer1 {
                                    HStack(spacing: 8) {
                                        Button {
                                            session.lanServer.forceHotspotIP = false
                                        } label: {
                                            Text("🏠 Wi-Fi (Auto)")
                                                .font(.system(size: 12, weight: .black, design: .rounded))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 8)
                                        }
                                        .buttonStyle(
                                            PopArtActionButtonStyle(
                                                backgroundColor: !session.lanServer.forceHotspotIP ? PopArt.yellow : PopArt.cream,
                                                cornerRadius: 10
                                            )
                                        )

                                        Button {
                                            session.lanServer.forceHotspotIP = true
                                        } label: {
                                            Text("📶 Partage 4G/5G (172.20.10.1)")
                                                .font(.system(size: 12, weight: .black, design: .rounded))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 8)
                                        }
                                        .buttonStyle(
                                            PopArtActionButtonStyle(
                                                backgroundColor: session.lanServer.forceHotspotIP ? PopArt.yellow : PopArt.cream,
                                                cornerRadius: 10
                                            )
                                        )
                                    }
                                }

                                HStack(spacing: 14) {
                                    if let qr = GameSessionController.makeQRCodeImage(from: liveJoinURL) {
                                        Image(uiImage: qr)
                                            .interpolation(.none)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 96, height: 96)
                                            .padding(6)
                                            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2.5))
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(isHotspotURL ? "En extérieur (Partage de connexion) :" : "À la maison (Même Wi-Fi) :")
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundStyle(PopArt.ink)
                                        Text(liveJoinURL)
                                            .font(.system(size: 12, weight: .black, design: .monospaced))
                                            .foregroundStyle(PopArt.blue)
                                        Text(
                                            isHotspotURL
                                                ? "1. Connectez d'abord l'autre téléphone au Wi-Fi Partage de connexion de cet iPhone.\n2. Scannez ce QR Code ou touchez « Rejoindre un Salon »."
                                                : "Scannez ce QR Code avec l'appareil photo ou touchez « Rejoindre un Salon » sur un autre iPhone."
                                        )
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(PopArt.ink.opacity(0.72))
                                    }
                                }

                                HStack(spacing: 8) {
                                    Button {
                                        session.startHostingSession()
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "tv.and.mediabox")
                                            Text("Héberger")
                                        }
                                        .font(.system(size: 12, weight: .black))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(
                                        PopArtActionButtonStyle(
                                            backgroundColor: session.role == .hostAndPlayer1 ? PopArt.yellow : PopArt.cream,
                                            cornerRadius: 12
                                        )
                                    )

                                    Button {
                                        session.switchToBonjourClientMode()
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "wifi")
                                            Text("Rejoindre un Salon")
                                        }
                                        .font(.system(size: 12, weight: .black))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(
                                        PopArtActionButtonStyle(
                                            backgroundColor: session.role == .bonjourClient ? PopArt.yellow : PopArt.cream,
                                            cornerRadius: 12
                                        )
                                    )
                                }
                            }
                            .padding(14)
                        }
                        .onAppear {
                            session.lanServer.refreshNetworkAddressAndNotifyIfNeeded(forceNotify: true)
                        }

                        // 4. RÉGLAGES AUDIO, AIRPLAY & HISTORIQUE DES QUESTIONS
                        PopArtCard(cornerRadius: 20, borderWidth: 3, backgroundColor: PopArt.white, shadowOffset: 4) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("⚙️ RÉGLAGES DU JEU")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.ink)

                                HStack {
                                    Label("Musique & Voix du plateau", systemImage: session.audio.isMusicMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                    Spacer()
                                    Button {
                                        session.audio.isMusicMuted.toggle()
                                    } label: {
                                        Text(session.audio.isMusicMuted ? "Couper (OFF)" : "Activé (ON)")
                                            .font(.system(size: 12, weight: .black, design: .rounded))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                    }
                                    .buttonStyle(
                                        PopArtActionButtonStyle(
                                            backgroundColor: session.audio.isMusicMuted ? PopArt.cream : PopArt.yellow,
                                            cornerRadius: 10
                                        )
                                    )
                                }

                                HStack {
                                    Label("Diffuser sur Apple TV (AirPlay)", systemImage: "airplayvideo")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(PopArt.ink)
                                    Spacer()
                                    AirPlayRoutePickerButton(tintColor: .black)
                                        .frame(width: 38, height: 38)
                                        .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 10))
                                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(PopArt.ink, lineWidth: 2))
                                }

                                let activeCounts = session.unseenQuestionsCount(for: snap.selectedPack)
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Questions inédites (\(snap.selectedPack.title))")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundStyle(PopArt.ink)
                                        Text("\(activeCounts.unseen) disponibles sur \(activeCounts.total)")
                                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                                            .foregroundStyle(PopArt.ink.opacity(0.65))
                                    }
                                    Spacer()
                                    Button {
                                        session.resetSeenQuestionsHistory()
                                    } label: {
                                        Text("🔄 Réinitialiser")
                                            .font(.system(size: 12, weight: .black, design: .rounded))
                                            .padding(.horizontal, 11)
                                            .padding(.vertical, 7)
                                    }
                                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.cream, cornerRadius: 10))
                                }
                            }
                            .padding(14)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Profil, Salon & Réglages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        session.sendLocalProfileUpdate()
                        isShowingSettingsSheet = false
                    } label: {
                        Text("Fermer")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                    }
                }
            }
        }
    }

    // MARK: - 3. Round Intro Controller Card (+ Sponsor Officiel du Jour)

    private var roundIntroMeemawAsset: String {
        switch snap.roundKind {
        case .leSolo:
            return "meemaw_boxing_referee"
        case .tuTeMetsCombien:
            return "meemaw_score"
        case .jackAttack, .finaleDouble:
            return "meemawHoldingTrophyBig"
        default:
            return "meemaw_studio_icon"
        }
    }

    private var roundIntroControllerSection: some View {
        VStack(spacing: 10) {
            PopArtCard(cornerRadius: 22, borderWidth: 2.5, backgroundColor: PopArt.cream) {
                VStack(spacing: 12) {
                    MeemawPoseIllustration(
                        assetName: roundIntroMeemawAsset,
                        size: 92,
                        isCircularStage: true
                    )

                    Text(snap.roundKind.badgeTitle)
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(PopArt.blue, in: Capsule())
                        .overlay(
                            Capsule().strokeBorder(PopArt.yellow, lineWidth: 2)
                        )
                        .multilineTextAlignment(.center)

                    Text(snap.roundKind.ruleSummary)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(PopArt.ink.opacity(0.9))
                        .multilineTextAlignment(.center)

                    Text("🎙️ Écoute Meemaw — démarrage auto dans \(max(1, Int(ceil(snap.timeRemainingSec))))s...")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(PopArt.yellow, in: Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(18)
            }

            if snap.roundKind == .cashSpeed, let sponsor = snap.activeSponsor {
                PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                    VStack(spacing: 5) {
                        Text("🪤 SPONSOR DU JOUR (RÉPONSE CACHÉE)")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(PopArt.orange, in: Capsule())
                        Text(sponsor.name)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                        Text(sponsor.slogan)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(PopArt.ink.opacity(0.75))
                            .multilineTextAlignment(.center)
                        Text(AppLanguage.isEnglish
                             ? "🎁 Spot our sponsor's product hidden in a multiple-choice question to win +\(sponsor.jackpotReward) PTS!"
                             : "🎁 Repère ce sponsor caché dans un QCM pour rafler +\(sponsor.jackpotReward) PTS !")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(PopArt.greenSuccess)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
            }
        }
    }

    // MARK: - 3A-Bis. Manche : 🔢 « Le Juste Pif » (Estimation Numérique au Plus Proche)

    private var justePifControllerSection: some View {
        VStack(spacing: 8) {
            if let pif = snap.activeJustePif {
                PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                    VStack(spacing: 5) {
                        HStack {
                            Text("🔢 LE JUSTE PIF • « \(pif.funnyTitle) »")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.orange)
                                .lineLimit(1)
                            Spacer()
                            Text(pif.unitLabel)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3)
                                .background(PopArt.yellow, in: Capsule())
                        }
                        Text(pif.prompt)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }

                if snap.stage == .justePifReveal {
                    PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                        VStack(spacing: 8) {
                            Text("🎯 VRAIE VALEUR : \(pif.correctValue) \(pif.unitLabel.uppercased())")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(PopArt.yellow, in: Capsule())
                                .multilineTextAlignment(.center)

                            Text(pif.meemawComment)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.85))
                                .multilineTextAlignment(.center)

                            VStack(spacing: 5) {
                                let ranked = snap.players.sorted {
                                    let d0 = abs(($0.lockedNumericEstimate ?? 999999) - pif.correctValue)
                                    let d1 = abs(($1.lockedNumericEstimate ?? 999999) - pif.correctValue)
                                    return d0 < d1
                                }
                                ForEach(ranked) { p in
                                    HStack {
                                        Text("\(p.avatarEmoji) \(p.name)")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundStyle(PopArt.ink)
                                        Spacer()
                                        if let est = p.lockedNumericEstimate {
                                            Text("\(est) \(pif.unitLabel)")
                                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                                .foregroundStyle(PopArt.ink)
                                        } else {
                                            Text("Pas répondu")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(PopArt.ink.opacity(0.5))
                                        }
                                        if let delta = p.lastDeltaScore {
                                            Text(delta >= 0 ? "+\(delta)" : "\(delta)")
                                                .font(.system(size: 13, weight: .black, design: .rounded))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(delta >= 0 ? PopArt.greenSuccess : PopArt.redError, in: Capsule())
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(14)
                    }
                } else if let lockedVal = me?.lockedNumericEstimate {
                    let count = snap.players.filter { $0.lockedNumericEstimate != nil }.count
                    PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                        VStack(spacing: 4) {
                            Text("🔒 TON PIF VERROUILLÉ : \(lockedVal) \(pif.unitLabel)")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                            Text("⏳ En attente des autres joueurs (\(count)/\(snap.players.count))...")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(PopArt.ink.opacity(0.75))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                    }
                } else {
                    PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.cream) {
                        VStack(spacing: 7) {
                            HStack {
                                Text(justePifInputString.isEmpty ? "—" : justePifInputString)
                                    .font(.system(size: 26, weight: .black, design: .monospaced))
                                    .foregroundStyle(PopArt.ink)
                                Text(pif.unitLabel)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(PopArt.ink.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(PopArt.white, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink.opacity(0.5), lineWidth: 1.5))

                            let rows = [
                                ["1", "2", "3"],
                                ["4", "5", "6"],
                                ["7", "8", "9"],
                                ["⌫", "0", "OK"]
                            ]
                            ForEach(rows, id: \.self) { row in
                                HStack(spacing: 8) {
                                    ForEach(row, id: \.self) { key in
                                        Button {
                                            if key == "⌫" {
                                                if !justePifInputString.isEmpty {
                                                    justePifInputString.removeLast()
                                                }
                                            } else if key == "OK" {
                                                if let val = Int(justePifInputString) {
                                                    session.submitNumericEstimate(val)
                                                }
                                            } else if justePifInputString.count < 7 {
                                                if justePifInputString == "0" {
                                                    justePifInputString = key
                                                } else {
                                                    justePifInputString.append(key)
                                                }
                                            }
                                        } label: {
                                            Text(key == "OK" ? "✅ VALIDER" : key)
                                                .font(.system(size: key == "OK" ? 14 : 21, weight: .black, design: .rounded))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 9)
                                        }
                                        .buttonStyle(
                                            PopArtActionButtonStyle(
                                                backgroundColor: key == "OK" ? PopArt.greenSuccess : (key == "⌫" ? PopArt.cream : PopArt.white),
                                                foregroundColor: key == "OK" ? .white : PopArt.ink,
                                                cornerRadius: 12
                                            )
                                        )
                                        .disabled(key == "OK" && Int(justePifInputString) == nil)
                                    }
                                }
                            }
                        }
                        .padding(10)
                    }
                }
            }
        }
    }

    // MARK: - 3A-Ter. Grande Finale : ⚡ « Le Jack Attack de Meemaw » (Buzzer Ultra-Rapide)

    private var jackAttackControllerSection: some View {
        VStack(spacing: 10) {
            if let round = snap.activeJackAttack,
               let wIdx = snap.activeJackAttackWaveIndex,
               round.waves.indices.contains(wIdx) {
                let wave = round.waves[wIdx]
                let optIdx = snap.activeJackAttackOptionIndex ?? 0
                let currentOption = wave.options.indices.contains(optIdx) ? wave.options[optIdx] : "..."
                let isFrozen = me?.isJackAttackFrozen ?? false

                PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                    VStack(spacing: 6) {
                        HStack {
                            Text("⚡ JACK ATTACK • VAGUE \(wIdx + 1)/\(round.waves.count)")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(PopArt.yellow, in: Capsule())
                            Spacer()
                            Text("+3 000 / -1 500")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(PopArt.ink.opacity(0.75))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(PopArt.cream, in: Capsule())
                        }
                        Text(wave.clueTitle)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(PopArt.orange)
                            .multilineTextAlignment(.center)
                        Text(wave.anchorText)
                            .font(.system(size: 21, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                }

                if snap.stage == .jackAttackWaveReveal {
                    PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                        VStack(spacing: 8) {
                            if let winner = snap.jackAttackWinnerName {
                                Text("⚡ \(winner.uppercased()) A BUZZÉ EN 1ER (+3 000 PTS) !")
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.greenSuccess)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("⏰ PERSONNE N'A BUZZÉ À TEMPS !")
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.redError)
                            }
                            Text("\(wave.anchorText) ➜ \(wave.options[wave.correctOptionIndex])")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                            Text(wave.explanation)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(PopArt.ink.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                    }
                } else {
                    Button {
                        session.submitJackAttackBuzz()
                    } label: {
                        VStack(spacing: 8) {
                            Text(isFrozen ? "🧊 BUZZER GELÉ (-1 500 PTS)" : "🚨 BUZZER MAINTENANT !")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(isFrozen ? .white.opacity(0.85) : PopArt.yellow)
                            Text(currentOption)
                                .font(.system(size: 25, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                            Text(isFrozen ? "Tu as buzzé sur un piège pendant cette vague !" : "Tape dès que la BONNE association s'affiche !")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 26)
                    }
                    .buttonStyle(
                        PopArtActionButtonStyle(
                            backgroundColor: isFrozen ? Color.gray : PopArt.redError,
                            foregroundColor: .white,
                            cornerRadius: 22
                        )
                    )
                    .disabled(isFrozen)
                }
            }
        }
    }

    // MARK: - 3B. Manche 2 : 🎯 « Tu Te Mets Combien ? » (Mise de 1 à 4 Étoiles — Calme & Sans Scroll)

    private var ttmcBettingControllerSection: some View {
        VStack(spacing: 8) {
            if let q = snap.activeQuestion {
                PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.cream) {
                    HStack(spacing: 12) {
                        MeemawPoseIllustration(
                            assetName: "meemaw_score",
                            size: 56,
                            isCircularStage: true
                        )

                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 6) {
                                Text("🎯 TU TE METS COMBIEN ?")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 4)
                                    .background(PopArt.blue, in: Capsule())

                                Text(q.theme.shortBadge)
                                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                    .foregroundStyle(PopArt.ink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(PopArt.yellow, in: Capsule())

                                if let dec = q.decade {
                                    Text(dec.shortTag)
                                        .font(.system(size: 10.5, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(PopArt.orange, in: Capsule())
                                }
                            }

                            Text("« \(q.funnyTitle) »")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }

                if let lockedStars = me?.lockedBetStars {
                    let betCount = snap.players.filter { $0.lockedBetStars != nil }.count
                    let stakes = QuizScoringEngine.ttmcStakes(for: lockedStars)
                    PopArtCard(cornerRadius: 14, borderWidth: 2, backgroundColor: PopArt.white) {
                        HStack {
                            Text("🔒 Pari : \(String(repeating: "⭐", count: lockedStars)) (+\(stakes.win) / \(stakes.loss))")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                            Spacer()
                            Text("⏳ \(betCount)/\(snap.players.count) prêts")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.75))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }

                let starOptions: [(stars: Int, title: String, subtitle: String, badgeColor: Color, badgeText: Color)] = [
                    (1, "⭐ 1 Étoile • Prudent", "+1 000 pts  •  -250 pts", PopArt.cyan, .white),
                    (2, "⭐⭐ 2 Étoiles • Confiant", "+2 000 pts  •  -500 pts", PopArt.blue, .white),
                    (3, "⭐⭐⭐ 3 Étoiles • Audacieux", "+3 500 pts  •  -1 000 pts", PopArt.yellow, PopArt.ink),
                    (4, "⭐⭐⭐⭐ 4 Étoiles • Expert", "+5 000 pts  •  -2 500 pts", PopArt.orange, .white)
                ]

                ForEach(starOptions, id: \.stars) { opt in
                    let isSelected = (me?.lockedBetStars == opt.stars)
                    let hasLocked = (me?.lockedBetStars != nil)
                    Button {
                        session.submitBetStars(opt.stars)
                    } label: {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(opt.title)
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.ink)
                                Text(opt.subtitle)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(PopArt.ink.opacity(0.75))
                            }
                            Spacer()
                            Text(isSelected ? "🔒 MISÉ" : "Miser")
                                .font(.system(size: 12.5, weight: .black, design: .rounded))
                                .foregroundStyle(isSelected ? PopArt.ink : opt.badgeText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isSelected ? PopArt.white : opt.badgeColor, in: Capsule())
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(
                        PopArtActionButtonStyle(
                            backgroundColor: isSelected ? PopArt.yellow : PopArt.white,
                            foregroundColor: PopArt.ink,
                            cornerRadius: 15
                        )
                    )
                    .opacity((hasLocked && !isSelected) ? 0.45 : 1.0)
                    .disabled(hasLocked)
                }
            }
        }
    }

    // MARK: - 4. Manche 4 : « LE SOLO » ou « CLOUER LE BEC » (Style Jack)

    private var soloBuzzerControllerSection: some View {
        VStack(spacing: 8) {
            if let q = snap.activeQuestion {
                PopArtCard(cornerRadius: 16, borderWidth: 2, backgroundColor: PopArt.cream) {
                    HStack(spacing: 10) {
                        MeemawPoseIllustration(
                            assetName: "meemaw_boxing_referee",
                            size: 42,
                            isCircularStage: true
                        )
                        Text("🚨 LE SOLO • 1er qui répond")
                            .font(.system(size: 12.5, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.redError)
                        Spacer()
                        Text("+\(q.baseValue * 2) / -\(q.baseValue) PTS")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(PopArt.blue, in: Capsule())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
            cashMCQControllerSection
        }
    }

    private var soloAnsweringControllerSection: some View {
        VStack(spacing: 8) {
            if snap.soloBuzzerPlayerID == session.localPlayerID {
                PopArtCard(cornerRadius: 14, borderWidth: 2, backgroundColor: PopArt.cream) {
                    VStack(spacing: 2) {
                        if let attacker = snap.screwAttackerName {
                            Text("🔩 \(attacker.uppercased()) T'A CLOUÉ LE BEC !")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.redError)
                            Text("Réponds juste pour doubler les points et punir \(attacker) !")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.8))
                        } else {
                            Text("🔥 TU AS PRIS LE SOLO ! 12 SECONDES POUR RÉPONDRE !")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.redError)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                }
                cashMCQControllerSection
            } else {
                PopArtCard(cornerRadius: 20, borderWidth: 2, backgroundColor: PopArt.white) {
                    VStack(spacing: 10) {
                        Text(snap.screwAttackerName != nil ? "🔩" : "🍿")
                            .font(.system(size: 46))
                        if let attacker = snap.screwAttackerName {
                            Text("🔩 \(attacker) a cloué le bec de \(snap.soloBuzzerPlayerName ?? "un joueur") !")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                            Text("Il est tout seul face à la question pendant \(max(1, Int(ceil(snap.timeRemainingSec))))s !")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(PopArt.ink.opacity(0.72))
                                .multilineTextAlignment(.center)
                        } else {
                            Text("\(snap.soloBuzzerPlayerName ?? "Un joueur") a dégainé en 1er !")
                                .font(.system(size: 19, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                            Text("Regarde s'il rafle le double ou s'il perd tout !")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(PopArt.ink.opacity(0.72))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                }
            }
        }
    }

    // MARK: - 5. Cash Speed, Solo & Finale ×2 Tactile A / B / C / D Buttons + Compact Jokers (Zero Scroll)

    private var cashMCQControllerSection: some View {
        VStack(spacing: 8) {
            if let q = snap.activeQuestion {
                let letters = ["A", "B", "C", "D"]

                if snap.roundKind == .tuTeMetsCombien, let stars = me?.lockedBetStars, snap.stage != .questionReveal {
                    let stakes = QuizScoringEngine.ttmcStakes(for: stars)
                    PopArtCard(cornerRadius: 12, borderWidth: 1.5, backgroundColor: PopArt.cream) {
                        HStack {
                            Text("🎯 Pari : \(String(repeating: "⭐", count: stars))")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                            Spacer()
                            Text("+\(stakes.win) / \(stakes.loss) PTS")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(PopArt.ink.opacity(0.75))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                }

                // 1) En attente des autres joueurs
                if snap.stage == .cashAnswering, let myChosen = me?.lockedChoiceIndex {
                    let answeredCount = snap.players.filter { $0.lockedChoiceIndex != nil }.count
                    PopArtCard(cornerRadius: 14, borderWidth: 2, backgroundColor: PopArt.cream) {
                        HStack {
                            Text("🔒 Choix \(letters[myChosen]) verrouillé")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                            Spacer()
                            Text("⏳ \(answeredCount)/\(snap.players.count) ont répondu")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }

                // 2) Révélation regroupée en haut (Verdict + Explication + Bouton Suivant sans scroller)
                if snap.stage == .questionReveal {
                    let myChosen = me?.lockedChoiceIndex
                    let correctIdx = snap.revealedCorrectIndex ?? q.correctIndex
                    let correctText = q.choices.indices.contains(correctIdx) ? "\(letters[correctIdx]) • \(q.choices[correctIdx])" : ""
                    let delta = me?.lastDeltaScore ?? 0
                    let isWin = (delta > 0) || (myChosen != nil && myChosen == correctIdx)

                    PopArtCard(
                        cornerRadius: 18,
                        borderWidth: 2,
                        backgroundColor: PopArt.white
                    ) {
                        VStack(spacing: 7) {
                            HStack {
                                Text(isWin ? "✅ BONNE RÉPONSE (+\(delta) PTS)" : (myChosen == nil && delta == 0 ? "⏰ TEMPS ÉCOULÉ (0 PT)" : "❌ MAUVAISE RÉPONSE (\(delta) PTS)"))
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(isWin ? PopArt.greenSuccess : PopArt.redError, in: Capsule())

                                Spacer()

                                Text("⏭️ \(max(1, Int(ceil(snap.timeRemainingSec))))s")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundStyle(PopArt.ink.opacity(0.6))
                            }

                            if !isWin {
                                Text("Réponse : \(correctText)")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.greenSuccess)
                                    .multilineTextAlignment(.center)
                            }

                            Text(q.explanation)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.88))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                    }
                } else {
                    PopArtCard(cornerRadius: 16, borderWidth: 2, backgroundColor: PopArt.white) {
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                if let dec = q.decade {
                                    Text(dec.badgeLabel)
                                        .font(.system(size: 10.5, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(PopArt.blue, in: Capsule())
                                }
                                Text(q.funnyTitle)
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.orange)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                            }
                            Text(q.prompt)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .minimumScaleFactor(0.85)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(11)
                    }
                }

                let letterBadgeColors: [Color] = [
                    PopArt.blue,          // A: App Icon Blazer Blue
                    PopArt.orange,        // B: App Icon Copper-Orange
                    PopArt.goldTrim,      // C: App Icon Spotlight Gold
                    PopArt.greenSuccess   // D: App Icon Emerald Green
                ]

                ForEach(0..<q.choices.count, id: \.self) { idx in
                    let isMyChoice = (me?.lockedChoiceIndex == idx)
                    let hasLockedSomething = (me?.lockedChoiceIndex != nil)
                    let isRevealed = (snap.stage == .questionReveal)
                    let isCorrect = (snap.revealedCorrectIndex == idx)
                    let badgeColor = letterBadgeColors[idx % letterBadgeColors.count]

                    let btnBg: Color = {
                        if isRevealed {
                            if isCorrect { return PopArt.greenSuccess }
                            if isMyChoice { return PopArt.redError }
                            return PopArt.white
                        }
                        return isMyChoice ? PopArt.yellow : PopArt.white
                    }()

                    Button {
                        session.submitChoice(idx)
                    } label: {
                        HStack(spacing: 11) {
                            Text(letters[idx])
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    isRevealed && (isCorrect || isMyChoice)
                                        ? PopArt.ink
                                        : .white
                                )
                                .frame(width: 36, height: 36)
                                .background(
                                    isRevealed && (isCorrect || isMyChoice)
                                        ? PopArt.white.opacity(0.95)
                                        : badgeColor,
                                    in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                                        .strokeBorder(PopArt.ink.opacity(0.65), lineWidth: 1.5)
                                )

                            Text(q.choices[idx])
                                .font(.system(size: 15.5, weight: .bold, design: .rounded))
                                .foregroundStyle(isRevealed && (isCorrect || isMyChoice) ? .white : PopArt.ink)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)

                            Spacer(minLength: 4)

                            if isRevealed && isCorrect {
                                Text("✅")
                                    .font(.system(size: 16))
                            } else if isRevealed && isMyChoice && !isCorrect {
                                Text("❌")
                                    .font(.system(size: 16))
                            } else if isMyChoice {
                                Text("🔒")
                                    .font(.system(size: 15))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: btnBg, cornerRadius: 15))
                    .opacity((hasLockedSomething && !isMyChoice && !isRevealed) ? 0.45 : (isRevealed && !isCorrect && !isMyChoice ? 0.55 : 1.0))
                    .disabled(me?.lockedChoiceIndex != nil || snap.stage == .questionReveal)
                }

                // Compact Single-Line Jokers Bar (🔩 Clouer le Bec & 💋 Bisou Baveux) — 44pt iOS Touch Targets
                let opponents = snap.players.filter { $0.id != session.localPlayerID }
                if snap.stage == .cashAnswering,
                   let me,
                   !opponents.isEmpty,
                   (!me.hasUsedScrew || !me.hasUsedBisouTrap) {
                    HStack(spacing: 8) {
                        if !me.hasUsedScrew {
                            Menu {
                                ForEach(opponents) { target in
                                    Button {
                                        session.sendScrewOpponent(to: target.id)
                                    } label: {
                                        Text("🔩 Clouer le bec de \(target.avatarEmoji) \(target.name)")
                                    }
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Text("🔩 Clouer un adversaire")
                                        .font(.system(size: 12.5, weight: .black, design: .rounded))
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(PopArt.blue, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                                        .strokeBorder(PopArt.yellow, lineWidth: 1.5)
                                )
                            }
                        }

                        if !me.hasUsedBisouTrap {
                            Menu {
                                ForEach(opponents) { target in
                                    Button {
                                        session.sendBisouTrap(to: target.id)
                                    } label: {
                                        Text("💋 Bisou baveux sur \(target.avatarEmoji) \(target.name)")
                                    }
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Text("💋 Bisou baveux")
                                        .font(.system(size: 12.5, weight: .black, design: .rounded))
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(PopArt.redError, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                                        .strokeBorder(PopArt.yellow, lineWidth: 1.5)
                                )
                            }
                        }
                    }
                    .padding(.top, 2)
                }
            }
        }
    }

    // MARK: - 6. Manche 3 : Raclette Quizz Buttons (Calm Palette & Zero Scroll)

    private func disOrDatButtonColor(side: String, defaultColor: Color) -> Color {
        let mySide = me?.lockedSide
        if snap.stage == .couciCoucaReveal, let correct = snap.revealedBinarySide {
            if correct == side { return PopArt.greenSuccess }
            if mySide == side { return PopArt.redError }
            return PopArt.white.opacity(0.5)
        }
        return mySide == side ? PopArt.yellow : defaultColor
    }

    private func disOrDatForegroundColor(side: String) -> Color {
        let mySide = me?.lockedSide
        if snap.stage == .couciCoucaReveal {
            return .white
        }
        return mySide == side ? PopArt.ink : PopArt.ink
    }

    private var couciCoucaControllerSection: some View {
        VStack(spacing: 10) {
            if snap.stage == .couciCoucaSummary {
                PopArtCard(cornerRadius: 20, borderWidth: 2, backgroundColor: PopArt.white) {
                    VStack(spacing: 8) {
                        Text("🧀 FIN DE LA RACLETTE QUIZZ !")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                        Text("Ton score actuel : \(me?.score ?? 0) PTS")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundStyle(PopArt.orange)
                        Text("🔥 La suite démarre dans \(max(1, Int(ceil(snap.timeRemainingSec))))s...")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(PopArt.ink.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(18)
                }
            } else if let round = snap.activeDisOrDat {
                let idx = snap.activeDisOrDatItemIndex ?? 0
                let item = round.items.indices.contains(idx) ? round.items[idx] : nil

                if snap.stage == .couciCoucaItem, let mySide = me?.lockedSide {
                    let answeredCount = snap.players.filter { $0.lockedSide != nil }.count
                    let chosenLabel = (mySide == "left") ? round.optionLeft : (mySide == "both" ? (round.optionBoth ?? "LES DEUX") : round.optionRight)
                    PopArtCard(cornerRadius: 14, borderWidth: 2, backgroundColor: PopArt.cream) {
                        HStack {
                            Text("🔒 Choix : \(chosenLabel)")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .lineLimit(1)
                            Spacer()
                            Text("⏳ \(answeredCount)/\(snap.players.count)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }

                PopArtCard(cornerRadius: 18, borderWidth: 2, backgroundColor: PopArt.white) {
                    VStack(spacing: 6) {
                        HStack {
                            Text("QUESTION \(idx + 1) / \(round.items.count)")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(PopArt.yellow, in: Capsule())

                            Spacer()

                            Text(round.funnyTitle)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.orange)
                                .lineLimit(1)
                        }

                        Text(item?.text ?? round.prompt)
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                }

                if snap.stage == .couciCoucaReveal, let correctSide = snap.revealedBinarySide {
                    let mySide = me?.lockedSide
                    let isRight = (mySide != nil && mySide == correctSide)
                    let delta = me?.lastDeltaScore ?? 0
                    let correctLabel = (correctSide == "left") ? round.optionLeft : (correctSide == "both" ? (round.optionBoth ?? "🧀 LES DEUX !") : round.optionRight)

                    PopArtCard(
                        cornerRadius: 18,
                        borderWidth: 2,
                        backgroundColor: PopArt.white
                    ) {
                        VStack(spacing: 8) {
                            Text(isRight ? "✅ C'EST GAGNÉ ! (+\(delta) PTS)" : (mySide == nil ? "⏰ TROP TARD !" : "❌ C'EST PERDU ! (\(delta) PTS)"))
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(isRight ? PopArt.greenSuccess : PopArt.redError, in: Capsule())

                            Text("Bonne réponse : \(correctLabel)")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                    }
                } else {
                    let hasLockedSide = (me?.lockedSide != nil)

                    HStack(spacing: 10) {
                        Button {
                            session.submitBinarySide("left")
                        } label: {
                            VStack(spacing: 7) {
                                Text(me?.lockedSide == "left" ? "🔒" : "⬅️")
                                    .font(.system(size: 20))
                                    .frame(width: 38, height: 38)
                                    .background(PopArt.blue, in: Circle())
                                Text(round.optionLeft)
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                            }
                            .foregroundStyle(PopArt.ink)
                            .frame(maxWidth: .infinity, minHeight: round.optionBoth != nil ? 104 : 130)
                            .padding(10)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: disOrDatButtonColor(side: "left", defaultColor: PopArt.white),
                                foregroundColor: PopArt.ink,
                                cornerRadius: 18
                            )
                        )
                        .opacity((hasLockedSide && me?.lockedSide != "left") ? 0.45 : 1.0)
                        .disabled(me?.lockedSide != nil || snap.stage != .couciCoucaItem)

                        Button {
                            session.submitBinarySide("right")
                        } label: {
                            VStack(spacing: 7) {
                                Text(me?.lockedSide == "right" ? "🔒" : "➡️")
                                    .font(.system(size: 20))
                                    .frame(width: 38, height: 38)
                                    .background(PopArt.orange, in: Circle())
                                Text(round.optionRight)
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                            }
                            .foregroundStyle(PopArt.ink)
                            .frame(maxWidth: .infinity, minHeight: round.optionBoth != nil ? 104 : 130)
                            .padding(10)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: disOrDatButtonColor(side: "right", defaultColor: PopArt.white),
                                foregroundColor: PopArt.ink,
                                cornerRadius: 18
                            )
                        )
                        .opacity((hasLockedSide && me?.lockedSide != "right") ? 0.45 : 1.0)
                        .disabled(me?.lockedSide != nil || snap.stage != .couciCoucaItem)
                    }

                    if let bothLabel = round.optionBoth {
                        Button {
                            session.submitBinarySide("both")
                        } label: {
                            HStack(spacing: 8) {
                                Text(me?.lockedSide == "both" ? "🔒" : "🧀")
                                    .font(.system(size: 22))
                                Text(bothLabel)
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                            }
                            .foregroundStyle(PopArt.ink)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .padding(.horizontal, 14)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: disOrDatButtonColor(side: "both", defaultColor: PopArt.yellow),
                                foregroundColor: PopArt.ink,
                                cornerRadius: 16
                            )
                        )
                        .opacity((hasLockedSide && me?.lockedSide != "both") ? 0.45 : 1.0)
                        .disabled(me?.lockedSide != nil || snap.stage != .couciCoucaItem)
                    }
                }
            }
        }
    }

    // MARK: - 7. Final Podium Controller Card

    private var finalPodiumControllerSection: some View {
        VStack(spacing: 12) {
            if let myAward = snap.podiumAwards.first(where: { $0.playerID == session.localPlayerID }) {
                PopArtCard(cornerRadius: 22, borderWidth: 2.5, backgroundColor: PopArt.cream) {
                    VStack(spacing: 10) {
                        MeemawPoseIllustration(
                            assetName: "meemawHoldingTrophyBig",
                            size: 92,
                            isCircularStage: true
                        )

                        Text("🏆 TON RÉSULTAT : #\(myAward.rank)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(PopArt.yellow, in: Capsule())
                        Text(myAward.funnyTitle)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.orange)
                            .multilineTextAlignment(.center)
                        Text("\(myAward.score) POINTS")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundStyle(PopArt.ink)
                        Text(myAward.subtitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(PopArt.ink.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(18)
                }
            }

            if session.role == .hostAndPlayer1 {
                Button {
                    session.startNewShow()
                } label: {
                    Text("🔄 REJOUER UNE PARTIE")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.orange, foregroundColor: .white, cornerRadius: 16))

                Button {
                    session.returnToLobby()
                } label: {
                    Text("🏠 Retour au salon (Changer de mode)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 46)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.white, cornerRadius: 14))
            } else {
                Button {
                    session.leaveRemoteSession()
                } label: {
                    Text("🚪 Quitter la partie")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.redError, foregroundColor: .white, cornerRadius: 14))
            }
        }
    }

    private var inGameQuitAndStopFooter: some View {
        HStack(spacing: 10) {
            if session.role == .hostAndPlayer1 {
                Button {
                    session.finishGameToPodiumNow()
                } label: {
                    Text("🏆 Finir sur le Podium")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.white, cornerRadius: 14))

                Button {
                    session.returnToLobby()
                } label: {
                    Text("⏹️ Arrêter / Quitter")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.redError, foregroundColor: .white, cornerRadius: 14))
            } else {
                Button {
                    session.leaveRemoteSession()
                } label: {
                    Text("🚪 Quitter la partie")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.redError, foregroundColor: .white, cornerRadius: 14))
            }
        }
        .padding(.top, 6)
    }

    // MARK: - 8. Bisou Baveux Sabotage Overlay

    private func bisouSabotageOverlay(wipesRemaining: Int, senderName: String) -> some View {
        ZStack {
            PopArt.pink.opacity(0.94)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("💋👵💋")
                    .font(.system(size: 86))
                Text("BISOU BAVEUX DE \(senderName.uppercased()) !")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("TAPE ENCORE \(wipesRemaining) FOIS POUR ESSUYER TON ÉCRAN !")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(PopArt.yellow)
                    .multilineTextAlignment(.center)

                Button {
                    session.wipeLocalBisouScreen()
                } label: {
                    Text("🧽 ESSUYER LA BAVE (\(wipesRemaining))")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 18)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 20))
            }
            .padding(28)
        }
        .onTapGesture {
            session.wipeLocalBisouScreen()
        }
    }
}
