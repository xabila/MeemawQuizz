import Foundation

/// Génère la WebApp Manette Pop-Art HTML5/CSS/JS complète servie directement par l'iPhone Hôte
/// lorsqu'un joueur Android (ou un invité sans l'app iOS) scanne le QR Code affiché sur la TV AirPlay.
public enum WebControllerHTML {

    public static func render(roomCode: String = "MEEMAW") -> String {
        return """
        <!DOCTYPE html>
        <html lang="fr">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
          <title>MeemawQuizz • Manette TV</title>
          <style>
            :root {
              --orange: #FF8C42;
              --cream: #FFF8F0;
              --ink: #1A1A1A;
              --yellow: #FFD700;
              --green: #10B981;
              --red: #E11D48;
            }
            * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; user-select: none; }
            body {
              margin: 0; padding: 14px;
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
              background-color: var(--cream);
              background-image: radial-gradient(rgba(255,140,66,0.14) 2px, transparent 2px);
              background-size: 16px 16px;
              color: var(--ink);
              min-height: 100dvh;
              display: flex;
              flex-direction: column;
              gap: 12px;
            }
            .card {
              background: #fff;
              border: 3.5px solid var(--ink);
              border-radius: 20px;
              padding: 14px;
              box-shadow: 0 5px 0 var(--ink);
            }
            .header {
              display: flex; justify-content: space-between; align-items: center;
              background: var(--orange); color: var(--ink);
              border: 3.5px solid var(--ink); border-radius: 18px;
              padding: 10px 14px; font-weight: 900; box-shadow: 0 4px 0 var(--ink);
            }
            .badge {
              background: #fff; border: 2.5px solid var(--ink);
              border-radius: 999px; padding: 4px 10px; font-size: 13px; font-weight: 900;
            }
            input[type="text"] {
              width: 100%; padding: 12px 14px; font-size: 18px; font-weight: 800;
              border: 3px solid var(--ink); border-radius: 14px; background: var(--cream);
              margin-top: 6px; margin-bottom: 12px; user-select: text;
            }
            .colors-grid {
              display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; margin-bottom: 12px;
            }
            .color-btn {
              border: 3px solid var(--ink); border-radius: 14px; padding: 10px 4px;
              font-weight: 900; font-size: 12px; color: #fff; text-shadow: 0 1px 2px rgba(0,0,0,0.65);
              display: flex; flex-direction: column; align-items: center; gap: 4px;
              box-shadow: 0 3px 0 var(--ink); cursor: pointer;
            }
            .color-btn.selected { outline: 4px solid var(--ink); transform: scale(1.04); }
            .color-btn.taken { opacity: 0.25; pointer-events: none; filter: grayscale(0.7); }
            .btn-primary {
              width: 100%; padding: 15px; font-size: 18px; font-weight: 900; text-transform: uppercase;
              background: var(--orange); color: var(--ink);
              border: 3.5px solid var(--ink); border-radius: 16px;
              box-shadow: 0 5px 0 var(--ink); cursor: pointer;
            }
            .btn-primary:active { transform: translateY(3px); box-shadow: 0 2px 0 var(--ink); }
            .choices-grid {
              display: grid; grid-template-columns: 1fr; gap: 10px; flex: 1;
            }
            .choice-btn {
              width: 100%; padding: 16px; font-size: 18px; font-weight: 900; text-align: left;
              background: #fff; color: var(--ink);
              border: 3.5px solid var(--ink); border-radius: 18px;
              box-shadow: 0 5px 0 var(--ink); display: flex; align-items: center; gap: 12px;
            }
            .choice-btn.locked { background: var(--yellow); transform: translateY(2px); }
            .choice-letter {
              width: 38px; height: 38px; border-radius: 10px; background: var(--orange);
              border: 2.5px solid var(--ink); display: flex; align-items: center; justify-content: center;
              font-size: 20px; font-weight: 900; flex-shrink: 0;
            }
            .solo-buzzer {
              width: 100%; min-height: 220px; border-radius: 32px;
              background: radial-gradient(circle at 35% 30%, #ff5c7c, #E11D48 70%);
              color: #fff; font-size: 28px; font-weight: 900; text-transform: uppercase;
              border: 5px solid var(--ink); box-shadow: 0 10px 0 var(--ink);
              display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 10px;
            }
            .solo-buzzer:active { transform: translateY(6px); box-shadow: 0 4px 0 var(--ink); }
            .binary-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; min-height: 180px; }
            .bisou-overlay {
              position: fixed; inset: 0; background: rgba(255,77,148,0.92);
              z-index: 999; display: none; flex-direction: column;
              align-items: center; justify-content: center; padding: 24px; text-align: center; color: #fff;
            }
          </style>
        </head>
        <body>
          <div class="header">
            <div>👵 MEEMAW QUIZZ</div>
            <div style="display:flex;gap:8px;align-items:center;">
              <div class="badge" id="scoreBadge">0 PTS</div>
              <button class="badge" style="background:#E11D48;color:#fff;cursor:pointer;" onclick="leaveGame()">🚪 Quitter</button>
            </div>
          </div>

          <div id="bisouOverlay" class="bisou-overlay" onclick="wipeBisou()">
            <div style="font-size:88px;">💋👵💋</div>
            <h2 id="bisouTitle" style="font-size:26px;text-shadow:0 2px 0 #1A1A1A;">GROS BISOU BAVEUX DE MEEMAW !</h2>
            <p style="font-weight:800;font-size:18px;">TAPE 3 FOIS SUR L'ÉCRAN POUR ESSUYER TA VITRE !</p>
          </div>

          <div id="profileCard" class="card">
            <div style="font-weight:900;font-size:16px;text-transform:uppercase;">1. Ton Pseudo & Ta Couleur</div>
            <input type="text" id="playerName" maxlength="15" placeholder="Entre ton prénom..." />
            <div class="colors-grid" id="colorsGrid"></div>
            <button class="btn-primary" onclick="sendProfile()">✅ Rejoindre / Mettre à jour</button>
          </div>

          <div id="stageCard" class="card" style="flex:1;display:flex;flex-direction:column;justify-content:center;gap:12px;">
            <div id="stageTitle" style="font-weight:900;font-size:20px;text-align:center;">Connexion au salon AirPlay...</div>
            <div id="stageContent"></div>
          </div>

          <script>
            const COLORS = [
              { id: 'orange', label: 'Orange', hex: '#FF8C42', emoji: '🦊' },
              { id: 'blue',   label: 'Bleu',   hex: '#2563EB', emoji: '🐬' },
              { id: 'mint',   label: 'Menthe', hex: '#10B981', emoji: '🐸' },
              { id: 'pink',   label: 'Rose',   hex: '#FF4D94', emoji: '🦩' },
              { id: 'purple', label: 'Violet', hex: '#8E44AD', emoji: '🐙' },
              { id: 'yellow', label: 'Jaune',  hex: '#F59E0B', emoji: '🦁' },
              { id: 'cyan',   label: 'Cyan',   hex: '#00ACC1', emoji: '🦄' },
              { id: 'red',    label: 'Rouge',  hex: '#E11D48', emoji: '🐞' }
            ];
            let playerID = localStorage.getItem('mq_pid') || ('web_' + Math.random().toString(36).slice(2, 9));
            localStorage.setItem('mq_pid', playerID);
            let selectedColor = localStorage.getItem('mq_color') || 'cyan';
            let selectedEmoji = '🦄';
            let ws = null;
            let lastState = null;

            const savedName = localStorage.getItem('mq_name') || '';
            document.getElementById('playerName').value = savedName;

            function beep(freq = 520, ms = 70) {
              try {
                if (navigator.vibrate) navigator.vibrate(35);
                const ctx = new (window.AudioContext || window.webkitAudioContext)();
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.frequency.value = freq;
                gain.gain.value = 0.12;
                osc.connect(gain); gain.connect(ctx.destination);
                osc.start(); setTimeout(() => { osc.stop(); ctx.close(); }, ms);
              } catch (_) {}
            }

            function renderColors(availableList) {
              const grid = document.getElementById('colorsGrid');
              const me = (lastState?.players || []).find(p => p.id === playerID);
              if (me) { selectedColor = me.color; selectedEmoji = me.avatarEmoji; }
              grid.innerHTML = COLORS.map(c => {
                const isMine = (me && me.color === c.id) || (selectedColor === c.id);
                const isFree = !availableList || availableList.includes(c.id) || (me && me.color === c.id);
                const cls = 'color-btn ' + (isMine ? 'selected ' : '') + (!isFree ? 'taken' : '');
                return `<div class="${cls}" style="background:${c.hex}" onclick="pickColor('${c.id}','${c.emoji}')">
                  <span style="font-size:20px">${c.emoji}</span><span>${c.label}</span>
                </div>`;
              }).join('');
            }

            function pickColor(cid, emoji) {
              selectedColor = cid; selectedEmoji = emoji;
              localStorage.setItem('mq_color', cid);
              beep(620, 50);
              sendProfile();
            }

            function sendMsg(payload) {
              if (ws && ws.readyState === WebSocket.OPEN) {
                ws.send(JSON.stringify({ playerID, platform: 'web_qr', ...payload }));
              }
            }

            function sendProfile() {
              const name = document.getElementById('playerName').value.trim() || 'Invité';
              localStorage.setItem('mq_name', name);
              sendMsg({ action: 'join_profile', playerName: name, requestedColor: selectedColor, avatarEmoji: selectedEmoji });
            }

            function wipeBisou() {
              beep(740, 45);
              sendMsg({ action: 'wipe_bisou' });
            }

            function leaveGame() {
              beep(320, 90);
              sendMsg({ action: 'leave_game' });
              document.getElementById('profileCard').style.display = 'block';
              document.getElementById('stageTitle').innerText = '👋 Tu as quitté la partie. Entre ton pseudo pour revenir !';
              document.getElementById('stageContent').innerHTML = '';
            }

            function updateUI(st) {
              lastState = st;
              const me = (st.players || []).find(p => p.id === playerID);
              if (me) {
                document.getElementById('scoreBadge').innerText = `${me.score} PTS`;
                const overlay = document.getElementById('bisouOverlay');
                if (me.activeBisouWipesRemaining > 0) {
                  overlay.style.display = 'flex';
                  document.getElementById('bisouTitle').innerText = `💋 BISOU DE ${(me.bisouSenderName || 'MEEMAW').toUpperCase()} ! (${me.activeBisouWipesRemaining}x)`;
                } else {
                  overlay.style.display = 'none';
                }
              }
              renderColors(st.availableColors);
              document.getElementById('profileCard').style.display = (st.stage === 'lobby') ? 'block' : 'none';

              const titleEl = document.getElementById('stageTitle');
              const contentEl = document.getElementById('stageContent');

              if (st.stage === 'lobby') {
                titleEl.innerText = '📺 Regarde la TV AirPlay ! La partie va commencer...';
                contentEl.innerHTML = `<div style="text-align:center;font-weight:700;opacity:0.75;">Thème choisi : ${st.selectedPack}</div>`;
                return;
              }

              if (st.stage === 'solo_buzz_open' && st.activeQuestion) {
                titleEl.innerText = `🚨 LE SOLO • ${st.activeQuestion.funnyTitle}`;
                contentEl.innerHTML = `<button class="solo-buzzer" onclick="beep(880,120);sendMsg({action:'buzz_solo'})">
                  <span style="font-size:46px;">🚨</span>
                  <span>JE PRENDS LE SOLO !</span>
                  <span style="font-size:14px;opacity:0.9;">Double Jackpot ou Perte Sèche !</span>
                </button>`;
                return;
              }

              if (st.stage === 'solo_player_answering' && st.activeQuestion) {
                if (st.soloBuzzerPlayerID === playerID) {
                  titleEl.innerText = '🔥 TU ES EN SOLO ! CHOISIS VITE !';
                  renderChoices(st.activeQuestion, me);
                } else {
                  titleEl.innerText = `🍿 ${st.soloBuzzerPlayerName || 'Un joueur'} a pris LE SOLO !`;
                  contentEl.innerHTML = `<div style="text-align:center;font-size:18px;font-weight:800;">Regarde la TV pour voir s'il se plante !</div>`;
                }
                return;
              }

              if ((st.stage === 'cash_answering' || st.stage === 'question_reading') && st.activeQuestion) {
                titleEl.innerText = st.activeQuestion.funnyTitle;
                renderChoices(st.activeQuestion, me);
                return;
              }

              if (st.stage === 'couci_couca_item' && st.activeDisOrDat) {
                const idx = st.activeDisOrDatItemIndex || 0;
                const item = (st.activeDisOrDat.items || [])[idx];
                titleEl.innerText = item ? item.text : st.activeDisOrDat.funnyTitle;
                contentEl.innerHTML = `<div class="binary-grid">
                  <button class="btn-primary" style="background:#2563EB;color:#fff;" onclick="beep(580,60);sendMsg({action:'select_binary',binarySide:'left'})">⬅️ ${st.activeDisOrDat.optionLeft}</button>
                  <button class="btn-primary" style="background:#E11D48;color:#fff;" onclick="beep(680,60);sendMsg({action:'select_binary',binarySide:'right'})">${st.activeDisOrDat.optionRight} ➡️</button>
                </div>`;
                return;
              }

              titleEl.innerText = st.meemawSpeech || 'Regarde la TV AirPlay !';
              contentEl.innerHTML = '';
            }

            function renderChoices(q, me) {
              const letters = ['A', 'B', 'C', 'D'];
              const locked = me ? me.lockedChoiceIndex : null;
              let html = '<div class="choices-grid">' + (q.choices || []).map((c, idx) => {
                const cls = 'choice-btn ' + (locked === idx ? 'locked' : '');
                return `<button class="${cls}" onclick="beep(640,65);sendMsg({action:'select_choice',choiceIndex:${idx}})">
                  <span class="choice-letter">${letters[idx] || '?'}</span>
                  <span>${c}</span>
                </button>`;
              }).join('') + '</div>';
              document.getElementById('stageContent').innerHTML = html;
            }

            function connectWS() {
              const proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
              ws = new WebSocket(`${proto}//${location.host}/ws`);
              ws.onopen = () => sendProfile();
              ws.onmessage = (ev) => {
                try { updateUI(JSON.parse(ev.data)); } catch (_) {}
              };
              ws.onclose = () => setTimeout(connectWS, 1200);
            }
            renderColors(null);
            connectWS();
          </script>
        </body>
        </html>
        """
    }
}
