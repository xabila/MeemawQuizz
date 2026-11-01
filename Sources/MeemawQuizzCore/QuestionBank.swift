import Foundation

public struct ShowGameDeck: Sendable {
    public var cashQuestions: [QuizMCQQuestion]
    public var ttmcQuestions: [QuizMCQQuestion]
    public var jukeboxQuestions: [QuizMCQQuestion]
    public var soloQuestions: [QuizMCQQuestion]
    public var couciCoucaRound: QuizDisOrDatRound
    public var quoizziPunRound: QuizDisOrDatRound
    public var finaleDoubleQuestions: [QuizMCQQuestion]

    public init(
        cashQuestions: [QuizMCQQuestion],
        ttmcQuestions: [QuizMCQQuestion] = [],
        jukeboxQuestions: [QuizMCQQuestion] = [],
        soloQuestions: [QuizMCQQuestion],
        couciCoucaRound: QuizDisOrDatRound,
        quoizziPunRound: QuizDisOrDatRound? = nil,
        finaleDoubleQuestions: [QuizMCQQuestion]
    ) {
        self.cashQuestions = cashQuestions
        self.ttmcQuestions = ttmcQuestions
        self.jukeboxQuestions = jukeboxQuestions
        self.soloQuestions = soloQuestions
        self.couciCoucaRound = couciCoucaRound
        self.quoizziPunRound = quoizziPunRound ?? couciCoucaRound
        self.finaleDoubleQuestions = finaleDoubleQuestions
    }

    public var allMCQIDs: [String] {
        (cashQuestions + soloQuestions + finaleDoubleQuestions).map(\.id)
    }

    public var allExtendedMCQIDs: [String] {
        (cashQuestions + ttmcQuestions + jukeboxQuestions + soloQuestions + finaleDoubleQuestions).map(\.id)
    }
}

public enum QuestionBank {

    public static func questions(for pack: QuizThemePack) -> [QuizMCQQuestion] {
        switch pack {
        case .francaisMeemaw:
            return francaisQuestions
        case .mathMeemaw:
            return mathQuestions
        case .seriesCinema:
            return seriesCinemaQuestions
        case .musiqueTubes:
            return musiqueQuestions
        case .cultureGInsolite:
            return cultureGQuestions
        case .ecoCash:
            return ecoCashQuestions
        case .grandMix:
            return francaisQuestions + mathQuestions + seriesCinemaQuestions + musiqueQuestions + cultureGQuestions + ecoCashQuestions
        }
    }

    public static func disOrDatRounds(for pack: QuizThemePack) -> [QuizDisOrDatRound] {
        let nonPun = allDisOrDatRounds.filter { !$0.isPunRound }
        switch pack {
        case .francaisMeemaw:
            return nonPun.filter { $0.theme == .francaisMeemaw }
        case .mathMeemaw:
            return nonPun.filter { $0.theme == .mathMeemaw }
        case .seriesCinema:
            return nonPun.filter { $0.theme == .seriesCinema }
        case .musiqueTubes:
            return nonPun.filter { $0.theme == .musiqueTubes }
        case .cultureGInsolite:
            return nonPun.filter { $0.theme == .cultureGInsolite }
        case .ecoCash:
            return nonPun.filter { $0.theme == .ecoCash }
        case .grandMix:
            return nonPun
        }
    }

    public static var allPunRounds: [QuizDisOrDatRound] {
        allDisOrDatRounds.filter(\.isPunRound)
    }

    public static func buildShowDeck(
        for pack: QuizThemePack,
        excludingQuestionIDs: Set<String> = [],
        excludingDisOrDatIDs: Set<String> = []
    ) -> ShowGameDeck {
        let baseQuestions = questions(for: pack)
        var freshPool = baseQuestions.filter { !excludingQuestionIDs.contains($0.id) }.shuffled()

        if freshPool.count < 9 {
            let grandMixUnseen = questions(for: .grandMix)
                .filter { !excludingQuestionIDs.contains($0.id) && !freshPool.map(\.id).contains($0.id) }
                .shuffled()
            freshPool.append(contentsOf: grandMixUnseen)
        }
        if freshPool.count < 9 {
            freshPool = baseQuestions.shuffled()
        }

        let cash = Array(freshPool.prefix(3))
        let solo = Array(freshPool.dropFirst(3).prefix(2))
        let finale = Array(freshPool.dropFirst(5).prefix(2))
        let ttmc = Array(freshPool.dropFirst(7).prefix(2))
        let pickedIDs = Set((cash + solo + finale + ttmc).map(\.id))

        let jukeboxPool = musiqueQuestions
            .filter { $0.id.hasPrefix("JUK_") && !excludingQuestionIDs.contains($0.id) && !pickedIDs.contains($0.id) }
            .shuffled()
        let fallbackMusicPool = musiqueQuestions
            .filter { !excludingQuestionIDs.contains($0.id) && !pickedIDs.contains($0.id) }
            .shuffled()
        let jukebox = Array((jukeboxPool + fallbackMusicPool + musiqueQuestions.shuffled()).prefix(2))

        let themeCouci = disOrDatRounds(for: pack)
        let unseenRaclette = themeCouci.filter { !excludingDisOrDatIDs.contains($0.id) && $0.optionBoth != nil }
        let unseenCouci = themeCouci.filter { !excludingDisOrDatIDs.contains($0.id) }
        let fallbackUnseenCouci = allDisOrDatRounds.filter { !$0.isPunRound && !excludingDisOrDatIDs.contains($0.id) }
        let couci = unseenRaclette.randomElement()
            ?? unseenCouci.randomElement()
            ?? fallbackUnseenCouci.randomElement()
            ?? themeCouci.randomElement()
            ?? allDisOrDatRounds[0]

        let unseenPuns = allPunRounds.filter { !excludingDisOrDatIDs.contains($0.id) }
        let punRound = unseenPuns.randomElement() ?? allPunRounds.randomElement() ?? allDisOrDatRounds[0]

        return ShowGameDeck(
            cashQuestions: cash,
            ttmcQuestions: ttmc.count == 2 ? ttmc : Array(freshPool.prefix(2)),
            jukeboxQuestions: jukebox,
            soloQuestions: solo,
            couciCoucaRound: couci,
            quoizziPunRound: punRound,
            finaleDoubleQuestions: finale
        )
    }

    // MARK: - 1. 👵 Français & Expressions de Meemaw (16 QCM)

    public static let francaisQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "FR_01",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Cent soucis, mais combien de « S » dans le tiroir ?",
            prompt: "Quand Meemaw écrit sur ton chèque d'anniversaire « Deux ___ quatre-vingts euros », comment s'écrit le mot CENT sans fâcher l'Académie française ?",
            choices: [
                "cents (avec un S, on est généreux)",
                "cent (sans S, car suivi d'un autre nombre !)",
                "sang (comme le boudin du boucher)",
                "sans (parce que le compte est vide)"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "On met un S à « deux cents » uniquement s'il n'y a rien derrière ! Dès qu'un chiffre suit, le S file à l'anglaise !",
            explanation: "💡 Règle du Certif' : « cent » et « vingt » prennent un S quand ils sont multipliés ET qu'ils terminent le nombre (« quatre-vingts », mais « deux cent quatre-vingts »).",
            audioCueID: "q_FR_01"
        ),
        QuizMCQQuestion(
            id: "FR_02",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Peigner la girafe avec un râteau",
            prompt: "Si ton grand-père te dit que tu passes ton après-midi à « peigner la girafe », qu'est-ce qu'il te reproche exactement ?",
            choices: [
                "D'avoir un brushing beaucoup trop haut",
                "De faire un travail interminable et complètement inutile",
                "De raconter des mensonges énormes",
                "D'oublier de fermer la porte du zoo"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais non mon poussin, peigner un cou de 3 mètres ça sert à rien, c'est se tourner les pouces !",
            explanation: "💡 « Peigner la girafe » (née lors de l'arrivée de la girafe Zarafa en France en 1827) signifie faire une tâche longue et parfaitement inutile.",
            audioCueID: "q_FR_02"
        ),
        QuizMCQQuestion(
            id: "FR_03",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Les poules ont couvé, mais qui s'accorde ?",
            prompt: "Complète cette phrase digne d'une dictée de Mérimée : « Les tartes aux pommes que Meemaw a ___ préparer étaient délicieuses. »",
            choices: [
                "fait (invariable devant un infinitif !)",
                "faites (parce que les tartes sont féminines)",
                "faits (un compromis diplomatique)",
                "fais (au pifomètre)"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Tombé dans le panneau classique ! Le participe passé « fait » suivi d'un infinitif est TOUJOURS invariable !",
            explanation: "💡 Règle d'or de Meemaw : « fait » suivi directement d'un verbe à l'infinitif (« a fait préparer ») ne s'accorde jamais, même si le COD est placé avant.",
            audioCueID: "q_FR_03"
        ),
        QuizMCQQuestion(
            id: "FR_04",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Il y a péril en la demeure (et dans le salon)",
            prompt: "Que veut VRAIMENT dire le mot « demeure » dans l'expression « Il y a péril en la demeure » ?",
            choices: [
                "La maison familiale",
                "Le retard ou le délai (du latin mora : attendre)",
                "La cave à fromage",
                "La chambre d'amis"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Tout le monde croit que c'est la maison ! Mais « demeure » vient de « demeurer / tarder » : il est dangereux d'attendre !",
            explanation: "💡 En vieux droit français, « la demeure » signifie le retard (comme dans « mise en demeure »). Il y a donc danger à perdre du temps !",
            audioCueID: "q_FR_04"
        ),
        QuizMCQQuestion(
            id: "FR_05",
            theme: .francaisMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Les amours, les délices et les orgues du dimanche",
            prompt: "Quelle bizarrerie partagent les trois mots français « amour », « délice » et « orgue » ?",
            choices: [
                "Ils n'ont aucune voyelle au pluriel",
                "Ils sont masculins au singulier et deviennent féminins au pluriel !",
                "Ils prennent un X au pluriel",
                "Ils sont interdits au Scrabble"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Un grand amour, mais de folles amours ! Un bel orgue, mais les grandes orgues !",
            explanation: "💡 Exception célèbre de la grammaire française : amour, délice et orgue sont masculins au singulier et féminins au pluriel.",
            audioCueID: "q_FR_05"
        ),
        QuizMCQQuestion(
            id: "FR_06",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Revenons à nos moutons (et pas à nos chèvres)",
            prompt: "D'où vient la célèbre expression « Revenons à nos moutons » utilisée quand quelqu'un change de sujet ?",
            choices: [
                "D'une recette de gigot d'Henri IV",
                "De la Farce de Maître Pathelin au Moyen Âge, où un marchand mélange un vol de drap et un vol de moutons au tribunal",
                "D'une fable perdue de La Fontaine",
                "Du premier bulletin météo de la télé"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le juge dans la Farce de Maître Pathelin qui supplie le drapier de revenir à ses moutons !",
            explanation: "💡 Dans « La Farce de Maître Pathelin » (vers 1460), le drapier embrouille tellement son procès que le juge lui crie : « Sus, revenons à ces moutons ! »",
            audioCueID: "q_FR_06"
        ),
        QuizMCQQuestion(
            id: "FR_07",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Faire ripaille sans manger des cailloux",
            prompt: "D'où vient le verbe « faire ripaille » qui veut dire faire un énorme festin bien arrosé ?",
            choices: [
                "Du château de Ripaille au bord du lac Léman, où le duc Amédée VIII menait la belle vie",
                "Du bruit que fait une fourchette sur une assiette",
                "D'une vieille soupe aux choux normande",
                "Des miettes de pain rassis"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Ça vient du château de Ripaille à Thonon-les-Bains, où le duc de Savoie s'était retiré avec ses amis gourmets !",
            explanation: "💡 Au XVe siècle, le duc Amédée VIII de Savoie se retire au château de Ripaille où la table est si bonne que « faire ripaille » devient synonyme de festin.",
            audioCueID: "q_FR_07"
        ),
        QuizMCQQuestion(
            id: "FR_08",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Des oranges orange et des pulls marron",
            prompt: "Comment écrit-on correctement les adjectifs de couleur dans : « Meemaw porte des chaussures ___ et des gants ___ » ?",
            choices: [
                "marrons / oranges (avec des S partout)",
                "marron / orange (invariables car ce sont des noms de fruits !)",
                "marronnes / orangés",
                "marrons / orange"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Les couleurs issues de fruits, de fleurs ou de pierres (marron, orange, cerise, turquoise) restent invariables, sauf rose, mauve, pourpre et écarlate !",
            explanation: "💡 Règle des couleurs : quand l'adjectif vient d'un nom (un marron, une orange), il ne prend jamais d'S au pluriel.",
            audioCueID: "q_FR_08"
        ),
        QuizMCQQuestion(
            id: "FR_09",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Passer l'arme à gauche sans fusil",
            prompt: "À l'origine, pourquoi l'expression militaire « passer l'arme à gauche » signifiait-elle mourir ?",
            choices: [
                "Parce que les gauchers étaient dispensés de corvée de patates",
                "Parce que le soldat passait son fusil dans sa main gauche pour recharger, offrant sa poitrine sans défense à l'ennemi",
                "Parce que le cimetière était toujours à gauche de la caserne",
                "Parce que l'épée rouillait du côté gauche"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Pour recharger son fusil à poudre, le fantassin devait le tenir de la main gauche, moment où il était le plus vulnérable !",
            explanation: "💡 Sous l'Empire, passer son arme du côté gauche pour recharger exposait le soldat au tir adverse.",
            audioCueID: "q_FR_09"
        ),
        QuizMCQQuestion(
            id: "FR_10",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Après qu'il est venu ou après qu'il soit venu ?",
            prompt: "Quelle phrase est grammaticalement IRRÉPROCHABLE aux yeux de Meemaw et du dictionnaire ?",
            choices: [
                "Après qu'il ait mangé la tarte",
                "Après qu'il a mangé la tarte (l'indicatif après « après que » !)",
                "Après qu'il eût mangé la tarte demain",
                "Après qu'il soit manger"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "« Avant que » veut le subjonctif (l'action n'a pas encore eu lieu), mais « après que » exprime un fait réel : il faut l'indicatif !",
            explanation: "💡 Règle d'or : « avant qu'il vienne » (subjonctif), mais « après qu'il est venu / après qu'il a mangé » (indicatif).",
            audioCueID: "q_FR_10"
        ),
        QuizMCQQuestion(
            id: "FR_11",
            theme: .francaisMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Se mettre sur son 31 (et pas sur son 28)",
            prompt: "Quelle est l'origine la plus célèbre de l'expression « se mettre sur son trente-et-un » pour dire qu'on s'habille très chic ?",
            choices: [
                "Un tissu de luxe très fin du Moyen Âge appelé le « trentain » (tissé avec trente fois cent fils)",
                "Le numéro du bus qui allait à l'Opéra Garnier",
                "L'âge auquel Louis XIV a acheté sa première perruque",
                "Le 31 décembre"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est une déformation du mot « trentain », un drap extrêmement luxueux composé de 3 000 fils !",
            explanation: "💡 Le « trentain » était un drap de laine très haut de gamme réservé aux habits de fête ; par déformation populaire, « se mettre sur son trentain » est devenu « sur son 31 ».",
            audioCueID: "q_FR_11"
        ),
        QuizMCQQuestion(
            id: "FR_12",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Les chacals du salon",
            prompt: "Quel est le VRAI pluriel du nom « un chacal » en français ?",
            choices: [
                "Des chacaux (comme des chevaux)",
                "Des chacals (avec un S !)",
                "Des chacaux-vapoteurs",
                "C'est invariable"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "On dit un bal, un carnaval, un festival, un récital, un régal et un chacal : tous prennent un S au pluriel !",
            explanation: "💡 Exception des mots en -al : bal, carnaval, chacal, festival, récital et régal forment leur pluriel en -als.",
            audioCueID: "q_FR_12"
        ),
        QuizMCQQuestion(
            id: "FR_13",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Fier comme Artaban dans la cuisine",
            prompt: "Dans l'expression « Fier comme Artaban », qui était donc ce fameux Artaban ?",
            choices: [
                "Le boulanger personnel de Napoléon",
                "Un héros de roman à succès du XVIIe siècle (Cléopâtre de La Calprenède), inspiré d'un roi des Parthes",
                "Le cheval blanc d'Henri IV",
                "L'inventeur de la moustache cirée"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Artaban est le personnage ultra-orgueilleux du roman fleuve de Gautier de Costes de La Calprenède au XVIIe siècle !",
            explanation: "💡 Le personnage d'Artaban était si hautain dans le roman « Cléopâtre » (1647) que son nom est passé dans le langage courant.",
            audioCueID: "q_FR_13"
        ),
        QuizMCQQuestion(
            id: "FR_14",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Tirer les vers du nez sans canne à pêche",
            prompt: "Quand Meemaw te « tire les vers du nez », qu'est-ce qu'elle réussit à faire ?",
            choices: [
                "Te soigner d'un gros rhume avec du thym",
                "Te faire avouer un secret habilement en te posant plein de petites questions",
                "Te faire manger tes légumes verts",
                "Te couper les poils des narines"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Tirer les vers du nez, c'est soutirer un secret à quelqu'un sans qu'il s'en rende compte !",
            explanation: "💡 L'expression remonte au Moyen Âge, où l'on croyait que les secrets cachés rongeaient l'esprit comme de petits vers.",
            audioCueID: "q_FR_14"
        ),
        QuizMCQQuestion(
            id: "FR_15",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Les rois se sont succédé sur le canapé",
            prompt: "Comment s'écrit le participe passé dans : « Les invités qui se sont ___ au buffet ont tout mangé » ?",
            choices: [
                "succédés (avec un S)",
                "succédé (invariable, car on succède À quelqu'un : COI !)",
                "succédées",
                "succéder"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "On dit « succéder À quelqu'un » ! Comme il n'y a jamais de COD avec « se succéder », « succédé » reste toujours invariable !",
            explanation: "💡 Astuce dictée : « ils se sont téléphoné / parlé / souri / succédé » ne prennent jamais d'S car le pronom « se » est COI (à eux-mêmes).",
            audioCueID: "q_FR_15"
        ),
        QuizMCQQuestion(
            id: "FR_16",
            theme: .francaisMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Manger sur le pouce sans se mordre les doigts",
            prompt: "D'où vient l'expression « manger sur le pouce » pour dire qu'on avale un repas vite fait debout ?",
            choices: [
                "De l'habitude des ouvriers et paysans qui coupaient leur pain et leur saucisson au couteau directement appuyés sur leur pouce, sans assiette",
                "De Tom Pouce qui mangeait très vite",
                "Des empereurs romains au Colisée",
                "Du premier sandwich vendu dans le métro"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Sans table ni assiette, on tenait le morceau de lard ou de fromage calé sous le pouce sur un quignon de pain en le tranchant au couteau !",
            explanation: "💡 Au XIXe siècle, les travailleurs mangeaient leur casse-croûte en coupant la nourriture au couteau directement sur leur pouce.",
            audioCueID: "q_FR_16"
        ),
        QuizMCQQuestion(
            id: "FR_17",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Avoir un poil dans la main (et pas une moustache)",
            prompt: "Que signifie l'expression « avoir un poil dans la main » que Meemaw utilise quand tu traînes pour débarrasser la table ?",
            choices: [
                "Être extrêmement paresseux (tellement qu'un poil aurait eu le temps de pousser dans la paume !)",
                "Avoir beaucoup de chance aux cartes",
                "Être très habile en bricolage",
                "Avoir besoin de gants en hiver"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Comme les poils ne poussent jamais dans la paume de la main, il faut vraiment ne rien faire pendant très longtemps pour qu'il y en ait un !",
            explanation: "💡 Apparue au XIXe siècle, l'image exagère l'inactivité d'une main qui ne travaille jamais.",
            audioCueID: "q_FR_17"
        ),
        QuizMCQQuestion(
            id: "FR_18",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Le seul mot français où l'on prononce « O-I » autrement",
            prompt: "Quel mot bien connu de la cuisine de Meemaw s'écrit avec « OI » mais se prononce « O » (et pas « OUA ») ?",
            choices: [
                "Un oignon",
                "Un poireau",
                "Une passoire",
                "Un entonnoir"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est l'oignon ! Le I servait autrefois juste à indiquer qu'il fallait mouiller le GN !",
            explanation: "💡 En ancien français, le « i » devant « gn » servait à noter le son « gn » mouillé ; la réforme de 1990 autorise d'ailleurs d'écrire « ognon ».",
            audioCueID: "q_FR_18"
        ),
        QuizMCQQuestion(
            id: "FR_19",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Poser un lapin au coin de la rue",
            prompt: "D'où vient l'expression « poser un lapin » (ne pas venir à un rendez-vous sans prévenir) ?",
            choices: [
                "De l'argot étudiant du XIXe siècle où « laisser un lapin » signifiait partir sans payer (donc laisser l'autre sans rien)",
                "D'Alice au Pays des Merveilles",
                "Des chasseurs bredouilles du dimanche",
                "D'un magicien qui avait oublié son chapeau"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Vers 1880, « poser un lapin » voulait dire partir sans payer, avant de prendre le sens de laisser quelqu'un attendre pour rien !",
            explanation: "💡 Vers 1890 chez les étudiants parisiens, « poser un lapin » glisse du sens de « ne pas payer » à « ne pas honorer un rendez-vous ».",
            audioCueID: "q_FR_19"
        ),
        QuizMCQQuestion(
            id: "FR_20",
            theme: .francaisMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Les chevaux, les pneus et les landaus",
            prompt: "Parmi ces quatre mots en « -AU » ou « -EU », lequel prend un « S » au pluriel au lieu d'un « X » ?",
            choices: [
                "Un pneu -> Des pneus (et un landau -> des landaus !)",
                "Un tuyau -> Des tuyaus",
                "Un cheveu -> Des cheveus",
                "Un noyau -> Des noyaus"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Des pneus, des bleus, des landaus et des sarraus prennent un S ! Tous les autres prennent un X !",
            explanation: "💡 Exceptions célèbres du pluriel : « des pneus, des bleus » (en -eu) et « des landaus, des sarraus » (en -au) prennent un S.",
            audioCueID: "q_FR_20"
        )
    ]

    // MARK: - 2. 📐 Meemaw Math & Logique Flash (16 QCM)

    public static let mathQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "MATH_01",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "La tarte aux prunes à 1 € 10 qui rend fou",
            prompt: "Une tartelette et sa boîte coûtent 1,10 € en tout. La tartelette coûte 1,00 € DE PLUS que la boîte. Combien coûte la boîte toute seule ?",
            choices: [
                "0,10 € (10 centimes, fastoche !)",
                "0,05 € (5 centimes !)",
                "0,15 €",
                "Rien du tout, Meemaw offre le carton"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Si la boîte coûtait 10 centimes, la tarte à 1 € de plus coûterait 1,10 €, soit 1,20 € au total ! La boîte vaut 5 centimes !",
            explanation: "💡 Piège cognitif classique : Boîte (0,05 €) + Tarte (1,05 €) = 1,10 € au total, avec exactement 1,00 € d'écart !",
            audioCueID: "q_MATH_01"
        ),
        QuizMCQQuestion(
            id: "MATH_02",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Les soldes qui te prennent pour un jambon",
            prompt: "Un pull baisse de 50 % pendant les soldes, puis le vendeur remonte son nouveau prix de 50 % la semaine suivante. Par rapport au prix de départ de 100 €, combien coûte-t-il maintenant ?",
            choices: [
                "Toujours 100 €, -50 % et +50 % ça s'annule !",
                "75 € (tu as quand même gagné 25 % !)",
                "125 €",
                "50 €"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Mais non ! 100 € moins 50 % ça fait 50 €. Et +50 % de 50 €, ça rajoute seulement 25 €, donc 75 € !",
            explanation: "💡 Les pourcentages ne s'additionnent pas : 100 € × 0,5 = 50 €, puis 50 € × 1,5 = 75 €.",
            audioCueID: "q_MATH_02"
        ),
        QuizMCQQuestion(
            id: "MATH_03",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Les nénuphars envahissent la mare aux canards",
            prompt: "Un nénuphar double de taille tous les jours dans le bassin de Meemaw. Il met 30 jours pour recouvrir TOUT le bassin. En combien de jours avait-il recouvert la MOITIÉ du bassin ?",
            choices: [
                "15 jours (la moitié de 30, logique !)",
                "29 jours (la veille du 30e jour !)",
                "7 jours et demi",
                "20 jours"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Puisqu'il double chaque jour, la veille du 30e jour (au jour 29), il occupait exactement la moitié du bassin !",
            explanation: "💡 Croissance exponentielle : s'il double chaque jour et atteint 100 % le jour 30, il était à 50 % le jour 29 !",
            audioCueID: "q_MATH_03"
        ),
        QuizMCQQuestion(
            id: "MATH_04",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Le train de 1951 qui décoiffe le chef de gare",
            prompt: "Si la micheline de Meemaw roule à 120 km/h de moyenne, quelle distance parcourt-elle en 45 minutes ?",
            choices: [
                "80 km",
                "90 km (trois quarts d'heure × 120)",
                "100 km",
                "60 km"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "120 km/h, c'est 2 kilomètres par minute ! En 45 minutes, 45 fois 2 égale 90 kilomètres !",
            explanation: "💡 Astuce Certif' de Meemaw : à 120 km/h on avance de 2 km chaque minute (120 ÷ 60 = 2), donc 45 × 2 = 90 km.",
            audioCueID: "q_MATH_04"
        ),
        QuizMCQQuestion(
            id: "MATH_05",
            theme: .mathMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Priorité aux multiplications avant le dessert",
            prompt: "Sans calculatrice et sans tricher sur le voisin, combien font : 10 + 10 × 0 + 10 ?",
            choices: [
                "0 (tout ce qui touche zéro meurt)",
                "10",
                "20 (car 10 × 0 = 0, donc 10 + 0 + 10 = 20 !)",
                "30"
            ],
            correctIndex: 2,
            baseValue: 2000,
            meemawRoastOnWrong: "La multiplication passe toujours avant l'addition ! Seul le milieu vaut zéro, il reste 10 plus 10 égale 20 !",
            explanation: "💡 Priorité opératoire : 10 + (10 × 0) + 10 = 10 + 0 + 10 = 20.",
            audioCueID: "q_MATH_05"
        ),
        QuizMCQQuestion(
            id: "MATH_06",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Cinq tricoteuses en furie",
            prompt: "Si 5 grand-mères tricotent 5 écharpes en 5 minutes, combien de minutes faut-il à 100 grand-mères pour tricoter 100 écharpes ?",
            choices: [
                "100 minutes",
                "Toujours 5 minutes !",
                "20 minutes",
                "1 minute"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Chaque grand-mère tricote sa propre écharpe en 5 minutes ! À 100 grand-mères en parallèle, ça prend toujours 5 minutes !",
            explanation: "💡 Travail en parallèle : 1 grand-mère met 5 minutes pour 1 écharpe, donc 100 grand-mères font 100 écharpes en 5 minutes.",
            audioCueID: "q_MATH_06"
        ),
        QuizMCQQuestion(
            id: "MATH_07",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "L'escargot têtu au fond du puits",
            prompt: "Un escargot est au fond d'un puits de 10 mètres. Chaque jour il monte de 3 mètres, mais chaque nuit il glisse de 2 mètres en dormant. Quel jour touche-t-il enfin le bord du puits ?",
            choices: [
                "Le 10e jour",
                "Le 8e jour (sans glisser la 8e nuit car il est déjà sorti !)",
                "Le 5e jour",
                "Jamais, il finit en persillade"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "À la fin du 7e jour + 7e nuit, il est à 7 mètres. Le 8e matin, il monte de 3 mètres et atteint 10 mètres : il est sorti !",
            explanation: "💡 Au bout de 7 jours complets, l'escargot est à 7 m. Le 8e jour, il grimpe de 3 m et atteint les 10 m avant la nuit !",
            audioCueID: "q_MATH_07"
        ),
        QuizMCQQuestion(
            id: "MATH_08",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "La course à pied où l'on double le deuxième",
            prompt: "Tu participes au marathon des tartes de Meemaw. Juste avant la ligne d'arrivée, tu doubles le DEUXIÈME de la course. À quelle place termines-tu ?",
            choices: [
                "Premier (médaille d'or !)",
                "Deuxième (tu prends la place de celui que tu viens de doubler !)",
                "Troisième",
                "Dernier"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Si tu doubles le deuxième, tu prends sa place de deuxième ! Le premier est toujours devant toi !",
            explanation: "💡 Piège classique : doubler le 2e te fait passer de la 3e à la 2e place.",
            audioCueID: "q_MATH_08"
        ),
        QuizMCQQuestion(
            id: "MATH_09",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Les chaussettes dans le noir complet",
            prompt: "Dans le tiroir de Meemaw, il y a 10 chaussettes rouges et 10 chaussettes bleues en vrac. Il fait nuit noire. Combien de chaussettes dois-tu prendre AU MINIMUM pour être sûr à 100 % d'avoir une paire de la même couleur ?",
            choices: [
                "2 chaussettes",
                "3 chaussettes (principe des tiroirs !)",
                "11 chaussettes",
                "6 chaussettes"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Comme il n'y a que 2 couleurs, en prenant 3 chaussettes tu as forcément au moins 2 rouges ou 2 bleues !",
            explanation: "💡 Principe des tiroirs de Dirichlet : avec 2 couleurs possibles, 3 tirages garantissent une paire identique.",
            audioCueID: "q_MATH_09"
        ),
        QuizMCQQuestion(
            id: "MATH_10",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Combien de mois ont 28 jours ?",
            prompt: "Question piège en 3 secondes : dans une année normale, combien de mois ont 28 jours ?",
            choices: [
                "Un seul (février, voyons !)",
                "Les 12 mois de l'année (ils ont tous au moins 28 jours !)",
                "Aucun les années bissextiles",
                "Deux mois"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Tous les mois de l'année ont un 28e jour, de janvier à décembre !",
            explanation: "💡 Les 12 mois comptent tous 28 jours (et 11 d'entre eux en ont même 30 ou 31).",
            audioCueID: "q_MATH_10"
        ),
        QuizMCQQuestion(
            id: "MATH_11",
            theme: .mathMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Diviser par un demi, ce n'est pas couper en deux",
            prompt: "Combien font : 30 divisé par 0,5 (la moitié), plus 10 ?",
            choices: [
                "25 (car 30 ÷ 2 = 15, + 10 = 25)",
                "70 (car diviser par 0,5 revient à multiplier par 2 : 60 + 10 = 70 !)",
                "40",
                "15"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Diviser par un demi (0,5), c'est demander combien de demis rentrent dans 30 : ça fait 60 ! Plus 10 égale 70 !",
            explanation: "💡 30 ÷ 0,5 = 30 × 2 = 60. Puis 60 + 10 = 70.",
            audioCueID: "q_MATH_11"
        ),
        QuizMCQQuestion(
            id: "MATH_12",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "La brique qui pèse une brique",
            prompt: "Une brique pèse 1 kilo plus une demi-brique. Combien pèse une brique entière ?",
            choices: [
                "1,5 kilo",
                "2 kilos !",
                "1 kilo",
                "3 kilos"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Si une brique vaut 1 kg + une demi-brique, alors l'autre demi-brique pèse 1 kg ! Donc la brique entière pèse 2 kilos !",
            explanation: "💡 Équation mentale : B = 1 + 0,5 B, donc 0,5 B = 1 kg, d'où B = 2 kg.",
            audioCueID: "q_MATH_12"
        ),
        QuizMCQQuestion(
            id: "MATH_13",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Les comprimés du docteur toutes les demi-heures",
            prompt: "Le médecin donne 3 comprimés à Meemaw en lui disant d'en prendre un toutes les 30 minutes. En combien de temps aura-t-elle avalé les 3 comprimés ?",
            choices: [
                "1 heure 30 (3 × 30 minutes)",
                "1 heure exactement (0 min, 30 min, et 60 min !)",
                "45 minutes",
                "2 heures"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Elle prend le 1er tout de suite (0 min), le 2e à 30 minutes, et le 3e à 60 minutes : ça fait 1 heure !",
            explanation: "💡 Problème d'intervalles : entre 3 prises, il n'y a que 2 intervalles de 30 minutes, soit 1 heure.",
            audioCueID: "q_MATH_13"
        ),
        QuizMCQQuestion(
            id: "MATH_14",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "L'astuce magique de la table de 11",
            prompt: "Calcul mental ultra-rapide façon Meemaw Math : combien font 11 × 45 ?",
            choices: [
                "450",
                "495 (on écarte le 4 et le 5, et on met 4+5=9 au milieu !)",
                "505",
                "485"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Pour multiplier par 11, tu additionnes les deux chiffres (4 + 5 = 9) et tu glisses le 9 entre le 4 et le 5 : 495 !",
            explanation: "💡 Astuce de Meemaw Math : 45 × 11 = 4_(4+5)_5 = 495.",
            audioCueID: "q_MATH_14"
        ),
        QuizMCQQuestion(
            id: "MATH_15",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Le carré des nombres qui finissent par 5",
            prompt: "Sans poser l'opération, combien font 35 × 35 ?",
            choices: [
                "1 025",
                "1 225 (3 × 4 = 12 devant 25 !)",
                "1 125",
                "925"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Tout carré finissant par 5 se termine par 25, précédé de la dizaine multipliée par la suivante : 3 fois 4 égale 12, donc 1 225 !",
            explanation: "💡 Secret de calcul mental : pour élever N5 au carré, calcule N × (N+1) puis colle 25 à la fin (3 × 4 = 12 → 1 225).",
            audioCueID: "q_MATH_15"
        ),
        QuizMCQQuestion(
            id: "MATH_16",
            theme: .mathMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Le pliage de feuille qui touche la Lune",
            prompt: "Si tu pouvais plier une simple feuille de papier (0,1 mm d'épaisseur) 42 fois sur elle-même en doublant son épaisseur à chaque pli, quelle hauteur atteindrait-elle ?",
            choices: [
                "La hauteur d'un dictionnaire Larousse (8 cm)",
                "La hauteur de la Tour Eiffel (330 m)",
                "Plus de 400 000 kilomètres : elle dépasserait la Lune !",
                "Environ 12 mètres"
            ],
            correctIndex: 2,
            baseValue: 2500,
            meemawRoastOnWrong: "2 puissance 42 fois 0,1 millimètre fait 439 800 kilomètres, soit plus que la distance Terre-Lune !",
            explanation: "💡 Puissance de 2 : 0,1 mm × 2^42 ≈ 439 804 km, dépassant la distance moyenne Terre-Lune (384 400 km).",
            audioCueID: "q_MATH_16"
        ),
        QuizMCQQuestion(
            id: "MATH_17",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Une livre de plumes contre une livre de plomb",
            prompt: "Qu'est-ce qui est le plus lourd sur la balance de Meemaw : 1 kilo de plumes d'oie ou 1 kilo de plomb ?",
            choices: [
                "Ils ont exactement le même poids : 1 kilo chacun !",
                "1 kilo de plomb, forcément",
                "1 kilo de plumes car ça prend tout le salon",
                "Ça dépend du sens du vent"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "1 kilo, c'est 1 kilo ! Par contre, si ça te tombe sur le gros orteil, tu préféreras les plumes !",
            explanation: "💡 Piège d'attention vieux comme le monde : la masse est identique (1 kg), seul le volume change.",
            audioCueID: "q_MATH_17"
        ),
        QuizMCQQuestion(
            id: "MATH_18",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Le paradoxe des anniversaires au repas de famille",
            prompt: "Dans une pièce de 23 personnes réunies au hasard, quelle est la probabilité qu'au moins DEUX personnes fêtent leur anniversaire le même jour de l'année ?",
            choices: [
                "Plus de 50 % (1 chance sur 2 !)",
                "Moins de 5 %",
                "Exactement 23 sur 365 (environ 6 %)",
                "Zéro, sauf si ce sont des jumeaux"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est le fameux paradoxe des anniversaires : dès 23 personnes, il y a 50,7 % de chances qu'une paire partage la même date !",
            explanation: "💡 Avec 23 personnes, on compare 253 paires possibles (23 × 22 ÷ 2), ce qui fait dépasser 50 % de probabilité !",
            audioCueID: "q_MATH_18"
        ),
        QuizMCQQuestion(
            id: "MATH_19",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Les moutons survivants du pré",
            prompt: "Le berger du village a 17 moutons dans son pré. Tous, sauf 9, s'échappent par la barrière ouverte. Combien lui reste-t-il de moutons dans le pré ?",
            choices: [
                "9 moutons !",
                "8 moutons (17 moins 9)",
                "Aucun mouton",
                "26 moutons"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Ne calcule pas 17 moins 9 ! La phrase te dit « Tous, SAUF 9, s'échappent » : il en reste donc 9 !",
            explanation: "💡 Énigme d'écoute : « tous sauf 9 partent » signifie directement que 9 restent.",
            audioCueID: "q_MATH_19"
        ),
        QuizMCQQuestion(
            id: "MATH_20",
            theme: .mathMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "La somme éclair du petit Carl Friedrich Gauss",
            prompt: "Quelle est la somme de tous les nombres entiers de 1 jusqu'à 100 (1 + 2 + 3 + ... + 99 + 100) ?",
            choices: [
                "5 050 (50 paires qui valent toutes 101 !)",
                "5 000 tout rond",
                "10 000",
                "4 950"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "À 9 ans, Gauss a regroupé 1+100=101, 2+99=101... 50 paires de 101 donnent 5 050 en 3 secondes !",
            explanation: "💡 Formule de Gauss : n × (n + 1) ÷ 2 = 100 × 101 ÷ 2 = 5 050.",
            audioCueID: "q_MATH_20"
        )
    ]

    // MARK: - 3. 🎬 Séries & Cinéma Pop (16 QCM)

    public static let seriesCinemaQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "CINE_01",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Meemaw résume le film : « Il fait très froid dans l'eau »",
            prompt: "Dans Titanic (1997), comment Jack Dawson gagne-t-il son billet de 3e classe cinq minutes avant le départ du paquebot ?",
            choices: [
                "En vendant le portrait d'un caniche",
                "Lors d'une partie de poker dans un pub du port",
                "En se cachant dans une malle à chapeaux",
                "Grâce à un bon de réduction SNCF"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Il gagne ses billets au poker avec un full ! Dommage pour lui, il aurait mieux fait de perdre cette main-là !",
            explanation: "💡 Jack et Fabrizio remportent leurs billets lors d'une partie de poker à Southampton juste avant l'embarquement.",
            audioCueID: "q_CINE_01"
        ),
        QuizMCQQuestion(
            id: "CINE_02",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "Prof de chimie cherche camping-car d'occasion",
            prompt: "Dans la série Breaking Bad, sous quel pseudonyme tiré d'un célèbre physicien quantique Walter White se fait-il appeler dans le milieu ?",
            choices: [
                "Oppenheimer",
                "Heisenberg",
                "Schrödinger",
                "Lavoisier"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Heisenberg, comme le principe d'incertitude de Werner Heisenberg !",
            explanation: "💡 Walter White choisit le nom de code « Heisenberg » en hommage au physicien allemand Werner Heisenberg.",
            audioCueID: "q_CINE_02"
        ),
        QuizMCQQuestion(
            id: "CINE_03",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Le gilet tricoté main par le Père Noël",
            prompt: "Dans la comédie culte « Le Père Noël est une ordure », comment Thérèse appelle-t-elle affectueusement la spécialité roulée aux marrons de monsieur Preskovic ?",
            choices: [
                "Les petits étouffe-chrétiens",
                "Les Doubitchous de Sofia (roulés à la main sous les aisselles)",
                "Les Kouglofs de Belgrade",
                "Les Rochers de tante Sidonie"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Ce sont les fameux Doubitchous de Sofia, bien meilleurs que le Kloug aux marrons !",
            explanation: "💡 Monsieur Preskovic apporte d'abord ses « Doubitchous de Sofia », avant de revenir avec son redoutable « Kloug aux marrons ».",
            audioCueID: "q_CINE_03"
        ),
        QuizMCQQuestion(
            id: "CINE_04",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Une blanquette à l'ancienne au Caire",
            prompt: "Dans « OSS 117 : Le Caire, nid d'espions », quelle couverture professionnelle Hubert Bonisseur de La Bath utilise-t-il en Égypte ?",
            choices: [
                "Importateur de tapis persans",
                "Directeur de la SCEP (Société Cairote d'Élevage de Poulets)",
                "Professeur de bilboquet",
                "Critique gastronomique de blanquette"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Il dirige la SCEP, la Société Cairote d'Élevage de Poulets !",
            explanation: "💡 L'agent OSS 117 opère sous la couverture de directeur d'une société d'élevage de poulets au Caire.",
            audioCueID: "q_CINE_04"
        ),
        QuizMCQQuestion(
            id: "CINE_05",
            theme: .seriesCinema,
            preferredRound: .finaleDouble,
            funnyTitle: "Retour vers le grille-pain temporel",
            prompt: "Dans « Retour vers le futur », quelle vitesse exacte la DeLorean du Doc Brown doit-elle atteindre pour voyager dans le temps ?",
            choices: [
                "50 miles par heure",
                "88 miles par heure (environ 141 km/h)",
                "120 miles par heure",
                "Mach 2"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "88 miles à l'heure, Nom de Zeus ! Pas un mile de moins !",
            explanation: "💡 La DeLorean DMC-12 active son convecteur temporel de 2,21 gigowatts dès qu'elle franchit 88 mph.",
            audioCueID: "q_CINE_05"
        ),
        QuizMCQQuestion(
            id: "CINE_06",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "La cuillère qui n'existe pas dans la soupe",
            prompt: "Dans le premier film « Matrix » (1999), de quelle couleur est la pilule que Neo avale pour découvrir la vérité et sortir de la simulation ?",
            choices: [
                "La pilule bleue",
                "La pilule rouge",
                "La pilule verte fluo",
                "Un suppositoire à l'eucalyptus"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "La pilule bleue te ramène dans ton lit, c'est la pilule ROUGE qui te montre jusqu'où va le terrier du lapin blanc !",
            explanation: "💡 Morpheus propose la pilule bleue (l'oubli) ou la pilule rouge (la vérité sur la Matrice).",
            audioCueID: "q_CINE_06"
        ),
        QuizMCQQuestion(
            id: "CINE_07",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Le dîner du mercredi soir avec des allumettes",
            prompt: "Dans « Le Dîner de cons » de Francis Veber, quelle est la grande passion de François Pignon (joué par Jacques Villeret) ?",
            choices: [
                "Collectionner les bouchons de champagne",
                "Construire des maquettes géantes en allumettes (dont le pont de Tancarville !)",
                "Imiter le cri de la mouette rieuse",
                "Peindre des nains de jardin"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Il construit des maquettes géantes avec 346 422 allumettes et un tube de colle !",
            explanation: "💡 François Pignon réalise des maquettes monumentales en allumettes, notamment la Tour Eiffel et le pont de Tancarville.",
            audioCueID: "q_CINE_07"
        ),
        QuizMCQQuestion(
            id: "CINE_08",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "C'est pas faux à la Table Ronde",
            prompt: "Dans la série « Kaamelott » d'Alexandre Astier, quelle botte secrète Perceval utilise-t-il quand il ne comprend pas un mot dans une conversation ?",
            choices: [
                "Il répond « C'est pas faux ! »",
                "Il chante une chanson galloise",
                "Il jette du fromage sur la table",
                "Il fait semblant de s'évanouir"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est la botte secrète de Karadoc et Perceval : répondre « C'est pas faux ! » d'un air entendu !",
            explanation: "💡 Karadoc enseigne à Perceval qu'en disant « C'est pas faux », on passe pour un sage sans avouer qu'on n'a pas compris un mot.",
            audioCueID: "q_CINE_08"
        ),
        QuizMCQQuestion(
            id: "CINE_09",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Le café où personne ne travaille jamais",
            prompt: "Dans la série « Friends », comment s'appelle le café aux canapés orange où Rachel, Monica, Phoebe, Joey, Chandler et Ross passent leurs journées ?",
            choices: [
                "Le Manhattan Espresso",
                "Le Central Perk",
                "Chez Gunther & Compagnie",
                "Le Café de la Gare"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le Central Perk, jeu de mots avec Central Park et « perk » (percolateur à café) !",
            explanation: "💡 Le Central Perk, tenu par Gunther, est le QG des six amis pendant les 10 saisons de Friends.",
            audioCueID: "q_CINE_09"
        ),
        QuizMCQQuestion(
            id: "CINE_10",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "La boîte de chocolats sur le banc de bus",
            prompt: "Quel personnage joué par Tom Hanks répète : « Maman disait toujours : la vie, c'est comme une boîte de chocolats, on ne sait jamais sur quoi on va tomber » ?",
            choices: [
                "Capitaine Miller",
                "Forrest Gump",
                "Woody le cow-boy",
                "Robinson Crusoé"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Cours, Forrest, cours ! C'est évidemment Forrest Gump en 1994 !",
            explanation: "💡 Cette réplique culte ouvre « Forrest Gump » (1994) de Robert Zemeckis, récompensé par 6 Oscars.",
            audioCueID: "q_CINE_10"
        ),
        QuizMCQQuestion(
            id: "CINE_11",
            theme: .seriesCinema,
            preferredRound: .finaleDouble,
            funnyTitle: "Le survêtement vert numéroté 456",
            prompt: "Dans la saison 1 de « Squid Game », quelle est la toute première épreuve mortelle à laquelle participent les 456 joueurs devant une poupée géante ?",
            choices: [
                "La marelle sur pont de verre",
                "1, 2, 3, Soleil !",
                "Le tir à la corde",
                "Le jeu des chaises musicales"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « 1, 2, 3, Soleil » (« Mugunghwa kkochi pieotseumnida » en coréen) !",
            explanation: "💡 La première épreuve de Squid Game est la version coréenne de « 1, 2, 3, Soleil » arbitrée par la poupée Young-hee.",
            audioCueID: "q_CINE_11"
        ),
        QuizMCQQuestion(
            id: "CINE_12",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "La soupe aux choux qui attire les soucoupes",
            prompt: "Dans « La Soupe aux choux » avec Louis de Funès et Jean Carmet, comment les deux compères surnomment-ils l'extraterrestre venu de la planète Oxo ?",
            choices: [
                "La Denrée",
                "Le Glaude",
                "Le Bombé",
                "Le Corniaud"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Le Glaude (Louis de Funès) et le Bombé (Jean Carmet) l'appellent affectueusement « La Denrée » (Jacques Villeret) !",
            explanation: "💡 L'extraterrestre joué par Jacques Villeret est baptisé « La Denrée » par Le Glaude.",
            audioCueID: "q_CINE_12"
        ),
        QuizMCQQuestion(
            id: "CINE_13",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "Le gentleman cambrioleur aux baskets Jordan",
            prompt: "Dans la série française « Lupin » avec Omar Sy, comment s'appelle le protagoniste inspiré d'Arsène Lupin ?",
            choices: [
                "Assane Diop",
                "Raoul d'Andrésy",
                "Hubert Pellegrini",
                "Ganimard Junior"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Il s'appelle Assane Diop (et « Assane » est presque une anagramme d'Arsène) !",
            explanation: "💡 Omar Sy incarne Assane Diop, qui venge son père en s'inspirant des romans de Maurice Leblanc.",
            audioCueID: "q_CINE_13"
        ),
        QuizMCQQuestion(
            id: "CINE_14",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "La crêpe au suc' sur les pistes de ski",
            prompt: "Dans « Les Bronzés font du ski » (1979), quelle boisson fortifiante contenant un crapaud les paysans savoyards servent-ils à la troupe égarée en montagne ?",
            choices: [
                "Du génépi millésimé",
                "De la liqueur d'échalote (« la fougne », relevée au crapaud !)",
                "Du vin chaud à la cannelle",
                "De la tisane de marmotte"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est la fameuse « fougne », la liqueur d'échalote crapaudine qui débouche les sinus sur trois générations !",
            explanation: "💡 Scène mythique du refuge : l'alcool de crapaud et d'échalote fait fondre les verres et les gosiers des Bronzés.",
            audioCueID: "q_CINE_14"
        ),
        QuizMCQQuestion(
            id: "CINE_15",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "La toupie qui tourne à la fin du rêve",
            prompt: "Dans le film « Inception » (2010) de Christopher Nolan, quel petit objet Cobb (Leonardo DiCaprio) fait-il tourner sur la table pour vérifier s'il rêve ou s'il est dans la réalité ?",
            choices: [
                "Un dé pipé",
                "Une petite toupie en métal (son totem)",
                "Une pièce de 2 francs",
                "Un dé à coudre de Meemaw"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est sa petite toupie en métal : si elle ne s'arrête jamais de tourner, c'est qu'il est encore dans un rêve !",
            explanation: "💡 La toupie est le totem de Mal et Cobb, donnant lieu au plan final le plus débattu du cinéma moderne.",
            audioCueID: "q_CINE_15"
        ),
        QuizMCQQuestion(
            id: "CINE_16",
            theme: .seriesCinema,
            preferredRound: .finaleDouble,
            funnyTitle: "Oкей, lajasse la voiture à messire !",
            prompt: "En quelle année est sorti au cinéma le premier volet de « Les Visiteurs » avec Jean Reno (Godefroy de Montmirail) et Christian Clavier (Jacquouille la Fripouille) ?",
            choices: [
                "1988",
                "1993",
                "1998",
                "2001"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'était en janvier 1993, avec près de 14 millions d'entrées en salles !",
            explanation: "💡 Sorti en 1993 et réalisé par Jean-Marie Poiré, « Les Visiteurs » a réuni 13,78 millions de spectateurs en France.",
            audioCueID: "q_CINE_16"
        ),
        QuizMCQQuestion(
            id: "CINE_17",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "PIVOT ! PIVOT ! PIVOOOOOT !",
            prompt: "Dans la scène mythique de la série « Friends », quel meuble Ross Geller essaie-t-il désespérément de monter dans sa cage d'escalier en hurlant « PIVOT ! » à Rachel et Chandler ?",
            choices: [
                "Un canapé neuf (qui finit coupé en deux !)",
                "Un piano à queue",
                "Le frigo de Monica",
                "Le baby-foot de Joey"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est son canapé beige, parce que Ross était trop radin pour payer 15 dollars de livraison !",
            explanation: "💡 Dans la saison 5 de Friends, Ross refuse de payer la livraison et coince son canapé dans l'escalier en criant « PIVOT ! ».",
            audioCueID: "q_CINE_17"
        ),
        QuizMCQQuestion(
            id: "CINE_18",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "Arrestation immédiate pour excès de mignonnerie",
            prompt: "Dans la série « The Rookie », comment les fans surnomment-ils le duo amoureux ultra-populaire formé par Lucy Chen et son ancien instructeur grincheux Tim Bradford ?",
            choices: [
                "Bradchen",
                "Chenford (Chen + Bradford !)",
                "Les Poulets Dorés",
                "Timlucy"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est CHENFORD, voyons ! Même Meemaw attendait qu'ils s'embrassent depuis la saison 1 !",
            explanation: "💡 Le couple « Chenford » (Lucy Chen & Tim Bradford) est devenu le phénomène absolu des fans de The Rookie.",
            audioCueID: "q_CINE_18"
        ),
        QuizMCQQuestion(
            id: "CINE_19",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "C'est une bonne situation, ça, scribe ?",
            prompt: "Dans « Astérix & Obélix : Mission Cléopâtre » (2002) d'Alain Chabat, comment s'appelle le scribe égyptien joué par Édouard Baer qui improvise un monologue mythique sur les rencontres et le destin ?",
            choices: [
                "Otis",
                "Numérobis",
                "Amonbofis",
                "Itinéris"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Otis ! « Vous savez, moi je ne crois pas qu'il y ait de bonne ou de mauvaise situation... »",
            explanation: "💡 Le monologue d'Otis (Édouard Baer) a été largement improvisé sur le tournage devant la caméra d'Alain Chabat.",
            audioCueID: "q_CINE_19"
        ),
        QuizMCQQuestion(
            id: "CINE_20",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Perfusion de caféine à Stars Hollow",
            prompt: "Dans la série culte « Gilmore Girls », quelle pancarte stricte est affichée derrière le comptoir du restaurant de Luke Danes (Luke's Diner) et que Lorelai ignore royalement tous les matins ?",
            choices: [
                "Interdit aux téléphones portables (No Cell Phones)",
                "Un seul café par personne",
                "Pas de blagues avant 10 heures",
                "Port de la chemise à carreaux obligatoire"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le fameux panneau « NO CELL PHONES » de Luke, sous sa casquette à l'envers !",
            explanation: "💡 Chez Luke's Diner à Stars Hollow, les téléphones portables sont formellement interdits — sauf quand Lorelai et Rory trichent !",
            audioCueID: "q_CINE_20"
        ),
        QuizMCQQuestion(
            id: "CINE_21",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "Meemaw résume le film : « Une lessive sauve un petit bonhomme à grandes oreilles »",
            prompt: "Dans « Harry Potter et la Chambre des Secrets », quel vêtement Harry glisse-t-il en douce dans le journal intime pour que Lucius Malefoy libère accidentellement son elfe de maison Dobby ?",
            choices: [
                "Son écharpe Gryffondor",
                "Une vieille chaussette sale et gluante",
                "Le slip en laine de Ron",
                "Un gant de Quidditch"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "« Le maître a donné une chaussette à Dobby ! Dobby est un elfe libre ! »",
            explanation: "💡 Un elfe de maison est libéré si son maître lui tend un vêtement : Harry piège Lucius Malefoy avec sa vieille chaussette.",
            audioCueID: "q_CINE_21"
        ),
        QuizMCQQuestion(
            id: "CINE_22",
            theme: .seriesCinema,
            preferredRound: .finaleDouble,
            funnyTitle: "Nouvelle émotion orange dans le quartier cérébral",
            prompt: "Dans le film d'animation « Vice-Versa 2 » (Inside Out 2) de Pixar, quelle nouvelle émotion toute orange à la coiffure ébouriffée débarque dans la tête de Riley à l'adolescence ?",
            choices: [
                "Anxiété",
                "Nostalgie",
                "Gourmandise",
                "Sieste"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Anxiété, avec ses six valises remplies de scénarios catastrophes !",
            explanation: "💡 Dans « Vice-Versa 2 » (2024), Anxiété, Envie, Ennui et Embarras rejoignent Joie, Tristesse, Colère, Peur et Dégoût.",
            audioCueID: "q_CINE_22"
        ),
        QuizMCQQuestion(
            id: "CINE_23",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Une main baladeuse très bien élevée",
            prompt: "Dans la série « Mercredi » (Wednesday) avec Jenna Ortega sur Netflix, comment s'appelle la main coupée vivante qui sert d'espionne et de meilleure amie à Mercredi Addams à l'académie Nevermore ?",
            choices: [
                "La Chose (Thing)",
                "Cousin Machin",
                "Cinq-Doigts",
                "La Manucure"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est La Chose ! Elle communique en claquant des doigts et fait même de meilleures coutures que Meemaw !",
            explanation: "💡 « La Chose » (Thing T. Thing), incarnée par le magicien Victor Dorobantu, veille sur Mercredi Addams à Nevermore.",
            audioCueID: "q_CINE_23"
        ),
        QuizMCQQuestion(
            id: "CINE_24",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Un baladeur cassette contre Vecna",
            prompt: "Dans la saison 4 de « Stranger Things », quelle chanson de 1985 de Kate Bush sauve Max de l'emprise de Vecna dans le Monde à l'Envers ?",
            choices: [
                "Running Up That Hill (A Deal with God)",
                "Wuthering Heights",
                "Sweet Dreams",
                "Girls Just Want to Have Fun"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « Running Up That Hill » de Kate Bush, revenue numéro 1 mondial 37 ans après sa sortie grâce à la série !",
            explanation: "💡 Grâce à cette scène mythique de Stranger Things 4, le titre de Kate Bush (1985) a dépassé le milliard d'écoutes en 2022.",
            audioCueID: "q_CINE_24"
        ),
        QuizMCQQuestion(
            id: "CINE_25",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Combinaison rouge et masque à moustaches",
            prompt: "Dans la série espagnole « La Casa de Papel », le masque porté par les braqueurs représente le visage de quel célèbre peintre surréaliste ?",
            choices: [
                "Salvador Dalí",
                "Pablo Picasso",
                "Vincent van Gogh",
                "Claude Monet"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Avec ses moustaches en pointes relevées vers le ciel, c'est Salvador Dalí !",
            explanation: "💡 Les braqueurs du Professeur portent une combinaison rouge et le masque à l'effigie du peintre catalan Salvador Dalí.",
            audioCueID: "q_CINE_25"
        ),
        QuizMCQQuestion(
            id: "CINE_26",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "Un rat sous la toque dans un grand restaurant parisien",
            prompt: "Dans le film d'animation « Ratatouille » de Pixar, comment s'appelle le petit rat gourmet qui rêve de devenir grand chef étoilé à Paris ?",
            choices: [
                "Rémy",
                "Linguini",
                "Gusteau",
                "Émile"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Le petit rat s'appelle Rémy ! Linguini, c'est le commis maladroit dont il tire les cheveux sous la toque !",
            explanation: "💡 Rémy guide Alfredo Linguini en tirant ses mèches de cheveux comme une marionnette dans les cuisines de chez Gusteau.",
            audioCueID: "q_CINE_26"
        ),
        QuizMCQQuestion(
            id: "CINE_27",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Le lionceau présenté au sommet du rocher",
            prompt: "Dans « Le Roi Lion » de Disney, comment s'appelle le vieux mandrill sage qui présente Simba aux animaux de la Terre des Lions ?",
            choices: [
                "Rafiki",
                "Zazu",
                "Timon",
                "Mufasa"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Rafiki (qui veut dire « ami » en swahili) avec son bâton à calebasses !",
            explanation: "💡 En swahili, Rafiki signifie « ami », Simba « lion » et Pumbaa « étourdi ».",
            audioCueID: "q_CINE_27"
        ),
        QuizMCQQuestion(
            id: "CINE_28",
            theme: .seriesCinema,
            preferredRound: .finaleDouble,
            funnyTitle: "La revanche d'Edmond Dantès au cinéma",
            prompt: "Quel acteur français incarne Edmond Dantès dans l'immense succès cinéma de 2024 « Le Comte de Monte-Cristo » (plus de 9 millions d'entrées) ?",
            choices: [
                "Pierre Niney",
                "François Civil",
                "Louis Garrel",
                "Tahar Rahim"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est Pierre Niney, grimé sous des heures de prothèses pour préparer sa vengeance au château d'If !",
            explanation: "💡 Sorti en juin 2024 et réalisé par Matthieu Delaporte et Alexandre de La Patellière, ce Monte-Cristo avec Pierre Niney a dépassé 9,4 millions d'entrées.",
            audioCueID: "q_CINE_28"
        )
    ]

    // MARK: - 4. 🎵 Musique & Tubes (16 QCM)

    public static let musiqueQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "MUS_01",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Les serviettes qui tournent à la fin du mariage",
            prompt: "Quel lac irlandais bien réel a inspiré l'introduction mythique de Michel Sardou à 2 heures du matin dans toutes les salles des fêtes de France ?",
            choices: [
                "Le Loch Ness",
                "Les Lacs du Connemara",
                "Le Lac d'Annecy",
                "Le Lac des Cygnes en bottes caoutchouc"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Terre brûlée au vent, des landes de pierres, autour des Lacs du Connemara !",
            explanation: "💡 Sortie en 1981, « Les Lacs du Connemara » a été composée avec un synthétiseur imitant des cornemuses écossaises.",
            audioCueID: "q_MUS_01"
        ),
        QuizMCQQuestion(
            id: "MUS_02",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            funnyTitle: "Deux robots casqués à Versailles",
            prompt: "Avant de devenir le duo casqué Daft Punk, comment s'appelait le tout premier groupe rock de Thomas Bangalter et Guy-Manuel de Homem-Christo — dont le nom venait d'une critique du journal Melody Maker ?",
            choices: [
                "Les Croissants Bioniques",
                "Darlin' (qualifié par le journal de « daft punky thrash » !)",
                "Air Baguette",
                "Téléphone Maison"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Ils s'appelaient Darlin' ! Et quand un journaliste anglais a écrit que c'était du « daft punky thrash », ils ont gardé Daft Punk !",
            explanation: "💡 En 1993, une critique qualifie le groupe « Darlin' » de « daft punky thrash » : le duo adopte aussitôt le nom Daft Punk !",
            audioCueID: "q_MUS_02"
        ),
        QuizMCQQuestion(
            id: "MUS_03",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "6 minutes sans refrain à secouer la tête dans la voiture",
            prompt: "En 1975, la maison de disques trouvait ce morceau de 5 minutes 55 de Queen « beaucoup trop long pour passer à la radio ». De quel chef-d'œuvre s'agit-il ?",
            choices: [
                "We Will Rock You",
                "Bohemian Rhapsody",
                "Radio Ga Ga",
                "La Danse des Canards"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Mamaaa, ooh-ooh-ooh ! C'est évidemment Bohemian Rhapsody de Freddie Mercury !",
            explanation: "💡 Malgré ses 5 min 55 mêlant ballade, opéra et hard rock, « Bohemian Rhapsody » est resté n°1 pendant 9 semaines au Royaume-Uni.",
            audioCueID: "q_MUS_03"
        ),
        QuizMCQQuestion(
            id: "MUS_04",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Alexandrie, ampoule et baignoire",
            prompt: "Dans le tube « Alexandrie Alexandra » (1978) de Claude François, que fait l'appétit du chanteur dans les paroles exactes ?",
            choices: [
                "J'ai plus d'appétit qu'un barracuda (Barracuda !)",
                "J'ai plus d'appétit qu'un piranha",
                "J'ai plus d'appétit qu'un cachalot",
                "J'ai mangé trois parts de clafoutis"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « J'ai plus d'appétit qu'un barracuda — Ba-rra-cu-da ! » écrit par Étienne Roda-Gil !",
            explanation: "💡 Les paroles d'« Alexandrie Alexandra » ont été signées par le parolier Étienne Roda-Gil.",
            audioCueID: "q_MUS_04"
        ),
        QuizMCQQuestion(
            id: "MUS_05",
            theme: .musiqueTubes,
            preferredRound: .finaleDouble,
            funnyTitle: "Marcher à reculons sur la Lune avec des chaussettes blanches",
            prompt: "Quel est l'album le plus vendu de toute l'histoire de la musique dans le monde (sorti en 1982 et produit par Quincy Jones) ?",
            choices: [
                "Back in Black (AC/DC)",
                "Thriller (Michael Jackson)",
                "The Dark Side of the Moon (Pink Floyd)",
                "L'Intégrale d'accordéon d'Yvette Horner"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Thriller de Michael Jackson, avec plus de 70 millions d'exemplaires vendus !",
            explanation: "💡 « Thriller » (1982) détient le record absolu des ventes mondiales avec 7 singles classés dans le Top 10.",
            audioCueID: "q_MUS_05"
        ),
        QuizMCQQuestion(
            id: "MUS_06",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Ella, elle l'a, ce je-ne-sais-quoi",
            prompt: "À quelle immense chanteuse de jazz américaine France Gall et Michel Berger rendent-ils hommage dans le tube « Ella, elle l'a » (1987) ?",
            choices: [
                "Billie Holiday",
                "Ella Fitzgerald",
                "Nina Simone",
                "Aretha Franklin"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Ella, c'est la grande Ella Fitzgerald, la reine du scat !",
            explanation: "💡 Michel Berger a composé « Ella, elle l'a » en hommage à la légende du jazz Ella Fitzgerald.",
            audioCueID: "q_MUS_06"
        ),
        QuizMCQQuestion(
            id: "MUS_07",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "L'album de Stromae qui met tout le monde d'accord",
            prompt: "Comment s'appelle l'album culte de Stromae sorti en 2013 qui contient à la fois « Papaoutai », « Formidable » et « Tous les mêmes » ?",
            choices: [
                "Cheese",
                "Racine carrée",
                "Multitude",
                "Hypotenuse"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « Racine carrée » (√), écoulé à plus de 2 millions d'exemplaires en France !",
            explanation: "💡 Sorti en 2013, « Racine carrée » est l'un des albums francophones les plus vendus du XXIe siècle.",
            audioCueID: "q_MUS_07"
        ),
        QuizMCQQuestion(
            id: "MUS_08",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            funnyTitle: "J'irai où tu iras, même sous les projecteurs",
            prompt: "Avec quel auteur-compositeur français Céline Dion chante-t-elle en duo « J'irai où tu iras » sur l'album « D'eux » (1995) ?",
            choices: [
                "Florent Pagny",
                "Jean-Jacques Goldman",
                "Francis Cabrel",
                "Garou"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Jean-Jacques Goldman, qui a écrit et composé tout l'album « D'eux » !",
            explanation: "💡 « D'eux » (1995), écrit par Jean-Jacques Goldman pour Céline Dion, reste l'album francophone le plus vendu de l'histoire.",
            audioCueID: "q_MUS_08"
        ),
        QuizMCQQuestion(
            id: "MUS_09",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Et dans 150 ans, on s'en souviendra pas",
            prompt: "Dans son tube « Djadja » (2018) écouté sur tous les continents, quelle expression popularisée par Aya Nakamura signifie « hors de question / même pas en rêve » ?",
            choices: [
                "Y'a pas moyen Djadja (en catchana baby tu dead ça)",
                "C'est la décadence",
                "Saperlipopette",
                "Zut de flûte"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Oh Djadja, y'a pas moyen Djadja ! Même Meemaw connaît la chorégraphie !",
            explanation: "💡 Sorti en 2018, « Djadja » d'Aya Nakamura a dépassé le milliard de streams dans le monde.",
            audioCueID: "q_MUS_09"
        ),
        QuizMCQQuestion(
            id: "MUS_10",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "4 garçons dans le vent sur un passage piéton",
            prompt: "Dans quelle ville anglaise se sont formés les Beatles (John, Paul, George et Ringo) ?",
            choices: [
                "Manchester",
                "Liverpool",
                "Londres",
                "Birmingham"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Ce sont les quatre garçons de Liverpool, habitués du Cavern Club !",
            explanation: "💡 Les Beatles se sont formés à Liverpool à la fin des années 1950 avant de conquérir la planète.",
            audioCueID: "q_MUS_10"
        ),
        QuizMCQQuestion(
            id: "MUS_11",
            theme: .musiqueTubes,
            preferredRound: .finaleDouble,
            funnyTitle: "Un deux trois, I Gotta Feeling !",
            prompt: "Quel DJ français a produit en 2009 le méga-tube planétaire « I Gotta Feeling » avec les Black Eyed Peas ?",
            choices: [
                "Bob Sinclar",
                "David Guetta",
                "DJ Snake",
                "Martin Solveig"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est David Guetta ! Le morceau est resté 14 semaines consécutives n°1 aux États-Unis !",
            explanation: "💡 Produit par David Guetta et Frédéric Riesterer, « I Gotta Feeling » est l'un des titres les plus téléchargés de l'histoire.",
            audioCueID: "q_MUS_11"
        ),
        QuizMCQQuestion(
            id: "MUS_12",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "La tribu bretonne qui réveille tout le camping",
            prompt: "Quel groupe breton a fait chanter toute la France en 1998 avec « La Tribu de Dana » (« Dans la vallée, oh-oh, de Dana, lalilala ») ?",
            choices: [
                "Matmatah",
                "Manau",
                "Louise Attaque",
                "Tri Yann"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le groupe de rap celtique Manau, sur l'air de la harpe d'Alan Stivell !",
            explanation: "💡 Sorti à l'été 1998, « La Tribu de Dana » de Manau s'est écoulé à plus de 1,7 million de singles.",
            audioCueID: "q_MUS_12"
        ),
        QuizMCQQuestion(
            id: "MUS_13",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            funnyTitle: "Allumez le feu au Stade de France",
            prompt: "Qui a écrit les paroles de l'hymne « Allumer le feu » (1998) interprété par Johnny Hallyday ?",
            choices: [
                "Michel Mallory",
                "Zazie (et composé par Pascal Obispo et Pierre Jaconelli !)",
                "Jean-Jacques Goldman",
                "Eddy Mitchell"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est Zazie qui a écrit les paroles (« Il suffira d'une étincelle... ») sur une musique de Pascal Obispo !",
            explanation: "💡 Zazie a signé le texte d'« Allumer le feu » pour le concert historique de Johnny au Stade de France en 1998.",
            audioCueID: "q_MUS_13"
        ),
        QuizMCQQuestion(
            id: "MUS_14",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Quatre prénoms qui forment une légende suédoise",
            prompt: "Que signifient les quatre lettres du groupe suédois « ABBA » (interprète de Dancing Queen et Mamma Mia) ?",
            choices: [
                "Les initiales des prénoms des 4 membres : Agnetha, Björn, Benny et Anni-Frid",
                "« Amour, Bonheur, Beauté, Accordéon » en suédois",
                "Le nom de leur rue à Stockholm",
                "Un modèle d'étagère IKEA"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "A-B-B-A : Agnetha, Björn, Benny et Anni-Frid ! Simple et efficace !",
            explanation: "💡 L'acronyme ABBA réunit les initiales d'Agnetha Fältskog, Björn Ulvaeus, Benny Andersson et Anni-Frid Lyngstad.",
            audioCueID: "q_MUS_14"
        ),
        QuizMCQQuestion(
            id: "MUS_15",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Je t'emmène au vent, je t'emmène au-dessus des gens",
            prompt: "Quel groupe mené par Gaëtan Roussel et son violon endiablé a sorti en 1997 « J't'emmène au vent » et « Ton invitation » ?",
            choices: [
                "Noir Désir",
                "Louise Attaque",
                "Indochine",
                "Téléphone"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Louise Attaque, avec le violon d'Arnaud Samuel qui met le feu aux soirées !",
            explanation: "💡 Le premier album éponyme de Louise Attaque (1997) s'est vendu à près de 3 millions d'exemplaires.",
            audioCueID: "q_MUS_15"
        ),
        QuizMCQQuestion(
            id: "MUS_16",
            theme: .musiqueTubes,
            preferredRound: .finaleDouble,
            funnyTitle: "Le moonwalk d'avant l'heure sur des talons",
            prompt: "En quelle année ABBA a-t-il remporté le concours de l'Eurovision avec la chanson « Waterloo » ?",
            choices: [
                "1968",
                "1974",
                "1981",
                "1989"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'était le 6 avril 1974 à Brighton, avec un chef d'orchestre déguisé en Napoléon !",
            explanation: "💡 La victoire d'ABBA à l'Eurovision 1974 avec « Waterloo » a lancé leur carrière mondiale.",
            audioCueID: "q_MUS_16"
        ),
        QuizMCQQuestion(
            id: "MUS_17",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "That's that me, un petit café serré !",
            prompt: "Quelle pop-star américaine de la Gen Z a fait danser toute la planète en 2024 avec son méga-tube « Espresso » (« Now he's thinkin' 'bout me every night, oh, is it that sweet? I guess so ! ») ?",
            choices: [
                "Sabrina Carpenter",
                "Ariana Grande",
                "Madison Beer",
                "Tate McRae"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Sabrina Carpenter ! Même Meemaw boit son déca en chantant « That's that me, Espresso » !",
            explanation: "💡 Sorti au printemps 2024 sur l'album « Short n' Sweet », « Espresso » de Sabrina Carpenter a dépassé le milliard d'écoutes en un temps record.",
            audioCueID: "q_MUS_17"
        ),
        QuizMCQQuestion(
            id: "MUS_18",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Apateu, Apateu ! Le refrain qui reste collé dans le cerveau",
            prompt: "Avec quelle chanteuse de K-Pop (membre du groupe BLACKPINK) Bruno Mars chante-t-il le tube planétaire « APT. » sorti fin 2024 ?",
            choices: [
                "ROSÉ",
                "Lisa",
                "Jennie",
                "Jisoo"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est ROSÉ de BLACKPINK avec Bruno Mars ! « Apateu, Apateu ! » inspiré d'un jeu coréen !",
            explanation: "💡 « APT. » (abréviation d'appartement en coréen, Apateu) réunit Rosé et Bruno Mars sur l'un des plus gros cartons mondiaux de 2024-2025.",
            audioCueID: "q_MUS_18"
        ),
        QuizMCQQuestion(
            id: "MUS_19",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            funnyTitle: "Les oiseaux qui volent ensemble jusqu'au bout",
            prompt: "Quel titre de Billie Eilish (issu de son album « Hit Me Hard and Soft » en 2024, co-écrit avec son frère Finneas) est devenu la chanson la plus écoutée de toute sa carrière ?",
            choices: [
                "Birds of a Feather",
                "Bad Guy",
                "Lunch",
                "What Was I Made For?"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est « Birds of a Feather » ! Un hymne magnifique qui a dépassé même Bad Guy en streaming !",
            explanation: "💡 « Birds of a Feather » (2024) de Billie Eilish a battu tous les records d'écoutes mondiales sur Spotify.",
            audioCueID: "q_MUS_19"
        ),
        QuizMCQQuestion(
            id: "MUS_20",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Le permis de conduire le plus triste de l'histoire de la pop",
            prompt: "Quelle jeune chanteuse a explosé mondialement à 17 ans en 2021 avec « drivers license », « good 4 u » et « vampire » ?",
            choices: [
                "Olivia Rodrigo",
                "Gracie Abrams",
                "Chappell Roan",
                "Camila Cabello"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Olivia Rodrigo et ses albums « SOUR » et « GUTS » !",
            explanation: "💡 Révélée dans la série High School Musical, Olivia Rodrigo a conquis la Gen Z dès son premier single « drivers license ».",
            audioCueID: "q_MUS_20"
        ),
        QuizMCQQuestion(
            id: "MUS_21",
            theme: .musiqueTubes,
            preferredRound: .finaleDouble,
            funnyTitle: "Les Swifties font littéralement trembler la Terre",
            prompt: "Lors de la tournée historique « The Eras Tour » de Taylor Swift à Seattle, qu'ont enregistré les sismologues américains pendant que 70 000 fans sautaient sur « Shake It Off » ?",
            choices: [
                "Une activité sismique équivalente à un tremblement de terre de magnitude 2,3 !",
                "Une coupure d'eau dans tout l'État",
                "Un envol de 10 000 pigeons",
                "Une panne de paillettes"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Le « Swift Quake » a atteint une magnitude de 2,3 sur l'échelle de Richter ! Mieux qu'un cours de zumba de Meemaw !",
            explanation: "💡 Les sismographes de Seattle ont officiellement baptisé « Swift Quake » la secousse de magnitude 2,3 générée par les fans de Taylor Swift.",
            audioCueID: "q_MUS_21"
        ),
        QuizMCQQuestion(
            id: "MUS_22",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Du château de Dammarie-les-Lys à toutes les radios",
            prompt: "Quel gagnant de la Star Academy a fait chanter toute la France en 2024 avec son tube « Ceux qu'on était » ?",
            choices: [
                "Pierre Garnier",
                "Héléna Bailly",
                "Julien Lieb",
                "Slimane"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Pierre Garnier ! Tout le monde connaissait déjà les paroles par cœur avant même sa sortie du château !",
            explanation: "💡 « Ceux qu'on était » de Pierre Garnier a été certifié single de diamant en quelques mois seulement en 2024.",
            audioCueID: "q_MUS_22"
        ),
        QuizMCQQuestion(
            id: "MUS_23",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Bruxelles je t'aime et Balance ton quoi",
            prompt: "Comment s'appelle le chien adoré de la chanteuse belge Angèle, qui apparaît sur la pochette de son album, dans ses clips et sur son compte Instagram ?",
            choices: [
                "Pépite",
                "Gaufrette",
                "Frite",
                "Chouquette"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Son chien s'appelle Pépite ! Une vraie star en Belgique et sur TikTok !",
            explanation: "💡 Pépite, le chien adopté par Angèle, possède même son propre compte Instagram suivi par des centaines de milliers de fans.",
            audioCueID: "q_MUS_23"
        ),
        QuizMCQQuestion(
            id: "MUS_24",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            funnyTitle: "Aveuglé par les néons à plus de 4 milliards d'écoutes",
            prompt: "Quelle chanson de The Weeknd (sortie fin 2019 avec un synthé façon années 80) détient le record absolu du titre le plus streamé de toute l'histoire de Spotify ?",
            choices: [
                "Blinding Lights",
                "Starboy",
                "Save Your Tears",
                "Shape of You"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est « Blinding Lights » de The Weeknd, avec plus de 4,5 milliards d'écoutes !",
            explanation: "💡 « Blinding Lights » de The Weeknd trône en tête des morceaux les plus écoutés de tous les temps sur Spotify.",
            audioCueID: "q_MUS_24"
        ),
        QuizMCQQuestion(
            id: "MUS_25",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Les lunettes noires les plus célèbres de France",
            prompt: "Quel chanteur aux lunettes noires indéboulonnables a enchaîné en 2024-2025 les méga-tubes « Spider », « Sois pas timide » et « Ciel » ?",
            choices: [
                "Gims",
                "Dadju",
                "Soprano",
                "Black M"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Gims ! « Spider », « Sois pas timide » et « Ciel » ont squatté la 1re place du Top Singles en France !",
            explanation: "💡 Gims a réalisé un triplé historique en classant « Spider », « Sois pas timide » et « Ciel » n°1 des écoutes en France.",
            audioCueID: "q_MUS_25"
        ),
        QuizMCQQuestion(
            id: "MUS_26",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Basique, simple : vous n'avez pas les bases !",
            prompt: "Quel rappeur normand répète « Simple, basique » dans son clip tourné en un seul plan-séquence sur un pont géant en Ukraine ?",
            choices: [
                "Orelsan",
                "Vald",
                "Nekfeu",
                "Bigflo & Oli"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Orelsan dans « Basique » (2017) ! Simple, basique !",
            explanation: "💡 Extrait de l'album « La fête est finie » d'Orelsan, « Basique » est devenu une réplique culte de toute une génération.",
            audioCueID: "q_MUS_26"
        ),
        QuizMCQQuestion(
            id: "MUS_27",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            funnyTitle: "La Symphonie des éclairs aux Victoires de la Musique",
            prompt: "Quelle jeune artiste française a remporté 4 Victoires de la Musique en 2024 avec son hymne électro-poétique « La Symphonie des éclairs » ?",
            choices: [
                "Zaho de Sagazan",
                "Santa",
                "Clara Luciani",
                "Juliette Armanet"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est Zaho de Sagazan ! « Il fait toujours beau au-dessus des nuages... »",
            explanation: "💡 Zaho de Sagazan a raflé 4 trophées aux Victoires de la Musique 2024 avant de chanter à la clôture des JO.",
            audioCueID: "q_MUS_27"
        ),
        QuizMCQQuestion(
            id: "MUS_28",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Dance the Night dans la maison de Barbie",
            prompt: "Quelle pop-star britannico-albanaise chante « Levitating », « Houdini » et le tube « Dance the Night » du film Barbie ?",
            choices: [
                "Dua Lipa",
                "Rita Ora",
                "Charli XCX",
                "Bebe Rexha"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Dua Lipa, qui joue même la Barbie Sirène aux cheveux bleus dans le film !",
            explanation: "💡 Dua Lipa a signé « Dance the Night » pour la bande originale de Barbie avant de sortir son album « Radical Optimism ».",
            audioCueID: "q_MUS_28"
        ),
        QuizMCQQuestion(
            id: "MUS_29",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Le signe des deux mains à Marseille",
            prompt: "Quel rappeur marseillais surnommé « l'Ovni » est devenu le plus gros vendeur d'albums de toute l'histoire du rap français (et a allumé le chaudron olympique à Marseille) ?",
            choices: [
                "Jul",
                "SCH",
                "Soprano",
                "Akhenaton"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Jul, le J ! Avec « Bande organisée » (« En bande organisée, personne peut nous canaliser ! ») !",
            explanation: "💡 Avec plus de 7 millions d'albums vendus, Jul détient le record absolu du rap français.",
            audioCueID: "q_MUS_29"
        ),
        QuizMCQQuestion(
            id: "MUS_30",
            theme: .musiqueTubes,
            preferredRound: .finaleDouble,
            funnyTitle: "Salto arrière sur le piano et voix surpuissante",
            prompt: "Quel jeune chanteur américain célèbre pour ses saltos arrière sur scène a explosé en 2024 avec le tube « Beautiful Things » (« Please stay, I want you, I need you, oh God ! ») ?",
            choices: [
                "Benson Boone",
                "Shawn Mendes",
                "Harry Styles",
                "Teddy Swims"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est Benson Boone ! Si Meemaw tente son salto arrière depuis le piano, appelez les pompiers !",
            explanation: "💡 « Beautiful Things » de Benson Boone a été le single le plus écouté dans le monde en 2024 selon l'IFPI.",
            audioCueID: "q_MUS_30"
        ),
        QuizMCQQuestion(
            id: "MUS_31",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "H-O-T-T-O-G-O ! La chorégraphie façon YMCA de la Gen Z",
            prompt: "Quelle chanteuse pop américaine au look flamboyant a enflammé TikTok et les festivals en 2024 avec « Good Luck, Babe! » et « HOT TO GO! » ?",
            choices: [
                "Chappell Roan",
                "Sabrina Carpenter",
                "Reneé Rapp",
                "Lana Del Rey"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Chappell Roan, sacrée révélation pop de l'année aux Grammy Awards !",
            explanation: "💡 Chappell Roan a transformé ses concerts en géantes chorégraphies collectives sur « HOT TO GO! » et « Good Luck, Babe! ».",
            audioCueID: "q_MUS_31"
        ),
        QuizMCQQuestion(
            id: "MUS_32",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            funnyTitle: "Du pop-corn salé et un piano en flammes",
            prompt: "Quelle chanteuse française (ex-leader du groupe Hyphen Hyphen) a ému toute la France avec sa ballade au piano « Popcorn salé » et son tube « Recommence-moi » ?",
            choices: [
                "Santa",
                "Pomme",
                "Louane",
                "Hoshi"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Santa ! Avec son piano suspendu dans les airs et son hymne « Recommence-moi » !",
            explanation: "💡 Samanta Cotta, dite Santa, a triomphé en solo avec « Popcorn salé » et « Recommence-moi » (hymne de la Star Academy 2024).",
            audioCueID: "q_MUS_32"
        ),
        QuizMCQQuestion(
            id: "MUS_33",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            funnyTitle: "L'Hymne à l'amour du haut du 1er étage de la Tour Eiffel",
            prompt: "Quelle légende de la chanson a clôturé la cérémonie d'ouverture des Jeux Olympiques de Paris 2024 en chantant « L'Hymne à l'amour » d'Édith Piaf depuis la Tour Eiffel sous la pluie ?",
            choices: [
                "Céline Dion",
                "Lady Gaga",
                "Aya Nakamura",
                "Mireille Mathieu"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était le grand retour historique de Céline Dion au premier étage de la Tour Eiffel !",
            explanation: "💡 Le 26 juillet 2024, Céline Dion a signé son retour sur scène en direct de la Tour Eiffel devant plus d'un milliard de téléspectateurs.",
            audioCueID: "q_MUS_33"
        ),
        QuizMCQQuestion(
            id: "MUS_34",
            theme: .musiqueTubes,
            preferredRound: .finaleDouble,
            funnyTitle: "Trois nuits par semaine avec Bob Morane",
            prompt: "Quel groupe de rock français mené par Nicola Sirkis depuis 1981 a chanté « L'Aventurier », « 3 Nuits par semaine » et « J'ai demandé à la lune » ?",
            choices: [
                "Indochine",
                "Téléphone",
                "Cure",
                "Dépêche Mode"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Indochine ! Le seul groupe qui fait chanter ensemble les grands-parents, les parents et les ados !",
            explanation: "💡 Fondé en 1981, Indochine détient les records d'affluence dans les stades français.",
            audioCueID: "q_MUS_34"
        ),
        // MARK: - 🎧 Jukebox Express : Paroles Coupées & Hitster (12 QCM)
        QuizMCQQuestion(
            id: "JUK_01",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Gims — « Spider »",
            prompt: "Complète les paroles exactes du tube « Spider » de Gims & Dystinct quand la musique coupe : « Elle m'a dit : chéri, t'es ___ ... »",
            choices: [
                "« ... t'es mignon mais t'es pas mon style ! »",
                "« ... t'esSpider-Man sur le plafond ! »",
                "« ... t'es gentil mais t'as pas un rond ! »",
                "« ... t'es beau mais t'as mis des claquettes ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Elle m'a dit : chéri, t'es mignon mais t'es pas mon style ! » Tout le monde l'a chanté tout l'été !",
            explanation: "💡 Tube numéro 1 de l'été 2024 signé Gims et Dystinct.",
            audioCueID: "q_JUK_01"
        ),
        QuizMCQQuestion(
            id: "JUK_02",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Pierre Garnier — « Ceux qu'on était »",
            prompt: "Complète le refrain que toute la France chante à tue-tête : « On garde le meilleur de ceux qu'on était, ___ ... »",
            choices: [
                "« ... je t'aimerai toujours même si c'est plus jamais ! »",
                "« ... on oubliera le reste au fond du café ! »",
                "« ... même si demain on change de quartier ! »",
                "« ... promis juré j'ai rangé ma chambre ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « On garde le meilleur de ceux qu'on était, je t'aimerai toujours même si c'est plus jamais » !",
            explanation: "💡 L'hymne de Pierre Garnier est devenu disque de diamant en un temps record.",
            audioCueID: "q_JUK_02"
        ),
        QuizMCQQuestion(
            id: "JUK_03",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Sabrina Carpenter — « Espresso »",
            prompt: "Complète la phrase culte du refrain d'« Espresso » de Sabrina Carpenter : « Now he's thinkin' 'bout me every night, oh, is it that sweet? I guess so... ___ »",
            choices: [
                "« Say you can't sleep, baby, I know — that's that me, espresso ! »",
                "« Drink your coffee with a croissant, espresso ! »",
                "« Wake me up at seven o'clock, espresso ! »",
                "« Put some sugar in the cup, espresso ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Say you can't sleep, baby, I know, that's that me, espresso ! » Demande à la fille de Chabi, elle la connaît par cœur !",
            explanation: "💡 Le refrain d'« Espresso » (2024) de Sabrina Carpenter est devenu l'un des plus viraux de la décennie.",
            audioCueID: "q_JUK_03"
        ),
        QuizMCQQuestion(
            id: "JUK_04",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Indochine — « J'ai demandé à la lune »",
            prompt: "Que répond la Lune dans la chanson d'Indochine : « J'ai demandé à la lune, et le soleil ne le sait pas, je lui ai montré mes brûlures... ___ » ?",
            choices: [
                "« ... et la lune s'est moquée de moi ! »",
                "« ... et la lune m'a mis du Biafine ! »",
                "« ... et la lune a pleuré tout bas ! »",
                "« ... et la lune s'est couchée trop tard ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Et la lune s'est moquée de moi ! » Sorti en 2002 sur l'album Paradize !",
            explanation: "💡 Écrite par Mickaël Furnon (Mickey 3D) pour Indochine en 2002.",
            audioCueID: "q_JUK_04"
        ),
        QuizMCQQuestion(
            id: "JUK_05",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Stromae — « Papaoutai »",
            prompt: "Complète le couplet d'ouverture de « Papaoutai » de Stromae : « Dites-moi d'où il vient, enfin je saurai où je vais, Maman dit que lorsqu'on cherche bien... ___ »",
            choices: [
                "« ... on finit toujours par trouver ! »",
                "« ... c'est rangé derrière le canapé ! »",
                "« ... faut demander à Meemaw où il est ! »",
                "« ... on tombe sur ses vieilles chaussettes ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Maman dit que lorsqu'on cherche bien, on finit toujours par trouver ! »",
            explanation: "💡 « Papaoutai » (2013) ouvre l'album « Racine carrée » de Stromae.",
            audioCueID: "q_JUK_05"
        ),
        QuizMCQQuestion(
            id: "JUK_06",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Céline Dion — « Pour que tu m'aimes encore »",
            prompt: "Complète les paroles écrites par Jean-Jacques Goldman : « J'irai chercher ton cœur si tu l'emportes ailleurs, même si dans tes danses... ___ »",
            choices: [
                "« ... d'autres dansent tes heures ! »",
                "« ... d'autres marchent sur mes pieds ! »",
                "« ... tu oublies les paroles ! »",
                "« ... d'autres chantent en chœur ! »"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Attention au piège du yaourt : c'est « même si dans tes danses, d'autres dansent tes heures » !",
            explanation: "💡 Tout le monde marmonne cette phrase, mais le texte exact de Goldman est bien « d'autres dansent tes heures ».",
            audioCueID: "q_JUK_06"
        ),
        QuizMCQQuestion(
            id: "JUK_07",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Angèle — « Balance ton quoi »",
            prompt: "Complète le refrain d'Angèle : « Donc laisse-moi te chanter d'aller te faire en... Hein, je passerai pas à la radio... ___ »",
            choices: [
                "« ... parce que mes mots ne sont pas très beaux ! »",
                "« ... parce que j'ai oublié mon micro ! »",
                "« ... parce que mon chien Pépite aboie trop ! »",
                "« ... parce que la chanson va trop vite ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Parce que mes mots ne sont pas très beaux ! » Extrait de son album Brol !",
            explanation: "💡 Sorti en 2019 sur l'album « Brol », le titre d'Angèle joue avec l'autocensure radio.",
            audioCueID: "q_JUK_07"
        ),
        QuizMCQQuestion(
            id: "JUK_08",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Manau — « La Tribu de Dana »",
            prompt: "Complète la toute première phrase du couplet de Manau que tout le monde attaque à fond : « Le vent souffle sur les plaines de la Bretagne armoricaine, je jette un dernier regard... ___ »",
            choices: [
                "« ... sur ma femme, mon fils et mon domaine ! »",
                "« ... sur ma crêpe, mon cidre et ma baleine ! »",
                "« ... sur mon épée et mon dolmen ! »",
                "« ... sur mon cheval et mabedaine ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Sur ma femme, mon fils et mon domaine ! Akim, le fils du forgeron, est venu me chercher ! »",
            explanation: "💡 Classique absolu de l'été 1998 que 99 % des Français connaissent dès la première note de harpe.",
            audioCueID: "q_JUK_08"
        ),
        QuizMCQQuestion(
            id: "JUK_09",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Hitster de Meemaw : Qui est sorti EN PREMIER ?",
            prompt: "Parmi ces quatre énormes tubes francophones, lequel est sorti le PLUS TÔT (en premier dans le temps) ?",
            choices: [
                "« Alors on danse » de Stromae (2009)",
                "« Djadja » d'Aya Nakamura (2018)",
                "« Balance ton quoi » d'Angèle (2018)",
                "« Bande organisée » de Jul & Marseille (2020)"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Alors on danse » de Stromae est sorti dès septembre 2009, presque 10 ans avant Djadja et Balance ton quoi !",
            explanation: "💡 Chronologie : Alors on danse (2009) → Djadja (2018) → Balance ton quoi (2018) → Bande organisée (2020).",
            audioCueID: "q_JUK_09"
        ),
        QuizMCQQuestion(
            id: "JUK_10",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Aya Nakamura — « Pookie »",
            prompt: "Complète le refrain ultra-connu de « Pookie » d'Aya Nakamura : « Blah, blah, blah de la pookie, ___ ! »",
            choices: [
                "« Ferme la porte, t'as la pookie dans le sas ! »",
                "« Mange un cookie dans la tasse ! »",
                "« Ouvre la fenêtre, il fait trop chaud ! »",
                "« Appelle Meemaw, y'a plus de glace ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Ferme la porte, t'as la pookie dans le sas ! » (Et non pas « dans le sac » ou « dans la glace » !)",
            explanation: "💡 L'une des phrases les plus déformées en soirée : Aya chante bien « t'as la pookie dans le sas » !",
            audioCueID: "q_JUK_10"
        ),
        QuizMCQQuestion(
            id: "JUK_11",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Zaho de Sagazan — « La Symphonie des éclairs »",
            prompt: "Complète le refrain poétique de Zaho de Sagazan : « Il fait toujours beau au-dessus des nuages, mais moi, si j'étais un oiseau... ___ »",
            choices: [
                "« ... j'irais danser sous l'orage ! »",
                "« ... je mangerais tout le fromage ! »",
                "« ... je partirais en voyage ! »",
                "« ... je dormirais sur la plage ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Mais moi, si j'étais un oiseau, j'irais danser sous l'orage ! »",
            explanation: "💡 Chanson sacrée meilleure chanson originale aux Victoires de la Musique 2024.",
            audioCueID: "q_JUK_11"
        ),
        QuizMCQQuestion(
            id: "JUK_12",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Paroles Coupées : Diam's — « La Boulette »",
            prompt: "Complète cette ouverture légendaire du rap français que toute une génération connaît par cœur : « Il y a comme un goût d'aigreur chez les jeunes de l'an 2000... ___ »",
            choices: [
                "« ... ça parle d'intégration mais ça nous pousse à l'exil ! »",
                "« ... j'écoute du Kyo et je pleure dans mon lit ! »",
                "« ... j'ai plus de forfait sur mon Nokia 3310 ! »",
                "« ... laisse-moi kiffer la vibe avec mon mec ! »"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est « La Boulette (Génération nan nan) » de Diam's sortie en 2006 sur l'album Dans ma bulle !",
            explanation: "💡 « La Boulette » et « Confessions nocturnes » (2006) de Diam's restent des classiques absolus des blind-tests.",
            audioCueID: "q_JUK_12"
        )
    ]

    // MARK: - 5. 🌍 Culture G & Insolite (16 QCM)

    public static let cultureGQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "CUL_01",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "Trois cœurs qui battent sous les tentacules",
            prompt: "Combien de cœurs possède une pieuvre (et de quelle couleur est son sang) ?",
            choices: [
                "1 cœur et du sang rouge comme nous",
                "3 cœurs et du sang bleu !",
                "8 cœurs (un dans chaque tentacule)",
                "Aucun cœur, elle fonctionne à l'eau salée"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Une pieuvre a 3 cœurs et du sang bleu à base de cuivre (l'hémocyanine) !",
            explanation: "💡 Le poulpe possède 2 cœurs branchiaux + 1 cœur systémique, et son sang riche en cuivre est bleu.",
            audioCueID: "q_CUL_01"
        ),
        QuizMCQQuestion(
            id: "CUL_02",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            funnyTitle: "La Tour Eiffel prend des centimètres l'été",
            prompt: "En plein été, sous l'effet de la chaleur et de la dilatation du fer puddlé, de combien la Tour Eiffel peut-elle grandir par rapport à l'hiver ?",
            choices: [
                "Elle ne bouge pas d'un millimètre",
                "D'environ 12 à 15 centimètres !",
                "De 4 mètres",
                "Elle rétrécit parce qu'elle transpire"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Avec la dilatation thermique du métal, la Dame de Fer prend environ 15 centimètres de hauteur en été !",
            explanation: "💡 Entre -10 °C l'hiver et +35 °C l'été, la dilatation thermique fait varier la hauteur de la Tour Eiffel d'environ 15 cm.",
            audioCueID: "q_CUL_02"
        ),
        QuizMCQQuestion(
            id: "CUL_03",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "Des crottes cubiques pour ne pas rouler dans la pente",
            prompt: "Quel animal australien est le SEUL au monde à faire des crottes en forme de petits cubes parfaits (comme des dés à jouer) ?",
            choices: [
                "Le kangourou roux",
                "Le wombat",
                "L'ornithorynque",
                "Le koala sous caféine"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est le wombat ! Ses crottes cubiques lui permettent de marquer son territoire sur les rochers sans qu'elles roulent !",
            explanation: "💡 L'intestin du wombat moule ses déjections en cubes, une découverte qui a même reçu le prix Ig-Nobel de physique !",
            audioCueID: "q_CUL_03"
        ),
        QuizMCQQuestion(
            id: "CUL_04",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "Cléopâtre, plus proche d'Apollo 11 que de Khéops",
            prompt: "Laquelle de ces deux affirmations historiques sur la reine Cléopâtre VII (née en 69 av. J.-C.) est rigoureusement vraie ?",
            choices: [
                "Elle a supervisé la pose de la dernière pierre de la Grande Pyramide",
                "Elle a vécu plus près dans le temps du premier pas sur la Lune (1969) que de la construction de la Grande Pyramide de Khéops !",
                "Elle parlait uniquement le latin",
                "Elle a inventé le grille-pain solaire"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Eh oui ! Khéops date d'environ 2560 av. J.-C. (2 500 ans avant Cléopâtre), alors qu'Apollo 11 n'est que 2 000 ans après elle !",
            explanation: "💡 2 490 ans séparent Khéops de Cléopâtre, contre seulement 1 999 ans entre la mort de Cléopâtre (30 av. J.-C.) et Apollo 11 (1969).",
            audioCueID: "q_CUL_04"
        ),
        QuizMCQQuestion(
            id: "CUL_05",
            theme: .cultureGInsolite,
            preferredRound: .finaleDouble,
            funnyTitle: "Le pot de miel oublié au fond du placard de Toutânkhamon",
            prompt: "Quel aliment naturel trouvé dans des tombes égyptiennes de 3 000 ans est toujours parfaitement comestible car il ne périme jamais ?",
            choices: [
                "Le beurre demi-sel",
                "Le miel",
                "Le yaourt aux fraises",
                "Le camembert au lait cru"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le miel ! Très pauvre en eau et naturellement acide, aucune bactérie ne peut s'y développer !",
            explanation: "💡 Grâce à sa très faible teneur en eau et à son pH acide, le miel pur se conserve des millénaires.",
            audioCueID: "q_CUL_05"
        ),
        QuizMCQQuestion(
            id: "CUL_06",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "La planète qui tourne à l'envers comme l'oncle Gérard",
            prompt: "Sur quelle planète de notre système solaire le Soleil se lève-t-il à l'Ouest et se couche-t-il à l'Est, et où un jour dure plus longtemps qu'une année ?",
            choices: [
                "Mars",
                "Vénus",
                "Jupiter",
                "Mercure"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est Vénus ! Elle tourne à l'envers (rotation rétrograde) et si lentement que son jour (243 jours terrestres) est plus long que son année (225 jours) !",
            explanation: "💡 Vénus a une rotation rétrograde très lente : un jour vénusien dure 243 jours terrestres contre 225 jours pour faire le tour du Soleil.",
            audioCueID: "q_CUL_06"
        ),
        QuizMCQQuestion(
            id: "CUL_07",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "La frontière terrestre la plus longue de la France",
            prompt: "Avec quel pays la France partage-t-elle sa plus longue frontière terrestre (730 kilomètres) ?",
            choices: [
                "L'Espagne",
                "Le Brésil (via la Guyane française !)",
                "La Belgique",
                "L'Allemagne"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est le Brésil ! Grâce à la Guyane française, la frontière franco-brésilienne fait 730 km, devant l'Espagne (623 km) et la Belgique (620 km) !",
            explanation: "💡 La frontière entre la Guyane française et le Brésil mesure 730 km, ce qui en fait la plus longue frontière terrestre française.",
            audioCueID: "q_CUL_07"
        ),
        QuizMCQQuestion(
            id: "CUL_08",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            funnyTitle: "La fraise qui se prend pour un fruit",
            prompt: "En botanique pure, où se trouvent les VRAIS fruits de la fraise ?",
            choices: [
                "Dans la chair rouge juteuse",
                "Ce sont les petits grains jaunes croquants à la surface (les akènes) !",
                "Dans la feuille verte sur le dessus",
                "Sous la terre comme une patate"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "La partie rouge n'est que le réceptacle floral gonflé ! Les vrais fruits sont les petits grains jaunes appelés akènes !",
            explanation: "💡 La fraise est un « faux-fruit » : chaque petit grain jaune (akène) à sa surface est en réalité un fruit individuel contenant une graine.",
            audioCueID: "q_CUL_08"
        ),
        QuizMCQQuestion(
            id: "CUL_09",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "L'inventeur de la barbe à papa avait une drôle de profession",
            prompt: "Quel était le vrai métier de William Morrison, qui a co-inventé la machine à barbe à papa en 1897 ?",
            choices: [
                "Coiffeur pour caniches",
                "Dentiste !",
                "Fabricant d'oreillers",
                "Pompier"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Il était dentiste ! De quoi s'assurer des clients avec des caries pour les 50 années suivantes !",
            explanation: "💡 Le dentiste américain William Morrison et le confiseur John C. Wharton ont breveté la machine à barbe à papa (« Fairy Floss ») en 1897.",
            audioCueID: "q_CUL_09"
        ),
        QuizMCQQuestion(
            id: "CUL_10",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "L'animal national officiel de l'Écosse",
            prompt: "Quel animal totalement légendaire est pourtant l'emblème national OFFICIEL de l'Écosse depuis le XIVe siècle ?",
            choices: [
                "Le monstre du Loch Ness",
                "La licorne !",
                "Le mouton à lunettes",
                "Le hérisson"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est la licorne ! Dans le folklore celtique, elle symbolise la pureté, la fierté et l'indomptabilité !",
            explanation: "💡 La licorne figure sur les armoiries royales d'Écosse depuis la fin du XIVe siècle.",
            audioCueID: "q_CUL_10"
        ),
        QuizMCQQuestion(
            id: "CUL_11",
            theme: .cultureGInsolite,
            preferredRound: .finaleDouble,
            funnyTitle: "Nintendo au temps des calèches",
            prompt: "En 1889 (il y a plus de 135 ans !), que fabriquait l'entreprise japonaise Nintendo lors de sa création à Kyoto ?",
            choices: [
                "Des sabres de samouraï en bois",
                "Des cartes à jouer traditionnelles peintes à la main (les Hanafuda)",
                "Des théières en fonte",
                "Des vélos à trois roues"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Fusajiro Yamauchi a fondé Nintendo en 1889 pour fabriquer des cartes à jouer fleuries appelées Hanafuda !",
            explanation: "💡 Fondée le 23 septembre 1889, Nintendo a produit des cartes à jouer pendant plus de 80 ans avant le jeu vidéo.",
            audioCueID: "q_CUL_11"
        ),
        QuizMCQQuestion(
            id: "CUL_12",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "Le cri du canard dans la salle de bain",
            prompt: "Quelle légende urbaine sur le « coin-coin » du canard a été formellement démentie par des acousticiens en laboratoire ?",
            choices: [
                "Qu'il ne produit jamais d'écho (c'est faux : le coin-coin a bien un écho comme tous les sons !)",
                "Qu'il fait bouillir l'eau",
                "Qu'il s'entend depuis l'espace",
                "Qu'il est en ré mineur"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "On entend partout que le cri du canard n'a pas d'écho, mais c'est un mythe : dans une cathédrale, le canard résonne très bien !",
            explanation: "💡 L'université de Salford a prouvé en chambre réverbérante que le canard produit bel et bien un écho.",
            audioCueID: "q_CUL_12"
        ),
        QuizMCQQuestion(
            id: "CUL_13",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            funnyTitle: "La boîte noire de l'avion qui n'est pas noire",
            prompt: "De quelle couleur sont peintes les « boîtes noires » (enregistreurs de vol) des avions de ligne modernes ?",
            choices: [
                "Noir mat",
                "Orange vif fluorescent (pour les repérer facilement dans les débris ou sous l'eau !)",
                "Blanc nacré",
                "Bleu marine"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Elles sont peintes en « International Orange » ultra-vif avec des bandes réfléchissantes !",
            explanation: "💡 Appelées « boîtes noires » par la presse dans les années 1950, elles sont en réalité orange fluo pour faciliter les recherches.",
            audioCueID: "q_CUL_13"
        ),
        QuizMCQQuestion(
            id: "CUL_14",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "La guerre éclair de 38 minutes chrono",
            prompt: "Combien de temps a duré la guerre la plus courte de toute l'Histoire (entre le Royaume-Uni et le sultanat de Zanzibar le 27 août 1896) ?",
            choices: [
                "Entre 38 et 45 minutes (le temps de boire le thé !)",
                "3 jours",
                "12 heures",
                "Une semaine"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Commencée à 9 h 02 et terminée à 9 h 40, elle n'a duré que 38 minutes !",
            explanation: "💡 La guerre anglo-zanzibarienne du 27 août 1896 détient le record Guinness de la guerre la plus courte de l'Histoire (38 minutes).",
            audioCueID: "q_CUL_14"
        ),
        QuizMCQQuestion(
            id: "CUL_15",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "Dormir en se tenant par la patte",
            prompt: "Pourquoi les loutres de mer dorment-elles sur le dos en se tenant la patte les unes aux autres ?",
            choices: [
                "Pour ne pas dériver séparément avec le courant pendant leur sommeil",
                "Pour jouer à Jacques a dit",
                "Pour se réchauffer les griffes",
                "Parce qu'elles ont peur du noir"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Elles se tiennent la patte (ou s'enroulent dans les algues) pour ne pas être séparées par les courants marins en dormant !",
            explanation: "💡 Ce comportement appelé « radeau de loutres » évite au groupe de dériver au large pendant la nuit.",
            audioCueID: "q_CUL_15"
        ),
        QuizMCQQuestion(
            id: "CUL_16",
            theme: .cultureGInsolite,
            preferredRound: .finaleDouble,
            funnyTitle: "L'os humain plus solide que le béton",
            prompt: "Quel est l'os le plus long, le plus lourd et le plus solide du corps humain ?",
            choices: [
                "L'humérus (dans le bras)",
                "Le fémur (dans la cuisse)",
                "Le tibia",
                "La mâchoire quand Meemaw croque du nougat dur"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le fémur ! Il peut supporter une pression verticale de plus d'une tonne !",
            explanation: "💡 Le fémur représente environ un quart de la taille d'un adulte et est l'os le plus résistant du squelette.",
            audioCueID: "q_CUL_16"
        ),
        QuizMCQQuestion(
            id: "CUL_17",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "L'animal qui retient son souffle mieux qu'un sous-marin",
            prompt: "Entre le grand dauphin et le paresseux à trois doigts, lequel peut retenir sa respiration le plus longtemps sous l'eau ?",
            choices: [
                "Le paresseux (jusqu'à 40 minutes en ralentissant son cœur !)",
                "Le dauphin (jusqu'à 3 heures)",
                "Ils coulent tous les deux",
                "Le caniche de Meemaw"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Incroyable mais vrai : un dauphin remonte respirer toutes les 10 minutes, alors que le paresseux ralentit son rythme cardiaque et tient 40 minutes sous l'eau !",
            explanation: "💡 En ralentissant son métabolisme au tiers de la normale, le paresseux peut retenir son souffle 40 minutes sous l'eau !",
            audioCueID: "q_CUL_17"
        ),
        QuizMCQQuestion(
            id: "CUL_18",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            funnyTitle: "Le pays qui compte le plus de fuseaux horaires au monde",
            prompt: "Quel pays détient le record mondial du plus grand nombre de fuseaux horaires différents (12 fuseaux horaires) ?",
            choices: [
                "La France (grâce à ses territoires d'outre-mer sur tous les océans !)",
                "La Russie",
                "Les États-Unis",
                "La Chine"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est la France avec 12 fuseaux horaires grâce aux outre-mer (Polynésie, Antilles, Réunion, Nouvelle-Calédonie...), devant la Russie et les États-Unis (11) !",
            explanation: "💡 Grâce à sa présence dans tous les océans du globe, la République française couvre 12 fuseaux horaires (tandis que la Chine n'en utilise qu'un seul !).",
            audioCueID: "q_CUL_18"
        ),
        QuizMCQQuestion(
            id: "CUL_19",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "Pourquoi les flamants roses ne naissent pas roses",
            prompt: "De quelle couleur naissent les bébés flamants roses, et qu'est-ce qui leur donne leur plumage rose vif en grandissant ?",
            choices: [
                "Ils naissent gris-blanc et deviennent roses grâce aux pigments (caroténoïdes) des petites crevettes et algues qu'ils mangent",
                "Ils naissent déjà rose fluo",
                "Ils bronzent au soleil de Camargue",
                "Leur maman les peint avec du sirop de grenadine"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Ils naissent tout gris ! Ce sont les caroténoïdes contenus dans les crevettes artémies qui colorent leurs plumes en rose !",
            explanation: "💡 Sans l'astaxanthine présente dans les crustacés et micro-algues qu'ils filtrent, les flamants redeviendraient blancs.",
            audioCueID: "q_CUL_19"
        ),
        QuizMCQQuestion(
            id: "CUL_20",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "La bêtise qui a donné naissance aux chips",
            prompt: "En 1853 à Saratoga Springs, pourquoi le chef George Crum a-t-il coupé ses pommes de terre en tranches fines comme du papier et les a frites jusqu'à les rendre ultra-croquantes ?",
            choices: [
                "Pour se venger d'un client pénible qui avait renvoyé son assiette en trouvant ses frites « trop épaisses et trop molles » !",
                "Parce qu'il avait cassé son couteau",
                "Pour nourrir son perroquet",
                "Parce qu'il n'avait plus d'eau pour faire de la purée"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Il voulait donner une leçon à un client capricieux en rendant les patates impossibles à piquer à la fourchette... et le client a adoré !",
            explanation: "💡 Selon la légende culinaire de Saratoga, George Crum a tranché ses pommes de terre ultra-fines par défi, inventant ainsi les « Saratoga Chips ».",
            audioCueID: "q_CUL_20"
        ),
        QuizMCQQuestion(
            id: "CUL_21",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            funnyTitle: "Combien d'arbres sur Terre par rapport aux étoiles de la Voie lactée ?",
            prompt: "Y a-t-il plus d'arbres sur la planète Terre ou plus d'étoiles dans toute notre galaxie (la Voie lactée) ?",
            choices: [
                "Beaucoup plus d'arbres sur Terre (environ 3 000 milliards d'arbres contre 100 à 400 milliards d'étoiles !)",
                "Beaucoup plus d'étoiles dans la Voie lactée",
                "Exactement le même nombre",
                "Moins d'un million des deux"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Il y a environ 10 fois plus d'arbres sur Terre (3 000 milliards) que d'étoiles dans la Voie lactée (environ 200 à 400 milliards) !",
            explanation: "💡 Une étude publiée dans la revue Nature recense ~3 040 milliards d'arbres sur Terre, bien au-dessus des 100 à 400 milliards d'étoiles de notre galaxie.",
            audioCueID: "q_CUL_21"
        ),
        QuizMCQQuestion(
            id: "CUL_22",
            theme: .cultureGInsolite,
            preferredRound: .finaleDouble,
            funnyTitle: "Le chocolat fondu dans la poche du radar",
            prompt: "Comment l'ingénieur américain Percy Spencer a-t-il découvert par hasard le principe du four à micro-ondes en 1945 ?",
            choices: [
                "Une barre chocolatée a fondu toute seule dans sa poche alors qu'il travaillait devant un magnétron de radar militaire !",
                "Son chat s'est mis à briller dans le noir",
                "Sa tasse de café s'est transformée en glaçon",
                "Il voulait sécher ses chaussettes mouillées"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Sa barre chocolatée aux cacahuètes a fondu dans sa poche devant le radar ! Il a tout de suite testé avec du maïs à pop-corn !",
            explanation: "💡 Après sa barre chocolatée fondue, le premier aliment volontairement cuit au micro-ondes par Percy Spencer fut du pop-corn !",
            audioCueID: "q_CUL_22"
        )
    ]

    // MARK: - 6. 💰 Éco & Cash Perso (Esprit RushTiVi × Meemaw — 16 QCM)

    public static let ecoCashQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "ECO_01",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Albert Einstein et le bas de laine de Meemaw",
            prompt: "Avec un rendement moyen de 8 % par an, combien d'années faut-il pour DOUBLER ton capital sans rien rajouter grâce à la fameuse « Règle de 72 » ?",
            choices: [
                "4 ans chrono",
                "9 ans (72 ÷ 8)",
                "18 ans",
                "30 ans"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Tu divises 72 par 8 et ça fait 9 ans mon bichon ! C'est la magie des intérêts composés !",
            explanation: "💡 Règle de 72 : divise 72 par ton rendement annuel (72 ÷ 8 = 9 ans) pour connaître le temps de doublement de ton épargne.",
            audioCueID: "q_ECO_01"
        ),
        QuizMCQQuestion(
            id: "ECO_02",
            theme: .ecoCash,
            preferredRound: .leSolo,
            funnyTitle: "Si j'accepte cette prime, je vais gagner moins !",
            prompt: "Ton cousin refuse une prime de 1 000 € en disant : « Ça va me faire passer dans la tranche d'impôt à 30 %, je vais perdre des sous ! ». Pourquoi a-t-il tout faux ?",
            choices: [
                "Il a raison, tout son salaire bascule à 30 %",
                "Parce que seuls les euros qui dépassent le seuil de la tranche sont taxés à 30 %, jamais le reste !",
                "Parce que les primes sont exonérées le mardi",
                "Parce que la tranche à 30 % n'existe plus"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "L'impôt fonctionne par tranches ! Franchir la tranche à 30 % ne taxe à 30 % que la portion qui dépasse le seuil !",
            explanation: "💡 Barème progressif : gagner plus ne fait jamais gagner moins en net après impôt sur le revenu.",
            audioCueID: "q_ECO_02"
        ),
        QuizMCQQuestion(
            id: "ECO_03",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "L'argent qui fond au soleil sur le compte courant",
            prompt: "Tu laisses 10 000 € dormir à 0 % sur ton compte courant pendant 5 ans avec 4 % d'inflation par an. Quel est ton vrai pouvoir d'achat au bout de 5 ans ?",
            choices: [
                "Toujours 10 000 €",
                "Environ 8 150 € (près de 1 850 € évaporés !)",
                "9 800 €",
                "5 000 €"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Le chiffre sur l'écran ne bouge pas, mais avec 4 % d'inflation par an, ton caddie a perdu 18,5 % de pouvoir d'achat !",
            explanation: "💡 Illusion nominale : 4 % d'inflation composée sur 5 ans ronge environ 18,5 % du pouvoir d'achat.",
            audioCueID: "q_ECO_03"
        ),
        QuizMCQQuestion(
            id: "ECO_04",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Le cadeau des 5 bougies du PEA",
            prompt: "Quand ton PEA (Plan d'Épargne en Actions) fête ses 5 ans, à combien tombe l'impôt sur le revenu sur tes plus-values boursières (hors prélèvements sociaux) ?",
            choices: [
                "30 %",
                "12,8 %",
                "0 % d'impôt sur le revenu !",
                "50 %"
            ],
            correctIndex: 2,
            baseValue: 2000,
            meemawRoastOnWrong: "Après 5 ans de PEA, l'impôt sur le revenu tombe à zéro pour cent ! Seuls les prélèvements sociaux restent dus.",
            explanation: "💡 Après 5 ans de détention, les gains du PEA sont totalement exonérés d'impôt sur le revenu (0 % au lieu de 12,8 %).",
            audioCueID: "q_ECO_04"
        ),
        QuizMCQQuestion(
            id: "ECO_05",
            theme: .ecoCash,
            preferredRound: .finaleDouble,
            funnyTitle: "Le singe à fléchettes contre Wall Street",
            prompt: "Sur 15 ans, quelle proportion des fonds « actifs » à gros frais (~2 %/an) parvient à battre un simple ETF indiciel mondial à faibles frais (~0,2 %/an) ?",
            choices: [
                "90 % des fonds actifs battent le marché",
                "Moins de 15 % (près de 90 % font moins bien que l'indice !)",
                "Pile 50 %",
                "Tous ceux qui portent des bretelles rouges"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Près de 90 % des gérants actifs font moins bien que l'indice sur 15 ans à cause de leurs frais annuels !",
            explanation: "💡 Selon l'étude SPIVA, près de 90 % des fonds actifs sous-performent leur indice de référence sur 15 ans.",
            audioCueID: "q_ECO_05"
        ),
        QuizMCQQuestion(
            id: "ECO_06",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Se payer en premier le jour de la paie",
            prompt: "Dans la célèbre règle budgétaire « 50 / 30 / 20 », à quoi correspondent les 20 % que Meemaw conseille de virer dès le lendemain du salaire ?",
            choices: [
                "Aux éclairs au chocolat",
                "À l'épargne et aux investissements long terme",
                "Au loyer et à l'électricité",
                "Aux cadeaux de Noël"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "50 % pour les besoins, 30 % pour les loisirs, et 20 % pour l'épargne virée dès le début du mois !",
            explanation: "💡 Règle 50/30/20 : 50 % charges fixes, 30 % envies, 20 % épargne automatique.",
            audioCueID: "q_ECO_06"
        ),
        QuizMCQQuestion(
            id: "ECO_07",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Le matelas de sécurité anti-tuiles",
            prompt: "Combien de mois de dépenses courantes Meemaw recommande-t-elle de garder sur un livret disponible (Livret A / LDDS) en « épargne de précaution » avant d'investir en Bourse ?",
            choices: [
                "0 mois, tapis sur le rouge !",
                "3 à 6 mois de dépenses courantes",
                "15 ans de salaire",
                "38 euros et un ticket resto"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Toujours garder 3 à 6 mois de dépenses sur un livret sans risque pour encaisser une panne de chaudière ou de voiture sans vendre ses actions au pire moment !",
            explanation: "💡 L'épargne de précaution (3 à 6 mois de charges) protège tes investissements long terme des imprévus.",
            audioCueID: "q_ECO_07"
        ),
        QuizMCQQuestion(
            id: "ECO_08",
            theme: .ecoCash,
            preferredRound: .leSolo,
            funnyTitle: "La méthode DCA du jardinier tranquille",
            prompt: "En investissement, que signifie faire du « DCA » (Dollar-Cost Averaging) ?",
            choices: [
                "Investir la même somme automatiquement chaque mois, que la Bourse monte ou baisse",
                "Attendre le krach du siècle en lisant dans le marc de café",
                "Tout vendre dès que le journal de 20h a peur",
                "Acheter uniquement des actions de fabricants de canapés"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Le DCA consiste à investir un montant fixe tous les mois pour lisser son prix d'achat sans stresser !",
            explanation: "💡 L'investissement programmé (DCA) neutralise le biais émotionnel : quand le marché baisse, ta mensualité achète plus de parts.",
            audioCueID: "q_ECO_08"
        ),
        QuizMCQQuestion(
            id: "ECO_09",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Ne pas mettre tous ses œufs dans le même panier",
            prompt: "Quand tu achètes UNE SEULE part d'un ETF « MSCI World », dans combien de grandes entreprises mondiales investis-tu simultanément ?",
            choices: [
                "Dans 3 entreprises du quartier",
                "Dans environ 1 400 à 1 500 grandes entreprises de 23 pays développés !",
                "Dans 10 banques suisses",
                "Uniquement dans la boulangerie du coin"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Un seul ETF MSCI World répartit ton argent dans près de 1 500 entreprises à travers 23 pays !",
            explanation: "💡 Un ETF indiciel mondial offre une diversification instantanée sur ~1 500 sociétés internationales.",
            audioCueID: "q_ECO_09"
        ),
        QuizMCQQuestion(
            id: "ECO_10",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Le piège psychologique du film ennuyeux",
            prompt: "Tu as payé 12 € ta place de cinéma, le film est horrible au bout de 20 minutes, mais tu restes souffrir 2 heures « parce que j'ai payé ». Comment les économistes appellent-ils ce piège mental ?",
            choices: [
                "Le biais des coûts irrécupérables (Sunk Cost Fallacy)",
                "L'effet pop-corn",
                "Le théorème du fauteuil mou",
                "L'inflation cinématographique"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est le biais des coûts irrécupérables ! Les 12 € sont perdus quoi que tu fasses : en restant, tu perds en plus 2 heures de ta soirée !",
            explanation: "💡 Le biais des coûts irrécupérables nous pousse à persister dans une mauvaise décision parce qu'on y a déjà mis du temps ou de l'argent.",
            audioCueID: "q_ECO_10"
        ),
        QuizMCQQuestion(
            id: "ECO_11",
            theme: .ecoCash,
            preferredRound: .finaleDouble,
            funnyTitle: "Le monstre du découvert bancaire",
            prompt: "Si tu es à découvert tous les mois avec des agios et commissions d'intervention, à quel taux annuel effectif (TAEG) cela revient-il souvent ?",
            choices: [
                "1 % par an",
                "Entre 15 % et plus de 20 % par an (l'argent le plus cher de la banque !)",
                "Gratuit le week-end",
                "3 % par an"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Le découvert bancaire et le crédit renouvelable coûtent souvent entre 15 % et 21 % par an ! C'est la priorité absolue à rembourser !",
            explanation: "💡 Rembourser une dette à 18 % d'intérêts équivaut à un placement garanti à 18 % net d'impôt.",
            audioCueID: "q_ECO_11"
        ),
        QuizMCQQuestion(
            id: "ECO_12",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Quand une action perd 50 %, combien doit-elle regagner ?",
            prompt: "Une action passe de 100 € à 50 € (elle perd 50 %). De quel pourcentage doit-elle remonter ensuite pour revenir à 100 € ?",
            choices: [
                "+50 % (ça s'équilibre !)",
                "+100 % (elle doit doubler pour repasser de 50 € à 100 € !)",
                "+75 %",
                "+25 %"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Passer de 50 € à 100 €, c'est gagner 50 € sur une base de 50 €, soit +100 % ! Une perte de 50 % exige un gain de 100 % !",
            explanation: "💡 Asymétrie des pertes : -50 % nécessite +100 % pour revenir à l'équilibre ; -80 % nécessite +400 % !",
            audioCueID: "q_ECO_12"
        ),
        QuizMCQQuestion(
            id: "ECO_13",
            theme: .ecoCash,
            preferredRound: .leSolo,
            funnyTitle: "L'effet Latte (ou le croissant quotidien)",
            prompt: "Dépensé chaque jour ouvré, 5 € de café/viennoiserie à emporter représente environ 1 200 € par an. Investis à 7 % par an pendant 20 ans, quel capital cela forme-t-il ?",
            choices: [
                "12 000 €",
                "Près de 50 000 € grâce aux intérêts composés !",
                "24 000 € tout rond",
                "4 500 €"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "100 € par mois capitalisés à 7 % pendant 20 ans forment près de 52 000 € (dont plus de la moitié d'intérêts) !",
            explanation: "💡 Les petites dépenses récurrentes automatisées vers l'épargne profitent à plein de la capitalisation sur 20 ans.",
            audioCueID: "q_ECO_13"
        ),
        QuizMCQQuestion(
            id: "ECO_14",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Le plafond du Livret A",
            prompt: "En France, quel est le plafond des versements sur un Livret A pour un particulier (hors intérêts capitalisés qui peuvent dépasser ce plafond) ?",
            choices: [
                "12 000 €",
                "22 950 €",
                "50 000 €",
                "150 000 €"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Le plafond des versements du Livret A est de 22 950 € (et 12 000 € pour le LDDS) !",
            explanation: "💡 Le Livret A est plafonné à 22 950 € de versements (mais les intérêts annuels peuvent s'ajouter au-delà).",
            audioCueID: "q_ECO_14"
        ),
        QuizMCQQuestion(
            id: "ECO_15",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "L'inflation du train de vie",
            prompt: "Comment appelle-t-on le phénomène où, à chaque augmentation de salaire, on augmente aussitôt ses dépenses si bien qu'on n'épargne pas un euro de plus ?",
            choices: [
                "L'inflation du style de vie (Lifestyle Creep)",
                "La déflation du frigo",
                "Le syndrome de l'écureuil",
                "La règle d'or"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est l'inflation du style de vie ! L'astuce de Meemaw : épargner automatiquement 50 % de chaque augmentation de salaire !",
            explanation: "💡 Le « Lifestyle Creep » explique pourquoi des revenus élevés peuvent quand même vivre à découvert s'ils n'automatisent pas leur épargne.",
            audioCueID: "q_ECO_15"
        ),
        QuizMCQQuestion(
            id: "ECO_16",
            theme: .ecoCash,
            preferredRound: .finaleDouble,
            funnyTitle: "La tulipe qui valait le prix d'un manoir",
            prompt: "En 1637 aux Pays-Bas, quelle fleur a provoqué la toute première grande bulle spéculative de l'Histoire (où un seul bulbe se vendait au prix d'une maison à Amsterdam) ?",
            choices: [
                "Le géranium de balcon",
                "La tulipe (la « Tulipomanie » !)",
                "Le pissenlit doré",
                "La marguerite"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est la fameuse Tulipomanie hollandaise de 1637, où un bulbe de tulipe Semper Augustus valait le prix d'un hôtel particulier !",
            explanation: "💡 La crise des tulipes de 1637 aux Pays-Bas est considérée par les historiens comme la première bulle spéculative moderne.",
            audioCueID: "q_ECO_16"
        ),
        QuizMCQQuestion(
            id: "ECO_17",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Le paquet de gâteaux qui rétrécit sans baisser de prix",
            prompt: "Comment appelle-t-on la technique des supermarchés qui consiste à réduire le poids d'un produit (passer de 500 g à 420 g) tout en gardant exactement le même prix et la même boîte ?",
            choices: [
                "La « Shrinkflation » (ou réduflation)",
                "La déflation magique",
                "Le régime forcé de Meemaw",
                "L'effet parachute"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est la Shrinkflation (réduflation) ! Pour ne jamais te faire avoir, regarde toujours le prix au kilo sur l'étiquette !",
            explanation: "💡 La « shrinkflation » (de l'anglais to shrink, rétrécir) masque une hausse du prix au kilo en diminuant la quantité vendue.",
            audioCueID: "q_ECO_17"
        ),
        QuizMCQQuestion(
            id: "ECO_18",
            theme: .ecoCash,
            preferredRound: .leSolo,
            funnyTitle: "La pizza la plus chère de toute l'histoire de l'humanité",
            prompt: "Le 22 mai 2010, le programmeur Laszlo Hanyecz a payé le tout premier achat réel en Bitcoin : combien de Bitcoins a-t-il donnés pour se faire livrer DEUX pizzas ?",
            choices: [
                "10 000 Bitcoins (soit des centaines de millions d'euros aujourd'hui !)",
                "2 Bitcoins",
                "100 Bitcoins",
                "0,5 Bitcoin"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "10 000 Bitcoins pour deux pizzas Papa John's ! À l'époque ça valait 40 dollars, aujourd'hui ça vaut une île entière !",
            explanation: "💡 Le 22 mai est célébré chaque année comme le « Bitcoin Pizza Day » en mémoire de ces 2 pizzas payées 10 000 BTC en 2010.",
            audioCueID: "q_ECO_18"
        ),
        QuizMCQQuestion(
            id: "ECO_19",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Le prix qui finit par 9,99 €",
            prompt: "Pourquoi les commerçants affichent-ils un prix à 19,99 € au lieu de 20,00 € alors qu'il n'y a qu'un seul centime d'écart ?",
            choices: [
                "À cause du « biais du chiffre de gauche » : notre cerveau retient le 1 de 19 et classe l'objet dans la dizaine inférieure !",
                "Pour écouler les pièces de 1 centime",
                "Parce que le chiffre 9 porte bonheur aux caissiers",
                "Pour payer moins de TVA"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "En lisant de gauche à droite, notre cerveau ancre son jugement sur le premier chiffre (19 au lieu de 20) : c'est le prix psychologique !",
            explanation: "💡 Le « Left-Digit Effect » démontre que passer de 20,00 € à 19,99 € augmente significativement les ventes.",
            audioCueID: "q_ECO_19"
        ),
        QuizMCQQuestion(
            id: "ECO_20",
            theme: .ecoCash,
            preferredRound: .finaleDouble,
            funnyTitle: "La règle des 4 % pour vivre de ses rentes",
            prompt: "Selon la célèbre « Règle des 4 % » (étude Trinity), de quel capital investi as-tu besoin pour retirer 1 000 € par mois (12 000 € par an) sans épuiser ton patrimoine sur 30 ans ?",
            choices: [
                "300 000 € (soit 25 fois tes dépenses annuelles : 12 000 × 25 !)",
                "48 000 €",
                "1 000 000 €",
                "120 000 €"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Retirer 4 % par an revient à multiplier ton besoin annuel par 25 : 12 000 € fois 25 égale 300 000 € !",
            explanation: "💡 Règle des 4 % (mouvement FIRE) : détenir 25 fois ses dépenses annuelles permet statistiquement de retirer 4 % par an pendant 30 ans.",
            audioCueID: "q_ECO_20"
        )
    ]

    // MARK: - ⚖️ Manche 3 : Les 12 Couci-Couça Binaire (DisOrDat — 72 items)

    public static let allDisOrDatRounds: [QuizDisOrDatRound] = [
        QuizDisOrDatRound(
            id: "DOD_FR_1",
            theme: .francaisMeemaw,
            funnyTitle: "Vrai Pluriel en « X » ou Pluriel en « S » ?",
            prompt: "Au pluriel : tape à GAUCHE si ce mot prend un « X », ou à DROITE s'il prend un simple « S » !",
            optionLeft: "PREND UN X ❌",
            optionRight: "PREND UN S 🐍",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Un hibou -> Des hibou...", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "Un clou -> Des clou...", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Un pneu -> Des pneu...", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "Un genou -> Des genou...", correctSide: "left"),
                QuizDisOrDatItem(index: 4, text: "Un bisou -> Des bisou...", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "Un caillou -> Des caillou...", correctSide: "left")
            ],
            audioCueID: "dod_FR_1"
        ),
        QuizDisOrDatRound(
            id: "DOD_FR_2",
            theme: .francaisMeemaw,
            funnyTitle: "Mot Masculin (« UN ») ou Mot Féminin (« UNE ») ?",
            prompt: "Attention aux pièges du dictionnaire : tape à GAUCHE si le mot est MASCULIN, ou à DROITE s'il est FÉMININ !",
            optionLeft: "MASCULIN (UN) 🎩",
            optionRight: "FÉMININ (UNE) 👒",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "___ tentacule (de pieuvre)", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "___ écritoire", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "___ pétale (de rose)", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "___ anagramme", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "___ haltère (de musculation)", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "___ oasis (dans le désert)", correctSide: "right")
            ],
            audioCueID: "dod_FR_2"
        ),
        QuizDisOrDatRound(
            id: "DOD_MATH_1",
            theme: .mathMeemaw,
            funnyTitle: "Plus Petit que 50 ou Plus Grand que 50 ?",
            prompt: "Calcul flash : tape à GAUCHE si le résultat est INFÉRIEUR à 50, ou à DROITE s'il est SUPÉRIEUR à 50 !",
            optionLeft: "< 50 📉",
            optionRight: "> 50 📈",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "7 × 7", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "6 × 9", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "25 % de 240", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "100 ÷ 2,5", correctSide: "left"),
                QuizDisOrDatItem(index: 4, text: "8 × 7", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "La moitié de 96", correctSide: "left")
            ],
            audioCueID: "dod_MATH_1"
        ),
        QuizDisOrDatRound(
            id: "DOD_MATH_2",
            theme: .mathMeemaw,
            funnyTitle: "Nombre Premier ou Nombre Divisible ?",
            prompt: "Tape à GAUCHE si ce nombre est PREMIER (divisible que par 1 et lui-même), ou à DROITE s'il est DIVISIBLE !",
            optionLeft: "PREMIER 🔒",
            optionRight: "DIVISIBLE ➗",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "17", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "21 (indice : 3 × 7)", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "29", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "51 (indice : 3 × 17 !)", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "23", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "49 (indice : 7 × 7)", correctSide: "right")
            ],
            audioCueID: "dod_MATH_2"
        ),
        QuizDisOrDatRound(
            id: "DOD_CINE_1",
            theme: .seriesCinema,
            funnyTitle: "Réplique des Bronzés ou Réplique d'Astérix Mission Cléopâtre ?",
            prompt: "Tape à GAUCHE si la réplique vient des BRONZÉS, ou à DROITE si elle vient d'ASTÉRIX & OBÉLIX : MISSION CLÉOPÂTRE !",
            optionLeft: "LES BRONZÉS 🎿",
            optionRight: "ASTÉRIX 🐪",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "« Vous savez, moi je ne crois pas qu'il y ait de bonne ou de mauvaise situation… »", correctSide: "right"),
                QuizDisOrDatItem(index: 1, text: "« Oublie que t'as aucune chance, vas-y, fonce ! »", correctSide: "left"),
                QuizDisOrDatItem(index: 2, text: "« C'est de la liqueur d'échalote, c'est relevé ! »", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "« Pas de pierre : pas de construction. Pas de construction : pas de palais… »", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "« Je vais vous faire le planté de bâton, monsieur Dusse ! »", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "« Ce tombeau sera votre tombeau ! »", correctSide: "right")
            ],
            audioCueID: "dod_CINE_1"
        ),
        QuizDisOrDatRound(
            id: "DOD_CINE_2",
            theme: .seriesCinema,
            funnyTitle: "Film Pixar ou Film DreamWorks ?",
            prompt: "Tape à GAUCHE si ce film d'animation vient du studio PIXAR, ou à DROITE s'il vient de DREAMWORKS !",
            optionLeft: "PIXAR 💡",
            optionRight: "DREAMWORKS 🌙",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Ratatouille", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "Shrek", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Vice-Versa (Inside Out)", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "Kung Fu Panda", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "Là-Haut (Up)", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Madagascar", correctSide: "right")
            ],
            audioCueID: "dod_CINE_2"
        ),
        QuizDisOrDatRound(
            id: "DOD_MUS_1",
            theme: .musiqueTubes,
            funnyTitle: "Tube des Années 80 ou Tube des Années 2000 ?",
            prompt: "Tape à GAUCHE si la chanson est sortie dans les ANNÉES 80, ou à DROITE si elle est sortie dans les ANNÉES 2000 !",
            optionLeft: "ANNÉES 80 📼",
            optionRight: "ANNÉES 2000 💿",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Les Démons de Minuit (Images)", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "Alors on danse (Stromae)", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Take On Me (a-ha)", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "Crazy in Love (Beyoncé)", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "L'Aventurier (Indochine)", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Moi... Lolita (Alizée)", correctSide: "right")
            ],
            audioCueID: "dod_MUS_1"
        ),
        QuizDisOrDatRound(
            id: "DOD_MUS_2",
            theme: .musiqueTubes,
            funnyTitle: "Chanson de Jean-Jacques Goldman ou de Michel Berger ?",
            prompt: "Tape à GAUCHE si c'est un classique de JEAN-JACQUES GOLDMAN, ou à DROITE si c'est de MICHEL BERGER !",
            optionLeft: "GOLDMAN 🎸",
            optionRight: "BERGER 🎹",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Envole-moi", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "La Groupie du pianiste", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Quand la musique est bonne", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "Le Paradis blanc", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "Je marche seul", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Quelques mots d'amour", correctSide: "right")
            ],
            audioCueID: "dod_MUS_2"
        ),
        QuizDisOrDatRound(
            id: "DOD_CUL_1",
            theme: .cultureGInsolite,
            funnyTitle: "Vraie Info Scientifique ou Gros Bobard de Meemaw ?",
            prompt: "Tape à GAUCHE si c'est VRAI, ou à DROITE si c'est un GROS BOBARD !",
            optionLeft: "100 % VRAI ✅",
            optionRight: "BOBARD 🤥",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Les bananes sont naturellement légèrement radioactives (potassium 40)", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "La Grande Muraille de Chine se voit à l'œil nu depuis la Lune", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Les requins existaient sur Terre avant les arbres et avant les dinosaures", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "Un poisson rouge n'a que 3 secondes de mémoire", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "Le cœur d'une baleine bleue a la taille d'une petite voiture", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Les autruches s'enterrent la tête dans le sable quand elles ont peur", correctSide: "right")
            ],
            audioCueID: "dod_CUL_1"
        ),
        QuizDisOrDatRound(
            id: "DOD_CUL_2",
            theme: .cultureGInsolite,
            funnyTitle: "Inventé AVANT 1900 ou APRÈS 1900 ?",
            prompt: "Tape à GAUCHE si cette invention date d'AVANT 1900, ou à DROITE si elle date d'APRÈS 1900 !",
            optionLeft: "AVANT 1900 🎩",
            optionRight: "APRÈS 1900 🚀",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Le briquet (inventé en 1823, avant même les allumettes modernes !)", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "Le four à micro-ondes (1945)", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Le Coca-Cola (1886)", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "Le Velcro / scratch (1941)", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "Le téléphone d'Alexander Graham Bell (1876)", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Le Post-it jaune (1980)", correctSide: "right")
            ],
            audioCueID: "dod_CUL_2"
        ),
        QuizDisOrDatRound(
            id: "DOD_ECO_1",
            theme: .ecoCash,
            funnyTitle: "Actif qui t'Enrichit ou Passif qui te Plume ?",
            prompt: "Tape à GAUCHE si ça met des sous dans ta poche (ACTIF), ou à DROITE si ça en fait sortir (PASSIF) !",
            optionLeft: "ACTIF 💰",
            optionRight: "PASSIF 💸",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Un ETF MSCI World logé dans ton PEA", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "Une voiture de sport achetée à crédit conso à 8 %", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Ton épargne de précaution sur Livret A / LDDS", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "Un crédit renouvelable à 19 % d'intérêts", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "Un studio loué dont le loyer net dépasse le crédit", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Quatre abonnements streaming que tu n'ouvres jamais", correctSide: "right")
            ],
            audioCueID: "dod_ECO_1"
        ),
        QuizDisOrDatRound(
            id: "DOD_ECO_2",
            theme: .ecoCash,
            funnyTitle: "Exonéré d'Impôt sur le Revenu ou Imposé ?",
            prompt: "En France : tape à GAUCHE si ce gain est EXONÉRÉ d'impôt sur le revenu, ou à DROITE s'il est IMPOSÉ !",
            optionLeft: "0 % D'IMPÔT 🎁",
            optionRight: "IMPOSÉ 🧾",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Les intérêts de ton Livret A", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "Les dividendes sur un Compte-Titres Ordinaire (CTO)", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Les plus-values d'un PEA ouvert depuis plus de 5 ans", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "Les intérêts d'un Livret bancaire fiscalisé (Super Livret)", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "La revente de ta résidence principale", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Une plus-value crypto convertie en euros (> 305 €/an)", correctSide: "right")
            ],
            audioCueID: "dod_ECO_2"
        ),
        // MARK: - 🧀 La Raclette Quizz (3 choix façon Burger Quiz : Gauche, Droite, ou LES DEUX !)
        QuizDisOrDatRound(
            id: "RAC_CINE_1",
            theme: .seriesCinema,
            funnyTitle: "🧀 Raclette Pop-Culture : Harry Potter, Le Seigneur des Anneaux, ou LES DEUX ?",
            prompt: "Façon Burger Quiz : c'est dans HARRY POTTER, dans LE SEIGNEUR DES ANNEAUX, ou dans LES DEUX ?",
            optionLeft: "HARRY POTTER ⚡",
            optionRight: "SEIGNEUR ANNEAUX 💍",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Un vieux monsieur à longue barbe blanche donne des conseils mystérieux", correctSide: "both"),
                QuizDisOrDatItem(index: 1, text: "On prend le train sur la voie 9 ¾ à la gare de King's Cross", correctSide: "left"),
                QuizDisOrDatItem(index: 2, text: "Une créature chauve obsédée par « son Précieux »", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "Des araignées géantes qui donnent des sueurs froides dans la forêt", correctSide: "both"),
                QuizDisOrDatItem(index: 4, text: "Un elfe libéré grâce à une vieille chaussette sale", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Le premier film de la saga est sorti au cinéma en 2001", correctSide: "both")
            ],
            audioCueID: "rac_CINE_1"
        ),
        QuizDisOrDatRound(
            id: "RAC_MUS_1",
            theme: .musiqueTubes,
            funnyTitle: "🧀 Raclette Pop Gen Z : Sabrina Carpenter, Billie Eilish, ou LES DEUX ?",
            prompt: "Chanteuses stars de la Gen Z : SABRINA CARPENTER, BILLIE EILISH, ou LES DEUX ?",
            optionLeft: "SABRINA ☕️",
            optionRight: "BILLIE EILISH 🦜",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "A chanté le méga-tube de l'été « Espresso »", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "Compose toutes ses chansons avec son grand frère Finneas", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "A dépassé le milliard de streams sur Spotify en 2024", correctSide: "both"),
                QuizDisOrDatItem(index: 3, text: "A remporté deux Oscars de la meilleure chanson originale (James Bond & Barbie)", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "A assuré la première partie de la tournée The Eras Tour de Taylor Swift", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Adorée par la fille de Xabi dans les playlists de la voiture", correctSide: "both")
            ],
            audioCueID: "rac_MUS_1"
        ),
        QuizDisOrDatRound(
            id: "RAC_CUL_1",
            theme: .cultureGInsolite,
            funnyTitle: "🧀 La Vraie Raclette : Fromage AOP, Village de Montagne, ou LES DEUX ?",
            prompt: "Attention ça fond dans le poêlon : c'est un FROMAGE, un VILLAGE/VILLE, ou LES DEUX à la fois ?",
            optionLeft: "FROMAGE 🧀",
            optionRight: "VILLAGE 🏔️",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Saint-Nectaire", correctSide: "both"),
                QuizDisOrDatItem(index: 1, text: "Boursin (créé par François Boursin)", correctSide: "left"),
                QuizDisOrDatItem(index: 2, text: "Roquefort-sur-Soulzon", correctSide: "both"),
                QuizDisOrDatItem(index: 3, text: "Courchevel", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "Maroilles", correctSide: "both"),
                QuizDisOrDatItem(index: 5, text: "Kiri", correctSide: "left")
            ],
            audioCueID: "rac_CUL_1"
        ),
        QuizDisOrDatRound(
            id: "RAC_FR_1",
            theme: .francaisMeemaw,
            funnyTitle: "🧀 Raclette du Dico : Mot Masculin, Mot Féminin, ou LES DEUX ?",
            prompt: "Dans le dictionnaire français : peut-on dire UN (masculin), UNE (féminin), ou LES DEUX ?",
            optionLeft: "MASCULIN (UN) 🎩",
            optionRight: "FÉMININ (UNE) 👒",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "___ après-midi", correctSide: "both"),
                QuizDisOrDatItem(index: 1, text: "___ tentacule", correctSide: "left"),
                QuizDisOrDatItem(index: 2, text: "___ oasis", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "___ crêpe (celle qui se mange ou le tissu/caoutchouc !)", correctSide: "both"),
                QuizDisOrDatItem(index: 4, text: "___ pétale", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "___ livre (de lecture ou de beurre !)", correctSide: "both")
            ],
            audioCueID: "rac_FR_1"
        ),
        QuizDisOrDatRound(
            id: "RAC_MATH_1",
            theme: .mathMeemaw,
            funnyTitle: "🧀 Raclette des Nombres : Divisible par 2, Divisible par 5, ou LES DEUX ?",
            prompt: "Calcul mental : ce nombre se divise-t-il par 2, par 5, ou par LES DEUX (donc par 10) ?",
            optionLeft: "PAR 2 ✌️",
            optionRight: "PAR 5 🖐️",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "24", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "35", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "70", correctSide: "both"),
                QuizDisOrDatItem(index: 3, text: "125", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "48", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "2020", correctSide: "both")
            ],
            audioCueID: "pun_1"
        ),
        QuizDisOrDatRound(
            id: "RAC_ECO_1",
            theme: .ecoCash,
            funnyTitle: "🧀 Raclette Épargne : Livret A, PEA (Plan d'Épargne en Actions), ou LES DEUX ?",
            prompt: "Question Cash : est-ce vrai pour le LIVRET A, pour le PEA, ou pour LES DEUX ?",
            optionLeft: "LIVRET A 🏦",
            optionRight: "PEA 📈",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Capital 100 % garanti sans aucun risque de baisse", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "Permet d'investir dans des ETF comme le MSCI World", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "0 % d'impôt sur le revenu sur les gains (après 5 ans pour le PEA)", correctSide: "both"),
                QuizDisOrDatItem(index: 3, text: "Plafond des versements fixé à 22 950 €", correctSide: "left"),
                QuizDisOrDatItem(index: 4, text: "Plafond des versements fixé à 150 000 €", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "Limité à un seul par personne majeure", correctSide: "both")
            ],
            audioCueID: "pun_2"
        ),
        QuizDisOrDatRound(
            id: "RAC_MUS_2",
            theme: .musiqueTubes,
            funnyTitle: "🧀 Raclette du Son : Gims, Stromae, ou LES DEUX ?",
            prompt: "Les géants du son francophone : c'est GIMS, c'est STROMAE, ou c'est LES DEUX ?",
            optionLeft: "GIMS 🕶️",
            optionRight: "STROMAE 🦋",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "Ne quitte presque jamais ses lunettes de soleil noires", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "A sorti l'album culte « Racine carrée » avec « Papaoutai »", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Ils ont chanté ensemble sur le tube « La Même » en 2018", correctSide: "both"),
                QuizDisOrDatItem(index: 3, text: "A cartonné en 2024-2025 avec « Spider » et « Ciel »", correctSide: "left"),
                QuizDisOrDatItem(index: 4, text: "Est né à Bruxelles en Belgique", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "A rempli les plus grands stades de France", correctSide: "both")
            ],
            audioCueID: "rac_MUS_2"
        ),
        QuizDisOrDatRound(
            id: "RAC_CINE_2",
            theme: .seriesCinema,
            funnyTitle: "🧀 Raclette Séries : The Rookie, Friends, ou LES DEUX ?",
            prompt: "Séries cultes en famille : c'est dans THE ROOKIE, dans FRIENDS, ou dans LES DEUX ?",
            optionLeft: "THE ROOKIE 🚓",
            optionRight: "FRIENDS ☕️",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 500,
            items: [
                QuizDisOrDatItem(index: 0, text: "John Nolan devient la recrue la plus âgée de la police de Los Angeles", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "On boit des cafés sur un canapé orange au Central Perk", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "Le couple chouchou des fans est surnommé « Chenford »", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "Ross hurle « PIVOT ! » dans l'escalier avec son canapé", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "C'est une série américaine qui compte au moins 6 saisons", correctSide: "both"),
                QuizDisOrDatItem(index: 5, text: "Un personnage s'appelle Rachel Green", correctSide: "right")
            ],
            audioCueID: "rac_CINE_2"
        )
    ]
}
