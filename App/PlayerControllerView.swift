import MeemawQuizzCore
import SwiftUI

struct PlayerControllerView: View {
    @Bindable var session: GameSessionController
    var displayManager = ExternalDisplayManager.shared

    private var snap: HostToClientStateSnapshot {
        session.effectiveSnapshot
    }

    private var me: QuizPlayer? {
        session.localPlayer
    }

    var body: some View {
        ZStack {
            PopArtTVBackground(roundKind: snap.roundKind)

            VStack(spacing: 12) {
                topPlayerAndHostBar

                if displayManager.isPreviewTVOnPhoneSelected {
                    MeemawTVStageView(session: session)
                        .aspectRatio(16.0 / 9.0, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(PopArt.ink, lineWidth: 3.5)
                        )
                        .shadow(color: PopArt.ink.opacity(0.35), radius: 6, x: 0, y: 4)
                } else if !displayManager.isExternalTVSceneConnected
                            && snap.stage != .drawLiveGuessing
                            && snap.stage != .esquisseDrawing {
                    compactPhoneMeemawBanner
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
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
                        case .couciCoucaIntro, .couciCoucaItem, .couciCoucaReveal, .couciCoucaSummary:
                            couciCoucaControllerSection
                        case .drawWordChoice, .drawLiveGuessing, .drawReveal:
                            drawSomethingControllerSection
                        case .esquissePromptEntry, .esquisseDrawing, .esquisseGuessing, .esquisseShowcase:
                            esquisseControllerSection
                        case .finalPodium:
                            finalPodiumControllerSection
                        }

                        if snap.stage != .lobby && snap.stage != .finalPodium {
                            inGameQuitAndStopFooter
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)

            // Bisou Baveux Screen Sabotage Overlay
            if let me, me.activeBisouWipesRemaining > 0 {
                bisouSabotageOverlay(wipesRemaining: me.activeBisouWipesRemaining, senderName: me.bisouSenderName ?? "Meemaw")
            }
        }
        .background(SceneAccessoryHostInjector().frame(width: 0, height: 0))
        .onChange(of: snap.stage) { _, newStage in
            if newStage == .questionReveal || newStage == .couciCoucaReveal {
                let delta = me?.lastDeltaScore ?? 0
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(delta > 0 ? .success : .error)
            }
        }
    }

    // MARK: - 1. Top Player Status & Host Régie Bar

    private var topPlayerAndHostBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Text(me?.avatarEmoji ?? session.localAvatarEmoji)
                        .font(.system(size: 22))
                    Text(me?.name ?? session.localPlayerName)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(PopArt.color(for: me?.color ?? session.localSelectedColor), in: Capsule())
                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2.5))

                Spacer()

                Text("\(me?.score ?? 0) PTS")
                    .font(.system(size: 17, weight: .black, design: .monospaced))
                    .foregroundStyle(PopArt.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(PopArt.yellow, in: Capsule())
                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2.5))

                Button {
                    displayManager.isPreviewTVOnPhoneSelected.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: displayManager.isPreviewTVOnPhoneSelected ? "tv.fill" : "tv")
                        Text("TV")
                            .font(.system(size: 13, weight: .black))
                    }
                    .foregroundStyle(PopArt.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(displayManager.isPreviewTVOnPhoneSelected ? PopArt.orange : PopArt.white, in: Capsule())
                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2.5))
                }

                Button {
                    session.audio.isMusicMuted.toggle()
                } label: {
                    Image(systemName: session.audio.isMusicMuted ? "speaker.slash.fill" : "music.note")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(PopArt.ink)
                        .frame(width: 34, height: 34)
                        .background(session.audio.isMusicMuted ? PopArt.white : PopArt.cyan, in: Circle())
                        .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2.5))
                }

                AirPlayRoutePickerButton(tintColor: .black)
                    .frame(width: 34, height: 34)
                    .background(PopArt.white, in: Circle())
                    .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2.5))
            }

            if session.role == .hostAndPlayer1 {
                HStack(spacing: 8) {
                    Label(
                        displayManager.isExternalTVSceneConnected
                            ? "AirPlay TV 16:9 Actif"
                            : "Serveur : \(snap.players.count) joueur(s)",
                        systemImage: displayManager.isExternalTVSceneConnected ? "airplayvideo" : "wifi"
                    )
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(PopArt.ink)

                    Spacer()

                    if snap.stage == .lobby {
                        if snap.players.contains(where: { $0.id.hasPrefix("bot_") }) {
                            Button {
                                session.removeAllBots()
                            } label: {
                                Text("🧹 Bots")
                                    .font(.system(size: 12, weight: .black))
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.white, cornerRadius: 10))
                        }

                        Button {
                            session.addDemoBotPlayers()
                        } label: {
                            Text("+ 🤖 Bot")
                                .font(.system(size: 12, weight: .black))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.white, cornerRadius: 10))

                        Button {
                            session.startNewShow()
                        } label: {
                            Text("▶️ LANCER")
                                .font(.system(size: 12, weight: .black))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.greenSuccess, foregroundColor: .white, cornerRadius: 10))
                    } else {
                        Button {
                            session.skipToNextStep()
                        } label: {
                            Text("⏭️ Suivant")
                                .font(.system(size: 12, weight: .black))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 10))

                        if snap.stage != .finalPodium {
                            Button {
                                session.finishGameToPodiumNow()
                            } label: {
                                Text("🏆 Podium")
                                    .font(.system(size: 12, weight: .black))
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.white, cornerRadius: 10))
                        }

                        Button {
                            session.returnToLobby()
                        } label: {
                            Text("⏹️ Arrêter")
                                .font(.system(size: 12, weight: .black))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.redError, foregroundColor: .white, cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2))
            } else {
                HStack(spacing: 8) {
                    Label(
                        session.isBonjourConnectedToRemoteHost ? "Connecté au salon AirPlay" : "Recherche du salon...",
                        systemImage: "bonjour"
                    )
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(PopArt.ink)

                    Spacer()

                    Button {
                        session.leaveRemoteSession()
                    } label: {
                        Text("🚪 Quitter la partie")
                            .font(.system(size: 12, weight: .black))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.redError, foregroundColor: .white, cornerRadius: 10))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2))
            }
        }
    }

    // MARK: - 1B. Compact Meemaw Banner on Phone (when testing without AirPlay TV)

    private var compactPhoneMeemawBanner: some View {
        PopArtCard(cornerRadius: 18, borderWidth: 3, backgroundColor: PopArt.white, shadowOffset: 4) {
            HStack(spacing: 12) {
                MeemawGuestStarAvatar(
                    pose: snap.meemawPose,
                    isSpeaking: MeemawShowAudioEngine.shared.isMeemawSpeaking,
                    size: 62
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(snap.stage == .lobby ? "🎙️ MEEMAW QUIZZ" : snap.roundKind.badgeTitle)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.orange)
                        Spacer()
                        if snap.timeRemainingSec > 0 && (snap.stage == .ttmcBetting || snap.stage == .cashAnswering || snap.stage == .soloBuzzOpen || snap.stage == .soloPlayerAnswering || snap.stage == .couciCoucaItem) {
                            Text(String(format: "⏱️ %.1fs", snap.timeRemainingSec))
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundStyle(snap.timeRemainingSec <= 3.5 ? PopArt.redError : PopArt.ink)
                        }
                    }

                    Text(snap.meemawSpeech)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(PopArt.ink)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(10)
        }
    }

    // MARK: - 2. Lobby Section (Role Switch, Profile, Colors & Theme Picker)

    private var lobbyControllerSection: some View {
        VStack(spacing: 14) {
            // Mode Hôte vs Client Bonjour
            HStack(spacing: 8) {
                Button {
                    session.startHostingSession()
                } label: {
                    HStack {
                        Image(systemName: "tv.and.mediabox")
                        Text("Héberger AirPlay")
                    }
                    .font(.system(size: 13, weight: .black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(
                    PopArtActionButtonStyle(
                        backgroundColor: session.role == .hostAndPlayer1 ? PopArt.orange : PopArt.white,
                        cornerRadius: 14
                    )
                )

                Button {
                    session.switchToBonjourClientMode()
                } label: {
                    HStack {
                        Image(systemName: "bonjour")
                        Text("Rejoindre Salon (Auto)")
                    }
                    .font(.system(size: 13, weight: .black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(
                    PopArtActionButtonStyle(
                        backgroundColor: session.role == .bonjourClient ? PopArt.cyan : PopArt.white,
                        foregroundColor: session.role == .bonjourClient ? .white : PopArt.ink,
                        cornerRadius: 14
                    )
                )
            }

            // Profile & Available Color Picker Card
            PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.white) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("👤 TON PROFIL JOUEUR & TA COULEUR")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.orange)

                    HStack(spacing: 10) {
                        TextField("Ton pseudo...", text: $session.localPlayerName)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2.5))
                            .onSubmit {
                                session.sendLocalProfileUpdate()
                            }

                        Button {
                            session.sendLocalProfileUpdate()
                        } label: {
                            Text("OK")
                                .font(.system(size: 16, weight: .black))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.orange, cornerRadius: 12))
                    }

                    Text("Choisis une couleur disponible (verrouillée en direct) :")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(PopArt.ink.opacity(0.68))

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
                                VStack(spacing: 4) {
                                    Text(isTakenByOther ? "🔒" : colorOption.defaultEmoji)
                                        .font(.system(size: 22))
                                    Text(isTakenByOther ? (owner?.name ?? "Pris") : colorOption.label)
                                        .font(.system(size: 11, weight: .black, design: .rounded))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(PopArt.color(for: colorOption), in: RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(isMine ? PopArt.ink : PopArt.ink.opacity(0.6), lineWidth: isMine ? 4 : 2)
                                )
                                .opacity(isTakenByOther ? 0.35 : 1.0)
                                .scaleEffect(isMine ? 1.04 : 1.0)
                            }
                            .disabled(isTakenByOther)
                        }
                    }
                }
                .padding(16)
            }

            // Mode & Theme Picker (Host Only)
            if session.role == .hostAndPlayer1 {
                PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.white) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🎮 CHOISIS LE MODE DE SOIRÉE")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.orange)

                        ForEach(ShowGameMode.allCases) { mode in
                            let isModeSelected = (snap.selectedGameMode == mode)
                            Button {
                                session.selectGameMode(mode)
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(hex: mode.accentHex))
                                        .frame(width: 16, height: 16)
                                        .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(mode.title)
                                            .font(.system(size: 16, weight: .black, design: .rounded))
                                            .foregroundStyle(PopArt.ink)
                                        Text(mode.subtitle)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(PopArt.ink.opacity(0.68))
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    if isModeSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22, weight: .black))
                                            .foregroundStyle(Color(hex: mode.accentHex))
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(isModeSelected ? Color(hex: mode.accentHex).opacity(0.16) : PopArt.cream)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(isModeSelected ? Color(hex: mode.accentHex) : PopArt.ink.opacity(0.25), lineWidth: isModeSelected ? 3 : 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }

                PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.white) {
                    VStack(alignment: .leading, spacing: 10) {
                        if snap.selectedGameMode == .fullQuizShow {
                        HStack {
                            Text("📚 CHOISIS LE THÈME DU SHOW")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.orange)
                            Spacer()
                            Button {
                                session.resetSeenQuestionsHistory()
                            } label: {
                                Text("🔄 Reset vues")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.ink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(PopArt.cream, in: Capsule())
                                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 1.5))
                            }
                        }

                        ForEach(QuizThemePack.allCases) { pack in
                            let isSelected = (snap.selectedPack == pack)
                            let counts = session.unseenQuestionsCount(for: pack)
                            Button {
                                session.selectThemePack(pack)
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(hex: pack.accentHex))
                                        .frame(width: 16, height: 16)
                                        .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2))

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text(pack.title)
                                                .font(.system(size: 16, weight: .black, design: .rounded))
                                                .foregroundStyle(PopArt.ink)
                                            Text("\(counts.unseen)/\(counts.total) inédites")
                                                .font(.system(size: 10, weight: .black, design: .rounded))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 7)
                                                .padding(.vertical, 2)
                                                .background(Color(hex: pack.accentHex), in: Capsule())
                                        }
                                        Text(pack.subtitle)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(PopArt.ink.opacity(0.65))
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22, weight: .black))
                                            .foregroundStyle(PopArt.orange)
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(isSelected ? PopArt.orange.opacity(0.15) : PopArt.cream)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(isSelected ? PopArt.orange : PopArt.ink.opacity(0.25), lineWidth: isSelected ? 3 : 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        } // end if fullQuizShow

                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                Button {
                                    session.startSoloTestShow(withBots: false)
                                } label: {
                                    HStack(spacing: 6) {
                                        Text("🕹️ Tester Seul")
                                            .font(.system(size: 14, weight: .black, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                }
                                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 14))

                                Button {
                                    session.startSoloTestShow(withBots: true)
                                } label: {
                                    HStack(spacing: 6) {
                                        Text("🤖 Seul + 2 Bots")
                                            .font(.system(size: 14, weight: .black, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                }
                                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.cyan, foregroundColor: .white, cornerRadius: 14))
                            }

                            Button {
                                session.startNewShow()
                            } label: {
                                HStack {
                                    Text("👨‍👩‍👧‍👦 LANCER LE QUIZZ EN FAMILLE (\(snap.players.count) J.) !")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.orange, cornerRadius: 18))
                        }
                        .padding(.top, 4)

                        // QR Code & Lien Famille directement visible sur l'iPhone Hôte aussi
                        HStack(spacing: 12) {
                            if let qr = GameSessionController.makeQRCodeImage(from: snap.joinURL) {
                                Image(uiImage: qr)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 72, height: 72)
                                    .padding(4)
                                    .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(PopArt.ink, lineWidth: 2))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("📲 Inviter la famille sur le Wi-Fi :")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(PopArt.ink)
                                Text("• iPhone : Auto-connexion Bonjour\n• Android : Scanne ce QR ou ouvre :")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(PopArt.ink.opacity(0.7))
                                Text(snap.joinURL)
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundStyle(PopArt.blue)
                            }
                            Spacer()
                        }
                        .padding(10)
                        .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink.opacity(0.3), lineWidth: 2))
                        .padding(.top, 4)
                    }
                    .padding(16)
                }
            } else {
                // Bonjour Client Waiting Card
                PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.white) {
                    VStack(spacing: 10) {
                        Text(session.isBonjourConnectedToRemoteHost ? "✅ Connecté automatiquement via Bonjour !" : "📡 Recherche automatique du salon Bonjour sur le Wi-Fi...")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)

                        Text("Regarde l'écran AirPlay : dès que l'Hôte lance la partie, tes boutons apparaîtront ici !")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(PopArt.ink.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                }
            }
        }
    }

    // MARK: - 3. Round Intro Controller Card

    private var roundIntroControllerSection: some View {
        PopArtCard(cornerRadius: 24, borderWidth: 4, backgroundColor: PopArt.yellow) {
            VStack(spacing: 12) {
                Text(snap.roundKind.badgeTitle)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(PopArt.ink)
                    .multilineTextAlignment(.center)

                Text(snap.roundKind.ruleSummary)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(PopArt.ink.opacity(0.85))
                    .multilineTextAlignment(.center)

                Text("👀 Écoute Meemaw — démarrage auto dans \(max(1, Int(ceil(snap.timeRemainingSec))))s...")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(PopArt.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
        }
    }

    // MARK: - 3B. Manche 2 : 🎯 « Tu Te Mets Combien ? » (Mise de 1 à 4 Étoiles avant de voir la question)

    private var ttmcBettingControllerSection: some View {
        VStack(spacing: 12) {
            if let q = snap.activeQuestion {
                PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: Color(hex: "#FEF9C3")) {
                    VStack(spacing: 8) {
                        HStack {
                            Text("🎯 TU TE METS COMBIEN ?")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(PopArt.purple, in: Capsule())
                                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                            Spacer()
                            Text(q.theme.shortBadge)
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: q.theme.accentHex), in: Capsule())
                        }

                        Text("Sujet mystère de Meemaw :")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(PopArt.ink.opacity(0.75))

                        Text("« \(q.funnyTitle) »")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                }

                if let lockedStars = me?.lockedBetStars {
                    let betCount = snap.players.filter { $0.lockedBetStars != nil }.count
                    let stakes = QuizScoringEngine.ttmcStakes(for: lockedStars)
                    PopArtCard(cornerRadius: 18, borderWidth: 3.5, backgroundColor: PopArt.yellow) {
                        VStack(spacing: 4) {
                            Text("🔒 PARI VERROUILLÉ : \(String(repeating: "⭐", count: lockedStars)) (+\(stakes.win) PTS / \(stakes.loss) PTS)")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                            Text("⏳ En attente des paris des autres joueurs (\(betCount)/\(snap.players.count))...")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.8))
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                    }
                }

                let starOptions: [(stars: Int, title: String, subtitle: String, color: Color)] = [
                    (1, "⭐ 1 ÉTOILE • PETIT JOUEUR", "+1 000 PTS si bon  •  -250 PTS si faux", PopArt.cyan),
                    (2, "⭐⭐ 2 ÉTOILES • TRANQUILLE", "+2 000 PTS si bon  •  -500 PTS si faux", PopArt.greenSuccess),
                    (3, "⭐⭐⭐ 3 ÉTOILES • CHAUD BOUILLANT", "+3 500 PTS si bon  •  -1 000 PTS si faux", PopArt.orange),
                    (4, "⭐⭐⭐⭐ 4 ÉTOILES • LE MELON TOTAL !", "+5 000 PTS si bon  •  -2 500 PTS si faux !", PopArt.redError)
                ]

                ForEach(starOptions, id: \.stars) { opt in
                    let isSelected = (me?.lockedBetStars == opt.stars)
                    let hasLocked = (me?.lockedBetStars != nil)
                    Button {
                        session.submitBetStars(opt.stars)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(opt.title)
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                                    .foregroundStyle(isSelected ? PopArt.ink : .white)
                                Text(opt.subtitle)
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .foregroundStyle(isSelected ? PopArt.ink.opacity(0.85) : .white.opacity(0.92))
                            }
                            Spacer()
                            if isSelected {
                                Text("🔒 MISÉ")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(PopArt.ink)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(
                        PopArtActionButtonStyle(
                            backgroundColor: isSelected ? PopArt.yellow : opt.color,
                            foregroundColor: isSelected ? PopArt.ink : .white,
                            cornerRadius: 18
                        )
                    )
                    .opacity((hasLocked && !isSelected) ? 0.35 : 1.0)
                    .disabled(hasLocked)
                }
            }
        }
    }

    // MARK: - 4. Manche 4 : « LE SOLO » ou « CLOUER LE BEC » (Style Jack)

    private var soloBuzzerControllerSection: some View {
        VStack(spacing: 12) {
            if let q = snap.activeQuestion {
                PopArtCard(cornerRadius: 18, borderWidth: 3.5, backgroundColor: PopArt.redError) {
                    VStack(spacing: 4) {
                        Text("🚨 LE SOLO • 1er QUI RÉPOND PREND TOUT !")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.yellow)
                        Text("Bonne réponse = +\(q.baseValue * 2) PTS • Mauvaise = -\(q.baseValue) PTS !")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
            }
            cashMCQControllerSection
        }
    }

    private var soloAnsweringControllerSection: some View {
        VStack(spacing: 14) {
            if snap.soloBuzzerPlayerID == session.localPlayerID {
                PopArtCard(cornerRadius: 18, borderWidth: 3.5, backgroundColor: PopArt.redError) {
                    VStack(spacing: 4) {
                        if let attacker = snap.screwAttackerName {
                            Text("🔩 \(attacker.uppercased()) T'A CLOUÉ LE BEC !")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.yellow)
                            Text("Réponds juste pour doubler les points et punir \(attacker) !")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                        } else {
                            Text("🔥 TU AS PRIS LE SOLO ! 12 SECONDES POUR RÉPONDRE !")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
                cashMCQControllerSection
            } else {
                PopArtCard(cornerRadius: 24, borderWidth: 4, backgroundColor: PopArt.white) {
                    VStack(spacing: 12) {
                        Text(snap.screwAttackerName != nil ? "🔩" : "🍿")
                            .font(.system(size: 56))
                        if let attacker = snap.screwAttackerName {
                            Text("🔩 \(attacker) a cloué le bec de \(snap.soloBuzzerPlayerName ?? "un joueur") !")
                                .font(.system(size: 21, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                            Text("Il est tout seul face à la question pendant \(max(1, Int(ceil(snap.timeRemainingSec))))s !")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(PopArt.ink.opacity(0.72))
                                .multilineTextAlignment(.center)
                        } else {
                            Text("\(snap.soloBuzzerPlayerName ?? "Un joueur") a dégainé en 1er !")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)
                            Text("Regarde la TV AirPlay pour voir s'il rafle le double ou s'il perd tout !")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(PopArt.ink.opacity(0.72))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                }
            }
        }
    }

    // MARK: - 5. Cash Speed, Solo & Finale ×2 Tactile A / B / C / D Buttons + Screw & Bisou Traps

    private var cashMCQControllerSection: some View {
        VStack(spacing: 12) {
            if let q = snap.activeQuestion {
                let letters = ["A", "B", "C", "D"]

                if snap.roundKind == .tuTeMetsCombien, let stars = me?.lockedBetStars {
                    let stakes = QuizScoringEngine.ttmcStakes(for: stars)
                    PopArtCard(cornerRadius: 16, borderWidth: 3, backgroundColor: PopArt.purple) {
                        HStack {
                            Text("🎯 TON PARI : \(String(repeating: "⭐", count: stars))")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.yellow)
                            Spacer()
                            Text("+\(stakes.win) PTS / \(stakes.loss) PTS")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                    }
                } else if snap.roundKind == .jukeboxExpress {
                    PopArtCard(cornerRadius: 16, borderWidth: 3, backgroundColor: PopArt.pink) {
                        HStack {
                            Text("🎧 JUKEBOX EXPRESS • N'OUBLIEZ PAS LES PAROLES !")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }

                // 1) En attente des autres joueurs (évite l'impression que la question revient !)
                if snap.stage == .cashAnswering, let myChosen = me?.lockedChoiceIndex {
                    let answeredCount = snap.players.filter { $0.lockedChoiceIndex != nil }.count
                    PopArtCard(cornerRadius: 18, borderWidth: 3.5, backgroundColor: PopArt.yellow) {
                        VStack(spacing: 4) {
                            Text("🔒 TON CHOIX (\(letters[myChosen])) EST ENREGISTRÉ !")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                            Text("⏳ En attente des autres joueurs (\(answeredCount)/\(snap.players.count) ont répondu)...")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.8))
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                    }
                }

                // 2) Grand Verdict Vert / Rouge immanquable à la révélation
                if snap.stage == .questionReveal {
                    let myChosen = me?.lockedChoiceIndex
                    let correctIdx = snap.revealedCorrectIndex ?? q.correctIndex
                    let correctText = q.choices.indices.contains(correctIdx) ? "\(letters[correctIdx]) : \(q.choices[correctIdx])" : ""
                    let delta = me?.lastDeltaScore ?? 0
                    let isWin = (delta > 0) || (myChosen != nil && myChosen == correctIdx)

                    PopArtCard(
                        cornerRadius: 20,
                        borderWidth: 4,
                        backgroundColor: isWin ? PopArt.greenSuccess : PopArt.redError
                    ) {
                        VStack(spacing: 6) {
                            Text(isWin ? "🎉✅ BONNE RÉPONSE ! +\(delta) PTS" : (myChosen == nil && delta == 0 ? "⏰ PAS DE RÉPONSE (0 PT)" : "💥❌ MAUVAISE RÉPONSE ! (\(delta) PTS)"))
                                .font(.system(size: 21, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)

                            if !isWin {
                                Text("👉 Bonne réponse : \(correctText)")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundStyle(PopArt.yellow)
                                    .multilineTextAlignment(.center)
                            } else if let streak = me?.streak, streak >= 2 {
                                Text("🔥 Série de \(streak) bonnes réponses d'affilée !")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundStyle(PopArt.yellow)
                            }

                            Text("⏭️ Question suivante auto dans \(max(1, Int(ceil(snap.timeRemainingSec))))s...")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                    }
                }

                PopArtCard(cornerRadius: 18, borderWidth: 3, backgroundColor: PopArt.white) {
                    VStack(spacing: 6) {
                        Text(q.funnyTitle)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.orange)
                            .multilineTextAlignment(.center)
                        Text(q.prompt)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                }

                ForEach(0..<q.choices.count, id: \.self) { idx in
                    let isMyChoice = (me?.lockedChoiceIndex == idx)
                    let hasLockedSomething = (me?.lockedChoiceIndex != nil)
                    let isRevealed = (snap.stage == .questionReveal)
                    let isCorrect = (snap.revealedCorrectIndex == idx)

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
                        HStack(spacing: 14) {
                            Text(letters[idx])
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .frame(width: 44, height: 44)
                                .background(PopArt.orange, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2.5))

                            Text(q.choices[idx])
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                                .foregroundStyle(isRevealed && (isCorrect || isMyChoice) ? .white : PopArt.ink)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if isRevealed && isCorrect {
                                Text("✅ BON")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(.white)
                            } else if isRevealed && isMyChoice && !isCorrect {
                                Text("❌ TON CHOIX")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(.white)
                            } else if isMyChoice {
                                Text("🔒 CHOISI")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(PopArt.ink)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: btnBg, cornerRadius: 18))
                    .opacity((hasLockedSomething && !isMyChoice && !isRevealed) ? 0.38 : 1.0)
                    .disabled(me?.lockedChoiceIndex != nil || snap.stage == .questionReveal)
                }

                if snap.stage == .questionReveal {
                    PopArtCard(
                        cornerRadius: 18,
                        borderWidth: 3.5,
                        backgroundColor: (me?.lastDeltaScore ?? 0) > 0 ? Color(hex: "#D1FAE5") : Color(hex: "#FFE4E8")
                    ) {
                        VStack(spacing: 8) {
                            Text(q.explanation)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                                .multilineTextAlignment(.center)

                            if session.role == .hostAndPlayer1 {
                                Button {
                                    session.skipToNextStep()
                                } label: {
                                    Text("Passer tout de suite ➡️")
                                        .font(.system(size: 14, weight: .black))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                }
                                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 12))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                    }
                }

                // Jokers Multi : 🔩 « Clouer le Bec » (Style You Don't Know Jack) + 💋 Bisou Baveux
                let opponents = snap.players.filter { $0.id != session.localPlayerID }
                if snap.stage == .cashAnswering,
                   let me,
                   !opponents.isEmpty,
                   (!me.hasUsedScrew || !me.hasUsedBisouTrap) {
                    PopArtCard(cornerRadius: 18, borderWidth: 3, backgroundColor: Color(hex: "#FFF8E7")) {
                        VStack(spacing: 10) {
                            if !me.hasUsedScrew {
                                VStack(spacing: 6) {
                                    Text("🔩 COUP DE JARNAC (JACK) : CLOUER LE BEC D'UN ADVERSAIRE !")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(PopArt.purple)
                                    Text("Il se retrouve seul face à la question : s'il se trompe, tu rafles ses points !")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(PopArt.ink.opacity(0.72))
                                        .multilineTextAlignment(.center)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(opponents) { target in
                                                Button {
                                                    session.sendScrewOpponent(to: target.id)
                                                } label: {
                                                    HStack(spacing: 6) {
                                                        Text("🔩")
                                                        Text(target.avatarEmoji)
                                                        Text("Clouer \(target.name)")
                                                            .font(.system(size: 13, weight: .black))
                                                    }
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                }
                                                .buttonStyle(
                                                    PopArtActionButtonStyle(
                                                        backgroundColor: PopArt.purple,
                                                        foregroundColor: .white,
                                                        cornerRadius: 12
                                                    )
                                                )
                                            }
                                        }
                                    }
                                }
                            }

                            if !me.hasUsedBisouTrap {
                                VStack(spacing: 6) {
                                    Text("💋 JOKER BAVEUX : EMBROUILLER L'ÉCRAN D'UN ADVERSAIRE")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(PopArt.pink)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(opponents) { target in
                                                Button {
                                                    session.sendBisouTrap(to: target.id)
                                                } label: {
                                                    HStack(spacing: 6) {
                                                        Text("💋")
                                                        Text(target.avatarEmoji)
                                                        Text(target.name)
                                                            .font(.system(size: 13, weight: .black))
                                                    }
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                }
                                                .buttonStyle(
                                                    PopArtActionButtonStyle(
                                                        backgroundColor: PopArt.pink,
                                                        foregroundColor: .white,
                                                        cornerRadius: 12
                                                    )
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(12)
                    }
                }
            }
        }
    }

    // MARK: - 6. Manche 3 : Raclette Quizz Buttons

    private static let itemCardPalette: [Color] = [
        Color(hex: "#FFF3E0"), // 1: Orange crème
        Color(hex: "#E0F7FA"), // 2: Cyan polaire
        Color(hex: "#F3E5F5"), // 3: Violet pop
        Color(hex: "#FFE4E8"), // 4: Rose bonbon
        Color(hex: "#ECFDF5"), // 5: Menthe fraîche
        Color(hex: "#FEF9C3")  // 6: Jaune citron
    ]

    private static let itemBadgePalette: [Color] = [
        PopArt.orange,
        PopArt.cyan,
        PopArt.purple,
        PopArt.pink,
        PopArt.greenSuccess,
        PopArt.blue
    ]

    private func disOrDatButtonColor(side: String, defaultColor: Color) -> Color {
        let mySide = me?.lockedSide
        if snap.stage == .couciCoucaReveal, let correct = snap.revealedBinarySide {
            if correct == side { return PopArt.greenSuccess }
            if mySide == side { return PopArt.redError }
            return defaultColor.opacity(0.35)
        }
        return mySide == side ? PopArt.yellow : defaultColor
    }

    private func disOrDatForegroundColor(side: String) -> Color {
        let mySide = me?.lockedSide
        if snap.stage == .couciCoucaReveal {
            return .white
        }
        return mySide == side ? PopArt.ink : .white
    }

    private var couciCoucaControllerSection: some View {
        VStack(spacing: 12) {
            if snap.stage == .couciCoucaSummary {
                PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.yellow) {
                    VStack(spacing: 10) {
                        Text("🧀 FIN DE LA RACLETTE QUIZZ !")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                        Text("Ton score actuel : \(me?.score ?? 0) PTS")
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundStyle(PopArt.redError)
                        Text("🔥 Prépare-toi : la Rafale Finale Points ×2 démarre dans \(max(1, Int(ceil(snap.timeRemainingSec))))s...")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(PopArt.ink.opacity(0.85))
                            .multilineTextAlignment(.center)
                        if session.role == .hostAndPlayer1 {
                            Button {
                                session.skipToNextStep()
                            } label: {
                                Text("Lancer la Finale ×2 ➡️")
                                    .font(.system(size: 15, weight: .black))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.orange, cornerRadius: 14))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                }
            } else if let round = snap.activeDisOrDat {
                let idx = snap.activeDisOrDatItemIndex ?? 0
                let item = round.items.indices.contains(idx) ? round.items[idx] : nil
                let cardBg = Self.itemCardPalette[idx % Self.itemCardPalette.count]
                let badgeBg = Self.itemBadgePalette[idx % Self.itemBadgePalette.count]

                if snap.stage == .couciCoucaItem, let mySide = me?.lockedSide {
                    let answeredCount = snap.players.filter { $0.lockedSide != nil }.count
                    let chosenLabel = (mySide == "left") ? round.optionLeft : (mySide == "both" ? (round.optionBoth ?? "LES DEUX") : round.optionRight)
                    PopArtCard(cornerRadius: 18, borderWidth: 3.5, backgroundColor: PopArt.yellow) {
                        VStack(spacing: 4) {
                            Text("🔒 CHOIX VERROUILLÉ : \(chosenLabel.uppercased())")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                            Text("⏳ En attente des autres joueurs (\(answeredCount)/\(snap.players.count))...")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.8))
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                    }
                }

                PopArtCard(cornerRadius: 20, borderWidth: 3.5, backgroundColor: cardBg) {
                    VStack(spacing: 8) {
                        HStack {
                            Text("QUESTION \(idx + 1) / \(round.items.count)")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(badgeBg, in: Capsule())
                                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))

                            Spacer()

                            Text("🧀 RACLETTE QUIZZ")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink.opacity(0.75))
                        }

                        Text(round.funnyTitle)
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(badgeBg)
                            .multilineTextAlignment(.center)

                        Text(item?.text ?? round.prompt)
                            .font(.system(size: 21, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.78), value: idx)

                // En mode Révélation : Grande Carte Verdict Plein Écran immanquable à la place des 3 boutons !
                if snap.stage == .couciCoucaReveal, let correctSide = snap.revealedBinarySide {
                    let mySide = me?.lockedSide
                    let isRight = (mySide != nil && mySide == correctSide)
                    let delta = me?.lastDeltaScore ?? 0
                    let correctLabel = (correctSide == "left") ? round.optionLeft : (correctSide == "both" ? (round.optionBoth ?? "🧀 LES DEUX !") : round.optionRight)
                    let myChosenLabel: String = {
                        guard let mySide else { return "Aucune réponse (Temps écoulé)" }
                        if mySide == "left" { return round.optionLeft }
                        if mySide == "both" { return round.optionBoth ?? "🧀 LES DEUX !" }
                        return round.optionRight
                    }()

                    PopArtCard(
                        cornerRadius: 22,
                        borderWidth: 4,
                        backgroundColor: isRight ? PopArt.greenSuccess : PopArt.redError
                    ) {
                        VStack(spacing: 10) {
                            Text(isRight ? "🎉✅ C'EST GAGNÉ !" : (mySide == nil ? "⏰ TROP TARD !" : "💥❌ C'EST PERDU !"))
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(.white)

                            Text(isRight ? "+\(delta) POINTS" : "\(delta) POINTS")
                                .font(.system(size: 20, weight: .black, design: .monospaced))
                                .foregroundStyle(PopArt.ink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(PopArt.yellow, in: Capsule())
                                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2.5))

                            VStack(spacing: 4) {
                                Text("Ton choix : \(myChosenLabel)")
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.92))
                                Text("👉 Bonne réponse : \(correctLabel)")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.yellow)
                            }
                            .multilineTextAlignment(.center)

                            HStack(spacing: 12) {
                                Text("⏭️ Suite auto dans \(max(1, Int(ceil(snap.timeRemainingSec))))s...")
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.9))

                                if session.role == .hostAndPlayer1 {
                                    Button {
                                        session.skipToNextStep()
                                    } label: {
                                        Text("Suivant ➡️")
                                            .font(.system(size: 13, weight: .black))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                    }
                                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 10))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(18)
                    }
                } else {
                    let hasLockedSide = (me?.lockedSide != nil)

                    HStack(spacing: 12) {
                        Button {
                            session.submitBinarySide("left")
                        } label: {
                            VStack(spacing: 8) {
                                Text(me?.lockedSide == "left" ? "🔒" : "⬅️")
                                    .font(.system(size: 34))
                                Text(round.optionLeft)
                                    .font(.system(size: 19, weight: .black, design: .rounded))
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(disOrDatForegroundColor(side: "left"))
                            .frame(maxWidth: .infinity, minHeight: round.optionBoth != nil ? 135 : 175)
                            .padding(12)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: disOrDatButtonColor(side: "left", defaultColor: PopArt.blue),
                                foregroundColor: disOrDatForegroundColor(side: "left"),
                                cornerRadius: 22
                            )
                        )
                        .opacity((hasLockedSide && me?.lockedSide != "left") ? 0.35 : 1.0)
                        .disabled(me?.lockedSide != nil || snap.stage != .couciCoucaItem)

                        Button {
                            session.submitBinarySide("right")
                        } label: {
                            VStack(spacing: 8) {
                                Text(me?.lockedSide == "right" ? "🔒" : "➡️")
                                    .font(.system(size: 34))
                                Text(round.optionRight)
                                    .font(.system(size: 19, weight: .black, design: .rounded))
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(disOrDatForegroundColor(side: "right"))
                            .frame(maxWidth: .infinity, minHeight: round.optionBoth != nil ? 135 : 175)
                            .padding(12)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: disOrDatButtonColor(side: "right", defaultColor: PopArt.pink),
                                foregroundColor: disOrDatForegroundColor(side: "right"),
                                cornerRadius: 22
                            )
                        )
                        .opacity((hasLockedSide && me?.lockedSide != "right") ? 0.35 : 1.0)
                        .disabled(me?.lockedSide != nil || snap.stage != .couciCoucaItem)
                    }

                    if let bothLabel = round.optionBoth {
                        Button {
                            session.submitBinarySide("both")
                        } label: {
                            HStack(spacing: 10) {
                                Text(me?.lockedSide == "both" ? "🔒" : "🧀")
                                    .font(.system(size: 28))
                                Text(bothLabel)
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                            }
                            .foregroundStyle(disOrDatForegroundColor(side: "both"))
                            .frame(maxWidth: .infinity, minHeight: 68)
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(
                            PopArtActionButtonStyle(
                                backgroundColor: disOrDatButtonColor(side: "both", defaultColor: PopArt.purple),
                                foregroundColor: disOrDatForegroundColor(side: "both"),
                                cornerRadius: 20
                            )
                        )
                        .opacity((hasLockedSide && me?.lockedSide != "both") ? 0.35 : 1.0)
                        .disabled(me?.lockedSide != nil || snap.stage != .couciCoucaItem)
                    }
                }
            }
        }
    }

    // MARK: - 7. Final Podium Controller Card

    private var finalPodiumControllerSection: some View {
        VStack(spacing: 14) {
            if let myAward = snap.podiumAwards.first(where: { $0.playerID == session.localPlayerID }) {
                PopArtCard(cornerRadius: 24, borderWidth: 4, backgroundColor: PopArt.yellow) {
                    VStack(spacing: 10) {
                        Text("🏆 TON RÉSULTAT : #\(myAward.rank)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                        Text(myAward.funnyTitle)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.redError)
                            .multilineTextAlignment(.center)
                        Text("\(myAward.score) POINTS")
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                            .foregroundStyle(PopArt.ink)
                        Text(myAward.subtitle)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(PopArt.ink.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(22)
                }
            }

            if session.role == .hostAndPlayer1 {
                Button {
                    session.startNewShow()
                } label: {
                    Text("🔄 REJOUER UNE PARTIE !")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.orange, cornerRadius: 18))

                Button {
                    session.returnToLobby()
                } label: {
                    Text("🏠 QUITTER VERS LE SALON (CHANGER THÈME)")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.white, cornerRadius: 16))
            } else {
                Button {
                    session.leaveRemoteSession()
                } label: {
                    Text("🚪 QUITTER LA PARTIE")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.redError, foregroundColor: .white, cornerRadius: 16))
            }
        }
    }

    // MARK: - 7B. 🎨 Draw Something & 📞 Esquissé ! Controller Sections

    private var drawSomethingControllerSection: some View {
        VStack(spacing: 12) {
            if let drawRound = snap.activeDrawRound {
                let isDrawer = (drawRound.drawerPlayerID == session.localPlayerID)

                if snap.stage == .drawWordChoice {
                    if isDrawer {
                        PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: Color(hex: "#ECFDF5")) {
                            VStack(spacing: 12) {
                                Text("🎨 C'EST À TOI DE DESSINER !")
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.ink)

                                Text("Choisis secrètement ton mot selon la difficulté :")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(PopArt.ink.opacity(0.75))

                                ForEach(drawRound.wordOptions) { opt in
                                    Button {
                                        session.selectDrawWord(opt.word)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(String(repeating: "⭐", count: opt.stars) + "  " + opt.word)
                                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                                Text("Indice : \(opt.categoryHint)")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .opacity(0.85)
                                            }
                                            Spacer()
                                            Text("+\(opt.points) PTS")
                                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(PopArt.yellow, in: Capsule())
                                                .foregroundStyle(PopArt.ink)
                                        }
                                        .padding(14)
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(
                                        PopArtActionButtonStyle(
                                            backgroundColor: opt.stars == 3 ? PopArt.pink : (opt.stars == 2 ? PopArt.orange : PopArt.greenSuccess),
                                            foregroundColor: .white,
                                            cornerRadius: 16
                                        )
                                    )
                                }
                            }
                            .padding(18)
                        }
                    } else {
                        PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.yellow) {
                            VStack(spacing: 10) {
                                Text("\(drawRound.drawerEmoji) \(drawRound.drawerPlayerName) choisit son mot...")
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(PopArt.ink)
                                    .multilineTextAlignment(.center)
                                Text("Prépare tes doigts pour composer le mot avec les tuiles façon Draw Something !")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(PopArt.ink.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(24)
                        }
                    }
                } else if snap.stage == .drawLiveGuessing {
                    if isDrawer {
                        PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.white) {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("🎨 DESSINE : « \(drawRound.chosenWord?.word ?? "") »")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.orange)
                                    Spacer()
                                    Text("⏱️ \(Int(ceil(snap.timeRemainingSec)))s")
                                        .font(.system(size: 15, weight: .black, design: .monospaced))
                                        .foregroundStyle(PopArt.ink)
                                }

                                InteractiveDrawingPadView(
                                    initialCanvas: drawRound.canvas,
                                    onCanvasChanged: { updatedCanvas in
                                        session.sendDrawingCanvasUpdate(updatedCanvas)
                                    }
                                )

                                if !drawRound.foundPlayerIDs.isEmpty {
                                    Text("🎉 \(drawRound.foundPlayerIDs.count) joueur(s) ont déjà trouvé ton dessin !")
                                        .font(.system(size: 13, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.greenSuccess)
                                }
                            }
                            .padding(14)
                        }
                    } else {
                        let alreadyFound = drawRound.foundPlayerIDs.contains(session.localPlayerID)
                        VStack(spacing: 10) {
                            PopArtCard(cornerRadius: 20, borderWidth: 3.5, backgroundColor: PopArt.white) {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("\(drawRound.drawerEmoji) \(drawRound.drawerPlayerName) dessine (\(drawRound.wordLength) lettres)")
                                            .font(.system(size: 13, weight: .black, design: .rounded))
                                            .foregroundStyle(PopArt.orange)
                                        Spacer()
                                        Text("⏱️ \(Int(ceil(snap.timeRemainingSec)))s")
                                            .font(.system(size: 14, weight: .black, design: .monospaced))
                                    }

                                    ZStack {
                                        Color.white
                                        VectorCanvasPreviewView(canvas: drawRound.canvas)
                                    }
                                    .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                                    .frame(maxHeight: 265)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2.5))
                                }
                                .padding(10)
                            }

                            if alreadyFound {
                                PopArtCard(cornerRadius: 20, borderWidth: 4, backgroundColor: PopArt.greenSuccess) {
                                    VStack(spacing: 6) {
                                        Text("🎉 BRAVO ! TU AS TROUVÉ LE MOT !")
                                            .font(.system(size: 20, weight: .black, design: .rounded))
                                            .foregroundStyle(.white)
                                        Text("« \(drawRound.chosenWord?.word ?? "") » (+\(me?.lastDeltaScore ?? 2000) PTS)")
                                            .font(.system(size: 18, weight: .black, design: .monospaced))
                                            .foregroundStyle(PopArt.yellow)
                                    }
                                    .padding(18)
                                }
                            } else {
                                DrawSomethingTileRackView(
                                    targetLength: max(1, drawRound.wordLength),
                                    targetWord: drawRound.chosenWord?.word ?? "",
                                    categoryHint: drawRound.chosenWord?.categoryHint ?? "Mystère",
                                    scrambledTiles: drawRound.scrambledTiles,
                                    hintsUsedCount: me?.drawHintsUsedCount ?? 0,
                                    onRequestHint: {
                                        session.requestDrawHint()
                                    },
                                    onGuessSubmitted: { guess in
                                        session.submitDrawGuessWord(guess)
                                    }
                                )
                            }
                        }
                    }
                } else {
                    // .drawReveal
                    let delta = me?.lastDeltaScore ?? 0
                    PopArtCard(
                        cornerRadius: 22,
                        borderWidth: 4,
                        backgroundColor: delta > 0 ? PopArt.greenSuccess : PopArt.white
                    ) {
                        VStack(spacing: 10) {
                            Text("🎨 LE MOT ÉTAIT : « \(drawRound.chosenWord?.word ?? "") »")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(delta > 0 ? .white : PopArt.ink)

                            ZStack {
                                Color.white
                                VectorCanvasPreviewView(canvas: drawRound.canvas)
                            }
                            .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                            .frame(maxHeight: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2.5))

                            if delta > 0 {
                                Text("🎉 +\(delta) PTS GAGNÉS SUR CE DESSIN !")
                                    .font(.system(size: 18, weight: .black, design: .monospaced))
                                    .foregroundStyle(PopArt.yellow)
                            } else if delta < 0 {
                                Text("💡 \(delta) PTS (indices utilisés)")
                                    .font(.system(size: 15, weight: .black, design: .monospaced))
                                    .foregroundStyle(PopArt.redError)
                            } else {
                                Text("0 pt sur ce dessin — prépare-toi pour la suite !")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(PopArt.ink.opacity(0.75))
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private var esquisseControllerSection: some View {
        VStack(spacing: 12) {
            if let esq = snap.activeEsquisseRound {
                if snap.stage == .esquisseShowcase {
                    let nbIndex = min(max(0, esq.showcaseNotebookIndex), max(0, esq.notebooks.count - 1))
                    if esq.notebooks.indices.contains(nbIndex) {
                        let notebook = esq.notebooks[nbIndex]
                        let alreadyVoted = notebook.voteVoterIDs.contains(session.localPlayerID)
                        PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.white) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("📒 CARNET DE \(notebook.ownerEmoji) \(notebook.ownerName.uppercased())")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(PopArt.orange)
                                    Spacer()
                                    Text("\(nbIndex + 1)/\(esq.notebooks.count)")
                                        .font(.system(size: 13, weight: .black, design: .monospaced))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(PopArt.yellow, in: Capsule())
                                }

                                ForEach(notebook.entries) { entry in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(entry.authorEmoji) \(entry.authorName) — \(entry.promptText != nil ? "✍️ Phrase" : "🎨 Dessin")")
                                            .font(.system(size: 12, weight: .black, design: .rounded))
                                            .foregroundStyle(PopArt.ink.opacity(0.7))

                                        if let text = entry.promptText {
                                            Text("« \(text) »")
                                                .font(.system(size: 17, weight: .black, design: .rounded))
                                                .foregroundStyle(PopArt.ink)
                                                .padding(10)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 12))
                                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2))
                                        }
                                        if let drawing = entry.drawing {
                                            ZStack {
                                                Color.white
                                                VectorCanvasPreviewView(canvas: drawing)
                                            }
                                            .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                                            .frame(maxHeight: 240)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2))
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                }

                                Button {
                                    session.voteEsquisseAlbum(notebook.id)
                                } label: {
                                    HStack {
                                        Text(alreadyVoted ? "✅ COUP DE CŒUR ENVOYÉ (\(notebook.voteVoterIDs.count) 😂)" : "😂 VOTER COUP DE CŒUR (+1 000 PTS)")
                                            .font(.system(size: 15, weight: .black, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(
                                    PopArtActionButtonStyle(
                                        backgroundColor: alreadyVoted ? PopArt.greenSuccess : PopArt.pink,
                                        foregroundColor: .white,
                                        cornerRadius: 16
                                    )
                                )
                                .disabled(alreadyVoted)
                            }
                            .padding(16)
                        }
                    }
                } else if me?.hasSubmittedEsquisseStep == true {
                    PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.greenSuccess) {
                        VStack(spacing: 10) {
                            Text("✅ CARNET TRANSMIS AU VOISIN !")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Attends quelques secondes que les autres artistes terminent leur étape...")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding(22)
                    }
                } else {
                    let assignedID = esq.activeAssignmentByPlayerID[session.localPlayerID]
                    let assignedNotebook = esq.notebooks.first(where: { $0.id == assignedID }) ?? esq.notebooks.first
                    EsquisseInteractiveStepCard(
                        stage: snap.stage,
                        stepIndex: esq.stepIndex,
                        previousEntry: assignedNotebook?.entries.last,
                        onSubmitText: { text in
                            session.submitEsquisseText(text)
                        },
                        onSubmitDrawing: { canvas in
                            session.submitEsquisseDrawing(canvas)
                        }
                    )
                }
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

// MARK: - Reusable Vector Canvas & Draw Something / Esquissé Subviews

struct VectorCanvasPreviewView: View {
    let canvas: DrawingCanvasData

    var body: some View {
        Canvas { context, size in
            // Proportional stroke scaling so phone, tablet, and Apple TV 16:9 have the EXACT same line thickness!
            let strokeScale = max(0.1, size.width / CGFloat(DrawingCanvasData.referenceWidth))
            for stroke in canvas.strokes {
                guard let first = stroke.points.first else { continue }
                let scaledLineWidth = CGFloat(stroke.lineWidth) * strokeScale
                var path = Path()
                path.move(to: CGPoint(x: first.x * size.width, y: first.y * size.height))
                if stroke.points.count == 1 {
                    path.addEllipse(in: CGRect(
                        x: first.x * size.width - scaledLineWidth / 2,
                        y: first.y * size.height - scaledLineWidth / 2,
                        width: scaledLineWidth,
                        height: scaledLineWidth
                    ))
                    context.fill(path, with: .color(Color(hex: stroke.colorHex)))
                } else {
                    for pt in stroke.points.dropFirst() {
                        path.addLine(to: CGPoint(x: pt.x * size.width, y: pt.y * size.height))
                    }
                    context.stroke(
                        path,
                        with: .color(Color(hex: stroke.colorHex)),
                        style: StrokeStyle(lineWidth: scaledLineWidth, lineCap: .round, lineJoin: .round)
                    )
                }
            }
        }
    }
}

struct InteractiveDrawingPadView: View {
    let initialCanvas: DrawingCanvasData
    var onCanvasChanged: (DrawingCanvasData) -> Void

    @State private var strokes: [DrawingStroke] = []
    @State private var activePoints: [NormalizedPoint] = []
    @State private var selectedColorHex: String = "#111827"
    @State private var selectedLineWidth: Double = 7.0
    @State private var lastSentAt: Date = .distantPast

    private let palette: [String] = [
        "#111827", "#E11D48", "#FF8C42", "#F59E0B", "#10B981", "#2563EB", "#8E44AD", "#FFFFFF"
    ]

    private let brushSizes: [(label: String, width: Double, dotSize: CGFloat)] = [
        ("Fin", 4.0, 8),
        ("Moyen", 7.5, 13),
        ("Épais", 13.0, 18)
    ]

    var body: some View {
        VStack(spacing: 10) {
            // Portrait 3:4 Drawing Canvas — Matches Apple TV aspect ratio 1:1
            GeometryReader { geo in
                ZStack {
                    Color.white
                    VectorCanvasPreviewView(
                        canvas: DrawingCanvasData(
                            strokes: strokes + (activePoints.isEmpty ? [] : [
                                DrawingStroke(colorHex: selectedColorHex, lineWidth: selectedLineWidth, points: activePoints)
                            ])
                        )
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(PopArt.ink, lineWidth: 3))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let w = max(1, geo.size.width)
                            let h = max(1, geo.size.height)
                            let nx = min(1.0, max(0.0, value.location.x / w))
                            let ny = min(1.0, max(0.0, value.location.y / h))
                            let pt = NormalizedPoint(x: nx, y: ny)
                            if let last = activePoints.last {
                                let dist = hypot(pt.x - last.x, pt.y - last.y)
                                if dist < 0.006 { return }
                            }
                            activePoints.append(pt)
                            if Date().timeIntervalSince(lastSentAt) > 0.12 {
                                lastSentAt = Date()
                                let preview = DrawingCanvasData(
                                    strokes: strokes + [DrawingStroke(colorHex: selectedColorHex, lineWidth: selectedLineWidth, points: activePoints)]
                                )
                                onCanvasChanged(preview)
                            }
                        }
                        .onEnded { _ in
                            guard !activePoints.isEmpty else { return }
                            strokes.append(DrawingStroke(colorHex: selectedColorHex, lineWidth: selectedLineWidth, points: activePoints))
                            activePoints.removeAll()
                            onCanvasChanged(DrawingCanvasData(strokes: strokes))
                        }
                )
            }
            .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
            .frame(maxWidth: .infinity)

            // Palette Row
            HStack(spacing: 8) {
                ForEach(palette, id: \.self) { hex in
                    let isEraser = (hex == "#FFFFFF")
                    let isSelected = (selectedColorHex == hex)
                    Button {
                        selectedColorHex = hex
                        if isEraser { selectedLineWidth = 18.0 }
                        else if selectedLineWidth > 14.0 { selectedLineWidth = 7.5 }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: isSelected ? 3.5 : 2))
                            if isEraser {
                                Text("🧽")
                                    .font(.system(size: 14))
                            }
                        }
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Brush Thickness + Undo / Clear Row
            HStack(spacing: 8) {
                ForEach(brushSizes, id: \.label) { sizeOpt in
                    let isCurrentSize = abs(selectedLineWidth - sizeOpt.width) < 1.5 && selectedColorHex != "#FFFFFF"
                    Button {
                        if selectedColorHex == "#FFFFFF" {
                            selectedColorHex = "#111827"
                        }
                        selectedLineWidth = sizeOpt.width
                    } label: {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(PopArt.ink)
                                .frame(width: sizeOpt.dotSize, height: sizeOpt.dotSize)
                            Text(sizeOpt.label)
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(PopArt.ink)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isCurrentSize ? PopArt.yellow : PopArt.cream, in: Capsule())
                        .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {
                    if !strokes.isEmpty {
                        _ = strokes.removeLast()
                        onCanvasChanged(DrawingCanvasData(strokes: strokes))
                    }
                } label: {
                    Text("↩️")
                        .font(.system(size: 15, weight: .black))
                        .frame(width: 36, height: 36)
                        .background(PopArt.cream, in: Circle())
                        .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2))
                }

                Button {
                    strokes.removeAll()
                    activePoints.removeAll()
                    onCanvasChanged(DrawingCanvasData(strokes: []))
                } label: {
                    Text("🗑️")
                        .font(.system(size: 15, weight: .black))
                        .frame(width: 36, height: 36)
                        .background(PopArt.cream, in: Circle())
                        .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2))
                }
            }
        }
    }
}

struct DrawSomethingTileRackView: View {
    let targetLength: Int
    let targetWord: String
    let categoryHint: String
    let scrambledTiles: [String]
    let hintsUsedCount: Int
    var onRequestHint: () -> Void
    var onGuessSubmitted: (String) -> Void

    @State private var selectedTileIndices: [Int] = []
    @State private var wrongAttemptFlash: Bool = false

    private var maxHintsAllowed: Int {
        max(1, targetLength - 1)
    }

    private var currentWord: String {
        selectedTileIndices.compactMap { idx in
            scrambledTiles.indices.contains(idx) ? scrambledTiles[idx] : nil
        }.joined()
    }

    private func applyLockedHintLetters(count: Int) {
        let normalizedTargetChars = Array(DrawingBank.normalizeWord(targetWord))
        let clampedCount = min(count, normalizedTargetChars.count)
        guard clampedCount > 0 else { return }

        var chosenIndices: [Int] = []
        for pos in 0..<clampedCount {
            let targetChar = String(normalizedTargetChars[pos])
            if let tileIdx = scrambledTiles.enumerated().first(where: { idx, tile in
                !chosenIndices.contains(idx) && DrawingBank.normalizeWord(tile) == targetChar
            })?.offset {
                chosenIndices.append(tileIdx)
            }
        }
        selectedTileIndices = chosenIndices
    }

    var body: some View {
        PopArtCard(cornerRadius: 20, borderWidth: 3.5, backgroundColor: wrongAttemptFlash ? Color(hex: "#FEE2E2") : PopArt.white) {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Text("🔤 \(targetLength) LETTRES")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.orange)

                    Spacer()

                    if hintsUsedCount < maxHintsAllowed {
                        Button {
                            let nextCount = hintsUsedCount + 1
                            onRequestHint()
                            applyLockedHintLetters(count: nextCount)
                        } label: {
                            Text("💡 Indice (-300 pts)")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(PopArt.purple, in: Capsule())
                                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                    }

                    if selectedTileIndices.count > hintsUsedCount {
                        Button {
                            _ = selectedTileIndices.popLast()
                        } label: {
                            Text("⌫")
                                .font(.system(size: 13, weight: .black))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(PopArt.cream, in: Capsule())
                                .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if hintsUsedCount > 0 {
                    HStack(spacing: 6) {
                        Text("💡 Catégorie : \(categoryHint) • \(hintsUsedCount) lettre(s) révélée(s) (-\(hintsUsedCount * 300) pts)")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.purple)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background( Color(hex: "#F3E8FF"), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(PopArt.purple, lineWidth: 1.5))
                }

                // Word Answer Slots
                HStack(spacing: 6) {
                    ForEach(0..<targetLength, id: \.self) { pos in
                        let isHintLocked = pos < hintsUsedCount
                        let letter: String = pos < selectedTileIndices.count
                            ? scrambledTiles[selectedTileIndices[pos]]
                            : ""
                        Button {
                            if pos >= hintsUsedCount && pos < selectedTileIndices.count {
                                selectedTileIndices.remove(at: pos)
                            }
                        } label: {
                            Text(letter)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(isHintLocked ? .white : PopArt.ink)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    isHintLocked ? PopArt.purple : (letter.isEmpty ? PopArt.cream : PopArt.yellow),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(PopArt.ink, lineWidth: 2.5))
                        }
                        .buttonStyle(.plain)
                        .disabled(isHintLocked)
                    }
                }

                // 12 Scrambled Letter Tiles (Draw Something style)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                    ForEach(Array(scrambledTiles.enumerated()), id: \.offset) { idx, letter in
                        let isUsed = selectedTileIndices.contains(idx)
                        Button {
                            guard !isUsed, selectedTileIndices.count < targetLength else { return }
                            selectedTileIndices.append(idx)
                            if selectedTileIndices.count == targetLength {
                                let attempt = currentWord
                                if DrawingBank.normalizeWord(attempt) == DrawingBank.normalizeWord(targetWord) {
                                    onGuessSubmitted(attempt)
                                } else {
                                    wrongAttemptFlash = true
                                    Task { @MainActor in
                                        try? await Task.sleep(for: .milliseconds(450))
                                        wrongAttemptFlash = false
                                        applyLockedHintLetters(count: hintsUsedCount)
                                        if hintsUsedCount == 0 {
                                            selectedTileIndices.removeAll()
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(letter)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(isUsed ? PopArt.ink.opacity(0.25) : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(isUsed ? PopArt.cream : PopArt.blue, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2.5))
                        }
                        .buttonStyle(.plain)
                        .disabled(isUsed)
                    }
                }
            }
            .padding(14)
        }
        .onChange(of: targetWord) { _, _ in
            selectedTileIndices.removeAll()
        }
        .onChange(of: hintsUsedCount) { _, newCount in
            if newCount > 0 && selectedTileIndices.count < newCount {
                applyLockedHintLetters(count: newCount)
            }
        }
    }
}

struct EsquisseInteractiveStepCard: View {
    let stage: ShowStageState
    let stepIndex: Int
    let previousEntry: EsquisseEntry?
    var onSubmitText: (String) -> Void
    var onSubmitDrawing: (DrawingCanvasData) -> Void

    @State private var typedText: String = ""
    @State private var currentCanvas = DrawingCanvasData()

    var body: some View {
        PopArtCard(cornerRadius: 22, borderWidth: 4, backgroundColor: PopArt.white) {
            VStack(alignment: .leading, spacing: 12) {
                if stage == .esquissePromptEntry {
                    Text("✍️ ÉTAPE 1/4 : INVENTE UNE SCÈNE FOLLE !")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.orange)

                    Text("Ton voisin devra la dessiner sans aide :")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(PopArt.ink.opacity(0.72))

                    TextField("Ex: Un tyrannosaure qui passe l'aspirateur...", text: $typedText)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .padding(12)
                        .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2.5))

                    HStack(spacing: 10) {
                        Button {
                            typedText = DrawingBank.randomEsquissePrompt()
                        } label: {
                            Text("🎲 Idée de Meemaw")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 14))

                        Button {
                            onSubmitText(typedText)
                        } label: {
                            Text("✅ Envoyer")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.greenSuccess, foregroundColor: .white, cornerRadius: 14))
                    }
                } else if stage == .esquisseDrawing {
                    Text("🎨 ÉTAPE \(stepIndex + 1)/4 : DESSINE CETTE PHRASE !")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.orange)

                    Text("« \(previousEntry?.promptText ?? "Un chat sur un vélo") »")
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.ink)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(PopArt.yellow.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(PopArt.ink, lineWidth: 2))

                    InteractiveDrawingPadView(
                        initialCanvas: currentCanvas,
                        onCanvasChanged: { updated in
                            currentCanvas = updated
                        }
                    )

                    Button {
                        onSubmitDrawing(currentCanvas)
                    } label: {
                        Text("✅ ENVOYER MON DESSIN AU VOISIN")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.greenSuccess, foregroundColor: .white, cornerRadius: 16))
                } else {
                    // .esquisseGuessing — 100% Free Text Keyboard (Gartic Phone style!)
                    Text("🕵️ ÉTAPE 3/4 : QU'EST-CE QUE C'EST QUE CE DESSIN ?")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(PopArt.pink)

                    if let drawing = previousEntry?.drawing {
                        ZStack {
                            Color.white
                            VectorCanvasPreviewView(canvas: drawing)
                        }
                        .aspectRatio(CGFloat(DrawingCanvasData.portraitAspectRatio), contentMode: .fit)
                        .frame(maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2.5))
                        .frame(maxWidth: .infinity)
                    }

                    Text("Tape librement au clavier ce que tu crois voir (le joueur suivant devra le redessiner !) :")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(PopArt.ink.opacity(0.75))

                    TextField("Écris ce que tu vois sur ce dessin...", text: $typedText)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .padding(12)
                        .background(PopArt.cream, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2.5))
                        .onSubmit {
                            if !typedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSubmitText(typedText)
                            }
                        }

                    Button {
                        onSubmitText(typedText)
                    } label: {
                        Text("✅ VALIDER MON INTERPRÉTATION")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.greenSuccess, foregroundColor: .white, cornerRadius: 16))
                }
            }
            .padding(16)
        }
        .onChange(of: stepIndex) { _, _ in
            typedText = ""
            currentCanvas = DrawingCanvasData()
        }
    }
}
