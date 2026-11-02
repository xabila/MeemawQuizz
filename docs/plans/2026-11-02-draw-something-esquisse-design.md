# MeemawQuizz — Design : Modes « Draw Something » & « Esquissé ! » (Gartic Phone)

**Date** : 2026-11-02  
**Statut** : Validé par Xabi

---

## 1. Objectif

Enrichir **MeemawQuizz** avec deux expériences de dessin multijoueur ultra-conviviales (iOS natif Bonjour + Web QR Code Android/iOS + écran TV 16:9 AirPlay) :

1. **🎨 « Meemaw Something » (Pictionary + Tuiles de lettres *Draw Something*)** :
   - Intégré à la fois comme **manche dans le Grand Show Quizz** et comme **Mode de Partie dédié (100 % Dessin)**.
   - Un joueur choisit un mot parmi 3 difficultés (⭐ 1 000 pts, ⭐⭐ 2 000 pts, ⭐⭐⭐ 3 000 pts) et le dessine en direct sur son téléphone.
   - Ses traits vectoriels s'affichent en temps réel sur la TV AirPlay et sur les téléphones des autres joueurs.
   - Les autres joueurs devinent le mot en touchant dans l'ordre **12 tuiles de lettres mélangées** façon *Draw Something* (zéro faute de frappe, ultra-rapide).
   - Le dessinateur gagne des points pour chaque joueur qui trouve son mot, et les devineurs gagnent selon leur rapidité.

2. **📞 « Esquissé ! » (Le Téléphone Arabe Dessiné — façon *Gartic Phone*)** :
   - Accessible comme **Mode de Partie dédié** depuis le salon.
   - Chaque joueur possède un **Carnet Secret** qui passe de joueur en joueur :
     1. **Idée initiale (Texte libre)** : chaque joueur tape une phrase libre au clavier (avec un bouton « 🎲 Idée de Meemaw » s'il veut une suggestion délirante instantanée).
     2. **Dessin 1 (40 s)** : chaque joueur reçoit la phrase d'un voisin et la dessine.
     3. **Interprétation (Texte 100 % libre au clavier — 35 s)** : chaque joueur voit uniquement le dessin précédent (sans la phrase !) et tape au clavier ce qu'il croit voir.
     4. **Dessin 2 (40 s)** : le voisin suivant dessine cette nouvelle phrase.
   - **Grand Défilé Final sur la TV AirPlay & Vote Coup de Cœur** :
     - Meemaw présente chaque carnet étape par étape sur la TV et les téléphones, et les joueurs votent pour leurs enchaînements préférés (`+1 000 pts` par vote reçu).

---

## 2. Architecture & Synchronisation Temps Réel

### 2.1 Modèles Vectoriels (`Sources/MeemawQuizzCore/QuizModels.swift`)
- `NormalizedPoint`: `(x: Double, y: Double)` dans `[0.0, 1.0]` arrondi au millième.
- `DrawingStroke`: `colorHex: String`, `lineWidth: Double`, `points: [NormalizedPoint]`.
- `DrawingCanvasData`: `strokes: [DrawingStroke]`.
- `ShowGameMode`:
  - `.fullQuizShow` (*📺 Grand Show Quizz + Dessin*)
  - `.drawSomethingOnly` (*🎨 100 % Draw Something*)
  - `.esquisseParty` (*📞 Esquissé ! Gartic Phone*)

### 2.2 États de Scène (`ShowStageState`)
Ajout des nouveaux états synchronisés entre Host iOS, Clients Bonjour iOS, Contrôleurs Web HTML5 et TV AirPlay :
- `.drawWordChoice` : le dessinateur choisit son mot (⭐ / ⭐⭐ / ⭐⭐⭐).
- `.drawLiveGuessing` : le dessinateur trace en direct, les autres composent le mot avec les 12 tuiles *Draw Something*.
- `.drawReveal` : révélation du mot, du dessin final et des points gagnés (dessinateur + devineurs).
- `.esquissePromptEntry` : saisie de l'expression de départ au clavier.
- `.esquisseDrawing` : chaque joueur dessine l'expression reçue dans le carnet courant.
- `.esquisseGuessing` : chaque joueur voit uniquement le dessin précédent et tape 100 % librement au clavier ce qu'il voit.
- `.esquisseShowcase` : défilé album par album sur la TV AirPlay avec vote « 😂 Coup de Cœur » sur les téléphones.

### 2.3 Support Solo & Bots + Voix Studio Audrey Premium
- Catalogue de croquis vectoriels pré-tracés (`DrawingBank.swift`) pour que les Bots (ou « Le Pinceau Magique de Meemaw » en solo) puissent dessiner trait par trait en direct et participer à *Esquissé !*.
- Nouvelles pistes `.m4a` générées via `MeemawStudioSynthesizer` (`com.apple.voice.premium.fr-FR.Audrey`) pour 100 % des annonces de ces modes.
