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

    public static func buildShowDeck(for pack: QuizThemePack) -> ShowGameDeck {
        var pool = questions(for: pack).shuffled()
        if pool.count < 7 {
            pool = questions(for: .grandMix).shuffled()
        }
        let cash = Array(pool.prefix(3))
        let solo = Array(pool.dropFirst(3).prefix(2))
        let finale = Array(pool.dropFirst(5).prefix(2))
        let couci = disOrDatRounds(for: pack).randomElement() ?? allDisOrDatRounds[0]

        return ShowGameDeck(
            cashQuestions: cash,
            soloQuestions: solo,
            couciCoucaRound: couci,
            finaleDoubleQuestions: finale
        )
    }

    // MARK: - 1. 👵 Français & Expressions de Meemaw

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
        )
    ]

    // MARK: - 2. 📐 Meemaw Math & Logique Flash

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
        )
    ]

    // MARK: - 3. 🎬 Séries & Cinéma Pop

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
        )
    ]

    // MARK: - 4. 🎵 Musique & Tubes

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
        )
    ]

    // MARK: - 5. 🌍 Culture G & Insolite

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
        )
    ]

    // MARK: - 6. 💰 Éco & Cash Perso (Esprit RushTiVi × Meemaw)

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
        )
    ]

    // MARK: - ⚖️ Manche 3 : Les Couci-Couça Binaire (DisOrDat)

    public static let allDisOrDatRounds: [QuizDisOrDatRound] = [
        QuizDisOrDatRound(
            id: "DOD_FR_1",
            theme: .francaisMeemaw,
            funnyTitle: "Vrai Pluriel en « X » ou Faute qui Pique les Yeux ?",
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
            id: "DOD_MATH_1",
            theme: .mathMeemaw,
            funnyTitle: "Plus Grand que 50 ou Plus Petit que 50 ?",
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
                QuizDisOrDatItem(index: 4, text: "« J'ai glissé, chef ! » (euh non : « Je vais vous faire le planté de bâton ! »)", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "« Ce tombeau sera votre tombeau ! »", correctSide: "right")
            ],
            audioCueID: "dod_CINE_1"
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
            id: "DOD_CUL_1",
            theme: .cultureGInsolite,
            funnyTitle: "Vraie Invention Scientifique ou Gros Bobard de Meemaw ?",
            prompt: "Tape à GAUCHE si c'est VRAI, ou à DROITE si c'est un GROS BOBARD inventé par Meemaw !",
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
        )
    ]
}
