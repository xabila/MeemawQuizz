import Foundation

public struct ShowGameDeck: Sendable {
    public var cashQuestions: [QuizMCQQuestion]
    public var soloQuestions: [QuizMCQQuestion]
    public var couciCoucaRound: QuizDisOrDatRound
    public var finaleDoubleQuestions: [QuizMCQQuestion]

    public init(
        cashQuestions: [QuizMCQQuestion],
        soloQuestions: [QuizMCQQuestion],
        couciCoucaRound: QuizDisOrDatRound,
        finaleDoubleQuestions: [QuizMCQQuestion]
    ) {
        self.cashQuestions = cashQuestions
        self.soloQuestions = soloQuestions
        self.couciCoucaRound = couciCoucaRound
        self.finaleDoubleQuestions = finaleDoubleQuestions
    }

    public var allMCQIDs: [String] {
        (cashQuestions + soloQuestions + finaleDoubleQuestions).map(\.id)
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
        switch pack {
        case .francaisMeemaw:
            return allDisOrDatRounds.filter { $0.theme == .francaisMeemaw }
        case .mathMeemaw:
            return allDisOrDatRounds.filter { $0.theme == .mathMeemaw }
        case .seriesCinema:
            return allDisOrDatRounds.filter { $0.theme == .seriesCinema }
        case .musiqueTubes:
            return allDisOrDatRounds.filter { $0.theme == .musiqueTubes }
        case .cultureGInsolite:
            return allDisOrDatRounds.filter { $0.theme == .cultureGInsolite }
        case .ecoCash:
            return allDisOrDatRounds.filter { $0.theme == .ecoCash }
        case .grandMix:
            return allDisOrDatRounds
        }
    }

    public static func buildShowDeck(
        for pack: QuizThemePack,
        excludingQuestionIDs: Set<String> = [],
        excludingDisOrDatIDs: Set<String> = []
    ) -> ShowGameDeck {
        let baseQuestions = questions(for: pack)
        var freshPool = baseQuestions.filter { !excludingQuestionIDs.contains($0.id) }.shuffled()

        if freshPool.count < 7 {
            let grandMixUnseen = questions(for: .grandMix)
                .filter { !excludingQuestionIDs.contains($0.id) && !freshPool.map(\.id).contains($0.id) }
                .shuffled()
            freshPool.append(contentsOf: grandMixUnseen)
        }
        if freshPool.count < 7 {
            freshPool = baseQuestions.shuffled()
        }

        let cash = Array(freshPool.prefix(3))
        let solo = Array(freshPool.dropFirst(3).prefix(2))
        let finale = Array(freshPool.dropFirst(5).prefix(2))

        let themeCouci = disOrDatRounds(for: pack)
        let unseenCouci = themeCouci.filter { !excludingDisOrDatIDs.contains($0.id) }
        let fallbackUnseenCouci = allDisOrDatRounds.filter { !excludingDisOrDatIDs.contains($0.id) }
        let couci = unseenCouci.randomElement()
            ?? fallbackUnseenCouci.randomElement()
            ?? themeCouci.randomElement()
            ?? allDisOrDatRounds[0]

        return ShowGameDeck(
            cashQuestions: cash,
            soloQuestions: solo,
            couciCoucaRound: couci,
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
        )
    ]
}
