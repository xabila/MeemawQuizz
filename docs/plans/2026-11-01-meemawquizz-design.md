# MeemawQuizz — AirPlay Multiplayer Party Quiz Show Design

**Date:** 2026-11-01
**Status:** Approved

---

## 1. Vision & Concept

**MeemawQuizz** est un jeu télévisé de soirée (« Party Quiz Show ») projeté en **AirPlay 16:9** sur la TV du salon, animé par **Meemaw en Guest Star** avec l'esprit humoristique et irrévérencieux de *You Don't Know Jack* (« Jake ») et l'esthétique Pop-Art de l'univers **Meemaw** / **Meemaw Math**.

- **L'iPhone Hôte (Serveur + Joueur 1)** projette le plateau télé géant sur l'écran externe AirPlay (ou en mode 16:9 Paysage simulé) tout en servant lui-même de manette tactile pour le joueur hôte, avec un bandeau de régie rapide.
- **Connexion Zéro-Friction Multi-Plateforme (iOS + Android)** :
  - **Sur iOS (avec l'app `MeemawQuizz`)** : découverte automatique **Bonjour (`_meemawquizz._tcp`)** via `NWBrowser`. Dès que l'application s'ouvre sur le même réseau Wi-Fi, elle détecte le salon et connecte le joueur sans aucune saisie d'IP.
  - **Sur Android (et invités sans l'app)** : le serveur embarqué `NWListener` de l'iPhone Hôte sert une **WebApp Manette Pop-Art** en HTTP + WebSocket temps réel (`http://<ip-locale>:<port>`), accessible instantanément en scannant le **QR Code** affiché sur l'écran TV AirPlay.
- **Personnalisation Joueur** : Chaque joueur choisit son pseudo et l'une des **8 couleurs Pop-Art disponibles** (verrouillées en temps réel dès qu'un joueur les sélectionne) + un emoji mascotte.

---

## 2. Architecture Technique

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        IPHONE HÔTE (Serveur + J1)                       │
│                                                                         │
│  ┌───────────────────────────┐       ┌───────────────────────────────┐  │
│  │  ExternalDisplayManager   │       │     QuizLANServer (NWListener)│  │
│  │  • UIWindowScene AirPlay  │       │  • Bonjour _meemawquizz._tcp  │  │
│  │  • iOS 27 SceneAccessory  │       │  • HTTP GET / -> Web Controller│ │
│  │  • 16:9 Landscape Sim     │       │  • WebSocket /ws JSON Temps   │  │
│  └─────────────┬─────────────┘       │    Réel (< 5 ms latence LAN)  │  │
│                │                     └───────┬───────────────┬───────┘  │
└────────────────┼─────────────────────────────┼───────────────┼──────────┘
                 ▼                             ▼               ▼
   ┌───────────────────────────┐   ┌───────────────────┐ ┌───────────────────┐
   │    ÉCRAN TV AIRPLAY 16:9  │   │  IPHONE JOUEUR    │ │  ANDROID / WEB    │
   │  • Plateau Pop-Art Géant  │   │  • App Native iOS │ │  • Scan QR Code   │
   │  • Meemaw Animée + Voix   │   │  • Auto-Bonjour   │ │  • Chrome/Safari  │
   │  • Jingles & Scores Live  │   │  • WebSocket /ws  │ │  • WebSocket /ws  │
   └───────────────────────────┘   └───────────────────┘ └───────────────────┘
```

### Composants Clés
1. **`ExternalDisplayManager.swift`** : Porté et adapté de `RushTiVi`, gère le double écran AirPlay/HDMI (720p / 1080p / 4K) avec `UIWindowScene` externe et `UISceneAccessory.externalNonInteractive` (iOS 27+), ainsi qu'un mode simulation TV sur l'iPhone.
2. **`QuizNetworkProtocol.swift`** : Modèles `Codable` partagés entre le serveur Hôte, le client iOS natif et le client Web Android (`ClientMessage` / `ServerStateSnapshot`).
3. **`QuizLANServer.swift`** : Serveur unique basé sur `Network.framework` (`NWListener`) sur un port dynamique ou fixe (ex. `8420`, fallback automatique) qui inspecte la première requête entrante sur chaque `NWConnection` :
   - Si requête HTTP `GET /` : renvoie la WebApp manette HTML5/CSS/JS Pop-Art complète (avec support tactile, vibrations `navigator.vibrate`, bips WebAudio et WebSocket auto-reconnect).
   - Si requête HTTP `Upgrade: websocket` : effectue le handshake RFC 6455 (`Sec-WebSocket-Accept` SHA-1 + Base64) et bascule la connexion en flux de trames WebSocket JSON bidirectionnelles.
   - Publie simultanément le service Bonjour `_meemawquizz._tcp` pour les clients iOS.
4. **`QuizBonjourClient.swift`** : Client iOS utilisant `NWBrowser` pour découvrir automatiquement `_meemawquizz._tcp` sur le réseau local et ouvrir une connexion WebSocket native (`NWConnection` avec `NWProtocolWebSocket.Options`).
5. **`GameSessionController.swift`** : Machine à états centrale `@Observable @MainActor` qui orchestre le salon, les joueurs, les couleurs disponibles, le minutage au millième de seconde, les 4 types de manches, la voix de Meemaw et la synchronisation temps réel.
6. **`MeemawShowAudioEngine.swift`** : Moteur audio 2-Tier combinant :
   - Fichiers `.m4a` pré-générés avec la voix **Audrey Premium** (`com.apple.voice.premium.fr-FR.Audrey`) pour les intros, questions, règles et punchlines de Meemaw.
   - Synthèse vocale dynamique (`AVSpeechSynthesizer` voix féminine Audrey) pour prononcer les pseudos des joueurs en direct sur la TV.
   - Jingles TV synthétisés / multi-pistes (Générique, Jingle Question, Sirène « LE SOLO », Jingle « Couci-Couça », Buzzer, Bonne/Mauvaise réponse, Musique de réflexion, Fanfare Podium).

---

## 3. Déroulé d'une Partie & Les 4 Manches

Une partie complète se déroule en **4 manches progressives** :

1. **Manche 1 — « Cash Rapide » (QCM Tout le monde répond)**
   - Tous les joueurs répondent sur leur téléphone dans le temps imparti (12s).
   - Le 1er joueur correct gagne 100 % de la valeur + bonus d'éclair ; les suivants gagnent un montant dégressif selon leur temps de réaction en millisecondes. Une erreur retire 50 % de la valeur.
   - **Joker « Le Bisou Baveux de Meemaw »** (1 par partie et par joueur) : permet d'envoyer un gros bisou/tarte de Meemaw sur l'écran d'un adversaire qu'il doit frotter/essuyer 3 fois avant de pouvoir cliquer sur sa réponse !

2. **Manche 2 — « LE SOLO » (Mode Buzzer YDKJ 90s)**
   - Pendant l'énoncé de la question, les téléphones affichent uniquement un **ÉNORME BUZZER ROUGE « JE PRENDS LE SOLO ! »**.
   - Le premier joueur qui buzze (départagé à la milliseconde par le serveur Hôte) bloque tous les autres téléphones.
   - Les 4 choix `A / B / C / D` s'affichent uniquement sur son téléphone avec **6 secondes** pour répondre :
     - Bonne réponse : **Double Jackpot (+4 000 pts)** !
     - Mauvaise réponse ou hors-délai : **-2 000 pts** et Meemaw se moque de lui par son pseudo à la télé !

3. **Manche 3 — « Le Couci-Couça de Meemaw » (`DisOrDat` Binaire Rapide)**
   - 6 affirmations décalées s'enchaînent toutes les 5 secondes avec 2 boutons géants **GAUCHE** / **DROITE** sur chaque téléphone (+500 pts par bonne réponse, +bonus de série).

4. **Manche 4 — « La Rafale Finale » (Points Doublés)**
   - Questions finales à haute vitesse où tous les points sont doublés, suivies du **Podium Télévisé** avec remise de titres humoristiques par Meemaw.

---

## 4. Les 6 Packs de Questions (100 % Originaux & Libres de Droits)

1. 👵 **Français & Expressions de Meemaw** (orthographe piège, expressions d'antan, devinettes).
2. 📐 **Meemaw Math & Calcul Flash** (calcul mental malin, problèmes de trains du Certif' 1951 revisités, logique).
3. 🎬 **Séries & Cinéma** (films cultes, séries, synopsis racontés par Mamie).
4. 🎵 **Musique & Tubes** (chanson française, pop/rock, paroles improbables).
5. 🌍 **Culture G & Insolite** (sciences folles, histoire décalée, records absurdes).
6. 💰 **Éco & Cash (Bonus RushTiVi)** + Mode **🔀 Grand Mix Show** (mélange de tous les thèmes sélectionnés).
