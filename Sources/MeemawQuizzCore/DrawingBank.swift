import Foundation

public enum DrawingBank {

    public struct CatalogEntry: Sendable {
        public let word: String
        public let categoryHint: String
        public let stars: Int
        public let points: Int

        public init(word: String, categoryHint: String, stars: Int, points: Int) {
            self.word = word
            self.categoryHint = categoryHint
            self.stars = stars
            self.points = points
        }
    }

    // MARK: - 60 French Words (4–9 letters, Draw Something Tile Ready)

    public static let allWords: [CatalogEntry] = [
        // ⭐ FACILE (1 000 PTS)
        CatalogEntry(word: "SOLEIL", categoryHint: "Météo & Ciel", stars: 1, points: 1000),
        CatalogEntry(word: "MAISON", categoryHint: "Bâtiment", stars: 1, points: 1000),
        CatalogEntry(word: "POISSON", categoryHint: "Animal marin", stars: 1, points: 1000),
        CatalogEntry(word: "PIZZA", categoryHint: "Gastronomie", stars: 1, points: 1000),
        CatalogEntry(word: "FUSEE", categoryHint: "Espace", stars: 1, points: 1000),
        CatalogEntry(word: "SAPIN", categoryHint: "Nature & Forêt", stars: 1, points: 1000),
        CatalogEntry(word: "BALLON", categoryHint: "Sport & Jeux", stars: 1, points: 1000),
        CatalogEntry(word: "LUNETTES", categoryHint: "Accessoire de Meemaw", stars: 1, points: 1000),
        CatalogEntry(word: "COURONNE", categoryHint: "Royauté", stars: 1, points: 1000),
        CatalogEntry(word: "BANANE", categoryHint: "Fruit", stars: 1, points: 1000),
        CatalogEntry(word: "VOITURE", categoryHint: "Transport", stars: 1, points: 1000),
        CatalogEntry(word: "BONHOMME", categoryHint: "Personnage", stars: 1, points: 1000),
        CatalogEntry(word: "FROMAGE", categoryHint: "Cuisine française", stars: 1, points: 1000),
        CatalogEntry(word: "BATEAU", categoryHint: "Mer & Océan", stars: 1, points: 1000),
        CatalogEntry(word: "COEUR", categoryHint: "Symbole", stars: 1, points: 1000),
        CatalogEntry(word: "ECLAIR", categoryHint: "Orage ou Pâtisserie", stars: 1, points: 1000),
        CatalogEntry(word: "POMME", categoryHint: "Fruit", stars: 1, points: 1000),
        CatalogEntry(word: "CADEAU", categoryHint: "Fête & Anniversaire", stars: 1, points: 1000),
        CatalogEntry(word: "NUAGE", categoryHint: "Météo", stars: 1, points: 1000),
        CatalogEntry(word: "GATEAU", categoryHint: "Goûter de Mamie", stars: 1, points: 1000),

        // ⭐⭐ MOYEN (2 000 PTS)
        CatalogEntry(word: "RACLETTE", categoryHint: "Spécialité d'hiver", stars: 2, points: 2000),
        CatalogEntry(word: "GUITARE", categoryHint: "Instrument de musique", stars: 2, points: 2000),
        CatalogEntry(word: "CHAMEAU", categoryHint: "Animal du désert", stars: 2, points: 2000),
        CatalogEntry(word: "FANTOME", categoryHint: "Frisson & Manoir", stars: 2, points: 2000),
        CatalogEntry(word: "REQUIN", categoryHint: "Prédateur marin", stars: 2, points: 2000),
        CatalogEntry(word: "VOLCAN", categoryHint: "Nature explosive", stars: 2, points: 2000),
        CatalogEntry(word: "ROBOT", categoryHint: "Science-fiction", stars: 2, points: 2000),
        CatalogEntry(word: "PIRATE", categoryHint: "Aventure en mer", stars: 2, points: 2000),
        CatalogEntry(word: "TORTUE", categoryHint: "Animal à carapace", stars: 2, points: 2000),
        CatalogEntry(word: "CROISSANT", categoryHint: "Boulangerie", stars: 2, points: 2000),
        CatalogEntry(word: "IGLOO", categoryHint: "Banquise", stars: 2, points: 2000),
        CatalogEntry(word: "CACTUS", categoryHint: "Plante qui pique", stars: 2, points: 2000),
        CatalogEntry(word: "TRACTOR", categoryHint: "Campagne", stars: 2, points: 2000),
        CatalogEntry(word: "PINGOUIN", categoryHint: "Oiseau en smoking", stars: 2, points: 2000),
        CatalogEntry(word: "CHATEAU", categoryHint: "Moyen Âge", stars: 2, points: 2000),
        CatalogEntry(word: "ESCARGOT", categoryHint: "Bête à cornes", stars: 2, points: 2000),
        CatalogEntry(word: "PAPILLON", categoryHint: "Insecte coloré", stars: 2, points: 2000),
        CatalogEntry(word: "DIAMANT", categoryHint: "Trésor précieux", stars: 2, points: 2000),
        CatalogEntry(word: "MEDUSE", categoryHint: "Plage & Piqûre", stars: 2, points: 2000),
        CatalogEntry(word: "SORCIERE", categoryHint: "Balai & Chaudron", stars: 2, points: 2000),

        // ⭐⭐⭐ DIFFICILE (3 000 PTS)
        CatalogEntry(word: "DINOSAURE", categoryHint: "Préhistoire", stars: 3, points: 3000),
        CatalogEntry(word: "LICORNE", categoryHint: "Créature magique", stars: 3, points: 3000),
        CatalogEntry(word: "ASTRONAUTE", categoryHint: "Métier de l'espace", stars: 3, points: 3000),
        CatalogEntry(word: "KANGOUROU", categoryHint: "Animal sauteur", stars: 3, points: 3000),
        CatalogEntry(word: "TORNADE", categoryHint: "Catastrophe météo", stars: 3, points: 3000),
        CatalogEntry(word: "VAMPIRE", categoryHint: "Créature de la nuit", stars: 3, points: 3000),
        CatalogEntry(word: "PARACHUTE", categoryHint: "Chute libre", stars: 3, points: 3000),
        CatalogEntry(word: "CROCODILE", categoryHint: "Grandes dents", stars: 3, points: 3000),
        CatalogEntry(word: "SOUSMARIN", categoryHint: "Exploration abyssale", stars: 3, points: 3000),
        CatalogEntry(word: "CATAPULTE", categoryHint: "Siège médiéval", stars: 3, points: 3000),
        CatalogEntry(word: "MOMIE", categoryHint: "Égypte antique", stars: 3, points: 3000),
        CatalogEntry(word: "PIEUVRE", categoryHint: "Huit tentacules", stars: 3, points: 3000),
        CatalogEntry(word: "CAMEMBERT", categoryHint: "Fierté normande", stars: 3, points: 3000),
        CatalogEntry(word: "ACCORDEON", categoryHint: "Bal musette", stars: 3, points: 3000),
        CatalogEntry(word: "MARACAS", categoryHint: "Musique latine", stars: 3, points: 3000),
        CatalogEntry(word: "TROTTINETTE", categoryHint: "Mobilité urbaine", stars: 3, points: 3000),
        CatalogEntry(word: "DETECTIVE", categoryHint: "Loupe & Imperméable", stars: 3, points: 3000),
        CatalogEntry(word: "FLAMANT", categoryHint: "Oiseau sur une patte", stars: 3, points: 3000),
        CatalogEntry(word: "JONGLEUR", categoryHint: "Cirque & Balles", stars: 3, points: 3000),
        CatalogEntry(word: "HIBOU", categoryHint: "Oiseau nocturne", stars: 3, points: 3000)
    ]

    /// Picks 3 word options (1 star, 2 stars, 3 stars) for the drawer to choose from.
    public static func pickThreeWordOptions(excluding usedWords: Set<String> = []) -> [DrawWordOption] {
        var result: [DrawWordOption] = []
        for starLevel in [1, 2, 3] {
            let candidates = allWords.filter { $0.stars == starLevel && !usedWords.contains($0.word) }
            let pool = candidates.isEmpty ? allWords.filter { $0.stars == starLevel } : candidates
            if let picked = pool.randomElement() {
                result.append(makeWordOption(from: picked))
            }
        }
        return result
    }

    public static func makeWordOption(from entry: CatalogEntry) -> DrawWordOption {
        DrawWordOption(
            word: entry.word,
            categoryHint: entry.categoryHint,
            stars: entry.stars,
            points: entry.points,
            scrambledTiles: scrambledTiles(for: entry.word)
        )
    }

    /// Generates a 12-tile (or up to 14-tile for longer words) Draw Something scrambled letter rack.
    public static func scrambledTiles(for word: String) -> [String] {
        let clean = normalizeWord(word)
        var letters = clean.map { String($0) }
        let targetCount = max(12, letters.count + 3)
        let alphabet = ["A", "E", "I", "O", "U", "R", "S", "T", "L", "N", "M", "C", "P", "B", "D", "F", "G", "V"]
        var seed = clean.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        while letters.count < targetCount {
            seed = (seed &* 1103515245 &+ 12345) & 0x7fffffff
            let extra = alphabet[seed % alphabet.count]
            letters.append(extra)
        }
        // Deterministic Fisher-Yates shuffle based on word + salt so all clients see the exact same rack
        for i in stride(from: letters.count - 1, through: 1, by: -1) {
            seed = (seed &* 1103515245 &+ 12345) & 0x7fffffff
            let j = seed % (i + 1)
            letters.swapAt(i, j)
        }
        return letters
    }

    public static func normalizeWord(_ raw: String) -> String {
        let folded = raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
        let upper = folded.uppercased().filter { $0.isLetter }
        return String(upper)
    }

    /// Builds a masked pattern like `"_ _ _ _ _ _"` or `"R _ _ L _ _ _ _"` with progressive hint reveals.
    public static func maskedPattern(for word: String, revealedIndices: Set<Int> = []) -> String {
        let chars = Array(normalizeWord(word))
        return chars.enumerated().map { idx, ch in
            revealedIndices.contains(idx) ? String(ch) : "_"
        }.joined(separator: " ")
    }

    // MARK: - 30 Simple, Finger-Friendly Visual Prompts for « Esquissé ! » (Easy to draw on a phone with basic shapes & stickmen!)

    public static let esquisseStarterPrompts: [String] = [
        "Un bonhomme de neige sous le soleil",
        "Un serpent avec des lunettes",
        "Un requin sous un petit bateau",
        "Une glace qui fond au soleil",
        "Une pomme avec un petit ver",
        "Un bonhomme sous la pluie sans parapluie",
        "Un ballon qui touche un cactus",
        "Un poisson dans un bocal",
        "Une maison avec de la fumée en forme de cœur",
        "Un œuf au plat dans une poêle",
        "Un bonhomme qui glisse sur une banane",
        "Une araignée au bout de son fil",
        "Un fantôme qui a peur d'une souris",
        "Une fusée qui vole vers la lune",
        "Un chat caché dans un carton",
        "Une fleur géante à côté d'une petite maison",
        "Un escargot avec un drapeau sur le dos",
        "Un bonhomme qui soulève des haltères",
        "Une île déserte avec un seul palmier",
        "Un soleil avec des lunettes noires",
        "Une tasse de café brûlante qui fume",
        "Un bonhomme au sommet d'une montagne",
        "Une bombe avec la mèche allumée",
        "Un cadeau avec un gros ruban",
        "Une part de pizza toute chaude",
        "Un parapluie retourné par le vent",
        "Un bonhomme dans une montgolfière",
        "Un poisson au bout d'une canne à pêche",
        "Une étoile filante au-dessus d'un sapin",
        "Un bonhomme qui fait du ski sur une bosse"
    ]

    public static func randomEsquissePrompt(excluding used: Set<String> = []) -> String {
        let avail = esquisseStarterPrompts.filter { !used.contains($0) }
        return (avail.isEmpty ? esquisseStarterPrompts : avail).randomElement() ?? "Un bonhomme de neige sous le soleil"
    }

    public static func pickThreeEsquissePrompts(excluding used: Set<String> = []) -> [String] {
        let avail = esquisseStarterPrompts.filter { !used.contains($0) }.shuffled()
        if avail.count >= 3 {
            return Array(avail.prefix(3))
        }
        return Array(esquisseStarterPrompts.shuffled().prefix(3))
    }

    /// Generates 3 quick-tap guess suggestions (1 close/funny + 2 neighbor prompts) so players aren't stuck deciphering a finger drawing on phone.
    public static func quickGuessSuggestions(from previousPrompt: String) -> [String] {
        let clean = previousPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let funny = botFunnyMisinterpretation(from: clean)
        var options: [String] = []
        if !clean.isEmpty {
            options.append(clean)
        }
        if !options.contains(funny) {
            options.append(funny)
        }
        for candidate in esquisseStarterPrompts.shuffled() where options.count < 3 {
            if !options.contains(candidate) {
                options.append(candidate)
            }
        }
        return options.shuffled()
    }

    /// Funny bot misinterpretation when a bot plays Step 2 (Guessing from a drawing) in Esquissé!
    public static func botFunnyMisinterpretation(from previousPrompt: String) -> String {
        let lower = previousPrompt.lowercased()
        if lower.contains("neige") || lower.contains("glace") {
            return "Une boule de glace qui fond sur le trottoir"
        } else if lower.contains("serpent") || lower.contains("ver") {
            return "Un spaghetti géant avec des phares de voiture"
        } else if lower.contains("requin") || lower.contains("bateau") || lower.contains("poisson") {
            return "Un sous-marin poursuivi par une sardine"
        } else if lower.contains("pluie") || lower.contains("parapluie") {
            return "Un bonhomme qui prend sa douche tout habillé"
        } else if lower.contains("ballon") || lower.contains("cactus") {
            return "Une sucette plantée dans un cornichon"
        } else if lower.contains("maison") || lower.contains("fumée") {
            return "Une cheminée qui envoie des bisous"
        } else if lower.contains("fusée") || lower.contains("lune") {
            return "Une carotte géante lancée dans l'espace"
        } else if lower.contains("montagne") || lower.contains("ski") {
            return "Un bonhomme qui dévale un toboggan géant"
        } else {
            let fallbacks = [
                "Un bonhomme bâton perdu dans le désert",
                "Un soleil qui bronzait à la plage",
                "Une soucoupe volante au-dessus du jardin",
                "Un chat déguisé en fantôme",
                "Un œuf sur le plat qui fait un sourire"
            ]
            return fallbacks.randomElement()!
        }
    }

    // MARK: - Phone Drawing Assistant: Geometric Shapes, Stickman Stamp & Curve Smoothing

    public enum DrawingToolMode: String, CaseIterable, Identifiable, Sendable {
        case freehand = "freehand"
        case line = "line"
        case circle = "circle"
        case rectangle = "rectangle"
        case triangle = "triangle"
        case stickman = "stickman"
        case arrow = "arrow"

        public var id: String { rawValue }

        public var label: String {
            switch self {
            case .freehand: "✏️ Libre"
            case .line: "📏 Ligne"
            case .circle: "⭕ Rond"
            case .rectangle: "🔲 Boîte"
            case .triangle: "🔺 Triangle"
            case .stickman: "🧍 Bonhomme"
            case .arrow: "➡️ Flèche"
            }
        }
    }

    /// Smooths shaky finger points on a phone screen using 1 pass of Chaikin corner-cutting.
    public static func smoothPoints(_ points: [NormalizedPoint]) -> [NormalizedPoint] {
        guard points.count >= 3 else { return points }
        var result: [NormalizedPoint] = [points[0]]
        for i in 0..<(points.count - 1) {
            let p0 = points[i]
            let p1 = points[i + 1]
            let q = NormalizedPoint(x: 0.75 * p0.x + 0.25 * p1.x, y: 0.75 * p0.y + 0.25 * p1.y)
            let r = NormalizedPoint(x: 0.25 * p0.x + 0.75 * p1.x, y: 0.25 * p0.y + 0.75 * p1.y)
            result.append(q)
            result.append(r)
        }
        result.append(points[points.count - 1])
        return result
    }

    /// Generates clean vector strokes when dragging from `start` to `end` on a phone screen.
    public static func makeShapeStrokes(
        tool: DrawingToolMode,
        start: NormalizedPoint,
        end: NormalizedPoint,
        colorHex: String,
        lineWidth: Double
    ) -> [DrawingStroke] {
        let minX = min(start.x, end.x)
        let maxX = max(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxY = max(start.y, end.y)
        let width = max(0.04, maxX - minX)
        let height = max(0.04, maxY - minY)
        let cx = (minX + maxX) / 2.0
        let cy = (minY + maxY) / 2.0

        switch tool {
        case .freehand:
            return [DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: [start, end])]

        case .line:
            return [DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: [start, end])]

        case .circle:
            let rx = width / 2.0
            let ry = height / 2.0
            let steps = 28
            let pts = (0...steps).map { idx -> NormalizedPoint in
                let angle = Double(idx) / Double(steps) * (.pi * 2.0)
                return NormalizedPoint(
                    x: min(1.0, max(0.0, cx + cos(angle) * rx)),
                    y: min(1.0, max(0.0, cy + sin(angle) * ry))
                )
            }
            return [DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: pts)]

        case .rectangle:
            let pts = [
                NormalizedPoint(x: minX, y: minY),
                NormalizedPoint(x: maxX, y: minY),
                NormalizedPoint(x: maxX, y: maxY),
                NormalizedPoint(x: minX, y: maxY),
                NormalizedPoint(x: minX, y: minY)
            ]
            return [DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: pts)]

        case .triangle:
            let pts = [
                NormalizedPoint(x: cx, y: minY),
                NormalizedPoint(x: maxX, y: maxY),
                NormalizedPoint(x: minX, y: maxY),
                NormalizedPoint(x: cx, y: minY)
            ]
            return [DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: pts)]

        case .stickman:
            let headR = min(width, height) * 0.18
            let headCY = minY + headR
            let neckY = headCY + headR
            let hipY = minY + height * 0.66
            let footY = maxY
            let armY = neckY + (hipY - neckY) * 0.32
            let armSpan = max(width * 0.45, headR * 1.8)
            let legSpan = max(width * 0.38, headR * 1.5)

            let headStroke = circleStroke(cx: cx, cy: headCY, r: headR, color: colorHex, width: lineWidth)
            let spineStroke = DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: [
                NormalizedPoint(x: cx, y: neckY),
                NormalizedPoint(x: cx, y: hipY)
            ])
            let armsStroke = DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: [
                NormalizedPoint(x: max(0.0, cx - armSpan), y: armY),
                NormalizedPoint(x: min(1.0, cx + armSpan), y: armY)
            ])
            let legsStroke = DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: [
                NormalizedPoint(x: max(0.0, cx - legSpan), y: footY),
                NormalizedPoint(x: cx, y: hipY),
                NormalizedPoint(x: min(1.0, cx + legSpan), y: footY)
            ])
            return [headStroke, spineStroke, armsStroke, legsStroke]

        case .arrow:
            let dx = end.x - start.x
            let dy = end.y - start.y
            let angle = atan2(dy, dx)
            let headLen = max(0.05, hypot(dx, dy) * 0.25)
            let p1 = NormalizedPoint(
                x: min(1.0, max(0.0, end.x - headLen * cos(angle - .pi / 6))),
                y: min(1.0, max(0.0, end.y - headLen * sin(angle - .pi / 6)))
            )
            let p2 = NormalizedPoint(
                x: min(1.0, max(0.0, end.x - headLen * cos(angle + .pi / 6))),
                y: min(1.0, max(0.0, end.y - headLen * sin(angle + .pi / 6)))
            )
            return [
                DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: [start, end]),
                DrawingStroke(colorHex: colorHex, lineWidth: lineWidth, points: [p1, end, p2])
            ]
        }
    }

    // MARK: - Pre-Recorded Vector Sketches for Solo ("Pinceau Magique de Meemaw") & Demo Bots

    public static func botSketch(for word: String) -> DrawingCanvasData {
        let clean = normalizeWord(word)
        switch clean {
        case "SOLEIL":
            var strokes: [DrawingStroke] = [
                circleStroke(cx: 0.5, cy: 0.5, r: 0.20, color: "#F59E0B", width: 8)
            ]
            for i in 0..<8 {
                let angle = Double(i) * (.pi / 4.0)
                let p1 = NormalizedPoint(x: 0.5 + cos(angle) * 0.25, y: 0.5 + sin(angle) * 0.25)
                let p2 = NormalizedPoint(x: 0.5 + cos(angle) * 0.38, y: 0.5 + sin(angle) * 0.38)
                strokes.append(DrawingStroke(colorHex: "#FF8C42", lineWidth: 6, points: [p1, p2]))
            }
            return DrawingCanvasData(strokes: strokes)

        case "MAISON":
            return DrawingCanvasData(strokes: [
                // Walls
                DrawingStroke(colorHex: "#2563EB", lineWidth: 7, points: [
                    NormalizedPoint(x: 0.25, y: 0.48),
                    NormalizedPoint(x: 0.25, y: 0.82),
                    NormalizedPoint(x: 0.75, y: 0.82),
                    NormalizedPoint(x: 0.75, y: 0.48),
                    NormalizedPoint(x: 0.25, y: 0.48)
                ]),
                // Roof
                DrawingStroke(colorHex: "#E11D48", lineWidth: 8, points: [
                    NormalizedPoint(x: 0.18, y: 0.48),
                    NormalizedPoint(x: 0.50, y: 0.18),
                    NormalizedPoint(x: 0.82, y: 0.48)
                ]),
                // Door
                DrawingStroke(colorHex: "#FF8C42", lineWidth: 6, points: [
                    NormalizedPoint(x: 0.44, y: 0.82),
                    NormalizedPoint(x: 0.44, y: 0.62),
                    NormalizedPoint(x: 0.56, y: 0.62),
                    NormalizedPoint(x: 0.56, y: 0.82)
                ])
            ])

        case "POISSON", "REQUIN":
            return DrawingCanvasData(strokes: [
                // Body oval + tail
                DrawingStroke(colorHex: "#00ACC1", lineWidth: 7, points: [
                    NormalizedPoint(x: 0.20, y: 0.50),
                    NormalizedPoint(x: 0.38, y: 0.32),
                    NormalizedPoint(x: 0.62, y: 0.36),
                    NormalizedPoint(x: 0.82, y: 0.64),
                    NormalizedPoint(x: 0.82, y: 0.36),
                    NormalizedPoint(x: 0.62, y: 0.64),
                    NormalizedPoint(x: 0.38, y: 0.68),
                    NormalizedPoint(x: 0.20, y: 0.50)
                ]),
                // Eye
                circleStroke(cx: 0.32, cy: 0.46, r: 0.03, color: "#111827", width: 6),
                // Dorsal fin
                DrawingStroke(colorHex: "#2563EB", lineWidth: 6, points: [
                    NormalizedPoint(x: 0.44, y: 0.33),
                    NormalizedPoint(x: 0.52, y: 0.18),
                    NormalizedPoint(x: 0.58, y: 0.35)
                ])
            ])

        case "FUSEE":
            return DrawingCanvasData(strokes: [
                // Rocket body
                DrawingStroke(colorHex: "#E11D48", lineWidth: 7, points: [
                    NormalizedPoint(x: 0.50, y: 0.14),
                    NormalizedPoint(x: 0.64, y: 0.36),
                    NormalizedPoint(x: 0.64, y: 0.70),
                    NormalizedPoint(x: 0.36, y: 0.70),
                    NormalizedPoint(x: 0.36, y: 0.36),
                    NormalizedPoint(x: 0.50, y: 0.14)
                ]),
                // Window
                circleStroke(cx: 0.50, cy: 0.45, r: 0.07, color: "#00ACC1", width: 6),
                // Fins & Flame
                DrawingStroke(colorHex: "#FF8C42", lineWidth: 7, points: [
                    NormalizedPoint(x: 0.36, y: 0.62),
                    NormalizedPoint(x: 0.24, y: 0.78),
                    NormalizedPoint(x: 0.36, y: 0.70)
                ]),
                DrawingStroke(colorHex: "#FF8C42", lineWidth: 7, points: [
                    NormalizedPoint(x: 0.64, y: 0.62),
                    NormalizedPoint(x: 0.76, y: 0.78),
                    NormalizedPoint(x: 0.64, y: 0.70)
                ]),
                DrawingStroke(colorHex: "#F59E0B", lineWidth: 8, points: [
                    NormalizedPoint(x: 0.42, y: 0.72),
                    NormalizedPoint(x: 0.50, y: 0.90),
                    NormalizedPoint(x: 0.58, y: 0.72)
                ])
            ])

        case "SAPIN":
            return DrawingCanvasData(strokes: [
                DrawingStroke(colorHex: "#10B981", lineWidth: 8, points: [
                    NormalizedPoint(x: 0.50, y: 0.15),
                    NormalizedPoint(x: 0.28, y: 0.42),
                    NormalizedPoint(x: 0.42, y: 0.42),
                    NormalizedPoint(x: 0.22, y: 0.68),
                    NormalizedPoint(x: 0.78, y: 0.68),
                    NormalizedPoint(x: 0.58, y: 0.42),
                    NormalizedPoint(x: 0.72, y: 0.42),
                    NormalizedPoint(x: 0.50, y: 0.15)
                ]),
                DrawingStroke(colorHex: "#FF8C42", lineWidth: 8, points: [
                    NormalizedPoint(x: 0.45, y: 0.68),
                    NormalizedPoint(x: 0.45, y: 0.86),
                    NormalizedPoint(x: 0.55, y: 0.86),
                    NormalizedPoint(x: 0.55, y: 0.68)
                ])
            ])

        case "LUNETTES":
            return DrawingCanvasData(strokes: [
                circleStroke(cx: 0.32, cy: 0.52, r: 0.14, color: "#8E44AD", width: 7),
                circleStroke(cx: 0.68, cy: 0.52, r: 0.14, color: "#8E44AD", width: 7),
                DrawingStroke(colorHex: "#8E44AD", lineWidth: 7, points: [
                    NormalizedPoint(x: 0.46, y: 0.50),
                    NormalizedPoint(x: 0.54, y: 0.50)
                ]),
                DrawingStroke(colorHex: "#8E44AD", lineWidth: 6, points: [
                    NormalizedPoint(x: 0.18, y: 0.50),
                    NormalizedPoint(x: 0.10, y: 0.40)
                ]),
                DrawingStroke(colorHex: "#8E44AD", lineWidth: 6, points: [
                    NormalizedPoint(x: 0.82, y: 0.50),
                    NormalizedPoint(x: 0.90, y: 0.40)
                ])
            ])

        case "COURONNE":
            return DrawingCanvasData(strokes: [
                DrawingStroke(colorHex: "#F59E0B", lineWidth: 8, points: [
                    NormalizedPoint(x: 0.20, y: 0.72),
                    NormalizedPoint(x: 0.20, y: 0.32),
                    NormalizedPoint(x: 0.36, y: 0.52),
                    NormalizedPoint(x: 0.50, y: 0.24),
                    NormalizedPoint(x: 0.64, y: 0.52),
                    NormalizedPoint(x: 0.80, y: 0.32),
                    NormalizedPoint(x: 0.80, y: 0.72),
                    NormalizedPoint(x: 0.20, y: 0.72)
                ]),
                circleStroke(cx: 0.50, cy: 0.20, r: 0.03, color: "#E11D48", width: 6)
            ])

        default:
            // Playful universal doodle (smiling character + star/arrows)
            return DrawingCanvasData(strokes: [
                circleStroke(cx: 0.50, cy: 0.42, r: 0.20, color: "#FF8C42", width: 7),
                circleStroke(cx: 0.43, cy: 0.37, r: 0.025, color: "#111827", width: 6),
                circleStroke(cx: 0.57, cy: 0.37, r: 0.025, color: "#111827", width: 6),
                DrawingStroke(colorHex: "#E11D48", lineWidth: 6, points: [
                    NormalizedPoint(x: 0.41, y: 0.47),
                    NormalizedPoint(x: 0.50, y: 0.54),
                    NormalizedPoint(x: 0.59, y: 0.47)
                ]),
                DrawingStroke(colorHex: "#2563EB", lineWidth: 7, points: [
                    NormalizedPoint(x: 0.50, y: 0.62),
                    NormalizedPoint(x: 0.50, y: 0.84),
                    NormalizedPoint(x: 0.36, y: 0.92),
                    NormalizedPoint(x: 0.50, y: 0.84),
                    NormalizedPoint(x: 0.64, y: 0.92)
                ]),
                DrawingStroke(colorHex: "#10B981", lineWidth: 6, points: [
                    NormalizedPoint(x: 0.32, y: 0.70),
                    NormalizedPoint(x: 0.68, y: 0.70)
                ])
            ])
        }
    }

    private static func circleStroke(cx: Double, cy: Double, r: Double, color: String, width: Double) -> DrawingStroke {
        let steps = 20
        var pts: [NormalizedPoint] = []
        for i in 0...steps {
            let a = (Double(i) / Double(steps)) * 2.0 * .pi
            pts.append(NormalizedPoint(x: cx + cos(a) * r, y: cy + sin(a) * r))
        }
        return DrawingStroke(colorHex: color, lineWidth: width, points: pts)
    }
}
