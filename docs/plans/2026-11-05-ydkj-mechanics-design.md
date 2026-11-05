# Design : Mécaniques YDKJ & Party Game (#2 Jack Attack, #3 Le Juste Pif, #4 Réponse Sponsorisée)

**Date** : 2026-11-05
**Application** : MeemawQuizz (`com.xlarrodeapp.meemawquizz`)

## 1. Objectif
Enrichir le **Grand Show TV** (`ShowGameMode.fullQuizShow`) avec 3 mécaniques emblématiques inspirées de *You Don't Know Jack* et des meilleurs party games de salon :
1. **🪤 La Réponse Sponsorisée de Mamie** (*Wrong Answer of the Game*)
2. **🎯 Manche « Le Juste Pif »** (3 questions d'estimation numérique au plus proche)
3. **⚡ Finale « Le Jack Attack de Meemaw »** (5 vagues d'associations rapides au buzzer)

## 2. Architecture & Modèles (`MeemawQuizzCore`)
- **`MeemawSponsor`** : `id`, `name`, `slogan`, `hintKeyword`, `trapChoiceText`, `jackpotReward` (`3500` pts).
  - Tiré au sort au lancement de la partie (`startNewShow`) et injecté dans l'une des questions QCM de la manche 1 ou 2 à la place d'un choix incorrect (`sponsoredChoiceIndex: Int?` sur `QuizMCQQuestion`).
- **`QuizJustePifQuestion`** : `id`, `theme`, `funnyTitle`, `prompt`, `unitLabel`, `correctValue: Int`, `meemawComment`.
  - Nouveau `QuizRoundKind.leJustePif` et étapes `justePifAnswering` / `justePifReveal` dans `ShowStageState`.
  - Nouveau message `ClientActionKind.submitNumericEstimate` (`numericEstimate: Int?`).
- **`QuizJackAttackWave` & `QuizJackAttackRound`** :
  - Chaque round contient 5 vagues (`QuizJackAttackWave`) avec `clueTitle`, `anchorText`, `options: [String]` (3 leurres + 1 bonne réponse), `correctOptionIndex: Int`.
  - Toutes les `1.6s`, l'hôte fait défiler `jackAttackOptionIndex`.
  - Nouveau message `ClientActionKind.buzzJackAttack`.
  - Premier joueur qui buzze sur la bonne option : `+3000` pts et passage à la révélation de la vague.
  - Joueur qui buzze sur un leurre : `-1500` pts et gel de son buzzer pour la vague en cours.
