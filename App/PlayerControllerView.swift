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
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        switch snap.stage {
                        case .lobby:
                            lobbyControllerSection
                        case .roundIntro:
                            roundIntroControllerSection
                        case .soloBuzzOpen:
                            soloBuzzerControllerSection
                        case .soloPlayerAnswering:
                            soloAnsweringControllerSection
                        case .questionReading, .cashAnswering, .questionReveal:
                            cashMCQControllerSection
                        case .couciCoucaIntro, .couciCoucaItem, .couciCoucaSummary:
                            couciCoucaControllerSection
                        case .finalPodium:
                            finalPodiumControllerSection
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
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.yellow, cornerRadius: 10))

                        Button {
                            session.returnToLobby()
                        } label: {
                            Text("🔄 Salon")
                                .font(.system(size: 12, weight: .black))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.white, cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PopArt.ink, lineWidth: 2))
            }
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

            // Theme Picker (Host Only)
            if session.role == .hostAndPlayer1 {
                PopArtCard(cornerRadius: 22, borderWidth: 3.5, backgroundColor: PopArt.white) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📚 CHOISIS LE THÈME DU SHOW (100 % GÉNÉRÉ)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.orange)

                        ForEach(QuizThemePack.allCases) { pack in
                            let isSelected = (snap.selectedPack == pack)
                            Button {
                                session.selectThemePack(pack)
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(hex: pack.accentHex))
                                        .frame(width: 16, height: 16)
                                        .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(pack.title)
                                            .font(.system(size: 16, weight: .black, design: .rounded))
                                            .foregroundStyle(PopArt.ink)
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

                        Button {
                            session.startNewShow()
                        } label: {
                            HStack {
                                Text("🎬 LANCER LE GRAND QUIZZ DE MEEMAW !")
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(PopArtActionButtonStyle(backgroundColor: PopArt.orange, cornerRadius: 18))
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

                Text("👀 Écoute Meemaw sur la TV AirPlay, prépare tes pouces !")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(PopArt.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
        }
    }

    // MARK: - 4. Manche 2 : « LE SOLO » Giant Red Buzzer

    private var soloBuzzerControllerSection: some View {
        VStack(spacing: 14) {
            if let q = snap.activeQuestion {
                PopArtCard(cornerRadius: 20, borderWidth: 3.5, backgroundColor: PopArt.white) {
                    VStack(spacing: 6) {
                        Text("🚨 LE SOLO • DOUBLE MISE (\(q.baseValue * 2) PTS)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(PopArt.redError)
                        Text(q.funnyTitle)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                        Text(q.prompt)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(PopArt.ink.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                }
            }

            Button {
                session.submitSoloBuzz()
            } label: {
                VStack(spacing: 12) {
                    Text("🚨")
                        .font(.system(size: 62))
                    Text("JE PRENDS LE SOLO !")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                    Text("Bloque tous les autres joueurs et joue pour le DOUBLE !")
                        .font(.system(size: 14, weight: .bold))
                        .opacity(0.92)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 240)
                .padding(20)
            }
            .buttonStyle(
                PopArtActionButtonStyle(
                    backgroundColor: PopArt.redError,
                    foregroundColor: .white,
                    cornerRadius: 32
                )
            )
        }
    }

    private var soloAnsweringControllerSection: some View {
        VStack(spacing: 14) {
            if snap.soloBuzzerPlayerID == session.localPlayerID {
                PopArtCard(cornerRadius: 18, borderWidth: 3.5, backgroundColor: PopArt.redError) {
                    Text("🔥 TU AS PRIS LE SOLO ! 6 SECONDES POUR RÉPONDRE !")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                }
                cashMCQControllerSection
            } else {
                PopArtCard(cornerRadius: 24, borderWidth: 4, backgroundColor: PopArt.white) {
                    VStack(spacing: 12) {
                        Text("🍿")
                            .font(.system(size: 56))
                        Text("\(snap.soloBuzzerPlayerName ?? "Un joueur") a pris LE SOLO !")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                        Text("Ton buzzer est verrouillé : regarde la TV AirPlay pour voir s'il rafle le double ou s'il se prend les pieds dans le tapis !")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(PopArt.ink.opacity(0.72))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                }
            }
        }
    }

    // MARK: - 5. Cash Speed & Finale ×2 Tactile A / B / C / D Buttons + Bisou Trap

    private var cashMCQControllerSection: some View {
        VStack(spacing: 12) {
            if let q = snap.activeQuestion {
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

                let letters = ["A", "B", "C", "D"]
                ForEach(0..<q.choices.count, id: \.self) { idx in
                    let isMyChoice = (me?.lockedChoiceIndex == idx)
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

                            if isMyChoice {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 18, weight: .black))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PopArtActionButtonStyle(backgroundColor: btnBg, cornerRadius: 18))
                    .disabled(me?.lockedChoiceIndex != nil || snap.stage == .questionReveal)
                }

                // Joker : Le Bisou Baveux de Meemaw (1 fois par partie)
                let opponents = snap.players.filter { $0.id != session.localPlayerID }
                if snap.stage == .cashAnswering,
                   let me,
                   !me.hasUsedBisouTrap,
                   !opponents.isEmpty {
                    PopArtCard(cornerRadius: 18, borderWidth: 3, backgroundColor: Color(hex: "#FFF0F6")) {
                        VStack(spacing: 8) {
                            Text("💋 JOKER COUP BAS : ENVOYER UN BISOU BAVEUX DE MEEMAW")
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
                        .padding(12)
                    }
                }
            }
        }
    }

    // MARK: - 6. Manche 3 : Couci-Couça Binary Buttons

    private var couciCoucaControllerSection: some View {
        VStack(spacing: 14) {
            if let round = snap.activeDisOrDat {
                let idx = snap.activeDisOrDatItemIndex ?? 0
                let item = round.items.indices.contains(idx) ? round.items[idx] : nil

                PopArtCard(cornerRadius: 20, borderWidth: 3.5, backgroundColor: PopArt.white) {
                    VStack(spacing: 8) {
                        Text("⚖️ \(round.funnyTitle)")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(PopArt.orange)
                        Text(item?.text ?? round.prompt)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(PopArt.ink)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(18)
                }

                HStack(spacing: 12) {
                    Button {
                        session.submitBinarySide("left")
                    } label: {
                        VStack(spacing: 10) {
                            Text("⬅️")
                                .font(.system(size: 38))
                            Text(round.optionLeft)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 190)
                        .padding(14)
                    }
                    .buttonStyle(
                        PopArtActionButtonStyle(
                            backgroundColor: me?.lockedSide == "left" ? PopArt.yellow : PopArt.blue,
                            foregroundColor: me?.lockedSide == "left" ? PopArt.ink : .white,
                            cornerRadius: 24
                        )
                    )
                    .disabled(me?.lockedSide != nil || snap.stage != .couciCoucaItem)

                    Button {
                        session.submitBinarySide("right")
                    } label: {
                        VStack(spacing: 10) {
                            Text("➡️")
                                .font(.system(size: 38))
                            Text(round.optionRight)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 190)
                        .padding(14)
                    }
                    .buttonStyle(
                        PopArtActionButtonStyle(
                            backgroundColor: me?.lockedSide == "right" ? PopArt.yellow : PopArt.redError,
                            foregroundColor: me?.lockedSide == "right" ? PopArt.ink : .white,
                            cornerRadius: 24
                        )
                    )
                    .disabled(me?.lockedSide != nil || snap.stage != .couciCoucaItem)
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
            }
        }
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
