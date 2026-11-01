# 👵📺 MeemawQuizz — Le Grand Quizz AirPlay de Meemaw

Un jeu télévisé de soirée (« Party Quiz Show ») projeté en **AirPlay 16:9** sur l'Apple TV, animé par **Meemaw en Guest Star** avec l'humour décalé de *You Don't Know Jack* (« Jake ») et l'esthétique Pop-Art de **Meemaw** & **Meemaw Math**.

---

## ✨ Fonctionnalités Principales

- **📺 Plateau TV Géant 16:9 AirPlay (`ExternalDisplayManager`)** :
  - Détection automatique de l'Apple TV / HDMI (`UIWindowScene` externe + `UISceneAccessory` iOS 27) et bouton **Aperçu TV** sur l'iPhone pour tester facilement sur un seul écran.
- **📡 Connexion Automatique Multi-Plateforme (iOS + Android)** :
  - **Sur iPhone / iPad (`QuizBonjourClient`)** : découverte automatique **Bonjour (`_meemawquizz._tcp`)** en 0 clic dès l'ouverture de l'app sur le même réseau Wi-Fi.
  - **Sur Android & Invités sans l'app (`QuizLANServer` + `WebControllerHTML`)** : scannez le **QR Code** affiché sur la TV AirPlay pour ouvrir instantanément la manette Web Pop-Art temps réel (`http://<ip-locale>:8420` + WebSocket RFC 6455).
- **🎨 Choix du Pseudo & des 8 Couleurs Pop-Art en Direct** :
  - Chaque couleur choisie par un joueur est verrouillée en temps réel sur tous les téléphones connectés.
- **🎮 4 Manches Rythmées façon « Jake » (YDKJ)** :
  1. **⚡ Manche 1 — Cash Rapide** : Tout le monde répond au chrono sur son téléphone (bonus d'éclair pour le 1er + joker **« 💋 Le Bisou Baveux de Meemaw »** pour embuer l'écran d'un adversaire !).
  2. **🚨 Manche 2 — LE SOLO (Buzzer YDKJ 90s)** : Le premier qui écrase le gros buzzer rouge bloque tous les autres téléphones et joue en solo sous les projecteurs pour **Double Jackpot (+4 000 pts)** ou **Perte Sèche (-2 000 pts)** !
  3. **⚖️ Manche 3 — Le Couci-Couça de Meemaw (`DisOrDat`)** : 6 affirmations binaires à toute vitesse (Gauche / Droite).
  4. **🔥 Manche 4 — La Rafale Finale (Points ×2) & Podium** : Scores doublés jusqu'à la dernière seconde et remise des titres absurdes de Meemaw.
- **📚 6 Packs de Questions 100 % Générés & Libres de Droits** :
  - `👵 Français & Expressions`, `📐 Meemaw Math & Logique`, `🎬 Séries & Cinéma`, `🎵 Musique & Tubes`, `🌍 Culture G & Insolite`, `💰 Éco & Cash Perso`, et `🔀 Grand Mix Show`.
- **🎙️ Voix de Meemaw (`Audrey Premium`) & Jingles TV** :
  - **89 pistes `.m4a` Studio** pré-générées + synthèse vocale en direct pour prononcer les vrais pseudos des joueurs sur la TV AirPlay + **7 jingles TV rétro-pop**.
