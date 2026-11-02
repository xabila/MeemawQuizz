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
    public var hasSubmittedEsquisseStep: Bool
    public var reactionTimeMs: Int?
    public var lastDeltaScore: Int?
    public var totalReactionMsSum: Int
    public var correctAnswersCount: Int
    public var soloWinsCount: Int

    public init(
        id: String,
        name: String,
        color: PlayerColor,
        avatarEmoji: String,
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
        switch self {
        case .grandMix: "🔀 Grand Mix Show"
        case .francaisMeemaw: "👵 Français & Expressions"
        case .mathMeemaw: "📐 Meemaw Math & Logique"
        case .seriesCinema: "🎬 Séries & Cinéma"
        case .musiqueTubes: "🎵 Musique & Tubes"
        case .cultureGInsolite: "🌍 Culture G & Insolite"
        case .ecoCash: "💰 Éco & Cash Perso"
        }
    }

    public var shortBadge: String {
        switch self {
        case .grandMix: "🔀 GRAND MIX"
        case .francaisMeemaw: "👵 FRANÇAIS"
        case .mathMeemaw: "📐 MATH FLASH"
        case .seriesCinema: "🎬 SÉRIES & CINÉ"
        case .musiqueTubes: "🎵 MUSIQUE"
        case .cultureGInsolite: "🌍 CULTURE G"
        case .ecoCash: "💰 ÉCO & CASH"
        }
    }

    public var subtitle: String {
        switch self {
        case .grandMix: "Le cocktail explosif de tous les thèmes de Meemaw !"
        case .francaisMeemaw: "Orthographe piège, expressions d'antan et devinettes"
        case .mathMeemaw: "Calcul mental malin, trains de 1951 et pièges logiques"
        case .seriesCinema: "Répliques cultes, films résumés par Mamie et séries"
        case .musiqueTubes: "Blind-test de paroles, records absurdes et pop/chanson"
        case .cultureGInsolite: "Sciences folles, histoire décalée et records improbables"
        case .ecoCash: "Intérêts composés, PEA, inflation et réflexes malins"
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
        switch self {
        case .fullQuizShow: "📺 Grand Show Quizz (+ Dessin)"
        case .drawSomethingOnly: "🎨 100% Draw Something"
        case .esquisseParty: "📞 Esquissé ! (Gartic Phone)"
        }
    }

    public var shortBadge: String {
        switch self {
        case .fullQuizShow: "📺 SHOW COMPLET"
        case .drawSomethingOnly: "🎨 DRAW SOMETHING"
        case .esquisseParty: "📞 ESQUISSÉ !"
        }
    }

    public var subtitle: String {
        switch self {
        case .fullQuizShow: "Quizz Rapide, Tu Te Mets Combien, Jukebox, Pinceau Draw Something, Solo & Raclette !"
        case .drawSomethingOnly: "Chacun dessine à tour de rôle en direct sur la TV, les autres trouvent le mot avec les lettres mélangées !"
        case .esquisseParty: "Le Téléphone Arabe Dessiné : Phrase libre -> Dessin -> Interprétation au clavier -> Dessin & Grand Défilé TV !"
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
    case drawSomething = "draw_something"
    case leSolo = "le_solo"
    case couciCouca = "couci_couca"
    case quoizziQuoissa = "quoizzi_quoissa"
    case esquisseTeleArabe = "esquisse_tele_arabe"
    case finaleDouble = "finale_double"

    public var badgeTitle: String {
        switch self {
        case .cashSpeed: "⚡ MANCHE 1 • CASH RAPIDE"
        case .tuTeMetsCombien: "🎯 MANCHE 2 • TU TE METS COMBIEN ?"
        case .jukeboxExpress: "🎧 MANCHE 3 • LE JUKEBOX EXPRESS"
        case .drawSomething: "🎨 MANCHE • PINCEAU DRAW SOMETHING"
        case .leSolo: "🚨 MANCHE • LE SOLO (1er QUI DÉGAINE)"
        case .couciCouca: "🧀 MANCHE • LA RACLETTE QUIZZ"
        case .quoizziQuoissa: "🤪 MANCHE • QUOIZZI-QUOISSA"
        case .esquisseTeleArabe: "📞 SOIRÉE • ESQUISSÉ ! (TÉLÉPHONE ARABE)"
        case .finaleDouble: "🔥 MANCHE FINALE • RAFALE POINTS ×2"
        }
    }

    public var ruleSummary: String {
        switch self {
        case .cashSpeed: "Tout le monde répond sur son tel ! Le plus rapide rafle le jackpot !"
        case .tuTeMetsCombien: "Avant de voir la question, mise de ⭐ (1 000 pts) à ⭐⭐⭐⭐ (5 000 pts) sur le sujet annoncé par Meemaw !"
        case .jukeboxExpress: "N'oubliez pas les paroles de Meemaw : complète le refrain exact au moment où la musique coupe !"
        case .drawSomething: "1 joueur dessine en direct sur la TV, les autres tapent les lettres façon Draw Something pour trouver le mot !"
        case .leSolo: "Pas besoin de buzzer : le 1er qui tape sa réponse coupe l'herbe sous le pied des autres (Double ou Gamelle) !"
        case .couciCouca: "Façon Burger Quiz version Savoie : tape Option A, Option B, ou 🧀 LES DEUX !"
        case .quoizziQuoissa: "6 jeux de mots et calembours tordus de Meemaw : réponds dès que ça s'affiche !"
        case .esquisseTeleArabe: "Écris une phrase -> Le voisin la dessine -> Le suivant tape ce qu'il croit voir -> Grand Défilé final sur la TV !"
        case .finaleDouble: "Dernière ligne droite : tous les points et pénalités sont DOUBLÉS !"
        }
    }
}

// MARK: - Question & Couci-Couça Models

public struct QuizMCQQuestion: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var theme: QuizThemePack
    public var preferredRound: QuizRoundKind
    public var funnyTitle: String
    public var prompt: String
    public var choices: [String]
    public var correctIndex: Int
    public var baseValue: Int
    public var meemawRoastOnWrong: String
    public var explanation: String
    public var audioCueID: String?

    public init(
        id: String,
        theme: QuizThemePack,
        preferredRound: QuizRoundKind = .cashSpeed,
        funnyTitle: String,
        prompt: String,
        choices: [String],
        correctIndex: Int,
        baseValue: Int = 2000,
        meemawRoastOnWrong: String,
        explanation: String,
        audioCueID: String? = nil
    ) {
        self.id = id
        self.theme = theme
        self.preferredRound = preferredRound
        self.funnyTitle = funnyTitle
        self.prompt = prompt
        self.choices = choices
        self.correctIndex = correctIndex
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
    case finalPodium = "final_podium"
}

public struct ClientToHostMessage: Codable, Equatable, Sendable {
    public enum ActionKind: String, Codable, Sendable {
        case joinOrUpdateProfile = "join_profile"
        case selectChoice = "select_choice"
        case selectBetStars = "select_bet_stars"
        case buzzSolo = "buzz_solo"
        case selectBinarySide = "select_binary"
        case sendBisouTrap = "send_bisou"
        case screwOpponent = "screw_opponent"
        case wipeBisouScreen = "wipe_bisou"
        case selectDrawWord = "select_draw_word"
        case updateDrawingCanvas = "update_drawing_canvas"
        case submitDrawGuessWord = "submit_draw_guess"
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
    public var platform: PlayerPlatform?
    public var choiceIndex: Int?
    public var betStars: Int?
    public var binarySide: String?
    public var targetPlayerID: String?
    public var textPayload: String?
    public var drawingCanvas: DrawingCanvasData?

    public init(
        playerID: String,
        action: ActionKind,
        playerName: String? = nil,
        requestedColor: PlayerColor? = nil,
        avatarEmoji: String? = nil,
        platform: PlayerPlatform? = nil,
        choiceIndex: Int? = nil,
        betStars: Int? = nil,
        binarySide: String? = nil,
        targetPlayerID: String? = nil,
        textPayload: String? = nil,
        drawingCanvas: DrawingCanvasData? = nil
    ) {
        self.playerID = playerID
        self.action = action
        self.playerName = playerName
        self.requestedColor = requestedColor
        self.avatarEmoji = avatarEmoji
        self.platform = platform
        self.choiceIndex = choiceIndex
        self.betStars = betStars
        self.binarySide = binarySide
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
    public var activeQuestion: QuizMCQQuestion?
    public var revealedCorrectIndex: Int?
    public var soloBuzzerPlayerID: String?
    public var soloBuzzerPlayerName: String?
    public var screwAttackerName: String?
    public var activeDisOrDat: QuizDisOrDatRound?
    public var activeDisOrDatItemIndex: Int?
    public var revealedBinarySide: String?
    public var activeDrawRound: DrawRoundState?
    public var activeEsquisseRound: EsquisseRoundState?
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
        activeQuestion: QuizMCQQuestion? = nil,
        revealedCorrectIndex: Int? = nil,
        soloBuzzerPlayerID: String? = nil,
        soloBuzzerPlayerName: String? = nil,
        screwAttackerName: String? = nil,
        activeDisOrDat: QuizDisOrDatRound? = nil,
        activeDisOrDatItemIndex: Int? = nil,
        revealedBinarySide: String? = nil,
        activeDrawRound: DrawRoundState? = nil,
        activeEsquisseRound: EsquisseRoundState? = nil,
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
        self.activeQuestion = activeQuestion
        self.revealedCorrectIndex = revealedCorrectIndex
        self.soloBuzzerPlayerID = soloBuzzerPlayerID
        self.soloBuzzerPlayerName = soloBuzzerPlayerName
        self.screwAttackerName = screwAttackerName
        self.activeDisOrDat = activeDisOrDat
        self.activeDisOrDatItemIndex = activeDisOrDatItemIndex
        self.revealedBinarySide = revealedBinarySide
        self.activeDrawRound = activeDrawRound
        self.activeEsquisseRound = activeEsquisseRound
        self.podiumAwards = podiumAwards
    }
}
