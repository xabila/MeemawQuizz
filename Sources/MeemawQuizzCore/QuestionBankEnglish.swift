import Foundation

public enum AppLanguage: String, Codable, Sendable {
    case fr = "fr"
    case en = "en"

    /// Résout automatiquement la langue de l'application à partir des réglages système iOS (`Locale.preferredLanguages`).
    public static var current: AppLanguage {
        for pref in Locale.preferredLanguages {
            let lower = pref.lowercased()
            if lower.hasPrefix("en") { return .en }
            if lower.hasPrefix("fr") { return .fr }
        }
        return .fr
    }

    public static var isEnglish: Bool {
        current == .en
    }
}

extension QuestionBank {

    public static var allEnglishQuestions: [QuizMCQQuestion] {
        englishFrancaisQuestions
            + englishMathQuestions
            + englishSeriesCinemaQuestions
            + englishMusiqueAndJukeboxQuestions
            + englishCultureGQuestions
            + englishEcoCashQuestions
    }

    // MARK: - 1. 👵 English Grammar, Idioms & Grandma Slang

    public static let englishFrancaisQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "EN_FR_01",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "The Great 'Their / There / They're' Meltdown",
            prompt: "Which sentence uses 'THEIR', 'THERE', and 'THEY'RE' with 100% Meemaw-approved grammar?",
            choices: [
                "They're parking their RV over there by the bingo hall!",
                "There parking they're RV over their by the bingo hall!",
                "Their parking there RV over they're by the bingo hall!",
                "They're parking there RV over their by the bingo hall!"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Sweetheart, 'They're' = They are, 'Their' = ownership, and 'There' = location! Put down your phone and read a book!",
            explanation: "💡 'They're' is a contraction of 'they are', 'their' is possessive, and 'there' refers to a place.",
            audioCueID: "en_q_FR_01"
        ),
        QuizMCQQuestion(
            id: "EN_FR_02",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "The Most Misspelled Word on the Internet",
            prompt: "What is the ONLY correct spelling of the word meaning 'without a doubt'?",
            choices: [
                "DEFINITELY",
                "DEFINATELY",
                "DEFINITLY",
                "DEFIANTLY"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "There is NO 'A' in definitely! Remember the word FINITE inside de-FINITE-ly, or Meemaw is taking away your Wi-Fi!",
            explanation: "💡 'Definitely' comes from 'definite' + '-ly' — never 'definately'.",
            audioCueID: "en_q_FR_02"
        ),
        QuizMCQQuestion(
            id: "EN_FR_03",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Spilling the Beans in the Kitchen",
            prompt: "When Meemaw says 'Don't spill the beans at Sunday dinner!', what is she telling you NOT to do?",
            choices: [
                "Reveal a secret prematurely",
                "Drop the chili pot on the carpet",
                "Feed the dog under the table",
                "Complain about her meatloaf"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Spilling the beans means giving away a secret! Though if you spill actual beans on Meemaw's rug, you're in trouble too!",
            explanation: "💡 'To spill the beans' is a classic English idiom meaning to reveal secret information.",
            audioCueID: "en_q_FR_03"
        ),
        QuizMCQQuestion(
            id: "EN_FR_04",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "A Piece of Cake (With Extra Frosting)",
            prompt: "In English slang, if a quiz question is 'a piece of cake', what does that mean?",
            choices: [
                "It is super easy",
                "It is full of calories",
                "It is a total lie",
                "It takes two hours to bake"
            ],
            correctIndex: 0,
            baseValue: 1800,
            meemawRoastOnWrong: "A piece of cake means effortless and easy! Just like beating your uncle at bingo!",
            explanation: "💡 Originating in the 1930s, 'a piece of cake' refers to something easily accomplished.",
            audioCueID: "en_q_FR_04"
        ),
        QuizMCQQuestion(
            id: "EN_FR_05",
            theme: .francaisMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Embarrassing Double Letters",
            prompt: "How many R's and how many S's are in the word meaning to make someone blush with shame?",
            choices: [
                "2 R's and 2 S's: EMBARRASS",
                "1 R and 2 S's: EMBARASS",
                "2 R's and 1 S: EMBARRAS",
                "1 R and 1 S: EMBARAS"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Double R, double S: EMBARRASS! Getting that wrong is... well, embarrassing!",
            explanation: "💡 Memory trick: you turn 'Really Red And Super Shy' (2 R's, 2 S's) when you are embarrassed.",
            audioCueID: "en_q_FR_05"
        ),
        QuizMCQQuestion(
            id: "EN_FR_06",
            theme: .francaisMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "Zero Interest in Your Cousin's Cat Slideshow",
            prompt: "If you have ZERO interest in your cousin's 45-minute slideshow of his cat, which phrase is logically correct?",
            choices: [
                "I COULDN'T care less",
                "I COULD care less",
                "I care more or less",
                "I might care on Tuesdays"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "If you COULD care less, that means you still care a little bit! 'I couldn't care less' means zero care left in the tank!",
            explanation: "💡 'I couldn't care less' means it is impossible to care any less than you already do.",
            audioCueID: "en_q_FR_06"
        ),
        QuizMCQQuestion(
            id: "EN_FR_07",
            theme: .francaisMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Bite the Bullet, Cowboy",
            prompt: "What does the idiom 'to bite the bullet' mean?",
            choices: [
                "Face a tough situation with courage",
                "Chew on aluminum foil for fun",
                "Argue with the family dentist",
                "Run away from an argument"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "It means facing something tough head-on, like eating Brussels sprouts without whining!",
            explanation: "💡 Historically linked to patients biting on a lead bullet to cope with pain before anesthesia.",
            audioCueID: "en_q_FR_07"
        ),
        QuizMCQQuestion(
            id: "EN_FR_08",
            theme: .francaisMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "You're vs. Your: The Text Message Crime",
            prompt: "When someone texts you 'Your welcome!', what grammar crime did they just commit?",
            choices: [
                "It should be 'You're welcome!'",
                "It should be 'Yore welcome!'",
                "It should be 'Ur welcomes!'",
                "Nothing, 'welcome' is a pet dog you own"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Unless I own a physical object called a 'welcome', it's YOU'RE welcome (You are welcome)!",
            explanation: "💡 'You're' = 'you are'; 'your' is possessive.",
            audioCueID: "en_q_FR_08"
        )
    ]

    // MARK: - 2. 📐 English Math & Logic Brainteasers

    public static let englishMathQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "EN_MATH_01",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "The $1.10 Bat and Ball Trap",
            prompt: "A baseball bat and a ball cost $1.10 in total. The bat costs $1.00 MORE than the ball. How much does the ball cost?",
            choices: [
                "5 cents",
                "10 cents",
                "1 cent",
                "50 cents"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Gotcha! If the ball were 10 cents, the bat would be $1.10, making $1.20 total! The ball is 5 cents and the bat is $1.05!",
            explanation: "💡 0.05 + (0.05 + 1.00) = 1.10. Over 50% of university students blurt out 10 cents!",
            audioCueID: "en_q_MATH_01"
        ),
        QuizMCQQuestion(
            id: "EN_MATH_02",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Meemaw's Oven Timer Riddle",
            prompt: "If it takes 5 machines 5 minutes to make 5 cookies, how long does it take 100 machines to make 100 cookies?",
            choices: [
                "5 minutes",
                "100 minutes",
                "500 minutes",
                "1 minute"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "5 minutes! All 100 machines work at the same time, and each one bakes its cookie in 5 minutes!",
            explanation: "💡 Each machine produces 1 cookie per 5-minute cycle, regardless of how many machines run in parallel.",
            audioCueID: "en_q_MATH_02"
        ),
        QuizMCQQuestion(
            id: "EN_MATH_03",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Passing Second Place in the Marathon",
            prompt: "You are running a race and you overtake the person in 2nd place. What place are you in right now?",
            choices: [
                "2nd place",
                "1st place",
                "3rd place",
                "Last place"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "If you pass the person in 2nd place, you take 2nd place! The leader is still ahead of you!",
            explanation: "💡 Overtaking #2 puts you in 2nd position.",
            audioCueID: "en_q_MATH_03"
        ),
        QuizMCQQuestion(
            id: "EN_MATH_04",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "Order of Operations Showdown",
            prompt: "Without a calculator, what is the result of: 8 + 2 × 5 ?",
            choices: [
                "18",
                "50",
                "25",
                "15"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "PEMDAS, honey! Multiplication comes before addition: 2 × 5 is 10, plus 8 makes 18!",
            explanation: "💡 By order of operations (PEMDAS/BODMAS), 2 × 5 = 10 is evaluated before 8 + 10 = 18.",
            audioCueID: "en_q_MATH_04"
        ),
        QuizMCQQuestion(
            id: "EN_MATH_05",
            theme: .mathMeemaw,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Rooster on the Barn Roof",
            prompt: "A rooster lays an egg right on the sharp peak of a barn roof. The wind is blowing from East to West. Which way does the egg roll?",
            choices: [
                "Nowhere",
                "To the West",
                "To the East",
                "Straight into the frying pan"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Wake up! Hens lay eggs, roosters just crow at 5 AM to annoy the neighborhood!",
            explanation: "💡 Roosters are male chickens and never lay eggs.",
            audioCueID: "en_q_MATH_05"
        ),
        QuizMCQQuestion(
            id: "EN_MATH_06",
            theme: .mathMeemaw,
            preferredRound: .finaleDouble,
            funnyTitle: "The Lily Pad Double-Up",
            prompt: "A patch of lily pads on a pond doubles in size every single day. If it takes 48 days to cover the entire pond, how many days did it take to cover HALF the pond?",
            choices: [
                "47 days",
                "24 days",
                "12 days",
                "46 days"
            ],
            correctIndex: 0,
            baseValue: 2400,
            meemawRoastOnWrong: "47 days, not 24! Because if it doubles every day, being half-full on day 47 means it's 100% full on day 48!",
            explanation: "💡 Exponential growth doubles each day, so half the pond is reached exactly 1 day before full coverage.",
            audioCueID: "en_q_MATH_06"
        ),
        QuizMCQQuestion(
            id: "EN_MATH_07",
            theme: .mathMeemaw,
            preferredRound: .cashSpeed,
            funnyTitle: "How Many Months Have 28 Days?",
            prompt: "Quick! How many months of the year have 28 days?",
            choices: [
                "All 12 months",
                "Only 1 month",
                "Only in leap years",
                "6 months"
            ],
            correctIndex: 0,
            baseValue: 1800,
            meemawRoastOnWrong: "All 12 months have a 28th day! Nobody said 'ONLY 28 days'!",
            explanation: "💡 Every month from January to December has at least 28 days.",
            audioCueID: "en_q_MATH_07"
        ),
        QuizMCQQuestion(
            id: "EN_MATH_08",
            theme: .mathMeemaw,
            preferredRound: .leSolo,
            funnyTitle: "Grandpa's Pill Schedule",
            prompt: "The doctor gives Grandpa 3 pills and tells him to take one every 30 minutes. How long until all 3 pills are taken?",
            choices: [
                "60 minutes",
                "90 minutes",
                "30 minutes",
                "3 hours"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Only 60 minutes! You take the first pill immediately at minute 0, the second at 30, and the third at 60!",
            explanation: "💡 Three pills require only two 30-minute intervals between them (60 minutes total).",
            audioCueID: "en_q_MATH_08"
        )
    ]

    // MARK: - 3. 🎬 Movies & TV Shows (Explained Badly by Meemaw)

    public static let englishSeriesCinemaQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "EN_CINE_01",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "The Most Misquoted Line in Galaxy History",
            prompt: "In 'Star Wars: The Empire Strikes Back', what does Darth Vader ACTUALLY say to Luke Skywalker?",
            choices: [
                "“No, I am your father.”",
                "“Luke, I am your father.”",
                "“Luke, ask your mother.”",
                "“Luke, clean your room.”"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Mandela Effect alert! Luke yells 'He told me enough! He told me you killed him!' and Vader replies: 'No, I am your father.'",
            explanation: "💡 Darth Vader's exact line is 'No, I am your father.'",
            audioCueID: "en_q_CINE_01"
        ),
        QuizMCQQuestion(
            id: "EN_CINE_02",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Movie Explained Badly by Meemaw #1",
            prompt: "Which blockbuster is Meemaw describing: 'A billionaire orphan dresses up as a nocturnal rodent to beat up a clown instead of going to therapy'?",
            choices: [
                "The Dark Knight",
                "Ratatouille",
                "Spider-Man",
                "Stuart Little"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "It's Batman! All those billions of dollars and he spends his nights in a rubber bat suit!",
            explanation: "💡 Bruce Wayne (Batman) battles the Joker across Gotham City.",
            audioCueID: "en_q_CINE_02"
        ),
        QuizMCQQuestion(
            id: "EN_CINE_03",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "Movie Explained Badly by Meemaw #2",
            prompt: "Which movie is Meemaw summarizing: 'Nine guys spend 9 hours walking across New Zealand to return a piece of cursed jewelry to the volcano factory'?",
            choices: [
                "The Lord of the Rings",
                "Titanic",
                "Breakfast at Tiffany's",
                "Jurassic Park"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "The Lord of the Rings! Nine hours of walking when they could have called the giant eagles for an Uber!",
            explanation: "💡 Frodo and the Fellowship trek to Mount Doom to destroy the One Ring.",
            audioCueID: "en_q_CINE_03"
        ),
        QuizMCQQuestion(
            id: "EN_CINE_04",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "Kevin Malone's Carpet Disaster in The Office",
            prompt: "In the legendary cold open of 'The Office' (US), what prized family recipe does Kevin Malone spill all over the Dunder Mifflin carpet?",
            choices: [
                "A giant pot of his homemade chili",
                "A 5-tier chocolate wedding cake",
                "Michael Scott's chicken pot pie",
                "A bucket of New England clam chowder"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Kevin's Famous Chili! 'The trick is to undercook the onions...' right before he belly-flops into it!",
            explanation: "💡 In Season 5 Episode 26 ('Casual Friday'), Kevin drops his giant pot of chili on the office carpet.",
            audioCueID: "en_q_CINE_04"
        ),
        QuizMCQQuestion(
            id: "EN_CINE_05",
            theme: .seriesCinema,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "PIVOT! PIVOT! PIVOT!",
            prompt: "In 'Friends', which character screams 'PIVOT! PIVOT! PIVAAAHT!' while trying to carry a couch up a narrow staircase?",
            choices: [
                "Ross Geller",
                "Joey Tribbiani",
                "Chandler Bing",
                "Gunther"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Ross Geller, armed with a hand-drawn sketch because he was too cheap to pay for delivery!",
            explanation: "💡 Ross yells 'PIVOT!' to Rachel and Chandler in Season 5 Episode 16 ('The One with the Cop').",
            audioCueID: "en_q_CINE_05"
        ),
        QuizMCQQuestion(
            id: "EN_CINE_06",
            theme: .seriesCinema,
            preferredRound: .finaleDouble,
            funnyTitle: "Doc Brown's Time Machine Speed",
            prompt: "In 'Back to the Future', what exact speed (in miles per hour) must the DeLorean reach to travel through time?",
            choices: [
                "88 mph",
                "100 mph",
                "66 mph",
                "121 mph"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "88 miles per hour (and 1.21 Gigawatts of power)! When this baby hits 88 mph, you're gonna see some serious stuff!",
            explanation: "💡 Doc Brown's DeLorean activates the flux capacitor at 88 mph.",
            audioCueID: "en_q_CINE_06"
        ),
        QuizMCQQuestion(
            id: "EN_CINE_07",
            theme: .seriesCinema,
            preferredRound: .cashSpeed,
            funnyTitle: "You're Gonna Need a Bigger Boat",
            prompt: "In which 1975 Steven Spielberg classic does Chief Brody utter the iconic line: 'You're gonna need a bigger boat'?",
            choices: [
                "Jaws",
                "Titanic",
                "Pirates of the Caribbean",
                "Finding Nemo"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Jaws! Right after seeing the giant great white shark pop out of the water!",
            explanation: "💡 Roy Scheider improvised the line 'You're gonna need a bigger boat' in Jaws (1975).",
            audioCueID: "en_q_CINE_07"
        ),
        QuizMCQQuestion(
            id: "EN_CINE_08",
            theme: .seriesCinema,
            preferredRound: .leSolo,
            funnyTitle: "Young Sheldon's Favorite Grandma",
            prompt: "In 'Young Sheldon' and 'The Big Bang Theory', what is the real first name of Sheldon Cooper's sassy Texas grandmother, 'Meemaw'?",
            choices: [
                "Constance Tucker",
                "Mary Cooper",
                "Betty White",
                "Dorothy Zbornak"
            ],
            correctIndex: 0,
            baseValue: 2400,
            meemawRoastOnWrong: "Constance 'Connie' Tucker, played by the fabulous Annie Potts! How dare you forget your own Meemaw's name?!",
            explanation: "💡 Sheldon's Meemaw is Constance 'Connie' Tucker.",
            audioCueID: "en_q_CINE_08"
        )
    ]

    // MARK: - 4. 🎧 Jukebox Express & Pop Hits (With JUK_ Prefix for Jukebox Round!)

    public static let englishMusiqueAndJukeboxQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "JUK_EN_01",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎤 Don't Forget the Lyrics — Queen",
            prompt: "Complete the legendary 'Bohemian Rhapsody' lyrics: “Scaramouche, Scaramouche, will you do the ___ ?”",
            choices: [
                "Fandango!",
                "Macarena!",
                "Cha-Cha-Cha!",
                "Flamingo!"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Will you do the FANDANGO! Not the Flamingo, we're not in a Florida zoo!",
            explanation: "💡 Freddie Mercury's 1975 rock opera classic continues: 'Thunderbolt and lightning, very, very frightening me!'",
            audioCueID: "en_q_JUK_01"
        ),
        QuizMCQQuestion(
            id: "JUK_EN_02",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎤 Don't Forget the Lyrics — ABBA",
            prompt: "In ABBA's 'Dancing Queen', how old is the Dancing Queen? “You are the dancing queen, young and sweet, only ___ !”",
            choices: [
                "Seventeen!",
                "Nineteen!",
                "Twenty-three!",
                "Seventy-three!"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Only SEVENTEEN! Feel the beat from the tambourine, oh yeah!",
            explanation: "💡 Released in 1976, ABBA's 'Dancing Queen' celebrates being 'young and sweet, only seventeen'.",
            audioCueID: "en_q_JUK_02"
        ),
        QuizMCQQuestion(
            id: "JUK_EN_03",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎤 Don't Forget the Lyrics — Spice Girls",
            prompt: "Complete the 1996 Spice Girls mega-hit 'Wannabe': “If you wanna be my lover, you gotta ___ !”",
            choices: [
                "Get with my friends!",
                "Wash all the dishes!",
                "Pay my rent!",
                "Ask my grandma!"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "You gotta get with my friends! Though washing the dishes wouldn't hurt either!",
            explanation: "💡 'Wannabe' (1996) is the best-selling debut single by an all-female group in history.",
            audioCueID: "en_q_JUK_03"
        ),
        QuizMCQQuestion(
            id: "JUK_EN_04",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎤 Don't Forget the Lyrics — Journey",
            prompt: "Complete the ultimate karaoke opening line of Journey's 'Don't Stop Believin'': “Just a small town girl, livin' in a ___ !”",
            choices: [
                "Lonely world!",
                "Material world!",
                "Barbie world!",
                "Crazy world!"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Livin' in a LONELY world! She took the midnight train goin' anywhere!",
            explanation: "💡 Journey's 1981 anthem is the most downloaded 20th-century track in history.",
            audioCueID: "en_q_JUK_04"
        ),
        QuizMCQQuestion(
            id: "JUK_EN_05",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎤 Don't Forget the Lyrics — Rick Astley",
            prompt: "You just got Rickrolled! Which promise does Rick Astley NOT make in 'Never Gonna Give You Up'?",
            choices: [
                "Never gonna lend you twenty bucks",
                "Never gonna give you up",
                "Never gonna let you down",
                "Never gonna run around and desert you"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Rick will never give you up or let you down, but he never promised you $20!",
            explanation: "💡 Rick Astley's 1987 hit became the internet's ultimate 'Rickroll' meme.",
            audioCueID: "en_q_JUK_05"
        ),
        QuizMCQQuestion(
            id: "JUK_EN_06",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎤 Don't Forget the Lyrics — Bon Jovi",
            prompt: "Complete the famous 1986 Bon Jovi rock chorus: “Whoa, we're half way there, whoa-oh, ___ !”",
            choices: [
                "Livin' on a prayer!",
                "Squidward on a chair!",
                "Lemon and a pear!",
                "Lizard on the stair!"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Livin' on a prayer! Though 'Squidward on a chair' is a classic internet remix!",
            explanation: "💡 Bon Jovi hit #1 on the Billboard Hot 100 with 'Livin' on a Prayer' in 1987.",
            audioCueID: "en_q_JUK_06"
        ),
        QuizMCQQuestion(
            id: "JUK_EN_07",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎤 Don't Forget the Lyrics — Michael Jackson",
            prompt: "In Michael Jackson's 'Billie Jean', finish the famous chorus: “Billie Jean is not my lover, she's just a girl who claims that ___ !”",
            choices: [
                "I am the one!",
                "I stole her car!",
                "I ate her pie!",
                "I can't moonwalk!"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "She's just a girl who claims that I am the one — but the kid is not my son!",
            explanation: "💡 From the 1982 album 'Thriller', the best-selling album of all time.",
            audioCueID: "en_q_JUK_07"
        ),
        QuizMCQQuestion(
            id: "JUK_EN_08",
            theme: .musiqueTubes,
            preferredRound: .jukeboxExpress,
            funnyTitle: "🎤 Don't Forget the Lyrics — Smash Mouth",
            prompt: "Complete the opening line of 'All Star' (the Shrek anthem!): “Somebody once told me the world is gonna ___ !”",
            choices: [
                "Roll me!",
                "Hold me!",
                "Scold me!",
                "Fold me!"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "The world is gonna ROLL me, I ain't the sharpest tool in the shed!",
            explanation: "💡 Smash Mouth's 1999 hit 'All Star' became immortalized in the opening credits of Shrek (2001).",
            audioCueID: "en_q_JUK_08"
        )
    ]

    // MARK: - 5. 🌍 Weird Science & Trivia

    public static let englishCultureGQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "EN_CUL_01",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "Australia's Great Feather War of 1932",
            prompt: "In 1932, the Australian military deployed soldiers with machine guns against which bird... and officially LOST the war?",
            choices: [
                "Emus",
                "Seagulls",
                "Penguins",
                "Ostriches"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "The Great Emu War! 20,000 giant flightless birds outran the Australian army for a month straight!",
            explanation: "💡 In November 1932, Royal Australian Artillery soldiers attempted to cull 20,000 emus in Western Australia, but the birds proved too fast and resilient.",
            audioCueID: "en_q_CUL_01"
        ),
        QuizMCQQuestion(
            id: "EN_CUL_02",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "The Surprising Day Job of Cotton Candy's Inventor",
            prompt: "What was the day job of William Morrison, the man who co-invented the Cotton Candy machine in 1897?",
            choices: [
                "He was a dentist",
                "He was a firefighter",
                "He was a barber",
                "He was a mattress maker"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "A dentist from Nashville! Sell spun sugar at the fair, book fillings all week — pure evil genius!",
            explanation: "💡 Dentist William Morrison and confectioner John C. Wharton patented the 'Fairy Floss' (cotton candy) machine in 1897.",
            audioCueID: "en_q_CUL_02"
        ),
        QuizMCQQuestion(
            id: "EN_CUL_03",
            theme: .cultureGInsolite,
            preferredRound: .leSolo,
            funnyTitle: "Wombat Poop Geometry",
            prompt: "What geometric shape is the poop of an Australian wombat (so it doesn't roll off rocks when marking its territory)?",
            choices: [
                "Cube-shaped",
                "Pyramid-shaped",
                "Heart-shaped",
                "Star-shaped"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Cubes! Wombats are the only animals on Earth that poop little cubes — nature's Yahtzee!",
            explanation: "💡 Scientists won an Ig Nobel Prize in 2019 for discovering how wombat intestines mold cube-shaped droppings.",
            audioCueID: "en_q_CUL_03"
        ),
        QuizMCQQuestion(
            id: "EN_CUL_04",
            theme: .cultureGInsolite,
            preferredRound: .cashSpeed,
            funnyTitle: "The True Color of an Airplane's Black Box",
            prompt: "What color is an airplane's 'Black Box' flight recorder actually painted?",
            choices: [
                "Bright Neon Orange",
                "Matte Black",
                "Camouflage Green",
                "Clear Glass"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Bright 'International Orange'! If it were actually black at the bottom of the ocean, nobody would ever find it!",
            explanation: "💡 Flight recorders are painted bright fluorescent orange with reflective strips to aid recovery.",
            audioCueID: "en_q_CUL_04"
        ),
        QuizMCQQuestion(
            id: "EN_CUL_05",
            theme: .cultureGInsolite,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "Cleopatra's Time Machine",
            prompt: "Chronologically, Queen Cleopatra (who died in 30 BC) lived closer in time to which of these events?",
            choices: [
                "The 1969 Moon Landing and the iPhone",
                "The building of the Great Pyramid of Giza",
                "The extinction of T-Rex",
                "The Ice Age"
            ],
            correctIndex: 0,
            baseValue: 2400,
            meemawRoastOnWrong: "The Great Pyramid was built around 2560 BC (2,530 years before Cleopatra), while the Moon Landing was only 1,999 years after her!",
            explanation: "💡 Over 2,500 years separate the Great Pyramid from Cleopatra, compared to ~2,000 years between Cleopatra and today.",
            audioCueID: "en_q_CUL_05"
        ),
        QuizMCQQuestion(
            id: "EN_CUL_06",
            theme: .cultureGInsolite,
            preferredRound: .finaleDouble,
            funnyTitle: "Octopus Cardiology",
            prompt: "How many hearts does an octopus have, and what color is its blood?",
            choices: [
                "3 hearts and blue blood",
                "1 heart and red blood",
                "8 hearts and red blood",
                "2 hearts and green blood"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "3 hearts and copper-based blue blood! Two hearts pump to the gills and one pumps to the body!",
            explanation: "💡 Octopuses have three hearts and hemocyanin-rich blue blood.",
            audioCueID: "en_q_CUL_06"
        )
    ]

    // MARK: - 6. 💰 Money, Shopping & Everyday Scams

    public static let englishEcoCashQuestions: [QuizMCQQuestion] = [
        QuizMCQQuestion(
            id: "EN_ECO_01",
            theme: .ecoCash,
            preferredRound: .cashSpeed,
            funnyTitle: "Honey, I Shrunk the Cereal Box",
            prompt: "What is the term for when a company secretly reduces the weight of a snack bag or cereal box while keeping the exact SAME price?",
            choices: [
                "Shrinkflation",
                "Snack-theft",
                "Dietflation",
                "Reverse Cashback"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Shrinkflation! Half the potato chips bag is air, and the price still went up!",
            explanation: "💡 Shrinkflation is the practice of downsizing product quantities while maintaining the retail price.",
            audioCueID: "en_q_ECO_01"
        ),
        QuizMCQQuestion(
            id: "EN_ECO_02",
            theme: .ecoCash,
            preferredRound: .tuTeMetsCombien,
            funnyTitle: "The Danish Cookie Tin Illusion",
            prompt: "Universal Law of Grandmas: when you open a round blue 'Royal Dansk' Danish butter cookie tin at Meemaw's house, what is inside 99.9% of the time?",
            choices: [
                "Sewing needles, thread, and buttons",
                "Freshly baked Danish butter cookies",
                "Shiny gold coins and jewelry",
                "Old family vacation postcards"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Sewing supplies! Has anyone in human history ever seen an actual cookie inside that blue tin at Grandma's house?!",
            explanation: "💡 Across every continent, the blue Danish butter cookie tin is the universal storage unit for sewing kits.",
            audioCueID: "en_q_ECO_02"
        ),
        QuizMCQQuestion(
            id: "EN_ECO_03",
            theme: .ecoCash,
            preferredRound: .leSolo,
            funnyTitle: "The 3-Digit Code on Your Credit Card",
            prompt: "What does 'CVV' (the 3-digit security code on the back of your credit card that phone scammers always try to steal) stand for?",
            choices: [
                "Card Verification Value",
                "Cash Vault Validator",
                "Customer VIP Voucher",
                "Credit Virus Vaccine"
            ],
            correctIndex: 0,
            baseValue: 2000,
            meemawRoastOnWrong: "Card Verification Value! And remember Meemaw's rule: never read it to a stranger on the phone!",
            explanation: "💡 CVV stands for Card Verification Value.",
            audioCueID: "en_q_ECO_03"
        ),
        QuizMCQQuestion(
            id: "EN_ECO_04",
            theme: .ecoCash,
            preferredRound: .finaleDouble,
            funnyTitle: "The Supermarket Shelf Placement Trick",
            prompt: "In supermarkets, where are the MOST expensive brand-name products strategically placed on the shelves?",
            choices: [
                "Right at eye level",
                "Hidden behind the milk",
                "On the very bottom shelf",
                "In the parking lot"
            ],
            correctIndex: 0,
            baseValue: 2200,
            meemawRoastOnWrong: "Eye level is buy level! Always squat down to the bottom shelf if you want the bargain price!",
            explanation: "💡 Brands pay 'slotting fees' to place high-margin items at adult — or kids' — eye level.",
            audioCueID: "en_q_ECO_04"
        )
    ]

    // MARK: - 7. 🧀 English Binary Rounds (Cheesy Quizz / DisOrDat)

    public static let englishDisOrDatRounds: [QuizDisOrDatRound] = [
        QuizDisOrDatRound(
            id: "EN_RAC_01",
            theme: .cultureGInsolite,
            funnyTitle: "🧀 Cheesy Quizz: Botanical Fruit, Kitchen Vegetable, or BOTH?",
            prompt: "Watch out for the trap between the botanist and Meemaw's kitchen pot!",
            optionLeft: "🍓 BOTANICAL FRUIT",
            optionRight: "🥕 ROOT / STEM VEGGIE",
            optionBoth: "🧀 BOTH (FRUIT IN THE SALAD BOWL)!",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "A Tomato", correctSide: "both"),
                QuizDisOrDatItem(index: 1, text: "A Carrot", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "An Avocado", correctSide: "both"),
                QuizDisOrDatItem(index: 3, text: "Rhubarb", correctSide: "right"),
                QuizDisOrDatItem(index: 4, text: "A Bell Pepper", correctSide: "both"),
                QuizDisOrDatItem(index: 5, text: "A Strawberry", correctSide: "left")
            ],
            audioCueID: "en_q_RAC_01",
            isPunRound: false
        ),
        QuizDisOrDatRound(
            id: "EN_RAC_02",
            theme: .francaisMeemaw,
            funnyTitle: "🧀 Cheesy Quizz: Real English Dictionary Word or Uncle Bob's Nonsense?",
            prompt: "Is this weird word actually in the Oxford Dictionary, or did Uncle Bob make it up?",
            optionLeft: "📖 REAL DICTIONARY WORD",
            optionRight: "🍺 UNCLE BOB'S NONSENSE",
            optionBoth: "🧀 BOTH!",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "“Bumbershoot”", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "“Petrichor”", correctSide: "left"),
                QuizDisOrDatItem(index: 2, text: "“Snore-o-meter”", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "“Discombobulate”", correctSide: "left"),
                QuizDisOrDatItem(index: 4, text: "“Couch-potatery”", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "“Hangry”", correctSide: "both")
            ],
            audioCueID: "en_q_RAC_02",
            isPunRound: false
        ),
        QuizDisOrDatRound(
            id: "EN_RAC_03",
            theme: .seriesCinema,
            funnyTitle: "🧀 Cheesy Quizz: Star Wars, Star Trek, or BOTH?",
            prompt: "Don't trigger the nerds at the table: is this from Star Wars, Star Trek, or BOTH?",
            optionLeft: "⚔️ STAR WARS",
            optionRight: "🖖 STAR TREK",
            optionBoth: "🧀 BOTH!",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "Mr. Spock and the Vulcan salute", correctSide: "right"),
                QuizDisOrDatItem(index: 1, text: "Chewbacca and the Millennium Falcon", correctSide: "left"),
                QuizDisOrDatItem(index: 2, text: "The USS Enterprise", correctSide: "right"),
                QuizDisOrDatItem(index: 3, text: "Directed by J.J. Abrams in the 2000s/2010s!", correctSide: "both"),
                QuizDisOrDatItem(index: 4, text: "Baby Yoda", correctSide: "left"),
                QuizDisOrDatItem(index: 5, text: "“Beam me up, Scotty!”", correctSide: "right")
            ],
            audioCueID: "en_q_RAC_03",
            isPunRound: false
        ),
        QuizDisOrDatRound(
            id: "EN_RAC_04",
            theme: .musiqueTubes,
            funnyTitle: "🧀 Cheesy Quizz: 1980s Hit, 1990s Hit, or BOTH?",
            prompt: "Which decade blasted this anthem on the car stereo?",
            optionLeft: "🕺 1980s HIT",
            optionRight: "💿 1990s HIT",
            optionBoth: "🧀 BOTH (CHARTED IN BOTH)!",
            valuePerItem: 1000,
            items: [
                QuizDisOrDatItem(index: 0, text: "“Billie Jean”", correctSide: "left"),
                QuizDisOrDatItem(index: 1, text: "“...Baby One More Time”", correctSide: "right"),
                QuizDisOrDatItem(index: 2, text: "“Bohemian Rhapsody”", correctSide: "both"),
                QuizDisOrDatItem(index: 3, text: "“Take On Me”", correctSide: "left"),
                QuizDisOrDatItem(index: 4, text: "“Smells Like Teen Spirit”", correctSide: "right"),
                QuizDisOrDatItem(index: 5, text: "“Eye of the Tiger”", correctSide: "left")
            ],
            audioCueID: "en_q_RAC_04",
            isPunRound: false
        )
    ]

    // MARK: - 8. 🪤 English Sponsors ("Wrong Answer of the Game")

    public static let englishSponsors: [MeemawSponsor] = [
        MeemawSponsor(
            id: "EN_SPON_01",
            name: "Meemaw's Turbo-Grip Orthopedic Slippers™",
            slogan: "“Drift down the hallway without losing your dentures!”",
            hintKeyword: "Turbo-Grip Slippers",
            trapChoiceText: "A pair of Meemaw's Turbo-Grip Orthopedic Slippers™",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "EN_SPON_02",
            name: "The Danish Butter Cookie Tin Full of Sewing Needles™",
            slogan: "“0% actual cookies, 100% buttons and tangled thread since 1994!”",
            hintKeyword: "Danish Cookie Sewing Tin",
            trapChoiceText: "A blue Danish cookie tin filled with sewing needles™",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "EN_SPON_03",
            name: "Meemaw's Industrial-Strength Prune Juice™",
            slogan: "“One glass at 6 PM and you're faster than a rocket by 6:15!”",
            hintKeyword: "Industrial Prune Juice",
            trapChoiceText: "Two gallons of Meemaw's Industrial-Strength Prune Juice™",
            jackpotReward: 3500
        ),
        MeemawSponsor(
            id: "EN_SPON_04",
            name: "Vintage Purse Peppermints Covered in Pocket Lint™",
            slogan: "“Aged at the bottom of Grandma's handbag since the Clinton administration!”",
            hintKeyword: "Purse Peppermints",
            trapChoiceText: "A sticky purse peppermint covered in tissue lint™",
            jackpotReward: 3500
        )
    ]

    // MARK: - 9. 🔢 English « Le Juste Pif » (Closest Estimate)

    public static let englishJustePifQuestions: [QuizJustePifQuestion] = [
        QuizJustePifQuestion(
            id: "EN_PIF_01",
            theme: .cultureGInsolite,
            funnyTitle: "The Great Toilet Paper Marathon",
            prompt: "How many rolls of toilet paper does the average person use in a single year?",
            unitLabel: "rolls / year",
            correctValue: 100,
            meemawComment: "Around 100 rolls per year (almost 2 rolls a week) — and double that after Taco Tuesday!"
        ),
        QuizJustePifQuestion(
            id: "EN_PIF_02",
            theme: .mathMeemaw,
            funnyTitle: "Bones in the Human Body",
            prompt: "How many bones are in an adult human skeleton?",
            unitLabel: "bones",
            correctValue: 206,
            meemawComment: "206 bones in an adult (babies are born with around 300 before some fuse together)!"
        ),
        QuizJustePifQuestion(
            id: "EN_PIF_03",
            theme: .seriesCinema,
            funnyTitle: "The Longest Shipwreck in Cinema",
            prompt: "How many minutes long is James Cameron's movie 'Titanic' (bring a cushion)?",
            unitLabel: "minutes",
            correctValue: 194,
            meemawComment: "194 minutes (3 hours and 14 minutes)! Plenty of time for Rose to make room for Jack on that door!"
        ),
        QuizJustePifQuestion(
            id: "EN_PIF_04",
            theme: .cultureGInsolite,
            funnyTitle: "Smartphone Addiction Check",
            prompt: "How many times per DAY does the average adult unlock or check their smartphone?",
            unitLabel: "times / day",
            correctValue: 96,
            meemawComment: "96 times a day — that's once every 10 waking minutes!"
        ),
        QuizJustePifQuestion(
            id: "EN_PIF_05",
            theme: .musiqueTubes,
            funnyTitle: "Thriller's Release Year",
            prompt: "In what year did Michael Jackson release the legendary album 'Thriller'?",
            unitLabel: "year",
            correctValue: 1982,
            meemawComment: "Released in November 1982 — still the best-selling album of all time!"
        ),
        QuizJustePifQuestion(
            id: "EN_PIF_06",
            theme: .ecoCash,
            funnyTitle: "Keys on a Grand Piano",
            prompt: "How many keys (black and white combined) are on a standard full-size piano?",
            unitLabel: "keys",
            correctValue: 88,
            meemawComment: "88 keys (52 white and 36 black)!"
        )
    ]

    // MARK: - 10. ⚡ English « Jack Attack » Finale Rounds

    public static let englishJackAttackRounds: [QuizJackAttackRound] = [
        QuizJackAttackRound(
            id: "EN_JACK_01",
            funnyTitle: "⚡ Jack Attack: Iconic Duos!",
            waves: [
                QuizJackAttackWave(
                    id: "EN_JACK_01_W1",
                    clueTitle: "BUZZ ON THE OTHER HALF OF THE FAMOUS DUO!",
                    anchorText: "Batman & ...",
                    options: ["Shrek", "Robin", "Gandalf", "SpongeBob"],
                    correctOptionIndex: 1,
                    explanation: "Batman & Robin, the Dynamic Duo!"
                ),
                QuizJackAttackWave(
                    id: "EN_JACK_01_W2",
                    clueTitle: "BUZZ ON THE OTHER HALF OF THE FAMOUS DUO!",
                    anchorText: "Sherlock Holmes & ...",
                    options: ["Dr. Evil", "Dr. Pepper", "Dr. Watson", "Dr. Doolittle"],
                    correctOptionIndex: 2,
                    explanation: "Elementary, my dear Dr. Watson!"
                ),
                QuizJackAttackWave(
                    id: "EN_JACK_01_W3",
                    clueTitle: "BUZZ ON THE OTHER HALF OF THE FAMOUS DUO!",
                    anchorText: "Timon & ...",
                    options: ["Pumbaa", "Mufasa", "Scooby-Doo", "Pikachu"],
                    correctOptionIndex: 0,
                    explanation: "Timon & Pumbaa ('Hakuna Matata')!"
                ),
                QuizJackAttackWave(
                    id: "EN_JACK_01_W4",
                    clueTitle: "BUZZ ON THE OTHER HALF OF THE FAMOUS DUO!",
                    anchorText: "Peanut Butter & ...",
                    options: ["Mustard", "Broccoli", "Jelly", "Toothpaste"],
                    correctOptionIndex: 2,
                    explanation: "Peanut Butter & Jelly!"
                ),
                QuizJackAttackWave(
                    id: "EN_JACK_01_W5",
                    clueTitle: "BUZZ ON THE OTHER HALF OF THE FAMOUS DUO!",
                    anchorText: "Bonnie & ...",
                    options: ["Claudette", "Clyde", "Terminator", "Columbo"],
                    correctOptionIndex: 1,
                    explanation: "Bonnie & Clyde!"
                )
            ]
        ),
        QuizJackAttackRound(
            id: "EN_JACK_02",
            funnyTitle: "⚡ Jack Attack: Famous Movie Quotes!",
            waves: [
                QuizJackAttackWave(
                    id: "EN_JACK_02_W1",
                    clueTitle: "MATCH THE CHARACTER TO THEIR FAMOUS LINE!",
                    anchorText: "Buzz Lightyear ➜ ...",
                    options: ["“Where's the beef?”", "“To infinity and beyond!”", "“I'll be back!”", "“Winter is coming”"],
                    correctOptionIndex: 1,
                    explanation: "Buzz Lightyear: 'To infinity and beyond!'"
                ),
                QuizJackAttackWave(
                    id: "EN_JACK_02_W2",
                    clueTitle: "MATCH THE CHARACTER TO THEIR FAMOUS LINE!",
                    anchorText: "The Terminator ➜ ...",
                    options: ["“I'll be back!”", "“Hakuna Matata!”", "“You shall not pass!”", "“Bazinga!”"],
                    correctOptionIndex: 0,
                    explanation: "Arnold Schwarzenegger in The Terminator: 'I'll be back!'"
                ),
                QuizJackAttackWave(
                    id: "EN_JACK_02_W3",
                    clueTitle: "MATCH THE CHARACTER TO THEIR FAMOUS LINE!",
                    anchorText: "Gandalf ➜ ...",
                    options: ["“I am Groot”", "“You shall not pass!”", "“Show me the money!”", "“Here's Johnny!”"],
                    correctOptionIndex: 1,
                    explanation: "Gandalf facing the Balrog: 'You shall not pass!'"
                ),
                QuizJackAttackWave(
                    id: "EN_JACK_02_W4",
                    clueTitle: "MATCH THE CHARACTER TO THEIR FAMOUS LINE!",
                    anchorText: "Forrest Gump ➜ ...",
                    options: ["“Life is like a box of chocolates”", "“May the Force be with you”", "“Why so serious?”", "“Yabba Dabba Doo!”"],
                    correctOptionIndex: 0,
                    explanation: "Mama always said life was like a box of chocolates!"
                ),
                QuizJackAttackWave(
                    id: "EN_JACK_02_W5",
                    clueTitle: "MATCH THE CHARACTER TO THEIR FAMOUS LINE!",
                    anchorText: "Sheldon Cooper ➜ ...",
                    options: ["“How you doin'?”", "“Bazinga!”", "“D'oh!”", "“Wakanda Forever!”"],
                    correctOptionIndex: 1,
                    explanation: "Sheldon's signature prank catchphrase: 'Bazinga!'"
                )
            ]
        )
    ]
}
