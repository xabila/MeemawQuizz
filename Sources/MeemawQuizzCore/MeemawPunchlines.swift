import Foundation

public struct MeemawStudioCue: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var text: String
    public var filename: String

    public init(id: String, text: String, filename: String) {
        self.id = id
        self.text = text
        self.filename = filename
    }
}

public enum MeemawPunchlines {

    /// Cues studio pré-générées en `.m4a` avec la voix Audrey Premium de Meemaw.
    public static let studioCues: [MeemawStudioCue] = [
        MeemawStudioCue(
            id: "intro_welcome",
            text: "Bienvenue dans le Grand Quizz de Meemaw ! Connectez vos téléphones, choisissez votre couleur, et préparez vos neurones mes petits choux !",
            filename: "mq_intro_welcome.m4a"
        ),
        MeemawStudioCue(
            id: "round1_cash",
            text: "Première manche : Cash Rapide ! Tout le monde répond sur son téléphone, mais c'est le plus rapide qui rafle la grosse galette !",
            filename: "mq_round1_cash.m4a"
        ),
        MeemawStudioCue(
            id: "round2_solo",
            text: "Attention les secousses, c'est l'heure du SOLO ! Le premier qui écrase le buzzer rouge bloque tous les autres et joue pour le double du pactole !",
            filename: "mq_round2_solo.m4a"
        ),
        MeemawStudioCue(
            id: "round3_couci",
            text: "Troisième manche : Le Couci-Couça de Meemaw ! Six affirmations à toute allure, tapez à gauche ou à droite sans renverser votre tisane !",
            filename: "mq_round3_couci.m4a"
        ),
        MeemawStudioCue(
            id: "round4_finale",
            text: "Dernière manche : La Rafale Finale ! Tous les points sont doublés, même les derniers peuvent encore coiffer tout le monde au poteau !",
            filename: "mq_round4_finale.m4a"
        ),
        MeemawStudioCue(
            id: "podium_outro",
            text: "Et voilà le travail ! Regardons qui repart avec la couronne de Meemaw et qui va faire la vaisselle ce soir !",
            filename: "mq_podium_outro.m4a"
        ),
        MeemawStudioCue(
            id: "bisou_attack",
            text: "Oh le coup bas ! Quelqu'un vient d'envoyer un gros bisou baveux de Meemaw sur l'écran d'un adversaire !",
            filename: "mq_bisou_attack.m4a"
        ),
        MeemawStudioCue(
            id: "react_all_correct",
            text: "Alors là chapeau ! Tout le salon a trouvé la bonne réponse, vous avez mangé du lion ce matin !",
            filename: "mq_react_all_correct.m4a"
        ),
        MeemawStudioCue(
            id: "react_nobody_correct",
            text: "Eh bien mes petits agneaux, c'est la Bérézina ! Pas un seul pour rattraper l'autre sur cette question !",
            filename: "mq_react_nobody_correct.m4a"
        ),
        MeemawStudioCue(
            id: "solo_success",
            text: "Boum ! Le Solo passe comme une lettre à la poste ! Double ration de points !",
            filename: "mq_solo_success.m4a"
        ),
        MeemawStudioCue(
            id: "solo_fail",
            text: "Aïe aïe aïe, la glissade en plein Solo ! Ça fait cher la fanfaronnade mon petit chou !",
            filename: "mq_solo_fail.m4a"
        )
    ]

    /// Réplique dynamique personnalisée avec le vrai pseudo du joueur (lue sur la TV par la voix féminine Audrey).
    public static func dynamicFastestPraise(playerName: String, delta: Int, reactionMs: Int) -> String {
        let sec = String(format: "%.1f", Double(reactionMs) / 1000.0)
        let templates = [
            "Bravo \(playerName) ! Dégainé en \(sec) secondes pour \(delta) points, même ma 2 CV démarre moins vite !",
            "Joli coup \(playerName) ! \(delta) points dans la poche en \(sec) secondes chrono !",
            "Chapeau \(playerName), tu as mis tout le salon d'accord en \(sec) secondes !"
        ]
        let idx = abs(playerName.hashValue) % templates.count
        return templates[idx]
    }

    public static func dynamicSoloBuzzCallout(playerName: String) -> String {
        "Stoppez les rotatives ! \(playerName) prend LE SOLO ! Voyons si ça passe ou si ça casse !"
    }

    public static func dynamicSoloResult(playerName: String, isCorrect: Bool, delta: Int) -> String {
        if isCorrect {
            return "Magnifique \(playerName) ! Le Solo est validé, plus \(delta) points dans l'escarcelle !"
        } else {
            return "Oh la boulette \(playerName) ! Tu as voulu faire le malin en Solo et tu perds \(abs(delta)) points !"
        }
    }

    public static func dynamicWrongRoast(playerName: String, roast: String) -> String {
        "\(playerName), écoute bien Mamie : \(roast)"
    }
}
