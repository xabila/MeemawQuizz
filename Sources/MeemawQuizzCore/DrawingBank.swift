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

    // MARK: - 30 Hilarious Starter Prompts for « Esquissé ! » (Téléphone Arabe Dessiné)

    public static let esquisseStarterPrompts: [String] = [
        "Un tyrannosaure qui passe l'aspirateur",
        "Dark Vador qui mange une raclette",
        "Un chat qui conduit un tracteur",
        "Meemaw qui fait du surf sur un requin",
        "Un pingouin qui bronze sous un palmier",
        "Un extraterrestre aux toilettes",
        "Un chien qui joue de la guitare électrique",
        "Un pirate qui a peur d'une petite souris",
        "Une licorne qui fait de la musculation",
        "Un fantôme coincé dans une machine à laver",
        "Un robot qui fait des crêpes en les lançant au plafond",
        "Une tortue avec un réacteur de fusée sur le dos",
        "Un kangourou sur un match de boxe",
        "Une vache qui saute en parachute",
        "Un vampire chez le dentiste",
        "Un bonhomme de neige au sauna",
        "Un poulpe qui joue de la batterie",
        "Un escargot poursuivi par la police",
        "Une poule qui pond un diamant géant",
        "Napoléon sur une trottinette électrique"
    ]

    public static func randomEsquissePrompt(excluding used: Set<String> = []) -> String {
        let avail = esquisseStarterPrompts.filter { !used.contains($0) }
        return (avail.isEmpty ? esquisseStarterPrompts : avail).randomElement() ?? "Un chat qui fait du vélo"
    }

    /// Funny bot misinterpretation when a bot plays Step 2 (Guessing from a drawing) in Esquissé!
    public static func botFunnyMisinterpretation(from previousPrompt: String) -> String {
        let lower = previousPrompt.lowercased()
        if lower.contains("tyrannosaure") || lower.contains("dino") {
            return "Un gros lézard vert qui promène son chien"
        } else if lower.contains("vador") || lower.contains("raclette") {
            return "Un pompier avec un casque noir qui fait fondre du fromage"
        } else if lower.contains("requin") || lower.contains("surf") {
            return "Mamie debout sur une grosse sardine dans les vagues"
        } else if lower.contains("tracteur") || lower.contains("chat") {
            return "Un lapin à moustaches dans une grosse tondeuse"
        } else if lower.contains("licorne") {
            return "Un cheval avec un cornet de glace planté sur le front"
        } else if lower.contains("fusée") || lower.contains("tortue") {
            return "Un escargot qui a mis le feu à sa coquille"
        } else if lower.contains("parachute") || lower.contains("vache") {
            return "Un chien à taches accroché sous un grand parapluie"
        }
        let fallbacks = [
            "Une patate avec des lunettes qui danse la macarena",
            "Un canard géant qui attaque une boulangerie",
            "Tonton Gérard qui essaie de monter un meuble suédois",
            "Un poulpe en rollers qui jongle avec des pizzas",
            "Un pigeon musclé qui soulève des haltères"
        ]
        return fallbacks.randomElement()!
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
