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
