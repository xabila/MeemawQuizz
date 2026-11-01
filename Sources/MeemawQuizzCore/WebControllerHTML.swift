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
            <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;">
              <div id="roundBadge" class="badge" style="background:var(--yellow);">🎙️ SALON</div>
              <div id="timerBadge" class="badge" style="font-family:monospace;">⏱️ --</div>
            </div>
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
            let lastRenderKey = '';
            let lastSoundKey = '';
            let optimisticQuestionID = null;
            let optimisticChoice = null;
            let optimisticItemKey = null;
            let optimisticSide = null;

            const savedName = localStorage.getItem('mq_name') || '';
            document.getElementById('playerName').value = savedName;

            function beep(freq = 520, ms = 70) {
              try {
                if (navigator.vibrate) navigator.vibrate(35);
                const ctx = new (window.AudioContext || window.webkitAudioContext)();
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.frequency.value = freq;
                gain.gain.value = 0.14;
                osc.connect(gain); gain.connect(ctx.destination);
                osc.start(); setTimeout(() => { osc.stop(); ctx.close(); }, ms);
              } catch (_) {}
            }

            function playVerdictSound(isRight) {
              if (isRight) {
                beep(660, 90);
                setTimeout(() => beep(880, 150), 100);
              } else {
                if (navigator.vibrate) navigator.vibrate([80, 50, 120]);
                beep(220, 220);
              }
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
              const full = { playerID, platform: 'web_qr', ...payload };
              if (ws && ws.readyState === WebSocket.OPEN) {
                ws.send(JSON.stringify(full));
              } else {
                fetch('/api/action', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify(full)
                }).then(r => r.json()).then(st => updateUI(st)).catch(() => {});
              }
            }

            function pickChoice(idx, qid) {
              optimisticQuestionID = qid;
              optimisticChoice = idx;
              lastRenderKey = '';
              beep(640, 65);
              sendMsg({ action: 'select_choice', choiceIndex: idx });
              if (lastState) updateUI(lastState);
            }

            function pickBinary(side, itemKey) {
              optimisticItemKey = itemKey;
              optimisticSide = side;
              lastRenderKey = '';
              beep(640, 65);
              sendMsg({ action: 'select_binary', binarySide: side });
              if (lastState) updateUI(lastState);
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

              // Always update timer badge smoothly without destroying buttons DOM
              const timerEl = document.getElementById('timerBadge');
              const roundEl = document.getElementById('roundBadge');
              const secs = Math.max(0, Math.ceil(st.timeRemainingSec || 0));
              timerEl.innerText = secs > 0 ? `⏱️ ${secs}s` : '⏱️ --';
              roundEl.innerText = st.stage === 'lobby' ? '🎙️ SALON' : `Q${st.questionNumber}/${st.totalQuestions}`;

              const qid = st.activeQuestion ? st.activeQuestion.id : '';
              if (optimisticQuestionID !== qid) {
                optimisticQuestionID = qid;
                optimisticChoice = null;
              }
              const itemKey = st.activeDisOrDat ? `${st.activeDisOrDat.id}_${st.activeDisOrDatItemIndex || 0}` : '';
              if (optimisticItemKey !== itemKey) {
                optimisticItemKey = itemKey;
                optimisticSide = null;
              }

              const effectiveChoice = (me && me.lockedChoiceIndex !== null && me.lockedChoiceIndex !== undefined)
                ? me.lockedChoiceIndex
                : optimisticChoice;
              const effectiveSide = (me && me.lockedSide)
                ? me.lockedSide
                : optimisticSide;

              const answeredCount = (st.players || []).filter(p => p.lockedChoiceIndex !== null && p.lockedChoiceIndex !== undefined || p.lockedSide).length;
              const renderKey = [
                st.stage,
                st.roundKind,
                qid,
                itemKey,
                effectiveChoice,
                effectiveSide,
                st.revealedCorrectIndex,
                st.revealedBinarySide,
                st.soloBuzzerPlayerID,
                st.screwAttackerName,
                answeredCount,
                (st.players || []).length,
                me ? me.hasUsedScrew : false,
                me ? me.hasUsedBisouTrap : false
              ].join('|');

              if (st.stage === 'lobby') {
                renderColors(st.availableColors);
              }
              document.getElementById('profileCard').style.display = (st.stage === 'lobby') ? 'block' : 'none';

              if (renderKey === lastRenderKey && st.stage !== 'lobby') {
                return;
              }
              lastRenderKey = renderKey;

              const titleEl = document.getElementById('stageTitle');
              const contentEl = document.getElementById('stageContent');
              const stageCard = document.getElementById('stageCard');
              stageCard.style.background = '#FFFFFF';

              if (st.stage === 'lobby') {
                titleEl.innerText = '📺 Regarde la TV AirPlay ! La partie va commencer...';
                contentEl.innerHTML = `<div style="text-align:center;font-weight:700;opacity:0.75;">Thème choisi : ${st.selectedPack}</div>`;
                return;
              }

              if ((st.stage === 'solo_buzz_open' || st.stage === 'cash_answering' || st.stage === 'question_reading' || st.stage === 'question_reveal') && st.activeQuestion) {
                const isSolo = (st.roundKind === 'le_solo');
                let topBanner = '';
                if (st.stage === 'solo_buzz_open') {
                  topBanner = `<div style="background:#E11D48;color:#fff;padding:10px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🚨 LE SOLO : LE 1er QUI RÉPOND PREND TOUT (DOUBLE OU GAMELLE) !</div>`;
                } else if (st.stage === 'cash_answering' && effectiveChoice !== null && effectiveChoice !== undefined) {
                  const letters = ['A', 'B', 'C', 'D'];
                  topBanner = `<div style="background:#FFD700;color:#1A1A1A;padding:12px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🔒 TON CHOIX (${letters[effectiveChoice]}) EST ENREGISTRÉ !<br><span style="font-size:13px;">⏳ En attente des autres joueurs (${answeredCount}/${(st.players || []).length})...</span></div>`;
                }
                titleEl.innerText = `${st.activeQuestion.funnyTitle} — ${st.activeQuestion.prompt}`;
                renderChoices(st.activeQuestion, me, effectiveChoice, st.stage === 'question_reveal', st.revealedCorrectIndex, topBanner, isSolo, st);
                return;
              }

              if (st.stage === 'solo_player_answering' && st.activeQuestion) {
                if (st.soloBuzzerPlayerID === playerID) {
                  const banner = st.screwAttackerName
                    ? `<div style="background:#8E44AD;color:#fff;padding:12px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🔩 ${st.screwAttackerName.toUpperCase()} T'A CLOUÉ LE BEC ! Réponds juste pour doubler les points !</div>`
                    : `<div style="background:#E11D48;color:#fff;padding:12px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🔥 TU ES EN SOLO ! 12 SECONDES POUR RÉPONDRE !</div>`;
                  titleEl.innerText = `${st.activeQuestion.funnyTitle} — ${st.activeQuestion.prompt}`;
                  renderChoices(st.activeQuestion, me, effectiveChoice, false, null, banner, true, st);
                } else {
                  titleEl.innerText = st.screwAttackerName
                    ? `🔩 ${st.screwAttackerName} a cloué le bec de ${st.soloBuzzerPlayerName || 'un joueur'} !`
                    : `🍿 ${st.soloBuzzerPlayerName || 'Un joueur'} a pris LE SOLO !`;
                  contentEl.innerHTML = `<div style="text-align:center;font-size:18px;font-weight:800;">Il est tout seul face à la question !</div>`;
                }
                return;
              }

              if ((st.stage === 'couci_couca_item' || st.stage === 'couci_couca_reveal') && st.activeDisOrDat) {
                const idx = st.activeDisOrDatItemIndex || 0;
                const item = (st.activeDisOrDat.items || [])[idx];
                const palette = ['#FFF3E0', '#E0F7FA', '#F3E5F5', '#FFE4E8', '#ECFDF5', '#FEF9C3'];
                stageCard.style.background = palette[idx % palette.length];
                const isReveal = (st.stage === 'couci_couca_reveal');
                const correctSide = st.revealedBinarySide;
                const mySide = effectiveSide;
                const delta = me ? (me.lastDeltaScore || 0) : 0;

                let feedbackHTML = '';
                if (!isReveal && mySide) {
                  const chosenLbl = (mySide === 'left') ? st.activeDisOrDat.optionLeft : (mySide === 'both' ? (st.activeDisOrDat.optionBoth || 'LES DEUX') : st.activeDisOrDat.optionRight);
                  feedbackHTML = `<div style="background:#FFD700;color:#1A1A1A;padding:10px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🔒 CHOIX VERROUILLÉ : ${chosenLbl}<br><span style="font-size:12px;">⏳ En attente des autres joueurs (${answeredCount}/${(st.players || []).length})...</span></div>`;
                } else if (isReveal && correctSide) {
                  const isRight = (mySide === correctSide);
                  const soundKey = `couci_${itemKey}`;
                  if (lastSoundKey !== soundKey) {
                    lastSoundKey = soundKey;
                    playVerdictSound(isRight);
                  }
                  const correctLbl = (correctSide === 'left') ? st.activeDisOrDat.optionLeft : (correctSide === 'both' ? (st.activeDisOrDat.optionBoth || '🧀 LES DEUX !') : st.activeDisOrDat.optionRight);
                  const fbBg = isRight ? '#10B981' : '#E11D48';
                  const fbText = isRight
                    ? `🎉✅ BONNE RÉPONSE ! +${delta} PTS`
                    : (mySide ? `💥❌ FAUX ! (${delta} PTS)<br><span style="font-size:14px;color:#FFD700;">👉 C'était : ${correctLbl}</span>` : `⏰ TROP TARD ! (0 PT)<br><span style="font-size:14px;color:#FFD700;">👉 C'était : ${correctLbl}</span>`);
                  feedbackHTML = `<div style="background:${fbBg};color:#fff;padding:12px;border-radius:14px;border:3.5px solid #1A1A1A;font-weight:900;font-size:18px;text-align:center;margin-bottom:10px;">${fbText}</div>`;
                }

                const btnStyle = (side, defHex) => {
                  if (isReveal && correctSide) {
                    if (correctSide === side) return 'background:#10B981;color:#fff;';
                    if (mySide === side) return 'background:#E11D48;color:#fff;';
                    return `background:${defHex};color:#fff;opacity:0.35;`;
                  }
                  if (mySide === side) return 'background:#FFD700;color:#1A1A1A;';
                  if (mySide) return `background:${defHex};color:#fff;opacity:0.35;`;
                  return `background:${defHex};color:#fff;`;
                };

                titleEl.innerText = `[Q${idx + 1}/${(st.activeDisOrDat.items || []).length}] ${item ? item.text : st.activeDisOrDat.funnyTitle}`;
                const bothBtn = st.activeDisOrDat.optionBoth
                  ? `<button class="btn-primary" style="margin-top:10px;${btnStyle('both', '#8E44AD')}" ${isReveal || mySide ? 'disabled' : ''} onclick="pickBinary('both','${itemKey}')">${isReveal && correctSide === 'both' ? '✅ ' : '🧀 '}${st.activeDisOrDat.optionBoth}</button>`
                  : '';

                contentEl.innerHTML = `${feedbackHTML}<div class="binary-grid">
                  <button class="btn-primary" style="${btnStyle('left', '#2563EB')}" ${isReveal || mySide ? 'disabled' : ''} onclick="pickBinary('left','${itemKey}')">${isReveal && correctSide === 'left' ? '✅ ' : '⬅️ '}${st.activeDisOrDat.optionLeft}</button>
                  <button class="btn-primary" style="${btnStyle('right', '#FF4D94')}" ${isReveal || mySide ? 'disabled' : ''} onclick="pickBinary('right','${itemKey}')">${st.activeDisOrDat.optionRight}${isReveal && correctSide === 'right' ? ' ✅' : ' ➡️'}</button>
                </div>${bothBtn}`;
                return;
              }

              titleEl.innerText = st.meemawSpeech || 'Regarde la TV AirPlay !';
              contentEl.innerHTML = `<div style="text-align:center;font-weight:800;color:var(--orange);">⏭️ Suite automatique dans quelques secondes...</div>`;
            }

            function renderChoices(q, me, locked, isReveal, correctIdx, topBannerHTML = '', isSolo = false, st = null) {
              const letters = ['A', 'B', 'C', 'D'];
              const delta = me ? (me.lastDeltaScore || 0) : 0;
              let revealBanner = '';
              if (isReveal) {
                const isRight = (delta > 0) || (locked !== null && locked !== undefined && locked === correctIdx);
                const soundKey = `mcq_${q.id}`;
                if (lastSoundKey !== soundKey) {
                  lastSoundKey = soundKey;
                  playVerdictSound(isRight);
                }
                const bg = isRight ? '#10B981' : '#E11D48';
                const correctText = (q.choices && q.choices[correctIdx]) ? `${letters[correctIdx]} : ${q.choices[correctIdx]}` : '';
                const txt = isRight
                  ? `🎉✅ BONNE RÉPONSE ! +${delta} PTS`
                  : (locked === null || locked === undefined && delta === 0
                      ? `⏰ PAS DE RÉPONSE (0 PT)<br><span style="font-size:14px;color:#FFD700;">👉 Bonne réponse : ${correctText}</span>`
                      : `💥❌ MAUVAISE RÉPONSE ! (${delta} PTS)<br><span style="font-size:14px;color:#FFD700;">👉 Bonne réponse : ${correctText}</span>`);
                revealBanner = `<div style="background:${bg};color:#fff;padding:14px;border-radius:16px;border:3.5px solid #1A1A1A;font-weight:900;font-size:19px;text-align:center;margin-bottom:10px;">${txt}<div style="font-size:13px;font-weight:700;margin-top:6px;opacity:0.95;">${q.explanation || ''}</div></div>`;
              }
              const hasLocked = (locked !== null && locked !== undefined);
              let html = topBannerHTML + revealBanner + '<div class="choices-grid">' + (q.choices || []).map((c, idx) => {
                let extraStyle = '';
                let icon = '';
                if (isReveal) {
                  if (idx === correctIdx) { extraStyle = 'background:#10B981;color:#fff;'; icon = ' ✅ BON'; }
                  else if (locked === idx) { extraStyle = 'background:#E11D48;color:#fff;'; icon = ' ❌ TON CHOIX'; }
                  else { extraStyle = 'opacity:0.45;'; }
                } else if (locked === idx) {
                  extraStyle = 'background:#FFD700;color:#1A1A1A;';
                  icon = ' 🔒 CHOISI';
                } else if (hasLocked) {
                  extraStyle = 'opacity:0.35;';
                }
                return `<button class="choice-btn" style="${extraStyle}" ${isReveal || hasLocked ? 'disabled' : ''} onclick="pickChoice(${idx},'${q.id}')">
                  <span class="choice-letter">${letters[idx] || '?'}</span>
                  <span>${c}${icon}</span>
                </button>`;
              }).join('') + '</div>';

              // Jokers Multi : 🔩 Clouer le Bec (Style Jack) + 💋 Bisou Baveux
              const opponents = ((st && st.players) || []).filter(p => p.id !== playerID);
              if (!isReveal && st && st.stage === 'cash_answering' && me && opponents.length > 0 && (!me.hasUsedScrew || !me.hasUsedBisouTrap)) {
                let jokersHTML = '<div style="margin-top:12px;padding:10px;border-radius:16px;border:3px solid #1A1A1A;background:#FFF8E7;display:flex;flex-direction:column;gap:8px;">';
                if (!me.hasUsedScrew) {
                  jokersHTML += `<div style="font-size:12px;font-weight:900;color:#8E44AD;text-align:center;">🔩 COUP DE JARNAC (JACK) : CLOUER UN ADVERSAIRE !</div><div style="display:flex;gap:6px;flex-wrap:wrap;justify-content:center;">` +
                    opponents.map(op => `<button class="badge" style="background:#8E44AD;color:#fff;padding:8px 12px;cursor:pointer;" onclick="beep(780,80);sendMsg({action:'screw_opponent',targetPlayerID:'${op.id}'})">🔩 Clouer ${op.avatarEmoji} ${op.name}</button>`).join('') + `</div>`;
                }
                if (!me.hasUsedBisouTrap) {
                  jokersHTML += `<div style="font-size:12px;font-weight:900;color:#FF4D94;text-align:center;">💋 ENVOYER UN BISOU BAVEUX :</div><div style="display:flex;gap:6px;flex-wrap:wrap;justify-content:center;">` +
                    opponents.map(op => `<button class="badge" style="background:#FF4D94;color:#fff;padding:8px 12px;cursor:pointer;" onclick="beep(720,80);sendMsg({action:'send_bisou',targetPlayerID:'${op.id}'})">💋 ${op.avatarEmoji} ${op.name}</button>`).join('') + `</div>`;
                }
                jokersHTML += '</div>';
                html += jokersHTML;
              }

              document.getElementById('stageContent').innerHTML = html;
            }

            function connectWS() {
              try {
                const proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
                ws = new WebSocket(`${proto}//${location.host}/ws`);
                ws.onopen = () => sendProfile();
                ws.onmessage = (ev) => {
                  try { updateUI(JSON.parse(ev.data)); } catch (_) {}
                };
                ws.onclose = () => setTimeout(connectWS, 1500);
              } catch (_) {}
            }
            setInterval(() => {
              if (!ws || ws.readyState !== WebSocket.OPEN) {
                fetch('/api/state').then(r => r.json()).then(st => updateUI(st)).catch(() => {});
              }
            }, 900);
            renderColors(null);
            connectWS();
            setTimeout(sendProfile, 400);
          </script>
        </body>
        </html>
        """
    }
}
