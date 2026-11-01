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
            text: "Manche 1 : Cash Rapide ! Tout le monde répond sur son téléphone, et vous avez une vis Clouer le Bec pour piéger un adversaire !",
            filename: "mq_round1_cash.m4a"
        ),
        MeemawStudioCue(
            id: "round_ttmc",
            text: "Manche 2 : Tu Te Mets Combien ? Avant de voir la question, misez de une à quatre étoiles sur le sujet annoncé par Meemaw : quatre étoiles, c'est cinq mille points ou la gamelle !",
            filename: "mq_round_ttmc.m4a"
        ),
        MeemawStudioCue(
            id: "round_jukebox",
            text: "Manche 3 : Le Jukebox Express de Meemaw ! Complétez les paroles exactes au moment où la musique coupe !",
            filename: "mq_round_jukebox.m4a"
        ),
        MeemawStudioCue(
            id: "round2_solo",
            text: "Manche 4 : C'est l'heure du Solo ! Pas besoin de buzzer avant : le tout premier qui touche une réponse coupe l'herbe sous le pied des autres ! S'il a bon il double la mise, s'il se trompe c'est la gamelle !",
            filename: "mq_round2_solo_fast.m4a"
        ),
        MeemawStudioCue(
            id: "round3_couci",
            text: "Manche 5 : La Raclette Quizz de Meemaw ! Faites chauffer les poêlons : c'est l'option A, l'option B, ou carrément les deux ?",
            filename: "mq_round3_raclette.m4a"
        ),
        MeemawStudioCue(
            id: "round4_quoizzi",
            text: "Le Quoizzi-Quoissa spécial Jeux de Mots ! Attention les neurones, les calembours de Meemaw volent bas ce soir !",
            filename: "mq_round4_quoizzi.m4a"
        ),
        MeemawStudioCue(
            id: "round4_finale",
            text: "Dernière manche : La Rafale Finale ! Tous les points sont doublés, même les derniers peuvent encore coiffer tout le monde au poteau !",
            filename: "mq_round4_finale.m4a"
        ),
        MeemawStudioCue(
            id: "podium_outro",
            text: "Et voilà le travail ! Félicitations au grand vainqueur du soir ! Regardons qui repart avec la couronne de Meemaw et qui va faire la vaisselle !",
            filename: "mq_podium_outro.m4a"
        ),
        MeemawStudioCue(
            id: "bisou_attack",
            text: "Oh le coup bas ! Quelqu'un vient d'envoyer un gros bisou baveux de Meemaw sur l'écran d'un adversaire !",
            filename: "mq_bisou_attack.m4a"
        ),
        MeemawStudioCue(
            id: "screw_attack",
            text: "Coup de Jarnac ! Tu viens de te faire clouer le bec ! Tu es tout seul face à Meemaw : douze secondes pour répondre, ou tu perds les points !",
            filename: "mq_screw_attack.m4a"
        ),
        MeemawStudioCue(
            id: "screw_backfire",
            text: "Retour de manivelle ! La victime connaissait la réponse et empoche le double des points ! Bien fait pour le saboteur !",
            filename: "mq_screw_backfire.m4a"
        ),
        MeemawStudioCue(
            id: "screw_success",
            text: "Bec cloué ! La victime s'est plantée en beauté ! Quel coup de Jarnac magnifique !",
            filename: "mq_screw_success.m4a"
        ),
        MeemawStudioCue(
            id: "solo_buzz",
            text: "Stoppez les rotatives ! Quelqu'un a dégainé en premier sur le Solo ! Voyons si c'est du génie ou du grand n'importe quoi !",
            filename: "mq_solo_buzz.m4a"
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
            "Joli coup \(playerName) ! \(delta) points dans la poche en \(sec) secondes, les autres sont encore en train de chercher leurs lunettes !",
            "Chapeau \(playerName), tu as mis tout le salon d'accord en \(sec) secondes chrono !",
            "Hop là ! \(playerName) rafle \(delta) points en \(sec) secondes pendant que le reste du canapé dort debout !",
            "Quel réflexe \(playerName) ! \(sec) secondes et \(delta) points, tu as mangé du fromage à raclette dopé ce midi ?",
            "Boum ! \(playerName) plie l'affaire en \(sec) secondes et empoche \(delta) points sous le nez de tout le monde !"
        ]
        let idx = abs(playerName.hashValue &+ reactionMs) % templates.count
        return templates[idx]
    }

    public static func dynamicSoloBuzzCallout(playerName: String) -> String {
        "Stoppez les rotatives ! \(playerName) a dégainé en premier sur LE SOLO ! Voyons si c'est du génie ou du grand n'importe quoi !"
    }

    public static func dynamicSoloResult(playerName: String, isCorrect: Bool, delta: Int) -> String {
        if isCorrect {
            let wins = [
                "Magnifique \(playerName) ! Tu as coupé l'herbe sous le pied de tout le salon et tu prends \(delta) points d'un coup !",
                "Hold-up parfait de \(playerName) en Solo ! Plus \(delta) points dans la tirelire, les autres peuvent pleurer !",
                "Quel culot \(playerName) ! Premier à dégainer, bonne réponse, et bim : \(delta) points dans la poche !"
            ]
            return wins[abs(playerName.hashValue &+ delta) % wins.count]
        } else {
            let fails = [
                "Oh la boulette \(playerName) ! Tu as voulu dégainer plus vite que ton ombre et tu perds \(abs(delta)) points !",
                "Patatras \(playerName) ! À vouloir répondre avant tout le monde sans réfléchir, c'est moins \(abs(delta)) points dans les gencives !",
                "Aïe aïe aïe \(playerName) ! Le Solo de la honte : tout le monde te regarde perdre \(abs(delta)) points en direct !"
            ]
            return fails[abs(playerName.hashValue &+ delta) % fails.count]
        }
    }

    public static func dynamicWrongRoast(playerName: String, roast: String) -> String {
        "\(playerName), écoute bien Mamie : \(roast)"
    }
}
