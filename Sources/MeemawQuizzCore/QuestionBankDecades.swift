import Foundation

// MARK: - 108 Questions Générationnelles par Décennie (1960s -> 2010s-2020s) dans les 6 Catégories

extension QuestionBank {

    public static let decadeFrancaisQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "DEC_FR_60_01",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            decade: .sixties,
            funnyTitle: "Le vocabulaire des surprises-parties yéyé",
            prompt: "Dans les années 1960, quand les ados de l'époque de Meemaw disaient « C'est bath ! » en écoutant Salut les Copains, qu'est-ce que ça voulait dire ?",
            choices: [
                "C'est super / génial",
                "Il faut aller prendre un bain",
                "C'est complètement raté",
                "C'est trop cher pour ma bourse"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais non mon chou ! « C'est bath ! », c'était le « C'est trop stylé » des années 60 !",
            explanation: "💡 Issu de l'argot parisien (de « Bath » en Angleterre, réputée chic), « C'est bath ! » signifiait « C'est chouette / formidable ! » dans les années 60.",
            audioCueID: "q_DEC_FR_60_01"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_60_02",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .sixties,
            funnyTitle: "La fameuse « surprise-partie » sur l'électrophone",
            prompt: "Dans les années 60, on abrégeait « surprise-partie » par un petit mot de 4 lettres devenu culte. Lequel ?",
            choices: [
                "Une boum",
                "Une surpatte",
                "Un guinch'",
                "Une teuf"
            ],
            correctIndex: 1,
            baseValue: 2000,
            meemawRoastOnWrong: "Raté ! Avant la boum des années 80 et la teuf des années 90, dans les années 60 on allait dans une « surpatte » (ou surpat') !",
            explanation: "💡 « Surpat' » (ou surpatte) était l'abréviation branchée de « surprise-partie » dans les années 1950-1960 avant d'être détrônée par « boum ».",
            audioCueID: "q_DEC_FR_60_02"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_60_03",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            decade: .sixties,
            funnyTitle: "Les « blousons noirs » et le Teppaz",
            prompt: "En 1963, quand Pépé mettait un disque 45 tours sur son « tourne-disque », quelle est la bonne orthographe au pluriel de « des tourne-disques » ?",
            choices: [
                "Des tourne-disques",
                "Des tournes-disques",
                "Des tourne-disque",
                "Des tournes-disque"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Eh non ! Dans un mot composé Verbe + Nom, le verbe « tourne » reste invariable et le nom « disques » prend un S !",
            explanation: "💡 Dans « tourne-disques » (verbe + nom), le verbe ne s'accorde jamais mais l'objet (« disques ») prend la marque du pluriel.",
            audioCueID: "q_DEC_FR_60_03"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_70_01",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            decade: .seventies,
            funnyTitle: "L'argot baba-cool des années 70",
            prompt: "Dans les années 1970, quand quelqu'un portait un pantalon « pattes d'éph' », de quel animal venait cette abréviation ?",
            choices: [
                "L'éléphant",
                "L'éphémère",
                "L'épagneul breton",
                "L'effraie"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais voyons ! « Pattes d'éph' », c'est l'abréviation de « pattes d'éléphant », rapport au bas du pantalon ultra-large !",
            explanation: "💡 Le pantalon « pattes d'éléphant » (abrégé « pattes d'éph' ») était l'emblème vestimentaire des années 1970.",
            audioCueID: "q_DEC_FR_70_01"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_70_02",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .seventies,
            funnyTitle: "La naissance du verlan de Renaud (1977)",
            prompt: "En 1977, Renaud popularise le mot verlan « laisse béton » dans sa chanson culte. De quel mot français « béton » est-il le verlan ?",
            choices: [
                "Tomber",
                "Bétonner",
                "Bâtonner",
                "Bonnet"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Aïe aïe aïe ! « Tom-ber » à l'envers donne « ber-tom », prononcé « béton » : « Laisse béton » veut dire « Laisse tomber » !",
            explanation: "💡 En inversant les syllabes de « tom-ber » (ber-tom -> béton), l'argot des années 70 a créé l'expression culte « Laisse béton ».",
            audioCueID: "q_DEC_FR_70_02"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_70_03",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            decade: .seventies,
            funnyTitle: "Avoir « les boules » au disco",
            prompt: "Dans les années 70, l'expression familière « être baba » (ou « rester baba ») devant quelque chose d'incroyable voulait dire :",
            choices: [
                "Rester ébahi / stupéfait d'admiration",
                "Manger un gâteau imbibé de rhum",
                "Avoir très sommeil",
                "Partir vivre au Népal"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Raté ! « Rester baba », ça veut dire rester bouche bée d'étonnement !",
            explanation: "💡 « Être baba » (d'origine onomatopéique : rester la bouche ouverte « ba-ba ») signifie être stupéfait ou émerveillé.",
            audioCueID: "q_DEC_FR_70_03"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_80_01",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            decade: .eighties,
            funnyTitle: "Le parler « chébran » des années 80",
            prompt: "Dans les années 1980, être « chébran » (ou « câblé »), c'était le verlan de quel adjectif à la mode ?",
            choices: [
                "Branché",
                "Chambreur",
                "Ébréché",
                "Charmant"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais non ! « Bran-ché » à l'envers, ça fait « ché-bran » ! T'es pas très chébran mon poussin !",
            explanation: "💡 Dans les années 1980, « chébran » (verlan de « branché ») désignait tout ce qui était à la pointe de la mode.",
            audioCueID: "q_DEC_FR_80_01"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_80_02",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .eighties,
            funnyTitle: "Avoir « la pêche » ou « la banane »",
            prompt: "Dans les années 80, quand on disait d'un copain qu'il « avait le look Coco » ou que c'était « chérot », que signifiait « chérot » ?",
            choices: [
                "Trop cher / hors de prix",
                "Très mignon",
                "Un peu froid",
                "Très rapide"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Eh non ! « C'est chérot » (ou chéro), c'est de l'argot affectueux pour dire « c'est trop cher » !",
            explanation: "💡 Formé sur l'adjectif « cher » avec le suffixe familier « -ot », « chérot » signifie « coûteux / trop cher ».",
            audioCueID: "q_DEC_FR_80_02"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_80_03",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            decade: .eighties,
            funnyTitle: "Le Walkman ou le « baladeur » (1983)",
            prompt: "En 1983, la commission de terminologie française a inventé un mot officiel (avec un seul L !) pour remplacer « Walkman ». Lequel ?",
            choices: [
                "Un baladeur",
                "Un balladeur",
                "Un écouteur-poche",
                "Un trotte-cassette"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Attention aux L ! On se « balade » avec un seul L (la « ballade » avec deux L, c'est le poème ou la chanson romantique) !",
            explanation: "💡 « Baladeur » s'écrit avec un seul L car il vient de « se balader » (se promener), contrairement à la « ballade » musicale ou poétique.",
            audioCueID: "q_DEC_FR_80_03"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_90_01",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            decade: .nineties,
            funnyTitle: "« C'est chanmé ! » dans la cour de récré (1995)",
            prompt: "Dans les années 1990, quand les jeunes disaient « C'est chanmé ! », de quel mot était-ce le verlan ?",
            choices: [
                "Méchant",
                "Chanté",
                "Changé",
                "Chanceux"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Raté ! « Mé-chant » à l'envers donne « chan-mé », utilisé dans les années 90 pour dire que quelque chose était incroyable !",
            explanation: "💡 « Chanmé » est le verlan de « méchant », employé par antiphrase dans les années 1990 pour signifier « génial / impressionnant ».",
            audioCueID: "q_DEC_FR_90_01"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_90_02",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .nineties,
            funnyTitle: "La réforme de l'orthographe de 1990",
            prompt: "En décembre 1990, les rectifications orthographiques ont autorisé à écrire un célèbre légume qui fait pleurer sans son « i ». Lequel ?",
            choices: [
                "Un ognon",
                "Un poirau",
                "Une échalotte",
                "Un champignion"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Eh oui ! Depuis 1990, on a le droit d'écrire « un ognon » sans le I muet (même si Meemaw préfère toujours son vieil oignon) !",
            explanation: "💡 La réforme orthographique de 1990 a validé la graphie « ognon » (sans le i qui servait autrefois à noter le son gn).",
            audioCueID: "q_DEC_FR_90_02"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_90_03",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            decade: .nineties,
            funnyTitle: "« Grave ! » et « Trop mortel ! »",
            prompt: "Dans les années 90, que signifiait l'expression « mettre une disquette » ou « raconter des salades » à quelqu'un ?",
            choices: [
                "Baratiner / raconter un mensonge flatteur",
                "Lui prêter un jeu sur Windows 95",
                "Lui couper la parole au téléphone",
                "L'inviter au restaurant"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais non, ça n'a rien à voir avec ton vieux PC ! « Mettre une disquette », c'est baratiner quelqu'un avec un discours préenregistré !",
            explanation: "💡 Née à la fin des années 90, l'expression « mettre / sortir une disquette » signifie réciter un baratin tout fait.",
            audioCueID: "q_DEC_FR_90_03"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_00_01",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            decade: .twoThousands,
            funnyTitle: "Le langage MSN Messenger et Skyblog (2005)",
            prompt: "Dans les années 2000 sur MSN Messenger, quand ton correspondant t'envoyait « MDR » ou « PTDR », que voulait dire « PTDR » ?",
            choices: [
                "Pété de rire",
                "Parti tard du boulot",
                "Pour toi de rien",
                "Prends ton temps de répondre"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Oh le coup de vieux ! « MDR » = Mort de rire, et le niveau au-dessus sur MSN, c'était « PTDR » = Pété de rire !",
            explanation: "💡 Sur MSN Messenger et par SMS dans les années 2000, « PTDR » (Pété de rire) était le superlatif de « MDR » (Mort de rire).",
            audioCueID: "q_DEC_FR_00_01"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_00_02",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .twoThousands,
            funnyTitle: "« Avoir le seum » dans les années 2000",
            prompt: "Popularisée dans les années 2000, de quelle langue vient l'expression « avoir le seum » (être dégoûté / en colère) ?",
            choices: [
                "De l'arabe « semm »",
                "De l'anglais « same »",
                "Du breton « somm »",
                "Du latin « summum »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Eh non ! « Le seum » vient du mot arabe « semm » qui veut dire « le venin » : avoir le seum, c'est littéralement « avoir le venin » !",
            explanation: "💡 Emprunté à l'arabe « semm » (venin), « avoir le seum » est l'équivalent exact de l'expression française « avoir les boules / être dégoûté ».",
            audioCueID: "q_DEC_FR_00_02"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_00_03",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            decade: .twoThousands,
            funnyTitle: "Le mot français officiel pour « e-mail » (2003)",
            prompt: "En 2003, quel mot français (inventé au Québec) a été officiellement adopté en France pour remplacer « e-mail » ?",
            choices: [
                "Un courriel",
                "Un missiviel",
                "Un postonet",
                "Un télétexte"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « courriel » (contraction de « courrier électronique ») ! Nos cousins québécois ont toujours un train d'avance !",
            explanation: "💡 Contraction de « courrier électronique », le mot québécois « courriel » a été officialisé en France en juin 2003.",
            audioCueID: "q_DEC_FR_00_03"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_10_01",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            decade: .twentyTens,
            funnyTitle: "« C'est cringe » et « Ghoster » (Années 2010–2020)",
            prompt: "Quand un jeune de moins de 25 ans dit que la blague de Tonton au repas de Noël est « ultra cringe », qu'est-ce que ça veut dire ?",
            choices: [
                "Qu'elle est gênante / provoque un malaise",
                "Qu'elle est hilarante",
                "Qu'elle est trop courte",
                "Qu'elle date du Moyen Âge"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Raté ! Quand c'est « cringe », c'est tellement gênant qu'on grimace de malaise dans son pull de Noël !",
            explanation: "💡 De l'anglais « to cringe » (grimacer de gêne), « cringe » qualifie une situation ou une blague malaisante.",
            audioCueID: "q_DEC_FR_10_01"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_10_02",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .twentyTens,
            funnyTitle: "« Quoicoubeh » et « Banger » sur TikTok",
            prompt: "Dans l'argot des années 2020, si quelqu'un qualifie un film ou une musique de « banger », qu'est-ce que cela signifie ?",
            choices: [
                "C'est une tuerie / un chef-d'œuvre absolu",
                "C'est un navet insupportable",
                "C'est un film d'horreur interdit aux moins de 16 ans",
                "C'est une vieille chanson oubliée"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais non ! Un « banger », c'est un son ou un film qui « tape fort », bref une pépite absolue !",
            explanation: "💡 Issu du vocabulaire musical anglophone, un « banger » désigne un morceau (et par extension un film ou un plat) exceptionnel.",
            audioCueID: "q_DEC_FR_10_02"
        ),
        QuizMCQQuestion(
            id: "DEC_FR_10_03",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            decade: .twentyTens,
            funnyTitle: "Divulgâcher la fin d'une série Netflix",
            prompt: "Quel mot-valise plein d'humour nos cousins québécois et le Robert ont-ils créé pour traduire le verbe anglais « spoiler » (raconter la fin d'un film) ?",
            choices: [
                "Divulgâcher",
                "Révélruiner",
                "Dévoilcasser",
                "Spolier"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « divulgâcher » ! Tu divulgues l'intrigue et tu gâches le plaisir : avoue que le mot est génial !",
            explanation: "💡 « Divulgâcher » fusionne « divulguer » et « gâcher » pour remplacer l'anglicisme « spoiler ».",
            audioCueID: "q_DEC_FR_10_03"
        ),
    ]

    public static let decadeMathQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "DEC_MATH_60_01",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            decade: .sixties,
            funnyTitle: "Le passage au Nouveau Franc (1er janvier 1960)",
            prompt: "En 1960, le général de Gaulle lance le « Nouveau Franc » : 1 Nouveau Franc vaut 100 Anciens Francs. Si le manteau de Meemaw coûtait 15 000 Anciens Francs, combien coûtait-il en Nouveaux Francs ?",
            choices: [
                "150 Nouveaux Francs",
                "1 500 Nouveaux Francs",
                "15 Nouveaux Francs",
                "1 500 000 Nouveaux Francs"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "On divise par 100 voyons ! 15 000 divisé par 100, on enlève deux zéros : ça fait 150 Nouveaux Francs !",
            explanation: "💡 Le 1er janvier 1960, 100 anciens francs sont devenus 1 nouveau franc : 15 000 ÷ 100 = 150 NF.",
            audioCueID: "q_DEC_MATH_60_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_60_02",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .sixties,
            funnyTitle: "Le plein de la 2CV en 1965",
            prompt: "En 1965, le réservoir de la 2CV de Pépé contient 20 litres et elle consomme 5 litres aux 100 km. Combien de kilomètres peut-il parcourir avec un plein complet ?",
            choices: [
                "400 km",
                "200 km",
                "500 km",
                "100 km"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "20 litres divisés par 5 litres aux 100 km, ça fait 4 tranches de 100 km, donc 400 km !",
            explanation: "💡 20 L ÷ 5 L/100 km = 4 × 100 km = 400 km d'autonomie.",
            audioCueID: "q_DEC_MATH_60_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_60_03",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            decade: .sixties,
            funnyTitle: "Les tours par minute du vinyle (Années 60)",
            prompt: "Un disque 45 tours tourne exactement à 45 tours par minute. Combien de tours fait-il pendant une chanson yéyé de 2 minutes ?",
            choices: [
                "90 tours",
                "45 tours",
                "135 tours",
                "180 tours"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "45 tours par minute × 2 minutes = 90 tours ! Même sans règle à calcul c'était cadeau !",
            explanation: "💡 45 tours/min × 2 minutes = 90 tours.",
            audioCueID: "q_DEC_MATH_60_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_70_01",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            decade: .seventies,
            funnyTitle: "Le vol supersonique du Concorde (1976)",
            prompt: "En 1976, le Concorde vole à Mach 2, soit environ 2 200 km/h. S'il maintient cette vitesse pendant 2 h 30, quelle distance parcourt-il ?",
            choices: [
                "5 500 km",
                "4 400 km",
                "6 600 km",
                "5 000 km"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "2 heures à 2 200 km/h font 4 400 km, plus une demi-heure (1 100 km) = 5 500 km, pile Paris–New York !",
            explanation: "💡 2 200 × 2,5 = 4 400 + 1 100 = 5 500 km (la traversée de l'Atlantique Nord).",
            audioCueID: "q_DEC_MATH_70_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_70_02",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .seventies,
            funnyTitle: "Le mot retourné sur la calculatrice Casio (Années 70)",
            prompt: "Dans les années 70, quel nombre fallait-il taper sur sa calculatrice de poche avant de la retourner à l'envers pour lire le mot « SOLEIL » ?",
            choices: [
                "713705",
                "3773",
                "537105",
                "713507"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "À l'envers : 5 = S, 0 = O, 7 = L, 3 = E, 1 = I, 7 = L ! Donc en partant de la droite, il fallait taper 713705 !",
            explanation: "💡 En retournant l'écran 7 segments à 180°, les chiffres 7-1-3-7-0-5 se lisent de droite à gauche S-O-L-E-I-L.",
            audioCueID: "q_DEC_MATH_70_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_70_03",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            decade: .seventies,
            funnyTitle: "Les 3 chaînes de l'ORTF en 1975",
            prompt: "En 1975, la télé couleur coûte 3 000 Francs. Pépé verse un acompte de 20 % à la commande. Combien lui reste-t-il à payer ?",
            choices: [
                "2 400 Francs",
                "2 800 Francs",
                "600 Francs",
                "2 000 Francs"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "20 % de 3 000 F, c'est 600 F d'acompte. Il reste donc 3 000 - 600 = 2 400 Francs !",
            explanation: "💡 3 000 × (1 - 0,20) = 3 000 - 600 = 2 400 Francs.",
            audioCueID: "q_DEC_MATH_70_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_80_01",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            decade: .eighties,
            funnyTitle: "La géométrie du Rubik's Cube (1980)",
            prompt: "En 1980, tout le monde s'arrache les cheveux sur le Rubik's Cube 3×3×3 classique. Combien de petits carrés colorés (autocollants) compte-t-on au total sur les 6 faces du cube ?",
            choices: [
                "54 petits carrés",
                "27 petits carrés",
                "36 petits carrés",
                "64 petits carrés"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Chaque face est une grille de 3 × 3 = 9 carrés. Et un cube a 6 faces : 6 × 9 = 54 autocollants !",
            explanation: "💡 Un Rubik's Cube 3×3 possède 6 faces de 9 facettes chacune, soit 6 × 9 = 54 facettes colorées.",
            audioCueID: "q_DEC_MATH_80_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_80_02",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .eighties,
            funnyTitle: "Rembobiner la cassette audio C90 au crayon Bic",
            prompt: "Une cassette audio « C90 » des années 80 dure 90 minutes au total en utilisant les deux faces (Face A + Face B). Combien de chansons de 3 minutes peut-on enregistrer sur la SEULE Face A ?",
            choices: [
                "15 chansons",
                "30 chansons",
                "45 chansons",
                "10 chansons"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Piège classique ! Une C90 fait 90 minutes au total, donc 45 minutes par face ! 45 ÷ 3 minutes = 15 chansons sur la Face A !",
            explanation: "💡 Une cassette C90 offre 45 minutes par face (A et B). 45 minutes ÷ 3 minutes = 15 chansons sur la Face A.",
            audioCueID: "q_DEC_MATH_80_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_80_03",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            decade: .eighties,
            funnyTitle: "Le record du TGV Orange (1981)",
            prompt: "En 1981, le TGV relie Paris à Lyon (450 km) à une vitesse moyenne de 225 km/h. Combien de temps dure le trajet ?",
            choices: [
                "Exactement 2 heures",
                "1 heure 30",
                "2 heures 30",
                "3 heures"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "450 divisé par 225, ça tombe tout rond : 2 heures pile !",
            explanation: "💡 Temps = Distance ÷ Vitesse = 450 km ÷ 225 km/h = 2 heures.",
            audioCueID: "q_DEC_MATH_80_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_90_01",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            decade: .nineties,
            funnyTitle: "Les piles de la Game Boy (1990)",
            prompt: "En 1990, la Game Boy de Nintendo nécessite 4 piles AA pour fonctionner pendant 15 heures. Combien de piles AA faut-il emporter pour tenir 60 heures de Tetris pendant les vacances ?",
            choices: [
                "16 piles AA",
                "12 piles AA",
                "20 piles AA",
                "24 piles AA"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "60 heures ÷ 15 heures = 4 jeux de piles. Et à 4 piles par jeu : 4 × 4 = 16 piles !",
            explanation: "💡 60 h ÷ 15 h = 4 recharges complètes de 4 piles, soit 4 × 4 = 16 piles AA.",
            audioCueID: "q_DEC_MATH_90_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_90_02",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .nineties,
            funnyTitle: "France 98 : 3 – 0 en finale !",
            prompt: "Le 12 juillet 1998, Zidane marque aux 27e et 45e minutes, puis Petit marque à la 90e minute. Combien de minutes se sont écoulées entre le 1er but de Zidane et celui d'Emmanuel Petit ?",
            choices: [
                "63 minutes",
                "53 minutes",
                "73 minutes",
                "45 minutes"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "90 moins 27, ça fait 63 minutes de bonheur ! Et 1, et 2, et 3 zéro !",
            explanation: "💡 90 - 27 = 63 minutes d'écart entre l'ouverture du score et le 3e but.",
            audioCueID: "q_DEC_MATH_90_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_90_03",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            decade: .nineties,
            funnyTitle: "Les disquettes 1,44 Mo de Windows 95",
            prompt: "Dans les années 90, une disquette 3,5 pouces stocke 1,44 Mo. Combien de disquettes fallait-il au minimum pour copier un fichier de 10 Mo ?",
            choices: [
                "7 disquettes",
                "6 disquettes",
                "5 disquettes",
                "10 disquettes"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "6 disquettes ne font que 6 × 1,44 = 8,64 Mo (trop court !). Il fallait donc une 7e disquette (7 × 1,44 = 10,08 Mo) !",
            explanation: "💡 6 × 1,44 Mo = 8,64 Mo < 10 Mo ; il faut donc 7 disquettes (10,08 Mo).",
            audioCueID: "q_DEC_MATH_90_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_00_01",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            decade: .twoThousands,
            funnyTitle: "La conversion Francs ➔ Euros (1er janvier 2002)",
            prompt: "En 2002, 1 Euro vaut environ 6,56 Francs (soit ~20 Francs pour 3 Euros). Si une place de cinéma coûte 7 Euros, combien cela représentait-il environ en Francs ?",
            choices: [
                "Environ 46 Francs",
                "Environ 21 Francs",
                "Environ 70 Francs",
                "Environ 105 Francs"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "7 × 6,56 = 45,92 Francs, soit environ 46 Francs ! Meemaw compte encore en anciens francs dans sa tête !",
            explanation: "💡 7 € × 6,55957 F/€ = 45,92 Francs (environ 46 F).",
            audioCueID: "q_DEC_MATH_00_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_00_02",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .twoThousands,
            funnyTitle: "Le forfait SMS limité du Nokia 3310 (2001)",
            prompt: "En 2001, un SMS est limité à 160 caractères. Si tu écris un grand message d'amour de 400 caractères sur ton Nokia 3310, combien de SMS seront décomptés de ton forfait ?",
            choices: [
                "3 SMS",
                "2 SMS",
                "4 SMS",
                "1 seul SMS"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "2 SMS ne contiennent que 320 caractères max. Pour 400 caractères, ça entame un 3e SMS !",
            explanation: "💡 2 × 160 = 320 caractères < 400 <= 480 (3 × 160), donc 3 SMS sont facturés.",
            audioCueID: "q_DEC_MATH_00_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_00_03",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            decade: .twoThousands,
            funnyTitle: "La mémoire du premier iPod (2001)",
            prompt: "Le tout premier iPod d'Apple disposait de 5 Go (soit 5 000 Mo). Si une chanson MP3 pèse en moyenne 5 Mo, combien de chansons pouvait-il contenir ?",
            choices: [
                "1 000 chansons",
                "100 chansons",
                "500 chansons",
                "10 000 chansons"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "5 000 Mo ÷ 5 Mo = 1 000 chansons ! C'était d'ailleurs le slogan officiel de Steve Jobs : « 1 000 chansons dans votre poche » !",
            explanation: "💡 5 000 Mo ÷ 5 Mo/chanson = 1 000 chansons (« 1,000 songs in your pocket »).",
            audioCueID: "q_DEC_MATH_00_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_10_01",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            decade: .twentyTens,
            funnyTitle: "Le jeu 2048 sur smartphone (2014)",
            prompt: "Dans le célèbre jeu mobile « 2048 », on fusionne des puissances de 2 (2, 4, 8, 16...). Combien obtient-on en fusionnant deux tuiles « 512 » ?",
            choices: [
                "1 024",
                "1 012",
                "2 048",
                "1 048"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "512 + 512 = 1 024 (soit 2 puissance 10), juste l'étape avant le fameux 2048 !",
            explanation: "💡 512 × 2 = 1 024 (et deux tuiles 1 024 fusionnent ensuite pour former 2 048).",
            audioCueID: "q_DEC_MATH_10_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_10_02",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            decade: .twentyTens,
            funnyTitle: "Binge-watching d'une saison Netflix (Années 2010–2020)",
            prompt: "Une saison de série compte 8 épisodes de 45 minutes chacun. Si tu regardes toute la saison d'une traite dimanche sous un plaid, combien d'heures cela dure-t-il exactement ?",
            choices: [
                "6 heures",
                "5 heures",
                "6 heures 30",
                "8 heures"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "8 × 45 minutes = 360 minutes. Et 360 ÷ 60 minutes = 6 heures tout pile !",
            explanation: "💡 45 minutes = 0,75 heure ; 8 × 0,75 h = 6 heures (360 minutes).",
            audioCueID: "q_DEC_MATH_10_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MATH_10_03",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            decade: .twentyTens,
            funnyTitle: "La batterie de l'iPhone à 20 %",
            prompt: "Ton smartphone passe de 100 % à 20 % de batterie en 8 heures d'utilisation régulière. À ce rythme constant, combien de minutes d'autonomie te reste-t-il avant qu'il s'éteigne à 0 % ?",
            choices: [
                "120 minutes",
                "60 minutes",
                "80 minutes",
                "160 minutes"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Tu as consommé 80 % en 8 heures, soit 10 % par heure ! Avec 20 % restants, il te reste 2 heures = 120 minutes !",
            explanation: "💡 80 % consommés en 8 h = 10 %/h. Les 20 % restants donnent 2 h = 120 minutes.",
            audioCueID: "q_DEC_MATH_10_03"
        ),
    ]

    public static let decadeSeriesCinemaQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "DEC_CINE_60_01",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            decade: .sixties,
            funnyTitle: "La Grande Vadrouille (1966)",
            prompt: "Dans « La Grande Vadrouille » (1966), quel duo mythique échange ses chaussures et se donne rendez-vous aux bains turcs en sifflotant « Tea for Two » ?",
            choices: [
                "Bourvil et Louis de Funès",
                "Jean Gabin et Lino Ventura",
                "Pierre Richard et Gérard Depardieu",
                "Alain Delon et Jean-Paul Belmondo"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Sacrilège ! Augustin Bouvet (Bourvil) et Stanislas Lefort (Louis de Funès), c'est la base absolue du cinéma français !",
            explanation: "💡 « La Grande Vadrouille » (1966) de Gérard Oury réunit Bourvil et Louis de Funès (17 millions d'entrées).",
            audioCueID: "q_DEC_CINE_60_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_60_02",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            decade: .sixties,
            funnyTitle: "Bonne nuit les petits (1962)",
            prompt: "Dans les années 1960 à la télé en noir et blanc, qui accompagnait Nounours sur son nuage pour jeter une poignée de sable doré aux enfants : « Bonne nuit les petits, faites de beaux rêves » ?",
            choices: [
                "Le Marchand de sable",
                "Casimir de l'Île aux Enfants",
                "Pollux du Manège Enchanté",
                "Zébulon"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Mais voyons ! C'était Ulysse le Marchand de sable, qui jouait de la flûte pendant que Nounours grondait « Pom pom pom pom » !",
            explanation: "💡 Créée par Claude Laydu en 1962, « Bonne nuit les petits » mettait en scène Nounours, le Marchand de sable, Nicolas et Pimprenelle.",
            audioCueID: "q_DEC_CINE_60_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_60_03",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            decade: .sixties,
            funnyTitle: "Les Tontons Flingueurs (1963)",
            prompt: "Dans la scène de la cuisine des « Tontons Flingueurs » (1963), quel fruit Lino Ventura et Bernard Blier trouvent-ils finalement dans leur fameux alcool polonais à 90 degrés ?",
            choices: [
                "De la pomme",
                "De la prune de Varsovie",
                "De la poire Williams",
                "De la betterave pure"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Vous avez beau dire, y'a pas seulement que de la pomme... — Y'en a ! » Cultissime dialogue de Michel Audiard !",
            explanation: "💡 Dans la réplique culte de Michel Audiard, Maître Folace reconnaît une pointe de pomme dans le vitriol du Mexicain.",
            audioCueID: "q_DEC_CINE_60_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_70_01",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            decade: .seventies,
            funnyTitle: "Les Bronzés font du ski (1979)",
            prompt: "En 1979 dans « Les Bronzés font du ski », quel animal répugnant se trouve au fond de la bouteille de liqueur « crapaud » que les paysans offrent à l'équipe du Splendid ?",
            choices: [
                "Un crapaud",
                "Une vipère des Alpes",
                "Un gros ver de terre",
                "Un escargot de Bourgogne"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Mais il y a une bête dedans ! — Oui, c'est un crapaud, c'est ce qui donne le goût ! »",
            explanation: "💡 Après la fougne, les montagnards servent leur fameuse liqueur d'échalote macérée au crapaud.",
            audioCueID: "q_DEC_CINE_70_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_70_02",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            decade: .seventies,
            funnyTitle: "L'Île aux Enfants (1974)",
            prompt: "Dans les années 1970, quel était le plat préféré de Casimir, le monstre gentil orange de « L'Île aux Enfants » ?",
            choices: [
                "Le gloubi-boulga",
                "La tartiflette aux fraises",
                "Le pudding à l'arsenic",
                "La soupe aux choux"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Comment oublier le gloubi-boulga ?! Confiture de fraises, chocolat râpé, bananes écrasées, moutarde très forte et saucisse de Toulouse crue mais tiède !",
            explanation: "💡 Le gloubi-boulga de Casimir mélangeait confiture de fraises, chocolat, banane, moutarde forte et saucisse de Toulouse crue.",
            audioCueID: "q_DEC_CINE_70_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_70_03",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            decade: .seventies,
            funnyTitle: "Columbo et sa vieille voiture française (Années 70)",
            prompt: "Dans la série « Columbo » des années 70, au volant de quel cabriolet français cabossé l'inspecteur en imperméable mène-t-il toutes ses enquêtes à Los Angeles ?",
            choices: [
                "Une Peugeot 403 cabriolet",
                "Une Citroën DS décapotable",
                "Une Renault Dauphine",
                "Une Simca Aronde"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était une Peugeot 403 cabriolet de 1959 choisie personnellement par Peter Falk !",
            explanation: "💡 Le lieutenant Columbo conduisait une Peugeot 403 cabriolet grise de 1959.",
            audioCueID: "q_DEC_CINE_70_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_80_01",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            decade: .eighties,
            funnyTitle: "Retour vers le Futur (1985)",
            prompt: "Dans « Retour vers le Futur » (1985), quelle vitesse exacte la DeLorean de Doc Brown doit-elle atteindre pour voyager dans le temps ?",
            choices: [
                "88 miles à l'heure",
                "100 miles à l'heure",
                "77 miles à l'heure",
                "120 miles à l'heure"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Nom de Zeus Marty ! C'est 88 miles à l'heure (environ 142 km/h) pour activer le convecteur temporel !",
            explanation: "💡 La DeLorean DMC-12 doit atteindre 88 mph (141,6 km/h) avec 1,21 gigowatt.",
            audioCueID: "q_DEC_CINE_80_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_80_02",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            decade: .eighties,
            funnyTitle: "La Boum (1980) et le casque Walkman",
            prompt: "Dans « La Boum » (1980) avec Sophie Marceau, qui joue son arrière-grand-mère pétillante Poupette, toujours prête à lui donner des conseils amoureux ?",
            choices: [
                "Denise Grey",
                "Annie Cordy",
                "Danielle Darrieux",
                "Line Renaud"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était l'inoubliable Denise Grey dans le rôle de Poupette, la grand-mère la plus cool des années 80 (juste après Mimo bien sûr) !",
            explanation: "💡 Denise Grey (alors âgée de 84 ans) incarnait Poupette, l'arrière-grand-mère complice de Vic (Sophie Marceau).",
            audioCueID: "q_DEC_CINE_80_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_80_03",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            decade: .eighties,
            funnyTitle: "MacGyver (1985) et son couteau suisse",
            prompt: "Dans la série culte « MacGyver » des années 80, quel est le véritable prénom de MacGyver (révélé très tard dans la série) ?",
            choices: [
                "Angus MacGyver",
                "Jack MacGyver",
                "Rick MacGyver",
                "Steve MacGyver"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Il s'appelle Angus MacGyver ! Pas étonnant qu'il ait préféré qu'on l'appelle juste Mac pendant 7 saisons !",
            explanation: "💡 Le prénom de MacGyver (joué par Richard Dean Anderson) est Angus.",
            audioCueID: "q_DEC_CINE_80_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_90_01",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            decade: .nineties,
            funnyTitle: "Les Visiteurs (1993) : « Okayyyy ! »",
            prompt: "Dans « Les Visiteurs » (1993), comment Jacquouille la Fripouille appelle-t-il la voiture du facteur (« la boîte à lettres qui roule ») ?",
            choices: [
                "La sarrazine",
                "La charrette jaune",
                "Le destrier à pétrole",
                "La carriole postale"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Messire, messire, un Sarrasin dans une sarrazine du diable tout en ferraille ! »",
            explanation: "💡 Jacquouille et Godefroy de Montmirail attaquent la Renault 4L jaune de La Poste en la prenant pour une « sarrazine ».",
            audioCueID: "q_DEC_CINE_90_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_90_02",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            decade: .nineties,
            funnyTitle: "La Cité de la Peur (1994)",
            prompt: "Dans « La Cité de la Peur » des Nuls (1994), quelle danse absurde Gérard Darmon et Alain Chabat exécutent-ils sur la Croisette à Cannes ?",
            choices: [
                "La Carioca",
                "La Macarena",
                "La Lambada",
                "Le Mia"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Youpi, dansons la Carioca ! C'est bien, faisez tous comme moi ! »",
            explanation: "💡 Le duo Patrick Bialès (Gérard Darmon) et Serge Karamazov (Alain Chabat) danse « La Carioca » au Festival de Cannes.",
            audioCueID: "q_DEC_CINE_90_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_90_03",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            decade: .nineties,
            funnyTitle: "Friends (1994) : Le café du canapé orange",
            prompt: "Dans la série « Friends » lancée en 1994, comment s'appelle le café new-yorkais où Rachel, Monica, Phoebe, Joey, Chandler et Ross passent leurs journées ?",
            choices: [
                "Le Central Perk",
                "Le Manhattan Bean",
                "Le Smelly Cat Café",
                "Le Soho Coffee"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le Central Perk (jeu de mots avec Central Park et « perk » du percolateur à café), tenu par Gunther !",
            explanation: "💡 Le café « Central Perk » (clin d'œil à Central Park) est le QG des six amis.",
            audioCueID: "q_DEC_CINE_90_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_00_01",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            decade: .twoThousands,
            funnyTitle: "Astérix et Obélix : Mission Cléopâtre (2002)",
            prompt: "En 2002 dans « Mission Cléopâtre » d'Alain Chabat, comment commence le célèbre monologue improvisé par Édouard Baer (Otis le scribe) ?",
            choices: [
                "« Vous savez, moi je ne crois pas qu'il y ait de bonne ou de mauvaise situation... »",
                "« Quand il fait trop chaud, je ne travaille plus »",
                "« Pas de pierre, pas de construction, pas de palais... »",
                "« Mais où avez-vous caché la potion magique ? »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« C'est une bonne situation ça, scribe ? — Vous savez, moi je ne crois pas qu'il y ait de bonne ou de mauvaise situation... »",
            explanation: "💡 Le monologue d'Otis (« C'est d'abord des rencontres... ») est devenu la réplique la plus citée des années 2000.",
            audioCueID: "q_DEC_CINE_00_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_00_02",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            decade: .twoThousands,
            funnyTitle: "Kaamelott (2005) : Perceval et Karadoc",
            prompt: "Dans « Kaamelott » d'Alexandre Astier (2005), quelle est la botte secrète de Perceval quand il ne comprend pas un mot compliqué dans une phrase ?",
            choices: [
                "Il répond — « C'est pas faux »",
                "Il crie — « Pays de Galles indépendant »",
                "Il mange une tranche de lard",
                "Il demande à Merlin"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« C'est pas faux ! » La technique infaillible enseignée par Karadoc quand on ne comprend pas le mot « péremptoire » !",
            explanation: "💡 Karadoc enseigne à Perceval de répondre « C'est pas faux » dès que son interlocuteur emploie un mot qu'il ne comprend pas.",
            audioCueID: "q_DEC_CINE_00_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_00_03",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            decade: .twoThousands,
            funnyTitle: "Bienvenue chez les Ch'tis (2008)",
            prompt: "Dans « Bienvenue chez les Ch'tis » (2008, 20 millions d'entrées), dans quelle petite ville du Nord Philippe Abrams (Kad Merad) est-il muté ?",
            choices: [
                "Bergues",
                "Maubeuge",
                "Dunkerque",
                "Béthune"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est à Bergues, célèbre pour son beffroi, son carillon et ses tartines de maroilles dans la chicorée !",
            explanation: "💡 Le film de Dany Boon se déroule à Bergues dans le département du Nord.",
            audioCueID: "q_DEC_CINE_00_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_10_01",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            decade: .twentyTens,
            funnyTitle: "Intouchables (2011) : « Pas de bras... »",
            prompt: "Dans « Intouchables » (2011) avec Omar Sy et François Cluzet, sur quel tube disco de « Earth, Wind & Fire » Driss fait-il danser tout le monde à l'anniversaire de Philippe ?",
            choices: [
                "Boogie Wonderland",
                "Stayin' Alive",
                "YMCA",
                "Le Freak"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est sur « Boogie Wonderland » que Driss (Omar Sy) met le feu après le concert de musique classique !",
            explanation: "💡 La scène de danse culte d'Omar Sy est rythmée par « Boogie Wonderland » d'Earth, Wind & Fire (1979).",
            audioCueID: "q_DEC_CINE_10_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_10_02",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            decade: .twentyTens,
            funnyTitle: "Stranger Things (2016) sur Netflix",
            prompt: "Dans la série « Stranger Things », comment s'appelle le monde parallèle sombre et terrifiant où disparaît le jeune Will Byers ?",
            choices: [
                "Le Monde à l'envers",
                "La Zone Fantôme",
                "La Chambre des Secrets",
                "Le Labyrinthe Noir"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le Monde à l'envers (« The Upside Down »), peuplé par le Démogorgon et Vecna !",
            explanation: "💡 La dimension parallèle de Hawkins est appelée « The Upside Down » (Le Monde à l'envers).",
            audioCueID: "q_DEC_CINE_10_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CINE_10_03",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            decade: .twentyTens,
            funnyTitle: "Squid Game (2021) : 1, 2, 3, Soleil !",
            prompt: "Dans la série phénomène « Squid Game » (2021), quelle forme géométrique est la PLUS difficile à découper à l'aiguille dans le gâteau de sucre coréen (Dalgona) ?",
            choices: [
                "Le parapluie",
                "Le cercle",
                "Le triangle",
                "Le carré"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est le fameux parapluie que choisit Gi-hun (n°456) et qu'il finit par lécher frénétiquement pour ne pas le casser !",
            explanation: "💡 Les quatre formes de l'épreuve du Dalgona sont le triangle, le cercle, l'étoile et le redoutable parapluie.",
            audioCueID: "q_DEC_CINE_10_03"
        ),
    ]

    public static let decadeMusiqueQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "DEC_MUS_60_01",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            decade: .sixties,
            funnyTitle: "Claude François et son marteau (1962)",
            prompt: "En 1962, que chante Claude François dans son premier grand tube : « Si j'avais un marteau, je cognerais le jour, je cognerais la nuit... » ?",
            choices: [
                "« J'y mettrais tout mon cœur »",
                "« Je casserais tous les murs »",
                "« Je réveillerais mes voisins »",
                "« J'achèterais des clous en or »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« J'y mettrais tout mon cœur ! Ce serait le bonheur ! » Mimo connaît ce refrain par cœur depuis ses 20 ans !",
            explanation: "💡 Adaptation française de « If I Had a Hammer », « Si j'avais un marteau » (1963) a lancé la carrière de Claude François.",
            audioCueID: "q_DEC_MUS_60_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_60_02",
            theme: .musiqueTubes,
            preferredRound: .tuTeMetsCombien,
            decade: .sixties,
            funnyTitle: "Les Poupées de France Gall et Gainsbourg (1965)",
            prompt: "Avec quelle chanson écrite par Serge Gainsbourg la jeune France Gall a-t-elle remporté le concours de l'Eurovision en 1965 ?",
            choices: [
                "Poupée de cire, poupée de son",
                "Les Sucettes",
                "Sacré Charlemagne",
                "Résiste"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est « Poupée de cire, poupée de son » (qui représentait le Luxembourg à l'Eurovision 1965) !",
            explanation: "💡 En mars 1965 à Naples, France Gall gagne l'Eurovision avec « Poupée de cire, poupée de son » composé par Serge Gainsbourg.",
            audioCueID: "q_DEC_MUS_60_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_60_03",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            decade: .sixties,
            funnyTitle: "Les Beatles traversent la rue (1969)",
            prompt: "Sur la pochette de l'album « Abbey Road » des Beatles (1969), quelle particularité a Paul McCartney sur le passage piéton ?",
            choices: [
                "Il marche pieds nus",
                "Il porte un parapluie rouge",
                "Il tient un petit chien en laisse",
                "Il marche à reculons"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Il est pieds nus ! Il faisait trop chaud ce matin d'août 1969 à Londres et il avait retiré ses sandales !",
            explanation: "💡 Sur la photo prise le 8 août 1969 par Iain Macmillan, Paul McCartney traverse Abbey Road pieds nus.",
            audioCueID: "q_DEC_MUS_60_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_70_01",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            decade: .seventies,
            funnyTitle: "Joe Dassin et « L'Été indien » (1975)",
            prompt: "Par quelle phrase parlée de Joe Dassin commence le slow légendaire « L'Été indien » en 1975 ?",
            choices: [
                "« Tu sais, je n'ai jamais été aussi heureux que ce matin-là... »",
                "« Aux Champs-Élysées, au soleil, sous la pluie... »",
                "« En passant par la Lorraine avec mes sabots... »",
                "« Salut, c'est encore moi »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Tu sais, je n'ai jamais été aussi heureux que ce matin-là... Nous marchions sur une plage un peu comme celle-ci... » Frissons garantis !",
            explanation: "💡 « L'Été indien » (1975) s'ouvre sur ce célèbre monologue parlé avec une robe longue façon aquarelle de Marie Laurencin.",
            audioCueID: "q_DEC_MUS_70_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_70_02",
            theme: .musiqueTubes,
            preferredRound: .tuTeMetsCombien,
            decade: .seventies,
            funnyTitle: "ABBA et la reine du Disco (1976)",
            prompt: "Dans le tube mondial « Dancing Queen » d'ABBA (1976), quel âge a la « Dancing Queen » dans le refrain (« Young and sweet, only... ») ?",
            choices: [
                "17 ans",
                "18 ans",
                "20 ans",
                "16 ans"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« You are the Dancing Queen, young and sweet, only seventeen ! » Elle a 17 ans !",
            explanation: "💡 Les paroles d'ABBA chantent : « You are the dancing queen, young and sweet, only seventeen ».",
            audioCueID: "q_DEC_MUS_70_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_70_03",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            decade: .seventies,
            funnyTitle: "Michel Sardou et les lacs irlandais (1981 / fin 70s)",
            prompt: "En 1977, dans quel tube disco français Patrick Juvet demande-t-il : « Où sont les femmes ? Avec leurs gestes pleins de... » ?",
            choices: [
                "« ...pleins de charme »",
                "« ...pleins de larmes »",
                "« ...pleins de paillettes »",
                "« ...pleins de flammes »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Où sont les femmes ? Avec leurs gestes pleins de charme ! Dis-moi où sont les femmes ? » Écrit par Jean-Michel Jarre !",
            explanation: "💡 Sorti en 1977 sur des paroles de Jean-Michel Jarre, « Où sont les femmes ? » est le plus grand tube disco de Patrick Juvet.",
            audioCueID: "q_DEC_MUS_70_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_80_01",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            decade: .eighties,
            funnyTitle: "Les Démons de Minuit (1986) en fin de mariage",
            prompt: "Dans « Les Démons de minuit » du groupe Images (1986), qu'est-ce que les démons nous entraînent à faire jusqu'au bout de la nuit ?",
            choices: [
                "« Jusqu'à l'insomnie, les fantômes de l'ennui dans mon cœur sont revenus »",
                "« Boire du Champomy sous les boules à facettes »",
                "« Chercher les clés de la Renault 5 sur le parking »",
                "« Danser le rock acrobatique avec Tonton »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Ils m'entraînent au bout de la nuit, les démons de minuit ! M'entraînent jusqu'à l'insomnie, les fantômes de l'ennui ! »",
            explanation: "💡 Numéro 1 du Top 50 pendant 13 semaines à l'été 1986, « Les Démons de minuit » reste l'hymne absolu des pistes de danse.",
            audioCueID: "q_DEC_MUS_80_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_80_02",
            theme: .musiqueTubes,
            preferredRound: .tuTeMetsCombien,
            decade: .eighties,
            funnyTitle: "L'Aventurier d'Indochine (1982)",
            prompt: "Dans « L'Aventurier » du groupe Indochine (1982), comment s'appelle le héros de romans d'aventure qui est « le roi de tous les vauriens » ?",
            choices: [
                "Bob Morane",
                "Largo Winch",
                "Corto Maltese",
                "Indiana Jones"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Et soudain surgit face au vent, le vrai héros de tous les temps : Bob Morane contre tout chacal, l'aventurier contre tout guerrier ! »",
            explanation: "💡 La chanson d'Indochine rend hommage aux romans de « Bob Morane » d'Henri Vernes et à son ennemi l'Ombre Jaune.",
            audioCueID: "q_DEC_MUS_80_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_80_03",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            decade: .eighties,
            funnyTitle: "Jean-Jacques Goldman : « Envole-moi » (1984)",
            prompt: "Dans « Quand la musique est bonne » (1982) de Jean-Jacques Goldman, quel mot est répété 3 fois d'affilée dans le refrain : « Quand la musique... » ?",
            choices: [
                "« Quand la musique donne, donne, donne Quand la musique sonne, sonne, sonne »",
                "« Quand la musique tourne, tourne, tourne »",
                "« Quand la musique cogne, cogne, cogne »",
                "« Quand la musique brille, brille, brille »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Quand la musique est bonne ! Quand la musique donne, donne, donne ! Quand la musique sonne, sonne, sonne, quand elle ne triche pas ! »",
            explanation: "💡 Sorti en 1982, ce titre a propulsé Jean-Jacques Goldman au sommet de la chanson française.",
            audioCueID: "q_DEC_MUS_80_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_90_01",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            decade: .nineties,
            funnyTitle: "IAM : « Je danse le Mia » (1994)",
            prompt: "Dans « Je danse le Mia » du groupe marseillais IAM (1994), quelle phrase culte les danseurs prononcent-ils sur la piste : « Ah ouais, ils passent... » ?",
            choices: [
                "« ...cette chanson »",
                "« ...du Céline Dion »",
                "« ...la serpillière au fond »",
                "« ...le permis moto »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Basé sur le sample de « Give Me the Night » de George Benson, « Je danse le Mia » raconte les soirées en boîte marseillaises des années 80-90 !",
            explanation: "💡 Sorti en 1994 sur l'album « Ombre est lumière », « Je danse le Mia » d'IAM s'est vendu à plus de 600 000 exemplaires.",
            audioCueID: "q_DEC_MUS_90_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_90_02",
            theme: .musiqueTubes,
            preferredRound: .tuTeMetsCombien,
            decade: .nineties,
            funnyTitle: "La Tribu de Dana de Manau (1998)",
            prompt: "Durant l'été 1998, comment commence le récit épique de « La Tribu de Dana » du groupe breton Manau ?",
            choices: [
                "« Le vent souffle sur les plaines de la Bretagne armoricaine... »",
                "« Au fond de la forêt de Brocéliande vivait un druide... »",
                "« Sur mon cheval blanc je galope vers la mer... »",
                "« Dans la vallée de Dana, il pleut tous les matins... »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Le vent souffle sur les plaines de la Bretagne armoricaine, je jette un dernier regard sur ma femme, mon fils et mon domaine ! » Tout le monde connaît ce couplet !",
            explanation: "💡 Sorti en mai 1998, « La Tribu de Dana » de Manau s'est écoulé à plus de 1,7 million d'exemplaires en France.",
            audioCueID: "q_DEC_MUS_90_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_90_03",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            decade: .nineties,
            funnyTitle: "Céline Dion : « Pour que tu m'aimes encore » (1995)",
            prompt: "Dans « Pour que tu m'aimes encore » (écrit par Goldman pour Céline Dion en 1995), en quoi Céline promet-elle de se changer dans le refrain ?",
            choices: [
                "« J'irai chercher ton cœur si tu l'emportes ailleurs... Je me changerai en or pour que tu m'aimes encore »",
                "« Je me changerai en sirène des mers du Nord »",
                "« Je traverserai l'Atlantique en pédalo »",
                "« Je chanterai sur la proue du Titanic »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Je trouverai des langages pour chanter tes louanges, je ferai nos bagages pour d'infinies vendanges, les formules magiques des marabouts d'Afrique... Je me changerai en or ! »",
            explanation: "💡 Tiré de l'album « D'eux » (1995), l'album francophone le plus vendu de tous les temps.",
            audioCueID: "q_DEC_MUS_90_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_00_01",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            decade: .twoThousands,
            funnyTitle: "Diam's : « La Boulette » (2006)",
            prompt: "En 2006 dans son tube « La Boulette », quelle rime générationnelle Diam's scande-t-elle : « Il y a comme un goût d'aigreur chez les jeunes de l'an 2000... » ?",
            choices: [
                "« Génération nan nan, qui pense qu'à la maille et aux vêtements »",
                "« Génération MSN qui écoute du rock américain »",
                "« Génération Skyblog qui sèche les cours de maths »",
                "« Génération Star Academy devant la télé »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Ouais gros, on fait des boulettes, ouais gros on perd la tête ! » Hymne absolu de l'année 2006 !",
            explanation: "💡 Extrait de l'album « Dans ma bulle » (diamant en 2006), « La Boulette » est le plus grand tube de Diam's.",
            audioCueID: "q_DEC_MUS_00_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_00_02",
            theme: .musiqueTubes,
            preferredRound: .tuTeMetsCombien,
            decade: .twoThousands,
            funnyTitle: "Stromae : « Alors on danse » (2009)",
            prompt: "Dans le tube planétaire « Alors on danse » de Stromae (sorti fin 2009), quelle suite de mots précède le fameux « Alors on danse » ?",
            choices: [
                "« Qui dit études dit travail, qui dit taf te dit les thunes, qui dit argent dit dépenses... »",
                "« Qui dit lundi dit café, qui dit mardi dit fatigué... »",
                "« Où t'es, papa où t'es ? »",
                "« Tous les mêmes, tous les mêmes et y'en a marre »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Qui dit études dit travail, qui dit taf te dit les thunes, qui dit argent dit dépenses, qui dit crédit dit créance... Alors on danse ! »",
            explanation: "💡 Sorti en septembre 2009, « Alors on danse » a propulsé le Belge Stromae numéro 1 dans 19 pays.",
            audioCueID: "q_DEC_MUS_00_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_00_03",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            decade: .twoThousands,
            funnyTitle: "Tragédie : « Hey Oh » (2003)",
            prompt: "En 2003, quelle question existentielle le duo nantais Tragédie pose-t-il dans le refrain de « Hey Oh » ?",
            choices: [
                "« Est-ce que tu m'entends, hey oh ? Est-ce que tu me sens, hey oh ? »",
                "« Est-ce que tu as du réseau sur ton SFR ? »",
                "« Où as-tu garé la Peugeot 206 ? »",
                "« Pourquoi tu ne réponds pas sur MSN ? »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Est-ce que tu m'entends, hey oh ? Est-ce que tu me sens, hey oh ? Touche-moi je suis là, hey oh ! »",
            explanation: "💡 Numéro 1 des ventes en France à l'automne 2003, « Hey Oh » de Tragédie est devenu le symbole R&B des années 2000.",
            audioCueID: "q_DEC_MUS_00_03"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_10_01",
            theme: .musiqueTubes,
            preferredRound: .cashSpeed,
            decade: .twentyTens,
            funnyTitle: "Daft Punk : « Get Lucky » (2013)",
            prompt: "En 2013, avec quel chanteur américain coiffé d'un grand chapeau et le guitariste Nile Rodgers le duo casqué Daft Punk signe-t-il le tube planétaire « Get Lucky » ?",
            choices: [
                "Pharrell Williams",
                "Bruno Mars",
                "The Weeknd",
                "Justin Timberlake"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était Pharrell Williams (et Nile Rodgers à la guitare funk) sur l'album « Random Access Memories » couronné aux Grammy Awards !",
            explanation: "💡 Sorti en avril 2013, « Get Lucky » associe Daft Punk, Pharrell Williams et Nile Rodgers.",
            audioCueID: "q_DEC_MUS_10_01"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_10_02",
            theme: .musiqueTubes,
            preferredRound: .tuTeMetsCombien,
            decade: .twentyTens,
            funnyTitle: "Aya Nakamura : « Djadja » (2018)",
            prompt: "En 2018, quelle réplique culte Aya Nakamura lance-t-elle dans le refrain de son tube mondial « Djadja » ?",
            choices: [
                "« Oh Djadja, y'a pas moyen Djadja, j'suis pas ta catin Djadja, genre en Catchana baby tu dead ça »",
                "« Mais t'es où, pas là, mais t'es où ? »",
                "« Basique, simple, vous n'avez pas les bases »",
                "« Balance ton quoi, même si tu parles mal des filles »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Oh Djadja, y'a pas moyen Djadja ! » Plus d'un milliard de vues et chanté dans le monde entier !",
            explanation: "💡 Sorti en avril 2018, « Djadja » d'Aya Nakamura est devenu la chanson francophone la plus écoutée de la décennie à l'international.",
            audioCueID: "q_DEC_MUS_10_02"
        ),
        QuizMCQQuestion(
            id: "DEC_MUS_10_03",
            theme: .musiqueTubes,
            preferredRound: .leSolo,
            decade: .twentyTens,
            funnyTitle: "Orelsan : « Basique » (2017)",
            prompt: "Dans son morceau « Basique » (2017), comment Orelsan ponctue-t-il chacune de ses affirmations évidentes dans le refrain ?",
            choices: [
                "« Basique Simple Vous n'avez pas les bases »",
                "« C'est carré C'est validé »",
                "« Au fond je crois que la terre est ronde »",
                "« On verra bien demain matin »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« OK, je vais devoir tout reprendre depuis le début parce que vous n'avez pas les bases... Basique ! Simple ! »",
            explanation: "💡 Le clip en plan-séquence de « Basique » (2017) a annoncé l'album « La fête est finie » d'Orelsan.",
            audioCueID: "q_DEC_MUS_10_03"
        ),
    ]

    public static let decadeCultureGQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "DEC_CUL_60_01",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            decade: .sixties,
            funnyTitle: "Le jour de congé des écoliers dans les années 60",
            prompt: "Dans les années 1960 (et jusqu'en 1972), quel jour de la semaine les écoliers français n'avaient-ils PAS école au milieu de la semaine (à la place du mercredi actuel) ?",
            choices: [
                "Le jeudi",
                "Le mardi",
                "Le vendredi",
                "Le lundi matin"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était le jeudi ! D'où l'expression « la semaine des quatre jeudis » ! Le mercredi libre n'a remplacé le jeudi qu'à la rentrée 1972 !",
            explanation: "💡 De 1882 à 1972, le jour de repos hebdomadaire des écoliers français en milieu de semaine était le jeudi.",
            audioCueID: "q_DEC_CUL_60_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_60_02",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            decade: .sixties,
            funnyTitle: "Le petit carré blanc à la télévision (1961)",
            prompt: "Apparu en 1961 en bas à droite de l'écran de l'ORTF, que signifiait le fameux « carré blanc » ?",
            choices: [
                "Que le film était déconseillé aux enfants et qu'il fallait les envoyer au lit",
                "Que le téléviseur était mal réglé",
                "Que le programme était diffusé en direct",
                "Qu'il allait pleuvoir le lendemain"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Dès que le carré blanc apparaissait dans le coin de l'écran, Meemaw disait : « Allez hop, une tisane et au lit les enfants ! »",
            explanation: "💡 Le « rectangle blanc » (appelé carré blanc) créé en mars 1961 signalait les œuvres déconseillées au jeune public.",
            audioCueID: "q_DEC_CUL_60_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_60_03",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            decade: .sixties,
            funnyTitle: "La nuit sur la Lune (21 juillet 1969)",
            prompt: "Le 21 juillet 1969, quel astronaute américain pose le pied sur la Lune en prononçant : « C'est un petit pas pour l'homme, mais un bond de géant pour l'humanité » ?",
            choices: [
                "Neil Armstrong",
                "Buzz Aldrin",
                "Youri Gagarine",
                "Thomas Pesquet"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était Neil Armstrong lors de la mission Apollo 11, suivi quelques minutes plus tard par Buzz Aldrin !",
            explanation: "💡 Neil Armstrong, commandant d'Apollo 11, est devenu le premier homme à marcher sur la Lune le 21 juillet 1969.",
            audioCueID: "q_DEC_CUL_60_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_70_01",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            decade: .seventies,
            funnyTitle: "Le verre de la cantine avec ton âge au fond",
            prompt: "Depuis les années 70 dans toutes les cantines scolaires françaises, quelle marque de verres incassables cache un numéro au fond que les enfants regardaient pour savoir « quel âge ils avaient » ?",
            choices: [
                "Les verres Duralex",
                "Les verres Pyrex",
                "Les verres Cristal d'Arques",
                "Les verres Baccarat"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Les verres Duralex bien sûr ! Le plus grand a l'âge le plus élevé et le plus jeune va chercher le broc d'eau ! (En vrai, c'est le numéro du moule d'usine !)",
            explanation: "💡 Le numéro gravé au fond des verres Duralex (modèle Picardie ou Gigogne) indique le moule de fabrication, mais servait de jeu d'âge dans toutes les cantines.",
            audioCueID: "q_DEC_CUL_70_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_70_02",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            decade: .seventies,
            funnyTitle: "« En France, on n'a pas de pétrole, mais... » (1976)",
            prompt: "Après le choc pétrolier des années 70, comment se terminait le célèbre slogan de l'Agence pour les économies d'énergie : « En France, on n'a pas de pétrole, mais... » ?",
            choices: [
                "« ...on a des idées »",
                "« ...on a du fromage »",
                "« ...on a des vélos »",
                "« ...on a des pulls en laine »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« En France, on n'a pas de pétrole, mais on a des idées ! » Et c'est à cette époque qu'on a instauré l'heure d'été en 1976 !",
            explanation: "💡 Lancé en 1976 par Jean Syrota, ce slogan accompagnait le passage à l'heure d'été et la chasse au gaspi.",
            audioCueID: "q_DEC_CUL_70_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_70_03",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            decade: .seventies,
            funnyTitle: "La colle Cléopâtre au parfum d'école",
            prompt: "Quel parfum sucré ultra-reconnaissable avait le petit pot de colle blanche Cléopâtre avec sa petite spatule orange sur les bureaux d'écoliers ?",
            choices: [
                "L'amande amère",
                "La fraise Tagada",
                "La vanille de Madagascar",
                "La fleur d'oranger"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "L'odeur d'amande amère ! Avoue que rien que d'y penser, tu revois le petit pinceau orange planté au milieu du pot !",
            explanation: "💡 La colle Cléopâtre (créée en 1930 et star des années 60-80) doit son odeur mythique à son parfum d'amande.",
            audioCueID: "q_DEC_CUL_70_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_80_01",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            decade: .eighties,
            funnyTitle: "Le Minitel 3615 (1982)",
            prompt: "Dans les années 1980, bien avant Internet, quel code fallait-il composer sur le téléphone avant de taper un service (comme ULLA, MÉTÉO ou SNCF) sur le Minitel ?",
            choices: [
                "3615",
                "0800",
                "118 218",
                "404"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Le mythique « 3615 code... » ! Avec le petit clavier qui faisait « clac-clac » et la facture France Télécom qui faisait tousser Pépé !",
            explanation: "💡 Lancé commercialement en 1982 en France, le réseau Télétel du Minitel était accessible via les numéros 3613, 3614 et le célèbre 3615.",
            audioCueID: "q_DEC_CUL_80_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_80_02",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            decade: .eighties,
            funnyTitle: "Le Top 50 de Marc Toesca (1984)",
            prompt: "À partir de 1984 sur Canal+, par quelle phrase rituelle l'animateur Marc Toesca ouvrait-il chaque émission du « Top 50 » ?",
            choices: [
                "« Salut les p'tits clous »",
                "« Bonsoir les jeunes »",
                "« En voiture Simone »",
                "« Magnéto Serge »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "« Salut les p'tits clous ! » sur la musique de « Toute première fois » de Jeanne Mas !",
            explanation: "💡 De 1984 à 1991, Marc Toesca saluait les téléspectateurs du Top 50 avec son fameux « Salut les p'tits clous ! ».",
            audioCueID: "q_DEC_CUL_80_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_80_03",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            decade: .eighties,
            funnyTitle: "La poudre qui claque sur la langue",
            prompt: "Dans les boulangeries des années 80, quel bonbon contenait une sucette en forme de pied qu'on trempait dans un sachet de poudre acidulée qui crépitait dans la bouche ?",
            choices: [
                "Frizzy Pazzy",
                "Le Carambar au nougat",
                "La boule de coco",
                "Le Roudoudou en coquillage"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Le Frizzy Pazzy et les sachets de poudre crépitante au sucre pétillant qui faisaient « paf-paf » jusque dans les oreilles !",
            explanation: "💡 Grâce au dioxyde de carbone emprisonné sous pression dans le sucre, les bonbons pétillants type Frizzy Pazzy crépitaient au contact de la salive.",
            audioCueID: "q_DEC_CUL_80_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_90_01",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            decade: .nineties,
            funnyTitle: "Les Pogs et le « Kini » dans la cour de récré (1995)",
            prompt: "En 1995, comment s'appelait le gros palet en plastique dur ou en métal que l'on jetait violemment sur une pile de Pogs en carton pour les retourner ?",
            choices: [
                "Un Kini",
                "Un Jojo's",
                "Un Calot",
                "Un Boulard"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était le Kini ! Et tous ceux qui se retournaient face visible finissaient dans ta poche (sauf si le prof les confisquait avant la sonnerie) !",
            explanation: "💡 Au jeu de Pogs, le palet lanceur plus épais et lourd s'appelait le « Kini » (ou « Slammer »).",
            audioCueID: "q_DEC_CUL_90_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_90_02",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            decade: .nineties,
            funnyTitle: "Le Tamagotchi de 1997",
            prompt: "En 1997, que se passait-il sur ton petit œuf électronique « Tamagotchi » japonais si tu oubliais de le nourrir et de ramasser ses petits besoins pendant toute la journée ?",
            choices: [
                "Il mourait et il fallait appuyer sur Reset avec un stylo",
                "Il commandait une pizza tout seul",
                "Il faisait exploser la pile",
                "Il appelait la maîtresse d'école"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Le drame absolu de 1997 : retrouver un petit ange avec des ailes sur l'écran LCD en sortant de cours parce que maman avait oublié de lui donner à manger !",
            explanation: "💡 Lancé par Bandai en 1996-1997, l'animal virtuel Tamagotchi réclamait des soins constants sous peine de repartir au paradis des pixels.",
            audioCueID: "q_DEC_CUL_90_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_90_03",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            decade: .nineties,
            funnyTitle: "Le bruit du modem Internet 56k (1998)",
            prompt: "Dans les années 90, pourquoi maman hurlait-elle depuis le salon : « DÉCONNECTE-TOI D'INTERNET MAINTENANT ! » ?",
            choices: [
                "Parce que le modem 56k occupait la ligne téléphonique fixe",
                "Parce que ça éteignait le réfrigérateur",
                "Parce que ça brouillait les chaînes de la télé",
                "Parce que l'ordinateur faisait sauter les plombs"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Tant que tu étais connecté en 56k, le téléphone fixe sonnait occupé pour toute la famille et le compteur France Télécom tournait à chaque minute !",
            explanation: "💡 Avant l'ADSL, le modem RTC 56k passait par la ligne téléphonique vocale, la rendant indisponible pour les appels.",
            audioCueID: "q_DEC_CUL_90_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_00_01",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            decade: .twoThousands,
            funnyTitle: "Le Wizz sur MSN Messenger (2005)",
            prompt: "Dans les années 2000 sur MSN Messenger, comment s'appelait le bouton qui faisait trembler toute la fenêtre de ton ami avec une sonnerie stridente quand il ne répondait pas assez vite ?",
            choices: [
                "Un Wizz",
                "Un Poke",
                "Un Shake",
                "Un Bip-Bip"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Le fameux Wizz : « DRRRING ! Vous venez d'envoyer un Wizz ! » Le moyen le plus efficace de rendre fou tout un bureau !",
            explanation: "💡 Sur MSN / Windows Live Messenger, le « Wizz » secouait l'écran du destinataire avec un son d'alerte.",
            audioCueID: "q_DEC_CUL_00_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_00_02",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            decade: .twoThousands,
            funnyTitle: "Le jeu culte du Nokia 3310 (2000)",
            prompt: "Sur l'indestructible téléphone Nokia 3310 sorti en l'an 2000, quel était le jeu préinstallé sur lequel tout le monde battait des records avec les touches 2, 4, 6 et 8 ?",
            choices: [
                "Snake II",
                "Angry Birds",
                "Candy Crush",
                "Flappy Bird"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Snake II bien sûr ! Jusqu'à ce que ton serpent fasse tout le tour de l'écran vert et noir et se morde la queue !",
            explanation: "💡 « Snake II » sur Nokia 3310 reste le jeu mobile le plus emblématique du début des années 2000.",
            audioCueID: "q_DEC_CUL_00_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_00_03",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            decade: .twoThousands,
            funnyTitle: "La dragonne de sécurité de la Nintendo Wii (2006)",
            prompt: "À Noël 2006, quel accident domestique se produisait dans des milliers de salons quand les joueurs s'emballaient au bowling sur « Wii Sports » sans attacher la dragonne au poignet ?",
            choices: [
                "La télécommande Wiimote partait comme un missile dans l'écran de la télé",
                "La console prenait feu",
                "Le tapis du salon glissait sous le canapé",
                "Les voisins recevaient les points sur leur propre télé"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Combien de téléviseurs tout neufs ont fini avec une Wiimote plantée au milieu de l'écran en plein strike de Wii Bowling !",
            explanation: "💡 Nintendo a même dû remplacer gratuitement des millions de dragonnes renforcées suite aux lancers accidentels de Wiimote dans les télés.",
            audioCueID: "q_DEC_CUL_00_03"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_10_01",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            decade: .twentyTens,
            funnyTitle: "La folie Pokémon GO de l'été 2016",
            prompt: "Durant l'été 2016, pourquoi voyait-on soudainement des centaines de personnes courir ensemble dans les parcs publics le téléphone à la main à 23 heures ?",
            choices: [
                "Ils chassaient un Pokémon rare sur Pokémon GO",
                "Ils cherchaient du réseau 4G gratuit",
                "Ils participaient à un marathon nocturne obligatoire",
                "Ils suivaient une étoile filante"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "L'été 2016 de Pokémon GO ! La seule époque où même Tonton faisait 12 km à pied le dimanche pour faire éclore un œuf de Pikachu !",
            explanation: "💡 Sorti en juillet 2016, le jeu en réalité augmentée « Pokémon GO » a rassemblé des foules immenses dans les parcs du monde entier.",
            audioCueID: "q_DEC_CUL_10_01"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_10_02",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            decade: .twentyTens,
            funnyTitle: "La robe qui a rendu Internet fou en 2015",
            prompt: "En février 2015, une simple photo d'une robe rayée a divisé les familles du monde entier en deux camps irréconciliables. Quelles étaient les deux combinaisons de couleurs que les gens voyaient ?",
            choices: [
                "« Bleue et noire » contre « Blanche et dorée »",
                "« Rouge et verte » contre « Jaune et violette »",
                "« Rose et grise » contre « Turquoise et grise »",
                "« Orange et noire » contre « Bleue et blanche »"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "La fameuse robe « Bleue et noire » ou « Blanche et dorée » ! (Et pour info, en vrai dans le magasin, elle était bien bleue et noire !)",
            explanation: "💡 Phénomène viral mondial de 2015 (« #TheDress »), cette illusion d'optique liée à l'éclairage faisait voir une robe bleue/noire comme blanche/dorée.",
            audioCueID: "q_DEC_CUL_10_02"
        ),
        QuizMCQQuestion(
            id: "DEC_CUL_10_03",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            decade: .twentyTens,
            funnyTitle: "Le jouet anti-stress de 2017",
            prompt: "En 2017, quel petit objet rotatif à trois branches doté d'un roulement à billes central a envahi toutes les cours d'école et les bureaux ?",
            choices: [
                "Le Hand Spinner",
                "Le Ruban Magique",
                "La Balle rebondissante lumineuse",
                "Le Ressort Ondamania"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Le Hand Spinner ! Tout le monde en avait trois dans son tiroir en mai 2017, et plus personne n'y touchait en septembre !",
            explanation: "💡 Au printemps 2017, le « Hand Spinner » (Fidget Spinner) a connu l'une des modes éclair les plus fulgurantes de l'histoire du jouet.",
            audioCueID: "q_DEC_CUL_10_03"
        ),
    ]

    public static let decadeEcoCashQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "DEC_ECO_60_01",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            decade: .sixties,
            funnyTitle: "Le prix de la baguette en 1965",
            prompt: "En 1965, combien coûtait environ une baguette de pain dans une boulangerie française (en Nouveaux Francs) ?",
            choices: [
                "Environ 0,40 Franc",
                "Environ 4 Francs",
                "Environ 10 Francs",
                "Environ 0,02 Franc"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Environ 40 centimes de franc en 1965 ! Avec une pièce de 1 Franc, tu repartais avec deux baguettes et quatre roudoudous !",
            explanation: "💡 En 1965, le prix réglementé de la baguette tournait autour de 0,40 NF (40 anciens francs).",
            audioCueID: "q_DEC_ECO_60_01"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_60_02",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            decade: .sixties,
            funnyTitle: "Le tout premier hypermarché de France (1963)",
            prompt: "En juin 1963, quelle enseigne ouvre le tout premier hypermarché de France (avec un immense parking gratuit et du libre-service géant) à Sainte-Geneviève-des-Bois ?",
            choices: [
                "Carrefour",
                "Monoprix",
                "Félix Potin",
                "Mammouth"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Carrefour le 15 juin 1963 à Sainte-Geneviève-des-Bois (Essonne) : 2 500 m², 400 places de parking et le début des chariots à roulettes !",
            explanation: "💡 Carrefour a inauguré le concept d'hypermarché en France en 1963 à Sainte-Geneviève-des-Bois.",
            audioCueID: "q_DEC_ECO_60_02"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_60_03",
            theme: .ecoCash,
            preferredRound: .leSolo,
            decade: .sixties,
            funnyTitle: "La pièce de 5 Francs « Semeuse » en argent",
            prompt: "Dans les années 1960, pourquoi beaucoup de grands-parents gardaient-ils précieusement les pièces de 5 Francs « Semeuse » frappées entre 1960 et 1969 dans une boîte à biscuits ?",
            choices: [
                "Parce qu'elles étaient fabriquées en véritable argent massif",
                "Parce qu'elles portaient bonheur au Loto",
                "Parce qu'elles marchaient dans tous les caddies",
                "Parce qu'elles brillaient dans le noir"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Elles contenaient 10 grammes d'argent pur (835‰) ! À partir de 1970, l'État les a remplacées par du cupro-nickel !",
            explanation: "💡 Les pièces de 5 Francs Semeuse (1960–1969) contenaient 83,5 % d'argent véritable, ce qui vaut aujourd'hui bien plus que leur valeur faciale.",
            audioCueID: "q_DEC_ECO_60_03"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_70_01",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            decade: .seventies,
            funnyTitle: "La création du SMIC (1970)",
            prompt: "En janvier 1970, le « SMIG » (Salaire Minimum Interprofessionnel Garanti) change de nom pour devenir le « SMIC ». Que signifie le « C » final de SMIC ?",
            choices: [
                "Croissance",
                "Consommation",
                "Citoyen",
                "Collectif"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Le C veut dire « Croissance » ! Contrairement au SMIG qui ne suivait que les prix, le SMIC a été indexé aussi sur la croissance du pouvoir d'achat !",
            explanation: "💡 Créé par la loi du 2 janvier 1970, le SMIC signifie « Salaire Minimum Interprofessionnel de Croissance ».",
            audioCueID: "q_DEC_ECO_70_01"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_70_02",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            decade: .seventies,
            funnyTitle: "Le tout premier tirage du Loto (19 mai 1976)",
            prompt: "Lors du tout premier tirage du Loto national le 19 mai 1976 (où il fallait cocher 6 numéros sur 49), combien de joueurs en France ont trouvé les 6 bons numéros ce premier soir ?",
            choices: [
                "Zéro gagnant au rang 1",
                "12 millionnaires d'un coup",
                "1 seul gagnant à Marseille",
                "100 gagnants"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Personne ! Il n'y avait eu que 73 000 bulletins joués pour ce tout premier tirage et aucun joueur n'avait trouvé les 6 numéros !",
            explanation: "💡 Lors du premier tirage du Loto le 19 mai 1976, aucun joueur n'a trouvé la combinaison à 6 chiffres (le premier grand gagnant arrivera en juillet 1976).",
            audioCueID: "q_DEC_ECO_70_02"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_70_03",
            theme: .ecoCash,
            preferredRound: .leSolo,
            decade: .seventies,
            funnyTitle: "Mammouth écrase les prix (Années 70)",
            prompt: "Quelle célèbre chaîne d'hypermarchés des années 70-80 avait pour slogan publicitaire : « Mammouth écrase les prix » (ce qui permettait aux humoristes d'en faire une contrepèterie célèbre) ?",
            choices: [
                "Les hypermarchés Mammouth",
                "Les magasins Continent",
                "Les magasins Euromarché",
                "Les magasins Radar"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était bien sûr l'enseigne Mammouth, immortalisée par la contrepèterie de Coluche !",
            explanation: "💡 L'enseigne d'hypermarchés Mammouth (groupe Docks de France, rachetée par Auchan en 1996) utilisait le slogan « Mammouth écrase les prix ».",
            audioCueID: "q_DEC_ECO_70_03"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_80_01",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            decade: .eighties,
            funnyTitle: "La pièce de 10 Francs « Mathieu » et la nouvelle bicolore (1988)",
            prompt: "Dans les années 1980, qui figurait sur le célèbre billet de 200 Francs rouge orangé que Meemaw glissait dans une enveloppe pour ton anniversaire ?",
            choices: [
                "Montesquieu",
                "Napoléon Bonaparte",
                "Victor Hugo",
                "Louis XIV"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'était le billet de 200 Francs Montesquieu (et le billet de 100 Francs Delacroix, ou le gros 500 Francs Pascal) !",
            explanation: "💡 Le billet de 200 Francs Montesquieu a circulé de 1982 à 1998 avant d'être remplacé par le 200 Francs Gustave Eiffel.",
            audioCueID: "q_DEC_ECO_80_01"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_80_02",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            decade: .eighties,
            funnyTitle: "Le taux record du Livret A en 1982",
            prompt: "Au début des années 1980 (en 1982), alors que l'inflation dépassait 11 %, quel taux d'intérêt historique (net d'impôt !) rapportait le Livret A ?",
            choices: [
                "8,50 % par an",
                "1,50 % par an",
                "15,00 % par an",
                "0,50 % par an"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "8,50 % sur le Livret A d'octobre 1981 à juillet 1983 ! Mais comme l'inflation était à 12 %, le pouvoir d'achat réel baissait quand même !",
            explanation: "💡 Le taux du Livret A a atteint son record historique de 8,5 % entre 1981 et 1983 dans un contexte de très forte inflation.",
            audioCueID: "q_DEC_ECO_80_02"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_80_03",
            theme: .ecoCash,
            preferredRound: .leSolo,
            decade: .eighties,
            funnyTitle: "« Un Mars et ça repart ! » et les pièces jaunes",
            prompt: "Dans les années 80, que pouvait-on acheter à la boulangerie avec une seule pièce de 1 Franc (soit 100 centimes de franc) ?",
            choices: [
                "10 bonbons à 10 centimes",
                "Un menu complet au restaurant",
                "Un disque vinyle 33 tours",
                "Une paire de baskets"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Avec 1 Franc en poche à la sortie de l'école dans les années 80, tu étais le roi du pétrole devant le bocal de bonbons à 10 ou 20 centimes !",
            explanation: "💡 Dans les années 1980, les bonbons à l'unité en boulangerie coûtaient entre 10 et 50 centimes de franc.",
            audioCueID: "q_DEC_ECO_80_03"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_90_01",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            decade: .nineties,
            funnyTitle: "La « Prime à la casse » de 1994 (Les Balladuriennes)",
            prompt: "En 1994, quelle prime de l'État offrait 5 000 Francs à tous les automobilistes qui envoyaient leur vieille voiture de plus de 10 ans à la casse pour acheter une voiture neuve ?",
            choices: [
                "La prime Balladur",
                "Le bonus écologique",
                "La prime Mobylette",
                "Le chèque autoroute"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "La fameuse « Balladurienne » de 5 000 Francs en 1994, suivie de la « Juppette » en 1995 qui a boosté les ventes de Twingo et de Clio !",
            explanation: "💡 En février 1994, le gouvernement d'Édouard Balladur a instauré une prime à la casse de 5 000 F pour relancer le marché automobile.",
            audioCueID: "q_DEC_ECO_90_01"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_90_02",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            decade: .nineties,
            funnyTitle: "Les nouveaux billets des années 90 (Saint-Exupéry & Cézanne)",
            prompt: "Sur le joli billet bleu de 50 Francs mis en circulation en 1993, quel écrivain-aviateur figurait aux côtés du « Petit Prince » et d'un mouton dessiné ?",
            choices: [
                "Antoine de Saint-Exupéry",
                "Jules Verne",
                "Marcel Pagnol",
                "Jean Mermoz"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Antoine de Saint-Exupéry et son Petit Prince ! Avec même le boa qui digère un éléphant caché en minuscule sur le billet !",
            explanation: "💡 Dessiné par Roger Pfund en 1993, le billet de 50 Francs rendait hommage à Antoine de Saint-Exupéry et au Petit Prince.",
            audioCueID: "q_DEC_ECO_90_02"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_90_03",
            theme: .ecoCash,
            preferredRound: .leSolo,
            decade: .nineties,
            funnyTitle: "La carte téléphonique « Télécarte » à puce (Années 90)",
            prompt: "Dans les cabines téléphoniques France Télécom des années 90, quelles étaient les deux capacités standard des Télécartes vendues au bureau de tabac ?",
            choices: [
                "50 unités et 120 unités",
                "10 minutes et 100 minutes",
                "5 Francs et 50 Francs",
                "1 appel et 10 appels"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Les Télécartes de 50 unités et 120 unités que tout le monde collectionnait dans des classeurs à pochettes plastiques !",
            explanation: "💡 Les Télécartes à puce inventées par Roland Moreno étaient commercialisées en versions de 50 unités et 120 unités.",
            audioCueID: "q_DEC_ECO_90_03"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_00_01",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            decade: .twoThousands,
            funnyTitle: "Le sachet « Premiers Euros » (Décembre 2001)",
            prompt: "En décembre 2001, juste avant le passage à l'euro du 1er janvier 2002, combien coûtait en Francs le petit sachet plastique contenant 40 pièces en euros (soit 15,25 €) vendu dans les banques et bureaux de poste ?",
            choices: [
                "Exactement 100 Francs",
                "Exactement 50 Francs",
                "Exactement 200 Francs",
                "Il était distribué gratuitement"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Il coûtait tout rond 100 Francs (pour 15,2449 € de pièces à l'intérieur, arrondis à 15,25 € grâce à un centime offert par l'État) !",
            explanation: "💡 Le « kit euro » (40 pièces = 15,25 €) a été vendu 100 Francs à partir du 14 décembre 2001 pour familiariser les Français aux nouvelles pièces.",
            audioCueID: "q_DEC_ECO_00_01"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_00_02",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            decade: .twoThousands,
            funnyTitle: "L'éclatement de la « bulle Internet » (2000)",
            prompt: "En mars 2000, le CAC 40 atteint un sommet historique avant l'éclatement de quelle bulle spéculative boursière ?",
            choices: [
                "La bulle Internet",
                "La bulle des tulipes",
                "La bulle du charbon",
                "La bulle du Minitel"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "La bulle Internet (dot-com) en l'an 2000, où n'importe quelle entreprise qui ajoutait « .com » à son nom doublait en Bourse en une semaine avant le krach !",
            explanation: "💡 En mars 2000, l'euphorie autour des valeurs technologiques et télécoms a provoqué l'éclatement de la « bulle Internet ».",
            audioCueID: "q_DEC_ECO_00_02"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_00_03",
            theme: .ecoCash,
            preferredRound: .leSolo,
            decade: .twoThousands,
            funnyTitle: "La crise des « Subprimes » (2008)",
            prompt: "En septembre 2008, la faillite de quelle grande banque d'investissement américaine déclenche une onde de choc financière mondiale ?",
            choices: [
                "Lehman Brothers",
                "La Banque Postale",
                "Goldman Sachs",
                "Western Union"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est la faillite de Lehman Brothers le 15 septembre 2008, point culminant de la crise des crédits immobiliers « subprimes » !",
            explanation: "💡 Le 15 septembre 2008, la banque Lehman Brothers dépose le bilan avec 600 milliards de dollars de dettes.",
            audioCueID: "q_DEC_ECO_00_03"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_10_01",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            decade: .twentyTens,
            funnyTitle: "Le paiement sans contact par carte bancaire",
            prompt: "Dans les années 2020 en France, quel est le plafond maximum d'un paiement « sans contact » en posant simplement sa carte bancaire physique sur le terminal (sans taper son code) ?",
            choices: [
                "50 €",
                "15 €",
                "100 €",
                "500 €"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est 50 € par achat pour la carte physique (et encore plus avec Apple Pay sur ton téléphone qui vérifie Face ID) !",
            explanation: "💡 Le plafond du paiement sans contact par carte bancaire est passé de 20 € (2012) à 30 € (2017) puis 50 € en mai 2020.",
            audioCueID: "q_DEC_ECO_10_01"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_10_02",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            decade: .twentyTens,
            funnyTitle: "Les 10 000 Bitcoins pour deux pizzas (Mai 2010)",
            prompt: "Le 22 mai 2010, qu'a acheté le développeur Laszlo Hanyecz pour réaliser le tout premier achat commercial de l'histoire en payant 10 000 Bitcoins (qui valaient alors 40 dollars) ?",
            choices: [
                "Deux grandes pizzas",
                "Une voiture électrique Tesla",
                "Une île privée aux Bahamas",
                "Un ordinateur portable"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Deux pizzas Papa John's payées 10 000 Bitcoins en 2010 ! Aujourd'hui, ces deux pizzas vaudraient plusieurs centaines de millions d'euros : la croûte la plus chère de l'histoire !",
            explanation: "💡 Le 22 mai 2010 (« Bitcoin Pizza Day »), 10 000 BTC ont été échangés contre deux pizzas livrées à domicile.",
            audioCueID: "q_DEC_ECO_10_02"
        ),
        QuizMCQQuestion(
            id: "DEC_ECO_10_03",
            theme: .ecoCash,
            preferredRound: .leSolo,
            decade: .twentyTens,
            funnyTitle: "La revente de vêtements en seconde main (Vinted)",
            prompt: "Dans les années 2010–2020, quelle application née en Lituanie est devenue le réflexe numéro 1 en France pour revendre les vêtements qu'on ne met plus : « Tu ne le portes pas ? Vends-le ! » ?",
            choices: [
                "Vinted",
                "Brocante 3615",
                "Troc-Pépé",
                "Vide-Grenier Express"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "C'est Vinted ! La France est même devenue le premier marché mondial de l'application !",
            explanation: "💡 Fondée à Vilnius en 2008 et popularisée en France dans les années 2010, Vinted a popularisé le slogan « Tu ne le portes pas ? Vends-le ! ».",
            audioCueID: "q_DEC_ECO_10_03"
        ),
    ]
}
