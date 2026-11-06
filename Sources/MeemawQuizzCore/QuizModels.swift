import Foundation

// MARK: - 8 Pop-Art Player Colors

public enum PlayerColor: String, CaseIterable, Codable, Identifiable, Sendable {
    case meemawOrange = "orange"
    case electricBlue = "blue"
    case mintGreen = "mint"
    case candyPink = "pink"
    case popPurple = "purple"
    case sunYellow = "yellow"
    case neonCyan = "cyan"
    case cherryRed = "red"

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .meemawOrange: "Orange Mamie"
        case .electricBlue: "Bleu Éclair"
        case .mintGreen: "Menthe Pop"
        case .candyPink: "Rose Bonbon"
        case .popPurple: "Violet Disco"
        case .sunYellow: "Jaune Soleil"
        case .neonCyan: "Cyan Néon"
        case .cherryRed: "Rouge Cerise"
        }
    }

    public var hex: String {
        switch self {
        case .meemawOrange: "#FF8C42"
        case .electricBlue: "#2563EB"
        case .mintGreen: "#10B981"
        case .candyPink: "#FF4D94"
        case .popPurple: "#8E44AD"
        case .sunYellow: "#F59E0B"
        case .neonCyan: "#00ACC1"
        case .cherryRed: "#E11D48"
        }
    }

    public var defaultEmoji: String {
        switch self {
        case .meemawOrange: "🦊"
        case .electricBlue: "🐬"
        case .mintGreen: "🐸"
        case .candyPink: "🦩"
        case .popPurple: "🐙"
        case .sunYellow: "🦁"
        case .neonCyan: "🦄"
        case .cherryRed: "🐞"
        }
    }
}

// MARK: - Decades (1960s -> 2010s-2020s) & Player Age Brackets

public enum QuizDecade: String, CaseIterable, Codable, Identifiable, Sendable {
    case sixties = "1960s"
    case seventies = "1970s"
    case eighties = "1980s"
    case nineties = "1990s"
    case twoThousands = "2000s"
    case twentyTens = "2010s"

    public var id: String { rawValue }

    public var badgeLabel: String {
        switch self {
        case .sixties: "🪩 Années 60"
        case .seventies: "🕺 Années 70"
        case .eighties: "📼 Années 80"
        case .nineties: "🕹️ Années 90"
        case .twoThousands: "💿 Années 2000"
        case .twentyTens: "📱 Années 2010–20"
        }
    }

    public var shortTag: String {
        switch self {
        case .sixties: "🪩 60s"
        case .seventies: "🕺 70s"
        case .eighties: "📼 80s"
        case .nineties: "🕹️ 90s"
        case .twoThousands: "💿 2000s"
        case .twentyTens: "📱 2010–20s"
        }
    }
}

public enum PlayerAgeBracket: String, CaseIterable, Codable, Identifiable, Sendable {
    case under25 = "under_25"
    case age25to39 = "25_39"
    case age40to54 = "40_54"
    case age55Plus = "55_plus"

    public var id: String { rawValue }

    public var shortBadge: String {
        switch self {
        case .under25: "🐣 -25 ans"
        case .age25to39: "🕹️ 25–39 ans"
        case .age40to54: "📼 40–54 ans"
        case .age55Plus: "🪩 55+ ans"
        }
    }

    public var subtitle: String {
        switch self {
        case .under25: "2000s – 2020s"
        case .age25to39: "90s – 2010s"
        case .age40to54: "70s – 90s"
        case .age55Plus: "60s – 80s"
        }
    }

    public var preferredDecades: [QuizDecade] {
        switch self {
        case .under25:
            return [.twoThousands, .twentyTens]
        case .age25to39:
            return [.nineties, .twoThousands, .twentyTens]
        case .age40to54:
            return [.seventies, .eighties, .nineties]
        case .age55Plus:
            return [.sixties, .seventies, .eighties]
        }
    }
}

// MARK: - Player & Lobby Registry

public enum PlayerPlatform: String, Codable, Sendable {
    case iosHost = "ios_host"
    case iosBonjour = "ios_bonjour"
    case webQR = "web_qr"
}

public struct QuizPlayer: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var color: PlayerColor
    public var avatarEmoji: String
    public var ageBracket: PlayerAgeBracket?
    public var score: Int
    public var streak: Int
    public var isHost: Bool
    public var isReady: Bool
    public var platform: PlayerPlatform
    public var hasUsedBisouTrap: Bool
    public var hasUsedScrew: Bool
    public var activeBisouWipesRemaining: Int
    public var bisouSenderName: String?
    public var lockedChoiceIndex: Int?
    public var lockedSide: String?
    public var lockedBetStars: Int?
    public var lockedDrawGuess: String?
    public var lockedNumericEstimate: Int?
    public var isJackAttackFrozen: Bool
    public var drawHintsUsedCount: Int
    public var hasSubmittedEsquisseStep: Bool
    public var reactionTimeMs: Int?
    public var lastDeltaScore: Int?
    public var totalReactionMsSum: Int
    public var correctAnswersCount: Int
    public var soloWinsCount: Int

    public var effectiveAgeBracket: PlayerAgeBracket {
        ageBracket ?? .age40to54
    }

    public init(
        id: String,
        name: String,
        color: PlayerColor,
        avatarEmoji: String,
        ageBracket: PlayerAgeBracket? = .age40to54,
        score: Int = 0,
        streak: Int = 0,
        isHost: Bool = false,
        isReady: Bool = true,
        platform: PlayerPlatform = .iosBonjour,
        hasUsedBisouTrap: Bool = false,
        hasUsedScrew: Bool = false,
        activeBisouWipesRemaining: Int = 0,
        bisouSenderName: String? = nil,
        lockedChoiceIndex: Int? = nil,
        lockedSide: String? = nil,
        lockedBetStars: Int? = nil,
        lockedDrawGuess: String? = nil,
        lockedNumericEstimate: Int? = nil,
        isJackAttackFrozen: Bool = false,
        drawHintsUsedCount: Int = 0,
        hasSubmittedEsquisseStep: Bool = false,
        reactionTimeMs: Int? = nil,
        lastDeltaScore: Int? = nil,
        totalReactionMsSum: Int = 0,
        correctAnswersCount: Int = 0,
        soloWinsCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.avatarEmoji = avatarEmoji
        self.ageBracket = ageBracket
        self.score = score
        self.streak = streak
        self.isHost = isHost
        self.isReady = isReady
        self.platform = platform
        self.hasUsedBisouTrap = hasUsedBisouTrap
        self.hasUsedScrew = hasUsedScrew
        self.activeBisouWipesRemaining = activeBisouWipesRemaining
        self.bisouSenderName = bisouSenderName
        self.lockedChoiceIndex = lockedChoiceIndex
        self.lockedSide = lockedSide
        self.lockedBetStars = lockedBetStars
        self.lockedDrawGuess = lockedDrawGuess
        self.lockedNumericEstimate = lockedNumericEstimate
        self.isJackAttackFrozen = isJackAttackFrozen
        self.drawHintsUsedCount = drawHintsUsedCount
        self.hasSubmittedEsquisseStep = hasSubmittedEsquisseStep
        self.reactionTimeMs = reactionTimeMs
        self.lastDeltaScore = lastDeltaScore
        self.totalReactionMsSum = totalReactionMsSum
        self.correctAnswersCount = correctAnswersCount
        self.soloWinsCount = soloWinsCount
    }
}

public struct PlayerLobbyRegistry: Sendable {
    public private(set) var players: [QuizPlayer] = []

    public init(players: [QuizPlayer] = []) {
        self.players = players
    }

    public func availableColors(excludingPlayerID: String?) -> [PlayerColor] {
        let taken = Set(
            players
                .filter { $0.id != excludingPlayerID }
                .map(\.color)
        )
        return PlayerColor.allCases.filter { !taken.contains($0) }
    }

    @discardableResult
    public mutating func upsertPlayer(
        id: String,
        name: String,
        requestedColor: PlayerColor?,
        avatarEmoji: String?,
        ageBracket: PlayerAgeBracket? = nil,
        isHost: Bool,
        platform: PlayerPlatform = .iosBonjour
    ) -> QuizPlayer {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = cleanName.isEmpty ? "Joueur \(players.count + 1)" : String(cleanName.prefix(16))
        let freeColors = availableColors(excludingPlayerID: id)

        if let existingIndex = players.firstIndex(where: { $0.id == id }) {
            var player = players[existingIndex]
            player.name = displayName
            if let req = requestedColor, freeColors.contains(req) {
                player.color = req
            } else if !freeColors.contains(player.color), let fallback = freeColors.first {
                player.color = fallback
            }
            if let emoji = avatarEmoji, !emoji.isEmpty {
                player.avatarEmoji = emoji
            }
            if let ageBracket {
                player.ageBracket = ageBracket
            }
            player.isReady = true
            players[existingIndex] = player
            return player
        } else {
            let chosenColor: PlayerColor
            if let req = requestedColor, freeColors.contains(req) {
                chosenColor = req
            } else {
                chosenColor = freeColors.first ?? .meemawOrange
            }
            let emoji = (avatarEmoji?.isEmpty == false) ? avatarEmoji! : chosenColor.defaultEmoji
            let newPlayer = QuizPlayer(
                id: id,
                name: displayName,
                color: chosenColor,
                avatarEmoji: emoji,
                ageBracket: ageBracket ?? .age40to54,
                isHost: isHost,
                isReady: true,
                platform: platform
            )
            players.append(newPlayer)
            return newPlayer
        }
    }

    public mutating func removePlayer(id: String) {
        players.removeAll { $0.id == id }
    }

    public mutating func updatePlayer(id: String, mutate: (inout QuizPlayer) -> Void) {
        guard let idx = players.firstIndex(where: { $0.id == id }) else { return }
        mutate(&players[idx])
    }

    public mutating func resetRoundLocks() {
        for idx in players.indices {
            players[idx].lockedChoiceIndex = nil
            players[idx].lockedSide = nil
            players[idx].lockedBetStars = nil
            players[idx].lockedDrawGuess = nil
            players[idx].lockedNumericEstimate = nil
            players[idx].isJackAttackFrozen = false
            players[idx].drawHintsUsedCount = 0
            players[idx].hasSubmittedEsquisseStep = false
            players[idx].reactionTimeMs = nil
            players[idx].lastDeltaScore = nil
            players[idx].activeBisouWipesRemaining = 0
            players[idx].bisouSenderName = nil
        }
    }

    public mutating func resetForNewShow() {
        for idx in players.indices {
            players[idx].score = 0
            players[idx].streak = 0
            players[idx].hasUsedBisouTrap = false
            players[idx].hasUsedScrew = false
            players[idx].activeBisouWipesRemaining = 0
            players[idx].bisouSenderName = nil
            players[idx].lockedChoiceIndex = nil
            players[idx].lockedSide = nil
            players[idx].lockedBetStars = nil
            players[idx].lockedDrawGuess = nil
            players[idx].lockedNumericEstimate = nil
            players[idx].isJackAttackFrozen = false
            players[idx].drawHintsUsedCount = 0
            players[idx].hasSubmittedEsquisseStep = false
            players[idx].reactionTimeMs = nil
            players[idx].lastDeltaScore = nil
            players[idx].totalReactionMsSum = 0
            players[idx].correctAnswersCount = 0
            players[idx].soloWinsCount = 0
        }
    }
}

// MARK: - 6 Question Theme Packs

public enum QuizThemePack: String, CaseIterable, Codable, Identifiable, Sendable {
    case grandMix = "grand_mix"
    case francaisMeemaw = "francais_meemaw"
    case mathMeemaw = "math_meemaw"
    case seriesCinema = "series_cinema"
    case musiqueTubes = "musique_tubes"
    case cultureGInsolite = "culture_g"
    case ecoCash = "eco_cash"

    public var id: String { rawValue }

    public var title: String {
        if AppLanguage.isEnglish {
            switch self {
            case .grandMix: return "🔀 Grand Mix Show"
            case .francaisMeemaw: return "👵 Wordplay & Idioms"
            case .mathMeemaw: return "📐 Meemaw Math & Logic"
            case .seriesCinema: return "🎬 Movies & TV Shows"
            case .musiqueTubes: return "🎵 Music & Pop Hits"
            case .cultureGInsolite: return "🌍 Weird Trivia & Science"
            case .ecoCash: return "💰 Money & Smart Cash"
            }
        }
        switch self {
        case .grandMix: return "🔀 Grand Mix Show"
        case .francaisMeemaw: return "👵 Français & Expressions"
        case .mathMeemaw: return "📐 Meemaw Math & Logique"
        case .seriesCinema: return "🎬 Séries & Cinéma"
        case .musiqueTubes: return "🎵 Musique & Tubes"
        case .cultureGInsolite: return "🌍 Culture G & Insolite"
        case .ecoCash: return "💰 Éco & Cash Perso"
        }
    }

    public var shortBadge: String {
        if AppLanguage.isEnglish {
            switch self {
            case .grandMix: return "🔀 GRAND MIX"
            case .francaisMeemaw: return "👵 WORDPLAY"
            case .mathMeemaw: return "📐 MATH FLASH"
            case .seriesCinema: return "🎬 MOVIES & TV"
            case .musiqueTubes: return "🎵 MUSIC HITS"
            case .cultureGInsolite: return "🌍 TRIVIA"
            case .ecoCash: return "💰 SMART CASH"
            }
        }
        switch self {
        case .grandMix: return "🔀 GRAND MIX"
        case .francaisMeemaw: return "👵 FRANÇAIS"
        case .mathMeemaw: return "📐 MATH FLASH"
        case .seriesCinema: return "🎬 SÉRIES & CINÉ"
        case .musiqueTubes: return "🎵 MUSIQUE"
        case .cultureGInsolite: return "🌍 CULTURE G"
        case .ecoCash: return "💰 ÉCO & CASH"
        }
    }

    public var subtitle: String {
        if AppLanguage.isEnglish {
            switch self {
            case .grandMix: return "The explosive cocktail of all Meemaw themes!"
            case .francaisMeemaw: return "Tricky spelling, vintage grandma sayings and riddles"
            case .mathMeemaw: return "Clever mental math, 1951 trains and logic traps"
            case .seriesCinema: return "Cult quotes, movies summarized by Grandma and TV hits"
            case .musiqueTubes: return "Finish the lyrics, absurd music records and pop hits"
            case .cultureGInsolite: return "Crazy science, weird history and unbelievable facts"
            case .ecoCash: return "Compound interest, inflation and smart money reflexes"
            }
        }
        switch self {
        case .grandMix: return "Le cocktail explosif de tous les thèmes de Meemaw !"
        case .francaisMeemaw: return "Orthographe piège, expressions d'antan et devinettes"
        case .mathMeemaw: return "Calcul mental malin, trains de 1951 et pièges logiques"
        case .seriesCinema: return "Répliques cultes, films résumés par Mamie et séries"
        case .musiqueTubes: return "Blind-test de paroles, records absurdes et pop/chanson"
        case .cultureGInsolite: return "Sciences folles, histoire décalée et records improbables"
        case .ecoCash: return "Intérêts composés, PEA, inflation et réflexes malins"
        }
    }

    public var accentHex: String {
        switch self {
        case .grandMix: "#FF8C42"
        case .francaisMeemaw: "#E11D48"
        case .mathMeemaw: "#2563EB"
        case .seriesCinema: "#8E44AD"
        case .musiqueTubes: "#FF4D94"
        case .cultureGInsolite: "#10B981"
        case .ecoCash: "#F59E0B"
        }
    }
}

// MARK: - Show Game Modes (Full Quiz + Draw, 100% Draw Something, 100% Esquissé!)

public enum ShowGameMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case fullQuizShow = "full_quiz_show"
    case drawSomethingOnly = "draw_something_only"
    case esquisseParty = "esquisse_party"

    public var id: String { rawValue }

    public var title: String {
        if AppLanguage.isEnglish {
            switch self {
            case .fullQuizShow: return "📺 Full TV Quiz Show (+ Drawing)"
            case .drawSomethingOnly: return "🎨 100% Draw Something"
            case .esquisseParty: return "📞 Sketch Relay! (1 Easy Word)"
            }
        }
        switch self {
        case .fullQuizShow: return "📺 Grand Show Quizz (+ Dessin)"
        case .drawSomethingOnly: return "🎨 100% Draw Something"
        case .esquisseParty: return "📞 Esquissé ! (1 Mot Facile)"
        }
    }

    public var shortBadge: String {
        if AppLanguage.isEnglish {
            switch self {
            case .fullQuizShow: return "📺 FULL SHOW"
            case .drawSomethingOnly: return "🎨 DRAW SOMETHING"
            case .esquisseParty: return "📞 SKETCH RELAY!"
            }
        }
        switch self {
        case .fullQuizShow: return "📺 SHOW COMPLET"
        case .drawSomethingOnly: return "🎨 DRAW SOMETHING"
        case .esquisseParty: return "📞 ESQUISSÉ !"
        }
    }

    public var subtitle: String {
        if AppLanguage.isEnglish {
            switch self {
            case .fullQuizShow: return "Speed Cash, Bet Your Brain, Jukebox, Closest Guess, Draw Something, Solo, Cheesy Quizz & Jack Attack!"
            case .drawSomethingOnly: return "Take turns drawing live on the TV while everyone else unscrambles the secret word on their phone!"
            case .esquisseParty: return "1 easy word to draw (Sun, Pizza, Fish...) ➔ Neighbor guesses 1 word ➔ Final drawing & Comic Book Showcase!"
            }
        }
        switch self {
        case .fullQuizShow: return "Quizz Rapide, Tu Te Mets Combien, Jukebox, Pinceau Draw Something, Solo & Raclette !"
        case .drawSomethingOnly: return "Chacun dessine à tour de rôle en direct sur la TV, les autres trouvent le mot avec les lettres mélangées !"
        case .esquisseParty: return "1 seul mot facile à dessiner (Soleil, Pizza, Poisson...) ➔ Le voisin devine 1 mot ➔ Dessin final & Grand Défilé BD !"
        }
    }

    public var accentHex: String {
        switch self {
        case .fullQuizShow: "#FF8C42"
        case .drawSomethingOnly: "#10B981"
        case .esquisseParty: "#FF4D94"
        }
    }
}

// MARK: - Game Round Kinds

public enum QuizRoundKind: String, Codable, Sendable {
    case cashSpeed = "cash_speed"
    case tuTeMetsCombien = "tu_te_mets_combien"
    case jukeboxExpress = "jukebox_express"
    case leJustePif = "le_juste_pif"
    case drawSomething = "draw_something"
    case leSolo = "le_solo"
    case couciCouca = "couci_couca"
    case quoizziQuoissa = "quoizzi_quoissa"
    case esquisseTeleArabe = "esquisse_tele_arabe"
    case finaleDouble = "finale_double"
    case jackAttack = "jack_attack"

    public var badgeTitle: String {
        if AppLanguage.isEnglish {
            switch self {
            case .cashSpeed: return "⚡ ROUND 1 • SPEED CASH"
            case .tuTeMetsCombien: return "🎯 ROUND 2 • BET YOUR BRAIN (1–4 ★)"
            case .jukeboxExpress: return "🎧 ROUND 3 • JUKEBOX EXPRESS"
            case .leJustePif: return "🔢 ROUND • CLOSEST GUESS"
            case .drawSomething: return "🎨 ROUND • DRAW SOMETHING LIVE"
            case .leSolo: return "🚨 ROUND • SOLO FASTEST FINGER"
            case .couciCouca: return "🧀 ROUND • CHEESY QUIZZ"
            case .quoizziQuoissa: return "🤪 ROUND • PUN-A-PALOOZA"
            case .esquisseTeleArabe: return "📞 PARTY • SKETCH RELAY!"
            case .finaleDouble: return "🔥 FINAL ROUND • DOUBLE POINTS ×2"
            case .jackAttack: return "⚡ GRAND FINALE • MEEMAW'S JACK ATTACK"
            }
        }
        switch self {
        case .cashSpeed: return "⚡ MANCHE 1 • CASH RAPIDE"
        case .tuTeMetsCombien: return "🎯 MANCHE 2 • TU TE METS COMBIEN ?"
        case .jukeboxExpress: return "🎧 MANCHE 3 • LE JUKEBOX EXPRESS"
        case .leJustePif: return "🔢 MANCHE • LE JUSTE PIF"
        case .drawSomething: return "🎨 MANCHE • PINCEAU DRAW SOMETHING"
        case .leSolo: return "🚨 MANCHE • LE SOLO (1er QUI DÉGAINE)"
        case .couciCouca: return "🧀 MANCHE • LA RACLETTE QUIZZ"
        case .quoizziQuoissa: return "🤪 MANCHE • QUOIZZI-QUOISSA"
        case .esquisseTeleArabe: return "📞 SOIRÉE • ESQUISSÉ ! (TÉLÉPHONE ARABE)"
        case .finaleDouble: return "🔥 MANCHE FINALE • RAFALE POINTS ×2"
        case .jackAttack: return "⚡ GRANDE FINALE • LE JACK ATTACK DE MEEMAW"
        }
    }

    public var ruleSummary: String {
        if AppLanguage.isEnglish {
            switch self {
            case .cashSpeed: return "Everyone answers on their phone! Fastest finger wins the speed bonus!"
            case .tuTeMetsCombien: return "Before seeing the question, bet from ⭐ (1,000 pts) to ⭐⭐⭐⭐ (5,000 pts) on Meemaw's topic!"
            case .jukeboxExpress: return "Don't forget the lyrics: complete the exact chorus line right when the music stops!"
            case .leJustePif: return "No multiple choice: type your best number on the keypad! Closest guess wins +3,000 pts (+5,000 pts for an exact Bullseye)!"
            case .drawSomething: return "1 player draws live on the TV while everyone else taps the scrambled letters to find the word!"
            case .leSolo: return "No separate buzzer needed: the FIRST player to tap an answer locks out the room (Double or Wipeout)!"
            case .couciCouca: return "Rapid-fire binary madness: tap Option A, Option B, or 🧀 BOTH!"
            case .quoizziQuoissa: return "Meemaw's twisted puns and dad jokes: answer as fast as you can!"
            case .esquisseTeleArabe: return "1 easy word to draw with your finger -> Neighbor guesses 1 word -> Next drawing & Grand Comic Showcase on TV!"
            case .finaleDouble: return "Home stretch: all points and penalties are DOUBLED!"
            case .jackAttack: return "Clues flash at high speed: HIT THE BUZZER only when the matching pair appears (+3,000 pts, or -1,500 pts if it's a trap)!"
            }
        }
        switch self {
        case .cashSpeed: return "Tout le monde répond sur son tel ! Le plus rapide rafle le jackpot !"
        case .tuTeMetsCombien: return "Avant de voir la question, mise de ⭐ (1 000 pts) à ⭐⭐⭐⭐ (5 000 pts) sur le sujet annoncé par Meemaw !"
        case .jukeboxExpress: return "N'oubliez pas les paroles de Meemaw : complète le refrain exact au moment où la musique coupe !"
        case .leJustePif: return "Pas de QCM : tape ton estimation chiffrée sur le pavé numérique ! Le plus proche rafle +3 000 pts (et +5 000 pts en Tout Pile) !"
        case .drawSomething: return "1 joueur dessine en direct sur la TV, les autres tapent les lettres façon Draw Something pour trouver le mot !"
        case .leSolo: return "Pas besoin de buzzer : le 1er qui tape sa réponse coupe l'herbe sous le pied des autres (Double ou Gamelle) !"
        case .couciCouca: return "Façon Burger Quiz version Savoie : tape Option A, Option B, ou 🧀 LES DEUX !"
        case .quoizziQuoissa: return "6 jeux de mots et calembours tordus de Meemaw : réponds dès que ça s'affiche !"
        case .esquisseTeleArabe: return "1 seul mot ultra-simple à dessiner au doigt -> Le voisin devine 1 mot -> Dessin suivant & Grand Défilé BD sur la TV !"
        case .finaleDouble: return "Dernière ligne droite : tous les points et pénalités sont DOUBLÉS !"
        case .jackAttack: return "Les propositions défilent à toute allure : BUZZE uniquement quand la bonne association s'affiche (+3 000 pts, ou -1 500 pts si piège) !"
        }
    }
}

// MARK: - Question, Sponsor, Juste Pif, Jack Attack & Couci-Couça Models

public struct MeemawSponsor: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var slogan: String
    public var hintKeyword: String
    public var trapChoiceText: String
    public var jackpotReward: Int

    public init(
        id: String,
        name: String,
        slogan: String,
        hintKeyword: String,
        trapChoiceText: String,
        jackpotReward: Int = 3500
    ) {
        self.id = id
        self.name = name
        self.slogan = slogan
        self.hintKeyword = hintKeyword
        self.trapChoiceText = trapChoiceText
        self.jackpotReward = jackpotReward
    }
}

public struct QuizJustePifQuestion: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var theme: QuizThemePack
    public var funnyTitle: String
    public var prompt: String
    public var unitLabel: String
    public var correctValue: Int
    public var meemawComment: String

    public init(
        id: String,
        theme: QuizThemePack,
        funnyTitle: String,
        prompt: String,
        unitLabel: String,
        correctValue: Int,
        meemawComment: String
    ) {
        self.id = id
        self.theme = theme
        self.funnyTitle = funnyTitle
        self.prompt = prompt
        self.unitLabel = unitLabel
        self.correctValue = correctValue
        self.meemawComment = meemawComment
    }
}

public struct QuizJackAttackWave: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var clueTitle: String
    public var anchorText: String
    public var options: [String]
    public var correctOptionIndex: Int
    public var explanation: String

    public init(
        id: String,
        clueTitle: String,
        anchorText: String,
        options: [String],
        correctOptionIndex: Int,
        explanation: String
    ) {
        self.id = id
        self.clueTitle = clueTitle
        self.anchorText = anchorText
        self.options = options
        self.correctOptionIndex = correctOptionIndex
        self.explanation = explanation
    }
}

public struct QuizJackAttackRound: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var funnyTitle: String
    public var waves: [QuizJackAttackWave]

    public init(
        id: String,
        funnyTitle: String,
        waves: [QuizJackAttackWave]
    ) {
        self.id = id
        self.funnyTitle = funnyTitle
        self.waves = waves
    }
}

public struct QuizMCQQuestion: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var theme: QuizThemePack
    public var preferredRound: QuizRoundKind
    public var decade: QuizDecade?
    public var funnyTitle: String
    public var prompt: String
    public var choices: [String]
    public var correctIndex: Int
    public var sponsoredChoiceIndex: Int?
    public var baseValue: Int
    public var meemawRoastOnWrong: String
    public var explanation: String
    public var audioCueID: String?

    public init(
        id: String,
        theme: QuizThemePack,
        preferredRound: QuizRoundKind = .cashSpeed,
        decade: QuizDecade? = nil,
        funnyTitle: String,
        prompt: String,
        choices: [String],
        correctIndex: Int,
        sponsoredChoiceIndex: Int? = nil,
        baseValue: Int = 2000,
        meemawRoastOnWrong: String,
        explanation: String,
        audioCueID: String? = nil
    ) {
        self.id = id
        self.theme = theme
        self.preferredRound = preferredRound
        self.decade = decade
        self.funnyTitle = funnyTitle
        self.prompt = prompt
        self.choices = choices
        self.correctIndex = correctIndex
        self.sponsoredChoiceIndex = sponsoredChoiceIndex
        self.baseValue = baseValue
        self.meemawRoastOnWrong = meemawRoastOnWrong
        self.explanation = explanation
        self.audioCueID = audioCueID
    }

    public static func choiceLetter(at index: Int) -> String {
        switch index {
        case 0: "A"
        case 1: "B"
        case 2: "C"
        case 3: "D"
        default: "?"
        }
    }
}

public struct QuizDisOrDatItem: Codable, Equatable, Identifiable, Sendable {
    public var index: Int
    public var text: String
    /// "left" or "right"
    public var correctSide: String

    public var id: Int { index }

    public init(index: Int, text: String, correctSide: String) {
        self.index = index
        self.text = text
        self.correctSide = correctSide
    }
}

public struct QuizDisOrDatRound: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var theme: QuizThemePack
    public var funnyTitle: String
    public var prompt: String
    public var optionLeft: String
    public var optionRight: String
    public var optionBoth: String?
    public var isPunRound: Bool
    public var valuePerItem: Int
    public var items: [QuizDisOrDatItem]
    public var audioCueID: String?

    public init(
        id: String,
        theme: QuizThemePack,
        funnyTitle: String,
        prompt: String,
        optionLeft: String,
        optionRight: String,
        optionBoth: String? = nil,
        valuePerItem: Int = 500,
        items: [QuizDisOrDatItem],
        audioCueID: String? = nil,
        isPunRound: Bool = false
    ) {
        self.id = id
        self.theme = theme
        self.funnyTitle = funnyTitle
        self.prompt = prompt
        self.optionLeft = optionLeft
        self.optionRight = optionRight
        self.optionBoth = optionBoth
        self.isPunRound = isPunRound
        self.valuePerItem = valuePerItem
        self.items = items
        self.audioCueID = audioCueID
    }
}

// MARK: - Vector Drawing & Esquissé Models

public struct NormalizedPoint: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = (x * 1000).rounded() / 1000
        self.y = (y * 1000).rounded() / 1000
    }
}

public struct DrawingStroke: Codable, Equatable, Sendable {
    public var colorHex: String
    public var lineWidth: Double
    public var points: [NormalizedPoint]

    public init(colorHex: String, lineWidth: Double = 6.0, points: [NormalizedPoint]) {
        self.colorHex = colorHex
        self.lineWidth = lineWidth
        self.points = points
    }
}

public struct DrawingCanvasData: Codable, Equatable, Sendable {
    /// Largeur de référence utilisée pour mettre à l'échelle l'épaisseur des traits de façon 100 % identique sur iPhone, iPad, Web et Apple TV.
    public static let referenceWidth: Double = 300.0
    /// Ratio Portrait 3:4 partagé entre le téléphone et l'Apple TV pour un rendu strictement identique sans déformation.
    public static let portraitAspectRatio: Double = 3.0 / 4.0

    public var strokes: [DrawingStroke]

    public init(strokes: [DrawingStroke] = []) {
        self.strokes = strokes
    }
}

public struct DrawWordOption: Codable, Equatable, Identifiable, Sendable {
    public var id: String { word }
    public var word: String
    public var categoryHint: String
    public var stars: Int
    public var points: Int
    public var scrambledTiles: [String]

    public init(
        word: String,
        categoryHint: String,
        stars: Int,
        points: Int,
        scrambledTiles: [String]
    ) {
        self.word = word
        self.categoryHint = categoryHint
        self.stars = stars
        self.points = points
        self.scrambledTiles = scrambledTiles
    }
}

public struct DrawRoundState: Codable, Equatable, Sendable {
    public var drawerPlayerID: String
    public var drawerPlayerName: String
    public var drawerEmoji: String
    public var wordOptions: [DrawWordOption]
    public var chosenWord: DrawWordOption?
    public var maskedWordPattern: String
    public var wordLength: Int
    public var scrambledTiles: [String]
    public var canvas: DrawingCanvasData
    public var foundPlayerIDs: [String]
    public var isMagicMeemawBrush: Bool

    public init(
        drawerPlayerID: String,
        drawerPlayerName: String,
        drawerEmoji: String,
        wordOptions: [DrawWordOption],
        chosenWord: DrawWordOption? = nil,
        maskedWordPattern: String = "",
        wordLength: Int = 0,
        scrambledTiles: [String] = [],
        canvas: DrawingCanvasData = DrawingCanvasData(),
        foundPlayerIDs: [String] = [],
        isMagicMeemawBrush: Bool = false
    ) {
        self.drawerPlayerID = drawerPlayerID
        self.drawerPlayerName = drawerPlayerName
        self.drawerEmoji = drawerEmoji
        self.wordOptions = wordOptions
        self.chosenWord = chosenWord
        self.maskedWordPattern = maskedWordPattern
        self.wordLength = wordLength
        self.scrambledTiles = scrambledTiles
        self.canvas = canvas
        self.foundPlayerIDs = foundPlayerIDs
        self.isMagicMeemawBrush = isMagicMeemawBrush
    }
}

public struct EsquisseEntry: Codable, Equatable, Identifiable, Sendable {
    public var id: String { "\(stepIndex)_\(authorPlayerID)" }
    public var stepIndex: Int
    public var authorPlayerID: String
    public var authorName: String
    public var authorEmoji: String
    public var promptText: String?
    public var drawing: DrawingCanvasData?

    public init(
        stepIndex: Int,
        authorPlayerID: String,
        authorName: String,
        authorEmoji: String,
        promptText: String? = nil,
        drawing: DrawingCanvasData? = nil
    ) {
        self.stepIndex = stepIndex
        self.authorPlayerID = authorPlayerID
        self.authorName = authorName
        self.authorEmoji = authorEmoji
        self.promptText = promptText
        self.drawing = drawing
    }
}

public struct EsquisseNotebook: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var ownerPlayerID: String
    public var ownerName: String
    public var ownerEmoji: String
    public var entries: [EsquisseEntry]
    public var voteVoterIDs: [String]

    public init(
        id: String,
        ownerPlayerID: String,
        ownerName: String,
        ownerEmoji: String,
        entries: [EsquisseEntry] = [],
        voteVoterIDs: [String] = []
    ) {
        self.id = id
        self.ownerPlayerID = ownerPlayerID
        self.ownerName = ownerName
        self.ownerEmoji = ownerEmoji
        self.entries = entries
        self.voteVoterIDs = voteVoterIDs
    }
}

public struct EsquisseRoundState: Codable, Equatable, Sendable {
    public var stepIndex: Int
    public var totalSteps: Int
    public var notebooks: [EsquisseNotebook]
    /// Map of `playerID -> notebookID` currently assigned to that player during this step
    public var activeAssignmentByPlayerID: [String: String]
    public var showcaseNotebookIndex: Int
    public var showcaseEntryCount: Int

    public init(
        stepIndex: Int,
        totalSteps: Int,
        notebooks: [EsquisseNotebook],
        activeAssignmentByPlayerID: [String: String] = [:],
        showcaseNotebookIndex: Int = 0,
        showcaseEntryCount: Int = 1
    ) {
        self.stepIndex = stepIndex
        self.totalSteps = totalSteps
        self.notebooks = notebooks
        self.activeAssignmentByPlayerID = activeAssignmentByPlayerID
        self.showcaseNotebookIndex = showcaseNotebookIndex
        self.showcaseEntryCount = showcaseEntryCount
    }
}

// MARK: - Network Protocol (Shared by iOS Bonjour & Android/Web QR Clients)

public enum ShowStageState: String, Codable, Sendable {
    case lobby = "lobby"
    case roundIntro = "round_intro"
    case ttmcBetting = "ttmc_betting"
    case questionReading = "question_reading"
    case cashAnswering = "cash_answering"
    case soloBuzzOpen = "solo_buzz_open"
    case soloPlayerAnswering = "solo_player_answering"
    case questionReveal = "question_reveal"
    case justePifAnswering = "juste_pif_answering"
    case justePifReveal = "juste_pif_reveal"
    case couciCoucaIntro = "couci_couca_intro"
    case couciCoucaItem = "couci_couca_item"
    case couciCoucaReveal = "couci_couca_reveal"
    case couciCoucaSummary = "couci_couca_summary"
    case drawWordChoice = "draw_word_choice"
    case drawLiveGuessing = "draw_live_guessing"
    case drawReveal = "draw_reveal"
    case esquissePromptEntry = "esquisse_prompt_entry"
    case esquisseDrawing = "esquisse_drawing"
    case esquisseGuessing = "esquisse_guessing"
    case esquisseShowcase = "esquisse_showcase"
    case jackAttackActive = "jack_attack_active"
    case jackAttackWaveReveal = "jack_attack_wave_reveal"
    case finalPodium = "final_podium"
}

public struct ClientToHostMessage: Codable, Equatable, Sendable {
    public enum ActionKind: String, Codable, Sendable {
        case joinOrUpdateProfile = "join_profile"
        case selectChoice = "select_choice"
        case selectBetStars = "select_bet_stars"
        case buzzSolo = "buzz_solo"
        case selectBinarySide = "select_binary"
        case submitNumericEstimate = "submit_numeric_estimate"
        case buzzJackAttack = "buzz_jack_attack"
        case sendBisouTrap = "send_bisou"
        case screwOpponent = "screw_opponent"
        case wipeBisouScreen = "wipe_bisou"
        case selectDrawWord = "select_draw_word"
        case swapSecretPrompt = "swap_secret_prompt"
        case updateDrawingCanvas = "update_drawing_canvas"
        case submitDrawGuessWord = "submit_draw_guess"
        case requestDrawHint = "request_draw_hint"
        case submitEsquisseText = "submit_esquisse_text"
        case submitEsquisseDrawing = "submit_esquisse_drawing"
        case voteEsquisseAlbum = "vote_esquisse_album"
        case leaveGame = "leave_game"
        case ping = "ping"
    }

    public var playerID: String
    public var action: ActionKind
    public var playerName: String?
    public var requestedColor: PlayerColor?
    public var avatarEmoji: String?
    public var ageBracket: PlayerAgeBracket?
    public var platform: PlayerPlatform?
    public var choiceIndex: Int?
    public var betStars: Int?
    public var binarySide: String?
    public var numericEstimate: Int?
    public var targetPlayerID: String?
    public var textPayload: String?
    public var drawingCanvas: DrawingCanvasData?

    public init(
        playerID: String,
        action: ActionKind,
        playerName: String? = nil,
        requestedColor: PlayerColor? = nil,
        avatarEmoji: String? = nil,
        ageBracket: PlayerAgeBracket? = nil,
        platform: PlayerPlatform? = nil,
        choiceIndex: Int? = nil,
        betStars: Int? = nil,
        binarySide: String? = nil,
        numericEstimate: Int? = nil,
        targetPlayerID: String? = nil,
        textPayload: String? = nil,
        drawingCanvas: DrawingCanvasData? = nil
    ) {
        self.playerID = playerID
        self.action = action
        self.playerName = playerName
        self.requestedColor = requestedColor
        self.avatarEmoji = avatarEmoji
        self.ageBracket = ageBracket
        self.platform = platform
        self.choiceIndex = choiceIndex
        self.betStars = betStars
        self.binarySide = binarySide
        self.numericEstimate = numericEstimate
        self.targetPlayerID = targetPlayerID
        self.textPayload = textPayload
        self.drawingCanvas = drawingCanvas
    }
}

public struct PodiumAward: Codable, Equatable, Identifiable, Sendable {
    public var id: String { playerID }
    public var playerID: String
    public var playerName: String
    public var playerColor: PlayerColor
    public var avatarEmoji: String
    public var rank: Int
    public var score: Int
    public var funnyTitle: String
    public var subtitle: String

    public init(
        playerID: String,
        playerName: String,
        playerColor: PlayerColor,
        avatarEmoji: String,
        rank: Int,
        score: Int,
        funnyTitle: String,
        subtitle: String
    ) {
        self.playerID = playerID
        self.playerName = playerName
        self.playerColor = playerColor
        self.avatarEmoji = avatarEmoji
        self.rank = rank
        self.score = score
        self.funnyTitle = funnyTitle
        self.subtitle = subtitle
    }
}

public struct HostToClientStateSnapshot: Codable, Equatable, Sendable {
    public var roomCode: String
    public var joinURL: String
    public var selectedGameMode: ShowGameMode
    public var selectedPack: QuizThemePack
    public var stage: ShowStageState
    public var roundKind: QuizRoundKind
    public var questionNumber: Int
    public var totalQuestions: Int
    public var meemawSpeech: String
    public var meemawPose: String
    public var timeRemainingSec: Double
    public var totalTimerSec: Double
    public var players: [QuizPlayer]
    public var availableColors: [PlayerColor]
    public var activeSponsor: MeemawSponsor?
    public var sponsorWinnerName: String?
    public var activeQuestion: QuizMCQQuestion?
    public var revealedCorrectIndex: Int?
    public var soloBuzzerPlayerID: String?
    public var soloBuzzerPlayerName: String?
    public var screwAttackerName: String?
    public var activeJustePif: QuizJustePifQuestion?
    public var activeDisOrDat: QuizDisOrDatRound?
    public var activeDisOrDatItemIndex: Int?
    public var revealedBinarySide: String?
    public var activeDrawRound: DrawRoundState?
    public var activeEsquisseRound: EsquisseRoundState?
    public var activeJackAttack: QuizJackAttackRound?
    public var activeJackAttackWaveIndex: Int?
    public var activeJackAttackOptionIndex: Int?
    public var jackAttackWinnerName: String?
    public var podiumAwards: [PodiumAward]

    public init(
        roomCode: String,
        joinURL: String,
        selectedGameMode: ShowGameMode = .fullQuizShow,
        selectedPack: QuizThemePack,
        stage: ShowStageState,
        roundKind: QuizRoundKind,
        questionNumber: Int,
        totalQuestions: Int,
        meemawSpeech: String,
        meemawPose: String,
        timeRemainingSec: Double,
        totalTimerSec: Double,
        players: [QuizPlayer],
        availableColors: [PlayerColor],
        activeSponsor: MeemawSponsor? = nil,
        sponsorWinnerName: String? = nil,
        activeQuestion: QuizMCQQuestion? = nil,
        revealedCorrectIndex: Int? = nil,
        soloBuzzerPlayerID: String? = nil,
        soloBuzzerPlayerName: String? = nil,
        screwAttackerName: String? = nil,
        activeJustePif: QuizJustePifQuestion? = nil,
        activeDisOrDat: QuizDisOrDatRound? = nil,
        activeDisOrDatItemIndex: Int? = nil,
        revealedBinarySide: String? = nil,
        activeDrawRound: DrawRoundState? = nil,
        activeEsquisseRound: EsquisseRoundState? = nil,
        activeJackAttack: QuizJackAttackRound? = nil,
        activeJackAttackWaveIndex: Int? = nil,
        activeJackAttackOptionIndex: Int? = nil,
        jackAttackWinnerName: String? = nil,
        podiumAwards: [PodiumAward] = []
    ) {
        self.roomCode = roomCode
        self.joinURL = joinURL
        self.selectedGameMode = selectedGameMode
        self.selectedPack = selectedPack
        self.stage = stage
        self.roundKind = roundKind
        self.questionNumber = questionNumber
        self.totalQuestions = totalQuestions
        self.meemawSpeech = meemawSpeech
        self.meemawPose = meemawPose
        self.timeRemainingSec = timeRemainingSec
        self.totalTimerSec = totalTimerSec
        self.players = players
        self.availableColors = availableColors
        self.activeSponsor = activeSponsor
        self.sponsorWinnerName = sponsorWinnerName
        self.activeQuestion = activeQuestion
        self.revealedCorrectIndex = revealedCorrectIndex
        self.soloBuzzerPlayerID = soloBuzzerPlayerID
        self.soloBuzzerPlayerName = soloBuzzerPlayerName
        self.screwAttackerName = screwAttackerName
        self.activeJustePif = activeJustePif
        self.activeDisOrDat = activeDisOrDat
        self.activeDisOrDatItemIndex = activeDisOrDatItemIndex
        self.revealedBinarySide = revealedBinarySide
        self.activeDrawRound = activeDrawRound
        self.activeEsquisseRound = activeEsquisseRound
        self.activeJackAttack = activeJackAttack
        self.activeJackAttackWaveIndex = activeJackAttackWaveIndex
        self.activeJackAttackOptionIndex = activeJackAttackOptionIndex
        self.jackAttackWinnerName = jackAttackWinnerName
        self.podiumAwards = podiumAwards
    }
}
