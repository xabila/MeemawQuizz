import Foundation

extension QuestionBank {

    // MARK: - 1B. +16 Nouvelles Questions 👵 Français & Expressions de Meemaw

    public static let extraFrancaisQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "FR_21",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "La soupe à la grimace et les haricots...",
            prompt: "Quand Meemaw soupire « C'est la fin des haricots ! », d'où vient vraiment cette expression dramatique ?",
            choices: [
                "D'une famine de cassoulet à Toulouse en 1812",
                "Des jeux de société où l'on misait des haricots secs en guise de jetons",
                "Du potager de Louis XIV dévoré par des sangliers",
                "D'une chanson triste de Johnny sur les légumes verts"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais non mon poussin ! Avant les jetons en plastique, on jouait aux cartes avec des haricots secs : plus de haricots, plus de tapis !",
            explanation: "💡 Au XIXe siècle, on utilisait des haricots secs comme jetons de mise. Quand un joueur n'avait plus un seul haricot devant lui, la partie était pliée !",
            audioCueID: "q_FR_21"
        ),
        QuizMCQQuestion(
            id: "FR_22",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "S'excuser sans fâcher l'Académie française",
            prompt: "Tu viens de renverser le plat de gratin dauphinois sur les pantoufles de Pépé. Quelle graphie est recommandée par l'Académie française pour t'excuser ?",
            choices: [
                "Au temps pour moi",
                "Autant pour moi",
                "Otan pour moi",
                "Oh tant pis pour toi"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « Au temps pour moi » ! Ça vient du commandement militaire et des chefs d'orchestre qui reprenaient la mesure « au temps » !",
            explanation: "💡 L'expression vient du langage militaire et musical (« Au temps ! » pour reprendre un mouvement depuis le début).",
            audioCueID: "q_FR_22"
        ),
        QuizMCQQuestion(
            id: "FR_23",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Le pluriel qui donne des boutons à Tonton",
            prompt: "Meemaw adore les robes « orange » et « marron ». Comment écrit-on : « Des pulls marron et des chaussettes orange » ?",
            choices: [
                "Des pulls marrons et des chaussettes oranges",
                "Des pulls marron et des chaussettes orange",
                "Des pulls marron et des chaussettes oranges",
                "On dit « beige foncé » comme ça on ne se trompe pas"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Raté ! Quand un adjectif de couleur vient d'un fruit ou d'une pierre (marron, orange, citron, turquoise), il reste INVARIABLE !",
            explanation: "💡 Les noms utilisés comme adjectifs de couleur (une orange, un marron, un abricot) ne prennent pas de S au pluriel (sauf rose, mauve, pourpre, écarlate et fauve).",
            audioCueID: "q_FR_23"
        ),
        QuizMCQQuestion(
            id: "FR_24",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Pousser Mémé dans les orties !",
            prompt: "Que signifie exactement « Il ne faut pas pousser Mémé dans les orties » (surtout quand elle est en short) ?",
            choices: [
                "Il faut désherber le jardin avant le dimanche midi",
                "Il ne faut pas exagérer ni abuser de la situation",
                "Les orties font une excellente tisane pour les genoux",
                "Il faut toujours laisser passer les personnes âgées à la caisse"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Et ho, tu veux vraiment me pousser dans les ronces ?! Ça veut dire qu'il ne faut pas dépasser les bornes des limites !",
            explanation: "💡 Apparue au XXe siècle, cette expression populaire rappelle avec humour qu'il ne faut pas abuser de la patience ou de la gentillesse de quelqu'un.",
            audioCueID: "q_FR_24"
        ),
        QuizMCQQuestion(
            id: "FR_25",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Le subjonctif qui pique les yeux",
            prompt: "Complète cette phrase de Meemaw sans faire pleurer ton prof de français : « Bien qu'il ___ très tard, Tonton redemande du fromage. »",
            choices: [
                "soit",
                "est",
                "soie",
                "serait"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Après « bien que » ou « quoique », c'est TOUJOURS le subjonctif : « bien qu'il soit » ! Pas « bien qu'il est » !",
            explanation: "💡 Les conjonctions « bien que » et « quoique » sont toujours suivies du subjonctif (« bien qu'il soit », « bien qu'il fasse »).",
            audioCueID: "q_FR_25"
        ),
        QuizMCQQuestion(
            id: "FR_26",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Passer du coq à l'âne",
            prompt: "À l'origine, au Moyen Âge, de quel deuxième animal parlait-on dans l'expression « passer du coq à l'âne » ?",
            choices: [
                "Du coq à la cane",
                "Du coq au chameau",
                "Du coq au boudin",
                "Du coq au lama"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Au départ on disait « sauter du coq à la cane » ! Puis par jeu de mots sonore (« à l'âne »), le pauvre baudet a remplacé la cane !",
            explanation: "💡 Au XIVe siècle, on disait « sauter du coq à la cane », avant que la proximité sonore entre « à la cane » et « à l'âne » ne transforme l'expression.",
            audioCueID: "q_FR_26"
        ),
        QuizMCQQuestion(
            id: "FR_27",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "L'anatomie secrète du grand paresseux",
            prompt: "Selon l'expression française, quand ton cousin met 4 heures à débarrasser trois petites cuillères, qu'a-t-il au creux de la paume ?",
            choices: [
                "Un hérisson en RTT",
                "Un poil dans la main",
                "Une crampe diplomatique",
                "Une allergie à l'éponge Spontex"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Il a un poil dans la main gros comme un baobab ! L'idée, c'est qu'il travaille si peu qu'un poil a eu le temps d'y pousser !",
            explanation: "💡 Comme aucun poil ne pousse sur la paume des mains, en avoir un prouve qu'on ne s'en sert jamais pour travailler !",
            audioCueID: "q_FR_27"
        ),
        QuizMCQQuestion(
            id: "FR_28",
            theme: .francaisMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Les amours, délices et orgues de Meemaw",
            prompt: "Quelle est la particularité grammaticale très célèbre des trois mots « amour », « délice » et « orgue » en français ?",
            choices: [
                "Ils sont masculins au singulier et deviennent féminins au pluriel !",
                "Ils s'écrivent exactement pareil à l'endroit et à l'envers",
                "Ils prennent trois X au pluriel",
                "Ils sont interdits au Scrabble le dimanche"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Un grand amour, mais des amours folles ! Un vrai délice, mais des délices infinies ! Masculins au singulier, féminins au pluriel !",
            explanation: "💡 « Amour », « délice » et « orgue » sont les trois célèbres noms français masculins au singulier et féminins au pluriel (« de belles amours »).",
            audioCueID: "q_FR_28"
        ),
        QuizMCQQuestion(
            id: "FR_29",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Se mettre sur son 31",
            prompt: "Quand Pépé sort son costume trois-pièces qui sent la naphtaline, on dit qu'il « se met sur son 31 ». Quelle est l'origine la plus citée ?",
            choices: [
                "D'un drap de luxe du Moyen Âge appelé le « trentain »",
                "Le numéro du bus qui allait au bal de l'Opéra",
                "Parce qu'on ne s'habille bien que le 31 décembre",
                "Le tour de taille de Pépé en 1968"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Ça vient du « trente-et-ain » (drap très chic du Moyen Âge tissé avec trente-et-un centaines de fils) !",
            explanation: "💡 Le « trente-et-ain » était une étoffe précieuse de très haute qualité. Porter son « trente-et-ain » est devenu « se mettre sur son 31 ».",
            audioCueID: "q_FR_29"
        ),
        QuizMCQQuestion(
            id: "FR_30",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Appeler un chat un chat chez Nicolas Boileau",
            prompt: "Dans le célèbre vers de Boileau « J'appelle un chat un chat, et Rollet un ___ », quel mot rime avec chat ou complète la phrase ?",
            choices: [
                "un fripon",
                "un matou",
                "un cornichon",
                "un glouton"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "« J'appelle un chat un chat, et Rollet un fripon ! » Charles Rollet était un procureur parisien réputé malhonnête sous Louis XIV !",
            explanation: "💡 Nicolas Boileau a popularisé la formule en 1666 dans ses Satires en visant directement le procureur Charles Rollet.",
            audioCueID: "q_FR_30"
        ),
        QuizMCQQuestion(
            id: "FR_31",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Le grand piège des pluriels en -AL",
            prompt: "Quel est le pluriel exact des mots « un chacal », « un festival » et « un bal » ?",
            choices: [
                "Des chacaux, des festivaux et des baux",
                "Des chacals, des festivals et des bals",
                "Des chacaux, des festivals et des bals",
                "On dit « une meute de bestioles qui font la fête »"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Eh oui ! Bal, carnaval, chacal, festival, récital, régal prennent un S au pluriel : des chacals, des festivals, des bals !",
            explanation: "💡 La liste classique de l'école primaire : bal, carnaval, cérémonial, chacal, festival, récital et régal font leur pluriel en -als.",
            audioCueID: "q_FR_31"
        ),
        QuizMCQQuestion(
            id: "FR_32",
            theme: .francaisMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Quand le salon est complètement retourné",
            prompt: "Après le passage des petits-enfants dans le salon, tout est retourné ! Comment écrit-on correctement cette expression ?",
            choices: [
                "Sens dessus dessous",
                "Sans dessus dessous",
                "Cent dessus dessous",
                "Sang dessus dessous"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "C'est S-E-N-S ! À l'origine « c'en dessus dessous » : ce qui devait être en haut se retrouve en bas !",
            explanation: "💡 « Sens dessus dessous » vient de l'ancien français « c'en dessus dessous » (ce qui est dessus est mis dessous).",
            audioCueID: "q_FR_32"
        )
    ]

    // MARK: - 2B. +16 Nouvelles Questions 🧮 Maths & Calculs de Comptoir

    public static let extraMathQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "MATH_21",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Le piège classique de la boulangerie",
            prompt: "Un éclair au chocolat et un café coûtent 1,10 € en tout. L'éclair coûte 1,00 € de PLUS que le café. Combien coûte le café ?",
            choices: [
                "0,10 €",
                "0,05 €",
                "0,50 €",
                "Gratuit si on sourit à la boulangère"
            ],
            correctIndex: 1,
            baseValue: 2200,
            meemawRoastOnWrong: "Tombé dans le panneau ! Si le café coûtait 0,10 €, l'éclair coûterait 1,10 € et le total ferait 1,20 € ! C'est 0,05 € et 1,05 € !",
            explanation: "💡 Café = 0,05 €, Éclair = 1,05 € (soit bien 1 € de plus que le café), et 1,05 + 0,05 = 1,10 € !",
            audioCueID: "q_MATH_21"
        ),
        QuizMCQQuestion(
            id: "MATH_22",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Les nénuphars du bassin de Pépé",
            prompt: "Un nénuphar double de taille tous les jours dans le bassin. Il met 30 jours à recouvrir TOUT le bassin. En combien de jours recouvre-t-il la MOITIÉ du bassin ?",
            choices: [
                "15 jours",
                "29 jours",
                "20 jours",
                "Ça dépend s'il pleut en Bretagne"
            ],
            correctIndex: 1,
            baseValue: 2400,
            meemawRoastOnWrong: "Réfléchis deux secondes ! S'il double chaque jour et qu'il est plein au jour 30, la veille au jour 29 il était exactement à la moitié !",
            explanation: "💡 Puisque la surface double chaque jour, la moitié du bassin est atteinte exactement la veille du dernier jour : au 29e jour.",
            audioCueID: "q_MATH_22"
        ),
        QuizMCQQuestion(
            id: "MATH_23",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "La course cycliste du dimanche",
            prompt: "Tu participes au Tour du Village à vélo et tu dépasses le 2e de la course juste avant la ligne. À quelle place termines-tu ?",
            choices: [
                "1er, champion du monde !",
                "2e",
                "3e",
                "Dans le fossé avec les orties"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais non ! Si tu doubles le 2e, tu prends sa place de 2e ! Le 1er est toujours devant toi en train de boire sa limonade !",
            explanation: "💡 En dépassant le coureur en 2e position, on prend la 2e place ; le 1er reste en tête.",
            audioCueID: "q_MATH_23"
        ),
        QuizMCQQuestion(
            id: "MATH_24",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "La boîte à couture géométrique",
            prompt: "Combien de faces possède un dé à jouer classique (un cube), et quelle est la somme de deux faces opposées sur un vrai dé ?",
            choices: [
                "6 faces, et deux faces opposées font toujours 7 !",
                "8 faces, et deux faces opposées font 6",
                "6 faces, et deux faces opposées font 10",
                "4 faces quand Pépé triche au Yam's"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Un cube a 6 faces, et sur un dé officiel, les faces opposées font toujours 7 (1 face au 6, 2 face au 5, 3 face au 4) !",
            explanation: "💡 Sur tout dé standard à 6 faces, la somme de deux faces opposées vaut toujours 7.",
            audioCueID: "q_MATH_24"
        ),
        QuizMCQQuestion(
            id: "MATH_25",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Les chaussettes dans le noir",
            prompt: "Dans le tiroir de Meemaw, il y a 10 chaussettes bleues et 10 chaussettes rouges en vrac. Dans le noir complet, combien faut-il en tirer AU MINIMUM pour être 100 % sûr d'avoir une paire de la même couleur ?",
            choices: [
                "11 chaussettes",
                "3 chaussettes",
                "2 chaussettes",
                "20 chaussettes"
            ],
            correctIndex: 1,
            baseValue: 2200,
            meemawRoastOnWrong: "C'est le principe des tiroirs ! Comme il n'y a que 2 couleurs (bleu ou rouge), dès que tu prends 3 chaussettes, tu en as forcément au moins 2 pareilles !",
            explanation: "💡 C'est le principe des tiroirs de Dirichlet : avec 2 couleurs possibles, 3 tirages garantissent au moins 2 chaussettes identiques.",
            audioCueID: "q_MATH_25"
        ),
        QuizMCQQuestion(
            id: "MATH_26",
            theme: .mathMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "La promo trompeuse du supermarché",
            prompt: "Un pull coûte 100 €. Il augmente d'abord de +20 %, puis la semaine suivante il baisse de -20 %. Quel est son nouveau prix ?",
            choices: [
                "100 €",
                "96 €",
                "104 €",
                "80 €"
            ],
            correctIndex: 1,
            baseValue: 2500,
            meemawRoastOnWrong: "Eh non, les pourcentages ne s'annulent pas ! 100 € + 20 % = 120 €. Et 20 % de 120 €, ça fait 24 € de remise : 120 - 24 = 96 € !",
            explanation: "💡 100 × 1,20 = 120 €, puis 120 × 0,80 = 96 €.",
            audioCueID: "q_MATH_26"
        ),
        QuizMCQQuestion(
            id: "MATH_27",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Le gâteau coupé en 3 coups de couteau",
            prompt: "En coupant un clafoutis bien rond avec 3 coups de couteau droits (sans empiler les parts), quel est le nombre MAXIMUM de parts qu'on peut obtenir ?",
            choices: [
                "6 parts",
                "7 parts",
                "8 parts",
                "1 seule grosse part pour Tonton"
            ],
            correctIndex: 1,
            baseValue: 2200,
            meemawRoastOnWrong: "Si tes 3 coupes ne passent pas toutes par le même point au milieu, la 3e coupe traverse les deux premières et crée une 7e part au centre !",
            explanation: "💡 C'est la suite du découpage de crêpe : 1 coupe = 2 parts, 2 coupes = 4 parts, 3 coupes = 7 parts (et 8 si on coupe aussi à l'horizontale en 3D).",
            audioCueID: "q_MATH_27"
        ),
        QuizMCQQuestion(
            id: "MATH_28",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Priorité des opérations au PMU",
            prompt: "Combien font exactement : 5 + 5 × 5 - 5 ?",
            choices: [
                "45",
                "25",
                "0",
                "50"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "La multiplication est toujours prioritaire ! On calcule d'abord 5 × 5 = 25, puis 5 + 25 - 5 = 25 !",
            explanation: "💡 Règle PEMDAS : 5 × 5 = 25, puis 5 + 25 - 5 = 25.",
            audioCueID: "q_MATH_28"
        )
    ]

    // MARK: - 3B. +16 Nouvelles Questions 🍿 Séries, Cinéma & TV Culte

    public static let extraSeriesCinemaQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "CINE_29",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Le dîner de cons du mercredi soir",
            prompt: "Dans « Le Dîner de cons », quelle est la grande passion de François Pignon (Jacques Villeret) qu'il veut absolument montrer à Pierre Brochant ?",
            choices: [
                "Les maquettes géantes en allumettes",
                "La collection de capsules de bière tiède",
                "L'élevage de hamsters acrobates",
                "Les boomerangs en carton-pâte"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "346 422 allumettes et 28 tubes de colle pour la tour Eiffel et le pont de Tancarville ! Un chef-d'œuvre !",
            explanation: "💡 François Pignon réalise d'immenses maquettes d'ouvrages d'art en allumettes dans la comédie culte de Francis Veber (1998).",
            audioCueID: "q_CINE_29"
        ),
        QuizMCQQuestion(
            id: "CINE_30",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Les Bronzés font du ski : la liqueur du chalet",
            prompt: "Dans « Les Bronzés font du ski », quel animal bien baveux flotte au fond de la bouteille d'alcool fort (« la fougère ») servie par les montagnards ?",
            choices: [
                "Un crapaud",
                "Un écureuil des Alpes",
                "Une truite arc-en-ciel",
                "Un vieux chausson de ski"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est un gros crapaud au fond de la bouteille ! « Mais c'est goûtu, c'est de l'alcool de crapaud ! »",
            explanation: "💡 Dans la scène culte du refuge, les paysans servent une eau-de-vie d'échalote macérée avec un crapaud au fond de la bouteille.",
            audioCueID: "q_CINE_30"
        ),
        QuizMCQQuestion(
            id: "CINE_31",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "OSS 117 et la blanquette",
            prompt: "Dans « OSS 117 : Le Caire, nid d'espions », comment est la blanquette selon Hubert Bonisseur de La Bath ?",
            choices: [
                "La blanquette est bonne !",
                "Elle manque d'un soupçon de muscade",
                "Elle est trop froide",
                "C'est un couscous déguisé"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Comment est votre blanquette ? — La blanquette est bonne ! » Le mot de passe le plus gastronomique de l'histoire de l'espionnage !",
            explanation: "💡 Réplique culte de Jean Dujardin dans OSS 117 : Le Caire, nid d'espions (Michel Hazanavicius, 2006).",
            audioCueID: "q_CINE_31"
        ),
        QuizMCQQuestion(
            id: "CINE_32",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "La Cité de la Peur : le goûter d'Odile",
            prompt: "Dans « La Cité de la peur » des Nuls, que faut-il prendre d'abord quand on vous attaque (« Vous voulez un whisky ? ») ?",
            choices: [
                "Juste un doigt",
                "Une tisane verveine-menthe",
                "Un chewing-gum Émile",
                "Une gencive de porc"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« — Vous voulez un whisky ? — Oh, juste un doigt. — Vous ne voulez pas un whisky d'abord ? » Classique absolu !",
            explanation: "💡 Échange culte entre Simon Jérémi (Dominique Farrugia) et Odile Deray (Chantal Lauby) dans La Cité de la peur (1994).",
            audioCueID: "q_CINE_32"
        ),
        QuizMCQQuestion(
            id: "CINE_33",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Astérix et Obélix : Mission Cléopâtre",
            prompt: "Selon le scribe Otis (Édouard Baer) dans son monologue légendaire, qu'est-ce qu'une bonne ou une mauvaise situation ?",
            choices: [
                "Il n'y a pas de bonne ou de mauvaise situation, c'est avant tout des rencontres !",
                "Une bonne situation c'est 13 mois de salaire et une place de parking",
                "C'est d'habiter face aux pyramides",
                "C'est d'avoir du pudding à l'arsenic au dessert"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Vous savez, moi je ne crois pas qu'il y ait de bonne ou de mauvaise situation... C'est avant tout des rencontres ! »",
            explanation: "💡 Improvisation mythique d'Édouard Baer dans Astérix & Obélix : Mission Cléopâtre d'Alain Chabat (2002).",
            audioCueID: "q_CINE_33"
        ),
        QuizMCQQuestion(
            id: "CINE_34",
            theme: .seriesCinema,
            preferredRound: .finaleDouble,
            funnyTitle: "Retour vers le Futur : la vitesse de la DeLorean",
            prompt: "Dans « Retour vers le futur », quelle vitesse exacte (en miles par heure) la DeLorean de Doc Brown doit-elle atteindre pour voyager dans le temps ?",
            choices: [
                "88 miles par heure",
                "100 miles par heure",
                "50 km/h",
                "2,21 gigowatts par heure"
            ],
            correctIndex: 0,
            baseValue: 2400,
            meemawRoastOnWrong: "Nom de Zeus ! C'est 88 miles par heure (et 2,21 gigowatts d'énergie électrique) !",
            explanation: "💡 La DeLorean DMC-12 doit atteindre exactement 88 mph (141,6 km/h) pour activer le convecteur temporel.",
            audioCueID: "q_CINE_34"
        ),
        QuizMCQQuestion(
            id: "CINE_35",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Kaamelott : la technique du gras",
            prompt: "Dans la série « Kaamelott », quel est le proverbe fétiche de Karadoc (Jean-Christophe Hembert) concernant la charcuterie ?",
            choices: [
                "Le gras, c'est la vie !",
                "Un saucisson par jour éloigne le médecin",
                "Qui mange du lard va moins au placard",
                "Pas de rillettes, pas de conquête"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Le gras, c'est la vie ! » Et il garde même une petite réserve de charcuterie sous son oreiller en cas d'insomnie !",
            explanation: "💡 Devise gastronomique célèbre du chevalier Karadoc de Vannes dans Kaamelott d'Alexandre Astier.",
            audioCueID: "q_CINE_35"
        ),
        QuizMCQQuestion(
            id: "CINE_36",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "Le Père Noël est une ordure : le cadeau de Thérèse",
            prompt: "Dans « Le Père Noël est une ordure », comment Pierre Mortez (Thierry Lhermitte) réagit-il en découvrant le gilet tricoté par Thérèse avec des trous sous les bras ?",
            choices: [
                "« Oh, une serpillière ! C'est formidable, Thérèse ! »",
                "« Il est un peu serré aux entournures »",
                "« Je vais le mettre pour aller au bal des pompiers »",
                "« C'est exactement ma couleur préférée : gris poussière »"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "« Oh, une serpillière ! C'est formidable Thérèse, je suis ravi ! — Mais non Pierre, c'est un gilet ! »",
            explanation: "💡 Scène d'anthologie du Splendid (1982) entre Thierry Lhermitte et Anémone.",
            audioCueID: "q_CINE_36"
        )
    ]

    // MARK: - 4B. +20 Nouvelles Questions 🎧 Jukebox Express & Musique Culte

    public static let extraMusiqueAndJukeboxQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "JUK_13",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Les Lacs du Connemara au mariage",
            prompt: "Complète les paroles de Michel Sardou avant que tout le monde ne fasse tourner les serviettes : « Terre brûlée au vent, des landes de ___ »",
            choices: [
                "pierres",
                "bières",
                "bruyères",
                "pommes de terre"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Terre brûlée au vent, des landes de PIERRES ! » Tu n'as jamais fait tourner ta serviette à 3h du matin ou quoi ?!",
            explanation: "💡 Sorti en 1981, Les Lacs du Connemara commence par « Terre brûlée au vent, des landes de pierres, autour des lacs, c'est pour les vivants ».",
            audioCueID: "q_JUK_13"
        ),
        QuizMCQQuestion(
            id: "JUK_14",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Les Démons de minuit",
            prompt: "Complète le refrain du groupe Images (1986) : « Ils m'entraînent au bout de la nuit, les démons de minuit, m'entraînent jusqu'à ___ »",
            choices: [
                "l'insomnie",
                "la boulangerie",
                "la mairie",
                "l'Italie"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« M'entraînent jusqu'à l'insomnie, les fantômes de l'ennui ! » Un tube 100 % synthétiseur années 80 !",
            explanation: "💡 Les Démons de minuit du groupe Images est resté 13 semaines n°1 du Top 50 en 1986.",
            audioCueID: "q_JUK_14"
        ),
        QuizMCQQuestion(
            id: "JUK_15",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Céline Dion dans le salon",
            prompt: "Complète le cri du cœur de Céline Dion dans « J'irai où tu iras » (écrit par Goldman) : « J'irai où tu iras, mon pays sera ___ »",
            choices: [
                "toi",
                "froid",
                "plat",
                "chez moi"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« J'irai où tu iras, mon pays sera TOI ! » Duo explosif entre Céline Dion et Jean-Jacques Goldman sur l'album D'eux (1995) !",
            explanation: "💡 Extrait de l'album D'eux (1995), l'album francophone le plus vendu de l'histoire.",
            audioCueID: "q_JUK_15"
        ),
        QuizMCQQuestion(
            id: "JUK_16",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Le tube planétaire de Stromae (2009)",
            prompt: "Dans le tube planétaire de Stromae (2009), que fait-on après une grosse journée de galère : « Alors on ___ » ?",
            choices: [
                "danse !",
                "dort !",
                "mange !",
                "râle !"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Alors on danse ! » Même Meemaw bouge les épaules quand le saxophone démarre !",
            explanation: "💡 « Alors on danse » (2009) a propulsé Stromae en tête des classements dans plus de 15 pays.",
            audioCueID: "q_JUK_16"
        ),
        QuizMCQQuestion(
            id: "JUK_17",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : La Tribu de Dana",
            prompt: "Complète le premier vers mythique du groupe Manau (1998) : « Le vent souffle sur les plaines de la Bretagne ___ »",
            choices: [
                "armoricaine",
                "américaine",
                "au beurre demi-sel",
                "sous la pluie"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« De la Bretagne armoricaine ! » Tout le monde a essayé de rapper ce couplet sans reprendre son souffle en 1998 !",
            explanation: "💡 La Tribu de Dana de Manau s'est écoulé à plus de 1,7 million d'exemplaires en 1998.",
            audioCueID: "q_JUK_17"
        ),
        QuizMCQQuestion(
            id: "JUK_18",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Gilbert Montagné sous les tropiques",
            prompt: "Complète le refrain solaire de Gilbert Montagné : « Sous les sunlights des tropiques, l'amour se raconte en ___ »",
            choices: [
                "musique",
                "tunique",
                "boutique",
                "Martinique"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« L'amour se raconte en MUSIQUE ! » Impossible de rester assis quand ce refrain démarre !",
            explanation: "💡 Sorti en 1984 et écrit avec Didier Barbelivien, Les Sunlights des tropiques est un classique absolu des soirées françaises.",
            audioCueID: "q_JUK_18"
        ),
        QuizMCQQuestion(
            id: "JUK_19",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Indochine et l'Aventurier",
            prompt: "Dans « L'Aventurier » d'Indochine (1982), comment s'appelle le héros qui est « le roi de tous les vauriens » ?",
            choices: [
                "Bob Morane",
                "Jean-Claude Van Damme",
                "Rahan fils des âges farouches",
                "Inspecteur Gadget"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Et soudain surgit face au vent, le vrai héros de tous les temps : Bob Morane contre tout chacal ! »",
            explanation: "💡 Nicola Sirkis rend hommage au héros des romans d'Henri Vernes, Bob Morane, dans ce tube de 1982.",
            audioCueID: "q_JUK_19"
        ),
        QuizMCQQuestion(
            id: "JUK_20",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : L'entrée de scène de Johnny Hallyday",
            prompt: "Complète l'entrée fracassante de Johnny Hallyday : « Il suffira d'une étincelle, d'un rien, d'un geste, il suffira d'une étincelle, et d'un mot d'amour pour ___ »",
            choices: [
                "allumer le feu !",
                "cuire le rôti !",
                "appeler les pompiers !",
                "faire sauter les plombs !"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Pour ALLUMER LE FEU ! » Écrit par Zazie et Pascal Obispo pour le concert de Johnny au Stade de France en 1998 !",
            explanation: "💡 Allumer le feu (1998) a été composé par Pascal Obispo et écrit par Zazie pour Johnny Hallyday.",
            audioCueID: "q_JUK_20"
        ),
        QuizMCQQuestion(
            id: "JUK_21",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Louise Attaque t'invite au goûter",
            prompt: "Complète le tube de Louise Attaque (1997) : « J't'emmène au vent, je t'emmène au-dessus des gens, et je voudrais que tu te rappelles, notre amour est éternel et pas ___ »",
            choices: [
                "artificiel !",
                "confidentiel !",
                "un pot de miel !",
                "superficiel !"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Notre amour est éternel et pas ARTIFICIEL ! » Avec le solo de violon qui rend fou tout le salon !",
            explanation: "💡 J't'emmène au vent (1997) est le titre phare du premier album de Louise Attaque.",
            audioCueID: "q_JUK_21"
        ),
        QuizMCQQuestion(
            id: "JUK_22",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Claude François et le téléphone",
            prompt: "Dans « Le Téléphone pleure » de Claude François (1974), quel âge a la petite fille au bout du fil (« Dis à ta mère que je suis en voyage... ») ?",
            choices: [
                "Elle a 6 ans",
                "Elle a 18 ans et passe son permis",
                "Elle a 2 mois et parle déjà trois langues",
                "C'est le démarcheur pour l'isolation à 1 €"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est la petite Frédérique, 6 ans, qui donnait la réplique au téléphone dans ce slow lacrymal de 1974 !",
            explanation: "💡 Le Téléphone pleure (1974) a dépassé les 2 millions de 45 tours vendus en France.",
            audioCueID: "q_JUK_22"
        ),
        QuizMCQQuestion(
            id: "JUK_23",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Diam's et la Boulette",
            prompt: "Complète la punchline culte de Diam's dans « La Boulette » (2006) : « Mais il y a un truc qui cloche, ___ »",
            choices: [
                "le contenu de nos poches !",
                "le bruit de la cloche !",
                "la coupe de mes proches !",
                "le gratin de patates sur la brioche !"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Mais y'a un truc qui cloche : le contenu de nos poches ! » Tout le monde connaît ce couplet par cœur !",
            explanation: "💡 Extrait de l'album Dans ma bulle (2006) de Diam's, certifié disque de diamant.",
            audioCueID: "q_JUK_23"
        ),
        QuizMCQQuestion(
            id: "JUK_24",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Daniel Balavoine et l'Aziza",
            prompt: "Complète le refrain de Daniel Balavoine (1985) : « L'Aziza, ton étoile ___ »",
            choices: [
                "jaune, c'est ta peau, tu n'as pas le choix !",
                "file dans le ciel du soir",
                "brille au-dessus des toits",
                "danse la samba"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« L'Aziza, ton étoile jaune, c'est ta peau, tu n'as pas le choix, ne la porte pas comme on porte un fardeau ! »",
            explanation: "💡 Écrite en 1985 par Daniel Balavoine pour son épouse Corinne, L'Aziza est un hymne contre le racisme.",
            audioCueID: "q_JUK_24"
        ),
        QuizMCQQuestion(
            id: "JUK_25",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Queen et le karaoké de minuit",
            prompt: "Dans « Bohemian Rhapsody » de Queen (1975), quel nom d'astronome célèbre est répété dans la partie opéra après « Scaramouche, Scaramouche, will you do the Fandango » ?",
            choices: [
                "Galileo !",
                "Copernic !",
                "Thomas Pesquet !",
                "Nostradamus !"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Galileo ! Galileo ! Galileo Figaro ! Magnifico-o-o-o ! » Attention aux cordes vocales dans les aigus !",
            explanation: "💡 Freddie Mercury et Roger Taylor ont superposé des dizaines de pistes vocales pour le passage « Galileo » de Bohemian Rhapsody.",
            audioCueID: "q_JUK_25"
        ),
        QuizMCQQuestion(
            id: "JUK_26",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎧 Jukebox : Téléphone et Cendrillon",
            prompt: "Comment commence la chanson « Cendrillon » du groupe Téléphone (1982) ?",
            choices: [
                "« Cendrillon pour ses vingt ans, est la plus jolie des enfants... »",
                "« Cendrillon a perdu sa pantoufle sur le périphérique... »",
                "« Il était une fois une citrouille bio... »",
                "« Un autre monde, super ! »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Cendrillon pour ses vingt ans, est la plus jolie des enfants, son bel amant le prince charmant la prend sur son cheval blanc ! »",
            explanation: "💡 Cendrillon (1982), chantée par Louis Bertignac au sein du groupe Téléphone, est un classique du rock français.",
            audioCueID: "q_JUK_26"
        )
    ]

    // MARK: - 5B. +16 Nouvelles Questions 🌍 Culture G Insolite & Animaux Absurdes

    public static let extraCultureGQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "CUL_23",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "Les crottes géométriques de la nature",
            prompt: "Quel animal australien est le seul au monde à faire des crottes en forme de CUBE parfait (pour ne pas qu'elles roulent en bas des collines) ?",
            choices: [
                "Le wombat",
                "Le kangourou",
                "L'ornithorynque",
                "Le koala après trois cafés"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le wombat ! Il empile des petits dés carrés sur les rochers pour marquer son territoire sans que ça roule !",
            explanation: "💡 Grâce à l'élasticité variable de son intestin, le wombat produit jusqu'à 100 petits cubes par nuit (études récompensées d'un prix Ig-Nobel).",
            audioCueID: "q_CUL_23"
        ),
        QuizMCQQuestion(
            id: "CUL_24",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "La Grande Guerre contre les oiseaux",
            prompt: "En 1932, l'armée australienne a déployé des soldats armés de mitrailleuses contre quel animal... et a officiellement PERDU la guerre ?",
            choices: [
                "Les émeus",
                "Les kangourous boxeurs",
                "Les mouettes voleuses de frites",
                "Les lapins géants"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "La Guerre des Émeus ! 20 000 gros oiseaux coureurs ont esquivé les mitrailleuses de l'armée pendant un mois entier !",
            explanation: "💡 En novembre 1932, l'armée australienne a tenté d'endiguer une invasion de 20 000 émeus dans les champs de blé, avant de battre en retraite.",
            audioCueID: "q_CUL_24"
        ),
        QuizMCQQuestion(
            id: "CUL_25",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            funnyTitle: "Le pays le plus proche de la France (attention piège !)",
            prompt: "Avec quel pays la France partage-t-elle sa plus LONGUE frontière terrestre (730 kilomètres) ?",
            choices: [
                "Le Brésil",
                "L'Espagne",
                "L'Allemagne",
                "La Belgique"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Eh oui, c'est le Brésil ! Grâce à la Guyane, la frontière franco-brésilienne fait 730 km, devant l'Espagne (623 km) et la Belgique (620 km) !",
            explanation: "💡 La frontière entre la Guyane française et le Brésil mesure 730 km, ce qui en fait la plus longue frontière terrestre de la France.",
            audioCueID: "q_CUL_25"
        ),
        QuizMCQQuestion(
            id: "CUL_26",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "La boîte noire de l'avion",
            prompt: "De quelle couleur est réellement la « boîte noire » d'un avion de ligne (pour qu'on la retrouve facilement au fond de l'océan ou dans les débris) ?",
            choices: [
                "Orange fluo vif",
                "Noir mat",
                "Jaune canari à pois bleus",
                "Transparente"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Une boîte noire est ORANGE FLUO ! Si elle était noire au milieu du charbon ou au fond de l'eau, bon courage pour la retrouver !",
            explanation: "💡 Les enregistreurs de vol sont peints en « International Orange » fluo pour maximiser leur visibilité lors des recherches.",
            audioCueID: "q_CUL_26"
        ),
        QuizMCQQuestion(
            id: "CUL_27",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Les cœurs de la pieuvre",
            prompt: "Combien de cœurs possède une pieuvre (un poulpe), et de quelle couleur est son sang ?",
            choices: [
                "3 cœurs et le sang bleu !",
                "1 cœur et le sang rouge",
                "8 cœurs",
                "2 cœurs et le sang vert fluo"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Elle a 3 cœurs (deux pour les branchies, un pour le corps) et le sang bleu à cause du cuivre (hémocyanine) qui remplace le fer !",
            explanation: "💡 Les céphalopodes possèdent 3 cœurs et un sang bleu riche en cuivre (hémocyanine), plus efficace dans les eaux froides.",
            audioCueID: "q_CUL_27"
        ),
        QuizMCQQuestion(
            id: "CUL_28",
            theme: .cultureGInsolite,
            preferredRound: .finaleDouble,
            funnyTitle: "Cléopâtre et la machine à remonter le temps",
            prompt: "De quel événement historique la reine Cléopâtre (morte en 30 av. J.-C.) était-elle chronologiquement la PLUS PROCHE ?",
            choices: [
                "Du premier pas sur la Lune et de l'iPhone",
                "De la construction de la pyramide de Khéops",
                "De l'extinction des dinosaures",
                "De la naissance de Meemaw"
            ],
            correctIndex: 0,
            baseValue: 2500,
            meemawRoastOnWrong: "Incroyable mais vrai ! Khéops a été bâtie vers 2560 av. J.-C. (2 530 ans avant Cléopâtre), alors qu'Apollo 11 a eu lieu 1 999 ans après elle !",
            explanation: "💡 Plus de 2 500 ans séparent la pyramide de Khéops de Cléopâtre, contre seulement 2 000 ans entre Cléopâtre et notre époque.",
            audioCueID: "q_CUL_28"
        ),
        QuizMCQQuestion(
            id: "CUL_29",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "L'inventeur de la barbe à papa",
            prompt: "Quel était le vrai métier de William Morrison, l'homme qui a co-inventé la machine à barbe à papa en 1897 ?",
            choices: [
                "Il était DENTISTE",
                "Il était coiffeur pour caniches",
                "Il était fabricant de matelas en laine",
                "Il était pompier"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Un dentiste du Tennessee ! Vendre du sucre filé le dimanche pour facturer des plombages le lundi, quel génie du commerce !",
            explanation: "💡 Le dentiste William Morrison et le confiseur John C. Wharton ont breveté la machine à « Fairy Floss » (barbe à papa) en 1897.",
            audioCueID: "q_CUL_29"
        ),
        QuizMCQQuestion(
            id: "CUL_30",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            funnyTitle: "La vitesse d'un éternuement de Pépé",
            prompt: "Quand Pépé éternue à plein poumons au milieu du repas de famille, à quelle vitesse approximative l'air sort-il de son nez ?",
            choices: [
                "Environ 160 km/h",
                "Environ 12 km/h",
                "Environ 1 200 km/h",
                "2 km/h"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Jusqu'à 160 km/h ! Voilà pourquoi Meemaw met toujours un couvercle sur la blanquette quand Pépé renifle !",
            explanation: "💡 Un éternuement expulse des gouttelettes d'air à une vitesse comprise entre 150 et 160 km/h.",
            audioCueID: "q_CUL_30"
        )
    ]

    // MARK: - 6B. +16 Nouvelles Questions 💶 Éco, Vie Quotidienne & Arnaques

    public static let extraEcoCashQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "ECO_21",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "La « réduflation » au rayon gâteaux",
            prompt: "Comment appelle-t-on la technique marketing qui consiste à réduire le poids d'un paquet de biscuits (ex: de 250 g à 210 g) tout en gardant le MÊME prix ?",
            choices: [
                "La « shrinkflation »",
                "La déflation chocolatée",
                "Le régime forcé de Meemaw",
                "Le cashback inversé"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est la « shrinkflation » (réduflation) ! Moins de pépites dans le paquet, mais autant de sous qui sortent du porte-monnaie !",
            explanation: "💡 Depuis 2024 en France, les grandes surfaces ont l'obligation d'afficher une mention lorsque la quantité d'un produit diminue sans baisse de prix.",
            audioCueID: "q_ECO_21"
        ),
        QuizMCQQuestion(
            id: "ECO_22",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Les pièces rouges dans le cochon de Meemaw",
            prompt: "Lors d'un paiement en espèces chez un commerçant en France, quel est le nombre MAXIMUM de pièces de monnaie qu'il est légalement obligé d'accepter d'un coup ?",
            choices: [
                "50 pièces maximum",
                "Illimité, même une brouette de 10 000 pièces de 1 centime",
                "10 pièces maximum",
                "Uniquement les pièces qui brillent"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "La loi européenne fixe la limite à 50 pièces par paiement ! Donc inutile d'aller payer ta télé avec 40 000 pièces de 1 centime !",
            explanation: "💡 Selon le règlement européen n° 974/98, nul n'est tenu d'accepter plus de 50 pièces lors d'un seul paiement.",
            audioCueID: "q_ECO_22"
        ),
        QuizMCQQuestion(
            id: "ECO_23",
            theme: .ecoCash,
            preferredRound: .leSolo,
            funnyTitle: "Le code secret à 3 chiffres de la Carte Bleue",
            prompt: "Comment s'appelle officiellement le code de sécurité à 3 chiffres inscrit au dos de ta carte bancaire (que les escrocs au téléphone essaient toujours de gratter) ?",
            choices: [
                "Le cryptogramme visuel",
                "Le code IBAN de secours",
                "Le numéro de Sécu du banquier",
                "L'identifiant RIB"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le cryptogramme visuel (CVV) ! Et comme dit Meemaw : même si le type au téléphone dit s'appeler la Banque de France, on ne le donne JAMAIS !",
            explanation: "💡 Le CVV (Card Verification Value) ou cryptogramme visuel valide les achats à distance.",
            audioCueID: "q_ECO_23"
        ),
        QuizMCQQuestion(
            id: "ECO_24",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Les billets d'euros et leurs monuments",
            prompt: "De quel pays d'Europe proviennent les ponts et les fenêtres dessinés sur les billets de 5 €, 10 €, 20 €, 50 € et 100 € ?",
            choices: [
                "D'aucun pays : ce sont des ponts 100 % fictifs",
                "Uniquement des ponts français et allemands",
                "Tous les ponts sont à Rome",
                "C'est le viaduc de Millau sous 7 angles différents"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Ils étaient totalement imaginaires pour ne favoriser aucun pays ! Mais la ville de Spijkenisse aux Pays-Bas a fini par construire les 7 ponts en vrai pour rigoler !",
            explanation: "💡 Le graphiste Robert Kalina a dessiné des ponts fictifs représentatifs des styles européens ; en 2011, la ville néerlandaise de Spijkenisse les a réellement construits !",
            audioCueID: "q_ECO_24"
        ),
        QuizMCQQuestion(
            id: "ECO_25",
            theme: .ecoCash,
            preferredRound: .finaleDouble,
            funnyTitle: "Le délai de rétractation après un achat impulsif",
            prompt: "Tu as commandé sur Internet à 2h du matin une machine à gaufres en forme de dinosaure. De combien de jours disposes-tu légalement en France pour changer d'avis après réception ?",
            choices: [
                "14 jours",
                "24 heures chrono",
                "365 jours si les gaufres sont brûlées",
                "Aucun, il faut assumer le tyrannosaure au Nutella"
            ],
            correctIndex: 0,
            baseValue: 2400,
            meemawRoastOnWrong: "Tu as 14 jours francs à compter de la réception du colis pour exercer ton droit de rétractation sans même avoir à te justifier !",
            explanation: "💡 La loi Hamon garantit un délai minimum de 14 jours pour se rétracter d'un achat effectué en ligne ou par téléphone.",
            audioCueID: "q_ECO_25"
        ),
        QuizMCQQuestion(
            id: "ECO_26",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "L'heure creuse du lave-vaisselle",
            prompt: "Dans un foyer français moyen (hors chauffage et eau chaude), quel appareil électroménager tourne 24h/24 et représente l'un des plus gros postes sur la facture d'électricité ?",
            choices: [
                "Le combiné réfrigérateur-congélateur",
                "Le grille-pain du matin",
                "Le réveil-matin électrique",
                "La brosse à dents rechargeable"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le frigo-congélateur ! Et dès qu'il y a 3 mm de givre sur les parois, sa consommation grimpe de 30 % !",
            explanation: "💡 Parce qu'il fonctionne 365 jours par an sans interruption, le froid (réfrigérateur + congélateur) est l'un des principaux postes électriques hors chauffage.",
            audioCueID: "q_ECO_26"
        )
    ]

    // MARK: - 7B. +8 Nouvelles Manches 🧀 La Raclette Quizz (48 nouvelles questions binaires !)

    public static let extraDisOrDatRounds: [QuizDisOrDatRound] = [
        QuizDisOrDatRound(
            id: "RAC_09",
            theme: .francaisMeemaw,
            funnyTitle: "🧀 Raclette : Mot du Dictionnaire ou Invention de Tonton ?",
            prompt: "Ce mot bizarre existe-t-il au dictionnaire, est-ce une blague de Tonton, ou LES DEUX ?",
            optionLeft: "📖 VRAI MOT DU DICO",
            optionRight: "🍷 INVENTION DE TONTON",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "« Callipyge »", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "« Pétrichor »", correctSide: "left"),
                QuizDisOrDatItem(index: 2, text: "« Ronflomètre à soupape »", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "« Tintinnabuler »", correctSide: "left"),
                QuizDisOrDatItem(index: 4, text: "« Dorlotarium »", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "« Boustifaille »", correctSide: "both")
            ],
            audioCueID: "q_RAC_09",
            isPunRound: false
        ),
        QuizDisOrDatRound(
            id: "RAC_10",
            theme: .seriesCinema,
            funnyTitle: "🧀 Raclette : Louis de Funès, Bourvil, ou LES DEUX ?",
            prompt: "Dans quel film retrouve-t-on Louis de Funès, Bourvil, ou le duo légendaire réuni ?",
            optionLeft: "🚓 LOUIS DE FUNÈS",
            optionRight: "🚲 BOURVIL",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "« La Grande Vadrouille »", correctSide: "both"),
                QuizDisOrDatItem(index: 1, text: "« Le Corniaud »", correctSide: "both"),
                QuizDisOrDatItem(index: 2, text: "« Rabbi Jacob »", correctSide: "left"),
                QuizDisOrDatItem(index: 3, text: "« La Traversée de Paris »", correctSide: "both"),
                QuizDisOrDatItem(index: 4, text: "« Le Cerveau »", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "« L'Aile ou la Cuisse »", correctSide: "left")
            ],
            audioCueID: "q_RAC_10",
            isPunRound: false
        ),
        QuizDisOrDatRound(
            id: "RAC_11",
            theme: .cultureGInsolite,
            funnyTitle: "🧀 Raclette : Fruit Botanique, Légume de Cuisine, ou LES DEUX ?",
            prompt: "Attention au piège entre le botaniste et la casserole de Meemaw !",
            optionLeft: "🍓 FRUIT BOTANIQUE",
            optionRight: "🥕 LÉGUME (PLANTE POTAGÈRE)",
            optionBoth: "🧀 LES DEUX !",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "La tomate", correctSide: "both"),
                QuizDisOrDatItem(index: 1, text: "La carotte", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "La rhubarbe", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "Le poivron", correctSide: "both"),
                QuizDisOrDatItem(index: 4, text: "Le poireau", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "L'avocat", correctSide: "both")
            ],
            audioCueID: "q_RAC_11",
            isPunRound: false
        ),
        QuizDisOrDatRound(
            id: "RAC_12",
            theme: .musiqueTubes,
            funnyTitle: "🧀 Raclette : Tube des Années 80, des Années 90, ou LES DEUX ?",
            prompt: "En quelle décennie ce tube a-t-il fait trembler le poste cassette de la R5 ?",
            optionLeft: "🕺 ANNÉES 80",
            optionRight: "💿 ANNÉES 90",
            optionBoth: "🧀 LES DEUX (REPRISE / HYMNE) !",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "« Les Démons de minuit »", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "« La Tribu de Dana »", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "« I Will Survive »", correctSide: "both"),
                QuizDisOrDatItem(index: 3, text: "« Foule sentimentale »", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "« L'Aventurier »", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "« Pour que tu m'aimes encore »", correctSide: "right")
            ],
            audioCueID: "q_RAC_12",
            isPunRound: false
        ),
        QuizDisOrDatRound(
            id: "RAC_13",
            theme: .mathMeemaw,
            funnyTitle: "🧀 Raclette : Moins de 100, Plus de 100, ou PILE 100 ?",
            prompt: "Calcul mental ultra-rapide sans sortir la calculette du téléphone !",
            optionLeft: "📉 MOINS DE 100",
            optionRight: "📈 PLUS DE 100",
            optionBoth: "🧀 PILE 100 !",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "9 × 11", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "25 × 4", correctSide: "both"),
                QuizDisOrDatItem(index: 2, text: "12 × 9", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "Le nombre de départements français en tout", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "La température d'ébullition de l'eau pure au niveau de la mer", correctSide: "both"),
                QuizDisOrDatItem(index: 5, text: "7 × 14", correctSide: "left")
            ],
            audioCueID: "q_RAC_13",
            isPunRound: false
        ),
        QuizDisOrDatRound(
            id: "RAC_14",
            theme: .ecoCash,
            funnyTitle: "🧀 Raclette : Gratuit par la Loi, Payant, ou Ça Dépend ?",
            prompt: "Au restaurant ou au quotidien en France, qu'est-ce qui est obligatoirement gratuit ?",
            optionLeft: "🆓 100 % GRATUIT PAR LA LOI",
            optionRight: "💶 PAYANT",
            optionBoth: "🧀 ÇA DÉPEND / LES DEUX !",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "La carafe d'eau et le pain pendant un repas au restaurant en France", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "L'accès aux toilettes dans un restaurant pour les clients attablés", correctSide: "left"),
                QuizDisOrDatItem(index: 2, text: "Les sacs plastiques ou papier à la caisse du supermarché", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "Le gonflage des pneus en station-service", correctSide: "both"),
                QuizDisOrDatItem(index: 4, text: "L'appel aux numéros d'urgence", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "Le remplacement d'une carte bancaire perdue avant sa date d'expiration", correctSide: "both")
            ],
            audioCueID: "q_RAC_14",
            isPunRound: false
        )
    ]

    // MARK: - 8. 🪤 Les Sponsors Bidons de Mamie (« Wrong Answer of the Game » façon YDKJ)

    public static let allSponsors: [MeemawSponsor] = [
        MeemawSponsor(
            id: "SPON_01",
            name: "Les Pantoufles Charentaises Turbo-Grip™",
            slogan: "« Pour déraper dans le couloir sans perdre son dentier ! »",
            hintKeyword: "Pantoufles / Charentaises",
            trapChoiceText: "Des pantoufles charentaises à semelle Turbo-Grip™",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "SPON_02",
            name: "Le Camembert Artisanal Le Parfumé™",
            slogan: "« Affiné sous le radiateur depuis 1984 : il marche tout seul jusqu'à la table ! »",
            hintKeyword: "Camembert Le Parfumé",
            trapChoiceText: "Un Camembert Le Parfumé™ oublié sous le radiateur",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "SPON_03",
            name: "La Tisane Sommeil de Plomb™",
            slogan: "« Une gorgée à 20h05, un ronflement dès le générique du JT ! »",
            hintKeyword: "Tisane Sommeil de Plomb",
            trapChoiceText: "Deux litres de Tisane Sommeil de Plomb™ à la verveine",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "SPON_04",
            name: "Le Caddie à 6 Roues Tout-Terrain MamieCross™",
            slogan: "« Franchit les trottoirs et écrase les pieds des resquilleurs au marché ! »",
            hintKeyword: "Caddie MamieCross",
            trapChoiceText: "Un caddie à 6 roues tout-terrain MamieCross™",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "SPON_05",
            name: "Les Bonbons à la Menthe Vieux-Plombage™",
            slogan: "« Collés au fond du sac à main avec trois mouchoirs et deux tickets de bus depuis 1999 ! »",
            hintKeyword: "Bonbons Vieux-Plombage",
            trapChoiceText: "Un bonbon Vieux-Plombage™ collé au fond du sac à main",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "SPON_06",
            name: "La Boîte à Biscuits en Métal Danoise™",
            slogan: "« 0 % sablés au beurre, 100 % bobines de fil et aiguilles à coudre ! »",
            hintKeyword: "Boîte à couture Danoise",
            trapChoiceText: "La boîte à biscuits bleue remplie de bobines de fil à coudre",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "SPON_07",
            name: "L'Eau de Cologne Foudroyante Lavande-Tonnerre™",
            slogan: "« Pique les yeux à 15 mètres et fait fuir les moustiques jusqu'en Dordogne ! »",
            hintKeyword: "Eau de Cologne Lavande-Tonnerre",
            trapChoiceText: "Un flacon d'Eau de Cologne Lavande-Tonnerre™",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "SPON_08",
            name: "Le Napperon au Crochet Anti-Poussière™",
            slogan: "« Posé sur la télé écran plat pour réchauffer les pixels ! »",
            hintKeyword: "Napperon au crochet",
            trapChoiceText: "Un napperon au crochet posé sur le décodeur télé",
            jackpotReward: 3500
        )
    ]

    // MARK: - 9. 🎯 Manche « Le Juste Pif » (18 questions d'estimation chiffrée au plus proche)

    public static let allJustePifQuestions: [QuizJustePifQuestion] = [
        QuizJustePifQuestion(
            id: "PIF_01",
            theme: .cultureGInsolite,
            funnyTitle: "Le rouleau compresseur des toilettes",
            prompt: "Combien de rouleaux de papier toilette un Français utilise-t-il en moyenne sur une année entière ?",
            unitLabel: "rouleaux / an",
            correctValue: 105,
            meemawComment: "Environ 105 rouleaux par an (soit 2 par semaine) ! Et le double quand Tonton prépare son chili con carne !"
        ),
        QuizJustePifQuestion(
            id: "PIF_02",
            theme: .cultureGInsolite,
            funnyTitle: "La baguette sacrée du matin",
            prompt: "Combien de baguettes de pain sont vendues chaque SECONDE en France dans les boulangeries ?",
            unitLabel: "baguettes / seconde",
            correctValue: 320,
            meemawComment: "320 baguettes par seconde, soit 10 milliards par an ! Et la moitié a déjà le quignon mangé dans la voiture !"
        ),
        QuizJustePifQuestion(
            id: "PIF_03",
            theme: .mathMeemaw,
            funnyTitle: "Les marches de la Dame de Fer",
            prompt: "Si l'ascenseur est en panne, combien de marches faut-il gravir à pied pour monter tout en haut de la Tour Eiffel (jusqu'au sommet) ?",
            unitLabel: "marches",
            correctValue: 1665,
            meemawComment: "1 665 marches jusqu'au sommet ! Rien que d'y penser, les rotules de Meemaw grincent !"
        ),
        QuizJustePifQuestion(
            id: "PIF_04",
            theme: .seriesCinema,
            funnyTitle: "Le marathon Louis de Funès",
            prompt: "En quelle année est sorti au cinéma le film culte « La Grande Vadrouille » avec Bourvil et Louis de Funès ?",
            unitLabel: "année",
            correctValue: 1966,
            meemawComment: "Sorti en décembre 1966, avec plus de 17 millions d'entrées en salles !"
        ),
        QuizJustePifQuestion(
            id: "PIF_05",
            theme: .ecoCash,
            funnyTitle: "L'empire du fromage qui fond",
            prompt: "Combien de kilos de fromage un Français mange-t-il en moyenne par an (raclette, camembert et comté compris) ?",
            unitLabel: "kg / an",
            correctValue: 27,
            meemawComment: "27 kilos par an et par habitant ! En Savoie, on appelle ça un mardi après-midi."
        ),
        QuizJustePifQuestion(
            id: "PIF_06",
            theme: .francaisMeemaw,
            funnyTitle: "Le record du mot le plus long",
            prompt: "Combien de lettres compte le mot « ANTICONSTITUTIONNELLEMENT », longtemps considéré comme le plus long du dictionnaire ?",
            unitLabel: "lettres",
            correctValue: 25,
            meemawComment: "25 lettres ! Même au Scrabble il dépasse du plateau et renverse le bol de cacahuètes !"
        ),
        QuizJustePifQuestion(
            id: "PIF_07",
            theme: .musiqueTubes,
            funnyTitle: "Les Lacs du Connemara en mariage",
            prompt: "En quelle année Michel Sardou a-t-il sorti « Les Lacs du Connemara », l'hymne officiel des serviettes qui tournent à 3h du matin ?",
            unitLabel: "année",
            correctValue: 1981,
            meemawComment: "En 1981 ! Depuis, 14 millions de serviettes de table ont fini accrochées au lustre !"
        ),
        QuizJustePifQuestion(
            id: "PIF_08",
            theme: .cultureGInsolite,
            funnyTitle: "Le coup d'œil au smartphone",
            prompt: "Combien de fois par JOUR un adulte consulte-t-il ou déverrouille-t-il son téléphone portable en moyenne ?",
            unitLabel: "fois / jour",
            correctValue: 96,
            meemawComment: "96 fois par jour (environ une fois toutes les 10 minutes éveillées) !"
        ),
        QuizJustePifQuestion(
            id: "PIF_09",
            theme: .mathMeemaw,
            funnyTitle: "Les os du corps humain",
            prompt: "Combien d'os possède le squelette d'un être humain adulte ?",
            unitLabel: "os",
            correctValue: 206,
            meemawComment: "206 os chez l'adulte (contre environ 300 à la naissance avant qu'ils ne se soudent) !"
        ),
        QuizJustePifQuestion(
            id: "PIF_10",
            theme: .ecoCash,
            funnyTitle: "Le passage à l'Euro",
            prompt: "En quelle année les pièces et billets en Euros sont-ils arrivés dans les porte-monnaie des Français (adieu les Francs) ?",
            unitLabel: "année",
            correctValue: 2002,
            meemawComment: "Le 1er janvier 2002 ! Et Meemaw convertit encore les baguettes en Anciens Francs !"
        ),
        QuizJustePifQuestion(
            id: "PIF_11",
            theme: .seriesCinema,
            funnyTitle: "Le naufrage du Titanic au cinéma",
            prompt: "Combien de minutes dure le film « Titanic » de James Cameron (prépare le coussin) ?",
            unitLabel: "minutes",
            correctValue: 194,
            meemawComment: "194 minutes (3 heures et 14 minutes) ! Largement le temps de faire tenir Jack sur la planche !"
        ),
        QuizJustePifQuestion(
            id: "PIF_12",
            theme: .cultureGInsolite,
            funnyTitle: "La vitesse d'un escargot en plein sprint",
            prompt: "Combien de MÈTRES un escargot de Bourgogne parcourt-il en 1 heure quand il court à fond vers une salade ?",
            unitLabel: "mètres / heure",
            correctValue: 48,
            meemawComment: "Environ 48 mètres par heure (1,3 cm par seconde) ! Presque aussi rapide que Pépé quand il faut débarrasser la table !"
        )
    ]

    // MARK: - 10. ⚡ Finale « Le Jack Attack de Meemaw » (6 rounds de 5 vagues au buzzer)

    public static let allJackAttackRounds: [QuizJackAttackRound] = [
        QuizJackAttackRound(
            id: "JACK_01",
            funnyTitle: "⚡ Jack Attack : Les Duos Inséparables !",
            waves: [
                QuizJackAttackWave(
                    id: "JACK_01_W1",
                    clueTitle: "TROUVE LE PARTENAIRE OFFICIEL DU DUO !",
                    anchorText: "Astérix & ...",
                    options: ["Robocop", "Obélix", "Gandalf", "Inspecteur Derrick"],
                    correctOptionIndex: 1,
                    explanation: "Astérix & Obélix, par Toutatis !"
                ),
                QuizJackAttackWave(
                    id: "JACK_01_W2",
                    clueTitle: "TROUVE LE PARTENAIRE OFFICIEL DU DUO !",
                    anchorText: "Timon & ...",
                    options: ["Simba-Turbo", "Tartiflette", "Pumbaa", "Scooby-Doo"],
                    correctOptionIndex: 2,
                    explanation: "Timon & Pumbaa (« Hakuna Matata ») !"
                ),
                QuizJackAttackWave(
                    id: "JACK_01_W3",
                    clueTitle: "TROUVE LE PARTENAIRE OFFICIEL DU DUO !",
                    anchorText: "Starsky & ...",
                    options: ["Hutch", "Capitaine Haddock", "Columbo", "Spock"],
                    correctOptionIndex: 0,
                    explanation: "Starsky & Hutch dans leur Ford Gran Torino rouge et blanche !"
                ),
                QuizJackAttackWave(
                    id: "JACK_01_W4",
                    clueTitle: "TROUVE LE PARTENAIRE OFFICIEL DU DUO !",
                    anchorText: "Sherlock Holmes & ...",
                    options: ["Arsène Lupin", "Docteur Maboul", "Docteur Watson", "Nestor Burma"],
                    correctOptionIndex: 2,
                    explanation: "Élémentaire, mon cher Docteur Watson !"
                ),
                QuizJackAttackWave(
                    id: "JACK_01_W5",
                    clueTitle: "TROUVE LE PARTENAIRE OFFICIEL DU DUO !",
                    anchorText: "Bonnie & ...",
                    options: ["Claudette", "Clyde", "Picsou", "Al Capone"],
                    correctOptionIndex: 1,
                    explanation: "Bonnie & Clyde !"
                )
            ]
        ),
        QuizJackAttackRound(
            id: "JACK_02",
            funnyTitle: "⚡ Jack Attack : À Chaque Ville sa Spécialité !",
            waves: [
                QuizJackAttackWave(
                    id: "JACK_02_W1",
                    clueTitle: "BUZZE SUR LA VRAIE SPÉCIALITÉ DE LA VILLE !",
                    anchorText: "Marseille ➜ ...",
                    options: ["La Choucroute garnie", "La Bouillabaisse", "Le Kouign-amann", "Le Cassoulet"],
                    correctOptionIndex: 1,
                    explanation: "Marseille et sa célèbre Bouillabaisse !"
                ),
                QuizJackAttackWave(
                    id: "JACK_02_W2",
                    clueTitle: "BUZZE SUR LA VRAIE SPÉCIALITÉ DE LA VILLE !",
                    anchorText: "Toulouse ➜ ...",
                    options: ["Les Crêpes au sarrasin", "La Fondue savoyarde", "Le Cassoulet", "Les Bêtises de Cambrai"],
                    correctOptionIndex: 2,
                    explanation: "Toulouse (avec Castelnaudary et Carcassonne), capitale du Cassoulet !"
                ),
                QuizJackAttackWave(
                    id: "JACK_02_W3",
                    clueTitle: "BUZZE SUR LA VRAIE SPÉCIALITÉ DE LA VILLE !",
                    anchorText: "Montélimar ➜ ...",
                    options: ["Le Nougat", "La Moutarde", "Le Roquefort", "Les Canelés"],
                    correctOptionIndex: 0,
                    explanation: "Le Nougat de Montélimar (attention aux plombages de Mamie) !"
                ),
                QuizJackAttackWave(
                    id: "JACK_02_W4",
                    clueTitle: "BUZZE SUR LA VRAIE SPÉCIALITÉ DE LA VILLE !",
                    anchorText: "Bordeaux ➜ ...",
                    options: ["La Quiche lorraine", "L'Aligot", "Les Canelés", "Le Calisson"],
                    correctOptionIndex: 2,
                    explanation: "Les Canelés bordelais caramélisés au rhum et à la vanille !"
                ),
                QuizJackAttackWave(
                    id: "JACK_02_W5",
                    clueTitle: "BUZZE SUR LA VRAIE SPÉCIALITÉ DE LA VILLE !",
                    anchorText: "Dijon ➜ ...",
                    options: ["Le Piment d'Espelette", "La Moutarde", "Les Galettes de Pont-Aven", "Le Pastis"],
                    correctOptionIndex: 1,
                    explanation: "La Moutarde de Dijon qui monte au nez !"
                )
            ]
        ),
        QuizJackAttackRound(
            id: "JACK_03",
            funnyTitle: "⚡ Jack Attack : Les Expressions de Meemaw !",
            waves: [
                QuizJackAttackWave(
                    id: "JACK_03_W1",
                    clueTitle: "COMPLÈTE L'EXPRESSION FRANÇAISE EXACTE !",
                    anchorText: "Pédaler dans la ...",
                    options: ["Bétonnière", "Semoule (ou Choucroute)", "Confiture de prunes", "Piscine municipale"],
                    correctOptionIndex: 1,
                    explanation: "Pédaler dans la semoule (ou dans la choucroute) !"
                ),
                QuizJackAttackWave(
                    id: "JACK_03_W2",
                    clueTitle: "COMPLÈTE L'EXPRESSION FRANÇAISE EXACTE !",
                    anchorText: "Poser un ...",
                    options: ["Kangourou", "Radiateur en fonte", "Lapin", "Parapluie"],
                    correctOptionIndex: 2,
                    explanation: "Poser un lapin (ne pas venir à un rendez-vous) !"
                ),
                QuizJackAttackWave(
                    id: "JACK_03_W3",
                    clueTitle: "COMPLÈTE L'EXPRESSION FRANÇAISE EXACTE !",
                    anchorText: "Avoir un poil dans la ...",
                    options: ["Soupe", "Narines", "Main", "Pantoufle"],
                    correctOptionIndex: 2,
                    explanation: "Avoir un poil dans la main (être sacrément flemmard) !"
                ),
                QuizJackAttackWave(
                    id: "JACK_03_W4",
                    clueTitle: "COMPLÈTE L'EXPRESSION FRANÇAISE EXACTE !",
                    anchorText: "Donner sa langue au ...",
                    options: ["Facteur", "Perroquet", "Chat", "Contrôleur des impôts"],
                    correctOptionIndex: 2,
                    explanation: "Donner sa langue au chat !"
                ),
                QuizJackAttackWave(
                    id: "JACK_03_W5",
                    clueTitle: "COMPLÈTE L'EXPRESSION FRANÇAISE EXACTE !",
                    anchorText: "Mettre les pieds dans le ...",
                    options: ["Plat", "Grille-pain", "Lavabo", "Pot d'échappement"],
                    correctOptionIndex: 0,
                    explanation: "Mettre les pieds dans le plat !"
                )
            ]
        ),
        QuizJackAttackRound(
            id: "JACK_04",
            funnyTitle: "⚡ Jack Attack : Les Répliques & Héros Cultes !",
            waves: [
                QuizJackAttackWave(
                    id: "JACK_04_W1",
                    clueTitle: "ASSOCIE LE HÉROS À SON EXPRESSION CULTE !",
                    anchorText: "Hubert Bonisseur de La Bath (OSS 117) ➜ ...",
                    options: ["« Vers l'infini et au-delà ! »", "« Comment est votre blanquette ? »", "« Je suis ton père »", "« Nom de Zeus ! »"],
                    correctOptionIndex: 1,
                    explanation: "« Comment est votre blanquette ? — Elle est bonne. » (OSS 117) !"
                ),
                QuizJackAttackWave(
                    id: "JACK_04_W2",
                    clueTitle: "ASSOCIE LE HÉROS À SON EXPRESSION CULTE !",
                    anchorText: "Doc Brown (Retour vers le Futur) ➜ ...",
                    options: ["« Nom de Zeus ! (2,21 Gigowatts !) »", "« Hakuna Matata ! »", "« Tu ne passeras pas ! »", "« Ça farte ? »"],
                    correctOptionIndex: 0,
                    explanation: "Doc Brown et ses 2,21 Gigowatts : « Nom de Zeus ! »"
                ),
                QuizJackAttackWave(
                    id: "JACK_04_W3",
                    clueTitle: "ASSOCIE LE HÉROS À SON EXPRESSION CULTE !",
                    anchorText: "Gandalf (Le Seigneur des Anneaux) ➜ ...",
                    options: ["« Où sont les toilettes ? »", "« Vous ne passerez pas ! »", "« Le gras, c'est la vie ! »", "« C'est à moi que tu parles ? »"],
                    correctOptionIndex: 1,
                    explanation: "Gandalf face au Balrog sur le pont de Khazad-dûm : « Vous ne passerez pas ! »"
                ),
                QuizJackAttackWave(
                    id: "JACK_04_W4",
                    clueTitle: "ASSOCIE LE HÉROS À SON EXPRESSION CULTE !",
                    anchorText: "Karadoc (Kaamelott) ➜ ...",
                    options: ["« Je s'appelle Groot »", "« Le gras, c'est la vie ! »", "« Hasta la vista, baby »", "« Mon précieux ! »"],
                    correctOptionIndex: 1,
                    explanation: "Karadoc de Vannes : « Le gras, c'est la vie ! »"
                ),
                QuizJackAttackWave(
                    id: "JACK_04_W5",
                    clueTitle: "ASSOCIE LE HÉROS À SON EXPRESSION CULTE !",
                    anchorText: "Brice de Nice ➜ ...",
                    options: ["« J'ai glissé chef ! »", "« Je t'ai cassé ! »", "« On attend pas Patrick ? »", "« C'est l'jeu ma pauv' Lucette ! »"],
                    correctOptionIndex: 1,
                    explanation: "Brice de Nice, roi de la casse : « Je t'ai cassé ! »"
                )
            ]
        )
    ]
}
