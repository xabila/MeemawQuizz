import Foundation

public enum QuizScoringEngine {

    /// Calcule les points d'une réponse en manche Cash Rapide ou Rafale Finale (×2).
    /// - Le 1er joueur qui trouve la bonne réponse prend 100 % de la valeur + bonus d'éclair (jusqu'à +800 pts).
    /// - Les joueurs suivants qui trouvent la bonne réponse prennent une part dégressive (80 %, 65 %, 50 %...) + bonus vitesse.
    /// - Une mauvaise réponse retire 50 % de la valeur de base.
    public static func scoreCashAnswer(
        baseValue: Int,
        isCorrect: Bool,
        correctRankIndex: Int?,
        reactionTimeMs: Int,
        totalTimeMs: Int,
        isDoubleFinale: Bool
    ) -> Int {
        let multiplier = isDoubleFinale ? 2 : 1
        let effectiveBase = baseValue * multiplier

        guard isCorrect else {
            return -(effectiveBase / 2)
        }

        let rank = max(0, correctRankIndex ?? 0)
        let rankFactor: Double
        switch rank {
        case 0: rankFactor = 1.00
        case 1: rankFactor = 0.80
        case 2: rankFactor = 0.65
        default: rankFactor = 0.50
        }

        let clampedReaction = max(0, min(totalTimeMs, reactionTimeMs))
        let speedRatio = max(0.0, 1.0 - (Double(clampedReaction) / Double(max(1, totalTimeMs))))
        let maxSpeedBonus = Double(800 * multiplier)
        let speedBonus = Int((speedRatio * maxSpeedBonus / 50.0).rounded()) * 50

        let rankBase = Int((Double(effectiveBase) * rankFactor / 50.0).rounded()) * 50
        return rankBase + speedBonus
    }

    /// Renvoie le gain et la perte pour 1 à 4 étoiles dans la manche « Tu Te Mets Combien ? »
    public static func ttmcStakes(for stars: Int) -> (win: Int, loss: Int) {
        switch stars {
        case 1: return (1000, -250)
        case 2: return (2000, -500)
        case 3: return (3500, -1000)
        case 4: return (5000, -2500)
        default: return (2000, -500)
        }
    }

    /// Calcule les points de la manche « Tu Te Mets Combien ? » (de 1 à 4 étoiles) :
    /// - 1 ⭐ : +1 000 / -250
    /// - 2 ⭐⭐ : +2 000 / -500
    /// - 3 ⭐⭐⭐ : +3 500 / -1 000
    /// - 4 ⭐⭐⭐⭐ (Le Melon) : +5 000 / -2 500
    /// +300 pts de bonus éclair pour le plus rapide qui a bon !
    public static func scoreTTMCAnswer(
        stars: Int,
        isCorrect: Bool,
        isFastest: Bool
    ) -> Int {
        let stakes = ttmcStakes(for: stars)
        if isCorrect {
            return stakes.win + (isFastest ? 300 : 0)
        } else {
            return stakes.loss
        }
    }

    /// Calcule les points d'une manche « LE SOLO » (style YDKJ Buzzer) :
    /// - Bonne réponse : Double Jackpot (×2)
    /// - Mauvaise réponse ou temps écoulé : Perte sèche (-1×)
    public static func scoreSoloAnswer(
        baseValue: Int,
        isCorrect: Bool
    ) -> Int {
        if isCorrect {
            return baseValue * 2
        } else {
            return -baseValue
        }
    }

    /// Calcule les points d'un item binaire « Couci-Couça » (DisOrDat) :
    /// - Bonne réponse : +valuePerItem (+200 de bonus de série à partir de 3 bonnes réponses d'affilée)
    /// - Mauvaise réponse : -(valuePerItem / 2)
    public static func scoreDisOrDatAnswer(
        valuePerItem: Int,
        isCorrect: Bool,
        currentStreak: Int
    ) -> Int {
        guard isCorrect else {
            return -(valuePerItem / 2)
        }
        let streakBonus = currentStreak >= 3 ? 200 : 0
        return valuePerItem + streakBonus
    }

    /// Coût en points d'un indice (1 lettre révélée + thème) demandé par un joueur dans « Draw Something ».
    public static let drawHintPenaltyPoints: Int = 300

    /// Calcule les points d'un joueur qui devine le mot dans « Draw Something » :
    /// - 1er à trouver : 100 % des points du mot + bonus vitesse (jusqu'à +600 pts)
    /// - 2e à trouver : 80 % des points + bonus vitesse
    /// - Suivants : 65 % des points + bonus vitesse
    /// - Chaque indice demandé retire `drawHintPenaltyPoints` (300 pts).
    public static func scoreDrawGuesser(
        wordPoints: Int,
        rankIndex: Int,
        reactionTimeMs: Int,
        totalTimeMs: Int = 45000,
        hintsUsed: Int = 0
    ) -> Int {
        let factor: Double
        switch rankIndex {
        case 0: factor = 1.00
        case 1: factor = 0.80
        default: factor = 0.65
        }
        let clamped = max(0, min(totalTimeMs, reactionTimeMs))
        let speedRatio = max(0.0, 1.0 - (Double(clamped) / Double(max(1, totalTimeMs))))
        let speedBonus = Int((speedRatio * 600.0 / 50.0).rounded()) * 50
        let base = Int((Double(wordPoints) * factor / 50.0).rounded()) * 50
        let penalty = max(0, hintsUsed) * drawHintPenaltyPoints
        return base + speedBonus - penalty
    }

    /// Calcule le bonus du dessinateur dans « Draw Something » :
    /// +1 000 pts dès le 1er joueur qui trouve + 500 pts par joueur supplémentaire !
    public static func scoreDrawArtist(
        wordPoints: Int,
        foundCount: Int
    ) -> Int {
        guard foundCount > 0 else { return 0 }
        return (wordPoints / 2) + (foundCount * 500)
    }

    /// Jackpot attribué à un joueur qui repère et sélectionne la « Réponse Sponsorisée de Mamie » (façon YDKJ Wrong Answer of the Game).
    public static let sponsorJackpotPoints: Int = 3500

    /// Calcule les points pour tous les joueurs ayant soumis une estimation dans « Le Juste Pif » :
    /// - Tout Pile Exact (`abs(estimate - correctValue) == 0`) : +5 000 pts
    /// - 1er plus proche : +3 000 pts
    /// - 2e plus proche (si >= 2 joueurs) : +1 500 pts
    /// - Le plus loin (« Le Pif Cassé », si >= 2 joueurs et pas ex-aequo avec le 1er) : -500 pts
    public static func scoreJustePifEstimates(
        correctValue: Int,
        estimatesByPlayerID: [String: Int]
    ) -> [String: Int] {
        guard !estimatesByPlayerID.isEmpty else { return [:] }

        let distances: [(playerID: String, dist: Int)] = estimatesByPlayerID.map { (id, val) in
            (playerID: id, dist: abs(val - correctValue))
        }.sorted { $0.dist < $1.dist }

        let minDist = distances.first!.dist
        let maxDist = distances.last!.dist
        let uniqueSortedDists = Array(Set(distances.map(\.dist))).sorted()
        let secondDist: Int? = uniqueSortedDists.count >= 2 ? uniqueSortedDists[1] : nil

        var deltas: [String: Int] = [:]
        for item in distances {
            if item.dist == 0 {
                deltas[item.playerID] = 5000
            } else if item.dist == minDist {
                deltas[item.playerID] = 3000
            } else if distances.count >= 2 && item.dist == maxDist && maxDist > minDist {
                deltas[item.playerID] = -500
            } else if let sec = secondDist, item.dist == sec {
                deltas[item.playerID] = 1500
            } else {
                deltas[item.playerID] = 500
            }
        }
        return deltas
    }

    /// Calcule les points d'un coup de buzzer dans la Finale « Le Jack Attack de Meemaw » :
    /// - Bonne association affichée : +3 000 pts
    /// - Leurre (piège) : -1 500 pts
    public static func scoreJackAttackBuzz(isCorrect: Bool) -> Int {
        isCorrect ? 3000 : -1500
    }

    /// Génère le Podium Final avec des titres humoristiques décernés par Meemaw.
    public static func buildPodiumAwards(from players: [QuizPlayer]) -> [PodiumAward] {
        let sorted = players.sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            return $0.correctAnswersCount > $1.correctAnswersCount
        }

        return sorted.enumerated().map { idx, player in
            let rank = idx + 1
            let avgMs: Int = player.correctAnswersCount > 0
                ? (player.totalReactionMsSum / player.correctAnswersCount)
                : 9999

            let title: String
            if rank == 1 {
                title = "👑 Le Chouchou Officiel de Meemaw"
            } else if player.soloWinsCount >= 1 {
                title = "🚨 Le Kamikaze du Buzzer SOLO"
            } else if avgMs < 3200 && player.correctAnswersCount >= 2 {
                title = "⚡ La Gâchette la plus Rapide du Salon"
            } else if rank == sorted.count && sorted.count > 1 {
                title = "🐢 La Tortue Rhumatisante du Dimanche"
            } else {
                title = "🍪 Amateur Éclairé de Petits Beurres"
            }

            let subtitle = "\(player.correctAnswersCount) bonnes réponses • Moy. \(String(format: "%.1f", Double(avgMs) / 1000.0))s"
            return PodiumAward(
                playerID: player.id,
                playerName: player.name,
                playerColor: player.color,
                avatarEmoji: player.avatarEmoji,
                rank: rank,
                score: player.score,
                funnyTitle: title,
                subtitle: subtitle
            )
        }
    }
}
