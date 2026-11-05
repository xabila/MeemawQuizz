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
            let optimisticStars = null;

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

            function pickBetStars(stars, qid) {
              optimisticQuestionID = qid;
              optimisticStars = stars;
              lastRenderKey = '';
              beep(720, 65);
              sendMsg({ action: 'select_bet_stars', betStars: stars });
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
                optimisticStars = null;
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
              const effectiveStars = (me && me.lockedBetStars)
                ? me.lockedBetStars
                : optimisticStars;

              const answeredCount = (st.players || []).filter(p => p.lockedChoiceIndex !== null && p.lockedChoiceIndex !== undefined || p.lockedSide).length;
              const betCount = (st.players || []).filter(p => p.lockedBetStars).length;
              const drawStrokeCount = st.activeDrawRound && st.activeDrawRound.canvas && st.activeDrawRound.canvas.strokes ? st.activeDrawRound.canvas.strokes.length : 0;
              const drawFoundKey = st.activeDrawRound && st.activeDrawRound.foundPlayerIDs ? st.activeDrawRound.foundPlayerIDs.join(',') : '';
              const esqStep = st.activeEsquisseRound ? `${st.activeEsquisseRound.stepIndex}_${st.activeEsquisseRound.showcaseNotebookIndex}` : '';
              const renderKey = [
                st.stage,
                st.roundKind,
                qid,
                itemKey,
                effectiveChoice,
                effectiveSide,
                effectiveStars,
                st.revealedCorrectIndex,
                st.revealedBinarySide,
                st.soloBuzzerPlayerID,
                st.screwAttackerName,
                answeredCount,
                betCount,
                (st.players || []).length,
                me ? me.hasUsedScrew : false,
                me ? me.hasUsedBisouTrap : false,
                me ? me.hasSubmittedEsquisseStep : false,
                me ? me.lockedNumericEstimate : null,
                me ? me.isJackAttackFrozen : false,
                st.activeJackAttackWaveIndex,
                st.activeJackAttackOptionIndex,
                drawFoundKey,
                esqStep
              ].join('|');

              if (st.stage === 'lobby') {
                renderColors(st.availableColors);
              }
              document.getElementById('profileCard').style.display = (st.stage === 'lobby') ? 'block' : 'none';

              // If we are in draw_live_guessing as a guesser, update the live preview canvas without rebuilding the tile rack DOM!
              if (st.stage === 'draw_live_guessing' && st.activeDrawRound && st.activeDrawRound.drawerPlayerID !== playerID) {
                const maskEl = document.getElementById('drawMaskText');
                if (maskEl) maskEl.innerText = st.activeDrawRound.maskedWordPattern || '';
                drawVectorPreview('guesserPreviewCanvas', st.activeDrawRound.canvas);
              }

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

              if ((st.stage === 'juste_pif_answering' || st.stage === 'juste_pif_reveal') && st.activeJustePif) {
                const pif = st.activeJustePif;
                titleEl.innerText = `🔢 LE JUSTE PIF : « ${pif.funnyTitle} » — ${pif.prompt}`;
                if (st.stage === 'juste_pif_reveal') {
                  contentEl.innerHTML = `<div style="background:#FFD700;color:#1A1A1A;padding:16px;border-radius:16px;border:3px solid #1A1A1A;font-weight:900;text-align:center;">
                    🎯 VRAIE VALEUR : ${pif.correctValue} ${pif.unitLabel}<br>
                    <span style="font-size:13px;font-weight:700;">${pif.meemawComment}</span>
                  </div>`;
                } else if (me && me.lockedNumericEstimate !== null && me.lockedNumericEstimate !== undefined) {
                  contentEl.innerHTML = `<div style="background:#FFD700;color:#1A1A1A;padding:16px;border-radius:16px;border:3px solid #1A1A1A;font-weight:900;text-align:center;">
                    🔒 TON PIF VERROUILLÉ : ${me.lockedNumericEstimate} ${pif.unitLabel}
                  </div>`;
                } else {
                  contentEl.innerHTML = `<div style="display:flex;flex-direction:column;gap:10px;">
                    <input id="pifNumInput" type="number" inputmode="numeric" placeholder="Ton estimation (${pif.unitLabel})" style="font-size:22px;font-weight:900;padding:12px;border-radius:12px;border:3px solid #1A1A1A;text-align:center;" />
                    <button class="choice-btn" style="background:#10B981;color:#fff;justify-content:center;font-size:18px;" onclick="const v=parseInt(document.getElementById('pifNumInput').value,10);if(!isNaN(v)){beep(760,70);sendMsg({action:'submit_numeric_estimate',numericEstimate:v});}">✅ VALIDER MON PIF</button>
                  </div>`;
                }
                return;
              }

              if ((st.stage === 'jack_attack_active' || st.stage === 'jack_attack_wave_reveal') && st.activeJackAttack) {
                const round = st.activeJackAttack;
                const wIdx = st.activeJackAttackWaveIndex || 0;
                const wave = round.waves[wIdx] || round.waves[0];
                const optIdx = st.activeJackAttackOptionIndex || 0;
                const optText = wave.options[optIdx] || '...';
                const frozen = me && me.isJackAttackFrozen;
                titleEl.innerText = `⚡ JACK ATTACK (${wIdx + 1}/${round.waves.length}) • ${wave.clueTitle} : ${wave.anchorText}`;
                if (st.stage === 'jack_attack_wave_reveal') {
                  contentEl.innerHTML = `<div style="background:#FFD700;color:#1A1A1A;padding:16px;border-radius:16px;border:3px solid #1A1A1A;font-weight:900;text-align:center;">
                    ${st.jackAttackWinnerName ? '⚡ ' + st.jackAttackWinnerName.toUpperCase() + ' RAFLE +3 000 PTS !<br>' : ''}
                    ${wave.anchorText} ➜ ${wave.options[wave.correctOptionIndex]}<br>
                    <span style="font-size:13px;font-weight:700;">${wave.explanation}</span>
                  </div>`;
                } else {
                  contentEl.innerHTML = `<button class="choice-btn" style="background:${frozen ? '#6B7280' : '#E11D48'};color:#fff;flex-direction:column;padding:28px 14px;text-align:center;" ${frozen ? 'disabled' : ''} onclick="beep(880,90);sendMsg({action:'buzz_jack_attack'})">
                    <div style="font-size:14px;color:#FFD700;font-weight:900;">${frozen ? '🧊 BUZZER GELÉ (-1 500 PTS)' : '🚨 BUZZER MAINTENANT !'}</div>
                    <div style="font-size:26px;font-weight:900;margin:6px 0;">${optText}</div>
                  </button>`;
                }
                return;
              }

              if (st.stage === 'ttmc_betting' && st.activeQuestion) {
                stageCard.style.background = '#FEF9C3';
                titleEl.innerText = `🎯 TU TE METS COMBIEN SUR : « ${st.activeQuestion.funnyTitle} » ?`;
                const opts = [
                  { s: 1, t: '⭐ 1 ÉTOILE • PETIT JOUEUR', sub: '+1 000 PTS si bon • -250 si faux', bg: '#00ACC1' },
                  { s: 2, t: '⭐⭐ 2 ÉTOILES • TRANQUILLE', sub: '+2 000 PTS si bon • -500 si faux', bg: '#10B981' },
                  { s: 3, t: '⭐⭐⭐ 3 ÉTOILES • CHAUD BOUILLANT', sub: '+3 500 PTS si bon • -1 000 si faux', bg: '#FF8C42' },
                  { s: 4, t: '⭐⭐⭐⭐ 4 ÉTOILES • LE MELON TOTAL !', sub: '+5 000 PTS si bon • -2 500 si faux !', bg: '#E11D48' }
                ];
                const lockBanner = effectiveStars
                  ? `<div style="background:#FFD700;color:#1A1A1A;padding:10px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🔒 PARI VERROUILLÉ : ${'⭐'.repeat(effectiveStars)}<br><span style="font-size:12px;">⏳ En attente des autres (${betCount}/${(st.players || []).length})...</span></div>`
                  : '';
                contentEl.innerHTML = lockBanner + '<div class="choices-grid">' + opts.map(o => {
                  const isSel = (effectiveStars === o.s);
                  const style = isSel
                    ? 'background:#FFD700;color:#1A1A1A;'
                    : `background:${o.bg};color:#fff;${effectiveStars ? 'opacity:0.35;' : ''}`;
                  return `<button class="choice-btn" style="${style};flex-direction:column;align-items:flex-start;gap:4px;" ${effectiveStars ? 'disabled' : ''} onclick="pickBetStars(${o.s},'${st.activeQuestion.id}')">
                    <div style="font-size:17px;font-weight:900;">${o.t} ${isSel ? '🔒' : ''}</div>
                    <div style="font-size:13px;font-weight:700;opacity:0.92;">${o.sub}</div>
                  </button>`;
                }).join('') + '</div>';
                return;
              }

              if ((st.stage === 'solo_buzz_open' || st.stage === 'cash_answering' || st.stage === 'question_reading' || st.stage === 'question_reveal') && st.activeQuestion) {
                const isSolo = (st.roundKind === 'le_solo');
                let topBanner = '';
                if (st.roundKind === 'tu_te_mets_combien' && effectiveStars) {
                  topBanner += `<div style="background:#8E44AD;color:#FFD700;padding:8px 12px;border-radius:12px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:8px;">🎯 TON PARI : ${'⭐'.repeat(effectiveStars)}</div>`;
                } else if (st.roundKind === 'jukebox_express') {
                  topBanner += `<div style="background:#FF4D94;color:#fff;padding:8px 12px;border-radius:12px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:8px;">🎧 JUKEBOX EXPRESS • COMPLÈTE LES PAROLES !</div>`;
                }
                if (st.stage === 'solo_buzz_open') {
                  topBanner += `<div style="background:#E11D48;color:#fff;padding:10px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🚨 LE SOLO : LE 1er QUI RÉPOND PREND TOUT (DOUBLE OU GAMELLE) !</div>`;
                } else if (st.stage === 'cash_answering' && effectiveChoice !== null && effectiveChoice !== undefined) {
                  const letters = ['A', 'B', 'C', 'D'];
                  topBanner += `<div style="background:#FFD700;color:#1A1A1A;padding:12px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🔒 TON CHOIX (${letters[effectiveChoice]}) EST ENREGISTRÉ !<br><span style="font-size:13px;">⏳ En attente des autres joueurs (${answeredCount}/${(st.players || []).length})...</span></div>`;
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

              if (st.stage === 'couci_couca_summary') {
                stageCard.style.background = '#FEF9C3';
                titleEl.innerText = '🧀 FIN DE LA RACLETTE QUIZZ !';
                contentEl.innerHTML = `<div style="background:#FFF8EE;border:3px solid #1A1A1A;border-radius:16px;padding:16px;text-align:center;">
                  <div style="font-size:22px;font-weight:900;color:#1A1A1A;">Score actuel : ${me ? me.score : 0} PTS</div>
                  <div style="font-size:15px;font-weight:800;color:#8E44AD;margin-top:8px;">🔥 Prépare-toi pour la Finale ×2 !</div>
                </div>`;
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
                const labelForSide = (s) => {
                  if (s === 'left') return st.activeDisOrDat.optionLeft;
                  if (s === 'right') return st.activeDisOrDat.optionRight;
                  if (s === 'both') return st.activeDisOrDat.optionBoth || '🧀 LES DEUX !';
                  return 'Aucune réponse';
                };

                titleEl.innerText = `[Q${idx + 1}/${(st.activeDisOrDat.items || []).length}] ${item ? item.text : st.activeDisOrDat.funnyTitle}`;

                if (isReveal && correctSide) {
                  const isRight = (mySide === correctSide);
                  const soundKey = `couci_${itemKey}`;
                  if (lastSoundKey !== soundKey) {
                    lastSoundKey = soundKey;
                    playVerdictSound(isRight);
                  }
                  const fbBg = isRight ? '#10B981' : '#E11D48';
                  const headline = isRight
                    ? `🎉✅ C'EST GAGNÉ ! +${Math.max(delta, st.activeDisOrDat.valuePerItem || 500)} PTS`
                    : (mySide ? `💥❌ C'EST PERDU ! (${delta} PTS)` : `⏰ TROP TARD ! (0 PT)`);
                  contentEl.innerHTML = `<div style="background:${fbBg};color:#fff;padding:18px;border-radius:18px;border:4px solid #1A1A1A;box-shadow:0 5px 0 #1A1A1A;text-align:center;">
                    <div style="font-size:22px;font-weight:900;margin-bottom:10px;">${headline}</div>
                    <div style="background:rgba(0,0,0,0.22);padding:8px 12px;border-radius:10px;font-size:15px;font-weight:800;margin-bottom:8px;">
                      Ton choix : ${labelForSide(mySide)} ${isRight ? '✅' : '❌'}
                    </div>
                    <div style="background:#1A1A1A;color:#FFD700;padding:10px 14px;border-radius:12px;font-size:16px;font-weight:900;">
                      👉 Bonne réponse : ${labelForSide(correctSide)}
                    </div>
                  </div>`;
                  return;
                }

                let feedbackHTML = '';
                if (mySide) {
                  feedbackHTML = `<div style="background:#FFD700;color:#1A1A1A;padding:10px;border-radius:14px;border:3px solid #1A1A1A;font-weight:900;text-align:center;margin-bottom:10px;">🔒 CHOIX VERROUILLÉ : ${labelForSide(mySide)}<br><span style="font-size:12px;">⏳ En attente des autres joueurs (${answeredCount}/${(st.players || []).length})...</span></div>`;
                }

                const btnStyle = (side, defHex) => {
                  if (mySide === side) return 'background:#FFD700;color:#1A1A1A;';
                  if (mySide) return `background:${defHex};color:#fff;opacity:0.35;`;
                  return `background:${defHex};color:#fff;`;
                };

                const bothBtn = st.activeDisOrDat.optionBoth
                  ? `<button class="btn-primary" style="margin-top:10px;${btnStyle('both', '#8E44AD')}" ${mySide ? 'disabled' : ''} onclick="pickBinary('both','${itemKey}')">🧀 ${st.activeDisOrDat.optionBoth}</button>`
                  : '';

                contentEl.innerHTML = `${feedbackHTML}<div class="binary-grid">
                  <button class="btn-primary" style="${btnStyle('left', '#2563EB')}" ${mySide ? 'disabled' : ''} onclick="pickBinary('left','${itemKey}')">⬅️ ${st.activeDisOrDat.optionLeft}</button>
                  <button class="btn-primary" style="${btnStyle('right', '#FF4D94')}" ${mySide ? 'disabled' : ''} onclick="pickBinary('right','${itemKey}')">${st.activeDisOrDat.optionRight} ➡️</button>
                </div>${bothBtn}`;
                return;
              }

              // 🎨 DRAW SOMETHING STAGES
              if ((st.stage === 'draw_word_choice' || st.stage === 'draw_live_guessing' || st.stage === 'draw_reveal') && st.activeDrawRound) {
                const dr = st.activeDrawRound;
                const isDrawer = (dr.drawerPlayerID === playerID);

                if (st.stage === 'draw_word_choice') {
                  if (isDrawer) {
                    titleEl.innerText = '🎨 C\\'EST À TOI DE DESSINER ! Choisis ton mot :';
                    contentEl.innerHTML = '<div class="choices-grid">' + (dr.wordOptions || []).map(opt => {
                      const bg = opt.stars === 3 ? '#FF4D94' : (opt.stars === 2 ? '#FF8C42' : '#10B981');
                      return `<button class="choice-btn" style="background:${bg};color:#fff;justify-content:space-between;" onclick="beep(700,60);sendMsg({action:'select_draw_word',textPayload:'${opt.word}'})">
                        <span>${'⭐'.repeat(opt.stars)} ${opt.word} <small style="opacity:0.85;">(${opt.categoryHint})</small></span>
                        <span class="badge" style="color:#1A1A1A;">+${opt.points} PTS</span>
                      </button>`;
                    }).join('') + '</div>';
                  } else {
                    titleEl.innerText = `${dr.drawerEmoji || '🎨'} ${dr.drawerPlayerName} choisit son mot...`;
                    contentEl.innerHTML = `<div style="text-align:center;font-weight:800;">Prépare-toi à toucher les lettres façon Draw Something !</div>`;
                  }
                  return;
                }

                if (st.stage === 'draw_live_guessing') {
                  if (isDrawer) {
                    titleEl.innerText = `🎨 DESSINE : « ${dr.chosenWord ? dr.chosenWord.word : ''} »`;
                    contentEl.innerHTML = `
                      <div style="background:#FFD700;border:3px solid #1A1A1A;border-radius:14px;padding:8px 12px;margin-bottom:8px;display:flex;justify-content:space-between;align-items:center;">
                        <div>
                          <div style="font-size:10px;font-weight:900;">MOT SECRET À FAIRE DEVINER :</div>
                          <div style="font-size:18px;font-weight:900;">« ${dr.chosenWord ? dr.chosenWord.word : ''} »</div>
                        </div>
                        <button class="badge" style="background:#fff;cursor:pointer;" onclick="beep(650,60);sendMsg({action:'swap_secret_prompt'})">🔄 CHANGER</button>
                      </div>
                      <canvas id="drawerPadCanvas" width="300" height="400" style="width:100%;max-width:300px;aspect-ratio:3/4;margin:0 auto;display:block;background:#fff;border:3px solid #1A1A1A;border-radius:14px;touch-action:none;"></canvas>
                      <div style="display:flex;gap:6px;justify-content:space-between;align-items:center;margin-top:8px;flex-wrap:wrap;">
                        ${['#111827','#E11D48','#FF8C42','#F59E0B','#10B981','#2563EB','#8E44AD'].map(c =>
                          `<button onclick="setPadColor('${c}')" style="width:30px;height:30px;border-radius:50%;background:${c};border:2.5px solid #1A1A1A;"></button>`
                        ).join('')}
                        <button class="badge" onclick="undoPadStroke()">↩️</button>
                        <button class="badge" onclick="clearPadCanvas()">🗑️</button>
                      </div>
                    `;
                    initInteractivePad('drawerPadCanvas', true);
                  } else {
                    const alreadyFound = (dr.foundPlayerIDs || []).includes(playerID);
                    titleEl.innerText = `${dr.drawerEmoji || '🎨'} ${dr.drawerPlayerName} dessine (${dr.wordLength || 6} lettres)`;
                    if (alreadyFound) {
                      contentEl.innerHTML = `
                        <canvas id="guesserPreviewCanvas" width="300" height="400" style="width:100%;max-width:220px;aspect-ratio:3/4;margin:0 auto;display:block;background:#fff;border:3px solid #1A1A1A;border-radius:14px;"></canvas>
                        <div style="background:#10B981;color:#fff;padding:16px;border-radius:16px;border:3.5px solid #1A1A1A;font-weight:900;text-align:center;margin-top:10px;">
                          🎉 BRAVO ! TU AS TROUVÉ « ${dr.chosenWord ? dr.chosenWord.word : ''} » !
                        </div>`;
                      drawVectorPreview('guesserPreviewCanvas', dr.canvas);
                    } else {
                      contentEl.innerHTML = `
                        <canvas id="guesserPreviewCanvas" width="300" height="400" style="width:100%;max-width:210px;aspect-ratio:3/4;margin:0 auto;display:block;background:#fff;border:3px solid #1A1A1A;border-radius:14px;"></canvas>
                        <div style="display:flex;justify-content:space-between;align-items:center;margin:8px 0;">
                          <div id="drawMaskText" style="font-family:monospace;font-size:18px;font-weight:900;">${dr.maskedWordPattern || ''}</div>
                          <button class="badge" style="background:#8E44AD;color:#fff;cursor:pointer;" onclick="buyDrawHint('${dr.chosenWord ? dr.chosenWord.categoryHint : ''}')">💡 Indice (-300 pts)</button>
                        </div>
                        <div id="drawHintBanner" style="display:none;background:#F3E8FF;color:#8E44AD;border:2px solid #8E44AD;border-radius:10px;padding:5px 10px;font-size:12px;font-weight:900;text-align:center;margin-bottom:8px;"></div>
                        <div id="drawSlotsRow" style="display:flex;gap:5px;justify-content:center;margin-bottom:8px;"></div>
                        <div id="drawTilesGrid" style="display:grid;grid-template-columns:repeat(6,1fr);gap:6px;"></div>
                      `;
                      drawVectorPreview('guesserPreviewCanvas', dr.canvas);
                      initDrawSomethingRack(dr.wordLength || 6, dr.chosenWord ? dr.chosenWord.word : '', dr.scrambledTiles || []);
                    }
                  }
                  return;
                }

                if (st.stage === 'draw_reveal') {
                  titleEl.innerText = `🎨 LE MOT ÉTAIT : « ${dr.chosenWord ? dr.chosenWord.word : ''} »`;
                  contentEl.innerHTML = `<canvas id="guesserPreviewCanvas" width="300" height="400" style="width:100%;max-width:230px;aspect-ratio:3/4;margin:0 auto;display:block;background:#fff;border:3px solid #1A1A1A;border-radius:14px;"></canvas>`;
                  drawVectorPreview('guesserPreviewCanvas', dr.canvas);
                  return;
                }
              }

              // 📞 ESQUISSÉ ! (GARTIC PHONE) STAGES
              if ((st.stage === 'esquisse_prompt_entry' || st.stage === 'esquisse_drawing' || st.stage === 'esquisse_guessing' || st.stage === 'esquisse_showcase') && st.activeEsquisseRound) {
                const esq = st.activeEsquisseRound;
                if (st.stage === 'esquisse_showcase') {
                  const nbIdx = Math.min(Math.max(0, esq.showcaseNotebookIndex || 0), Math.max(0, (esq.notebooks || []).length - 1));
                  const nb = (esq.notebooks || [])[nbIdx];
                  if (nb) {
                    const voted = (nb.voteVoterIDs || []).includes(playerID);
                    titleEl.innerText = `📒 CARNET DE ${nb.ownerEmoji || '🎨'} ${nb.ownerName} (${nbIdx + 1}/${esq.notebooks.length})`;
                    contentEl.innerHTML = `<button class="btn-primary" style="background:${voted ? '#10B981' : '#FF4D94'};color:#fff;" ${voted ? 'disabled' : ''} onclick="beep(750,80);sendMsg({action:'vote_esquisse_album',textPayload:'${nb.id}'})">${voted ? '✅ COUP DE CŒUR ENVOYÉ !' : '😂 VOTER COUP DE CŒUR (+1 000 PTS)'}</button>`;
                  }
                  return;
                }

                if (me && me.hasSubmittedEsquisseStep) {
                  titleEl.innerText = '✅ CARNET TRANSMIS AU VOISIN !';
                  contentEl.innerHTML = `<div style="text-align:center;font-weight:800;color:#10B981;">Attends que les autres joueurs terminent leur étape...</div>`;
                  return;
                }

                const assignedID = (esq.activeAssignmentByPlayerID || {})[playerID];
                const nb = (esq.notebooks || []).find(n => n.id === assignedID) || (esq.notebooks || [])[0];
                const lastEntry = nb && nb.entries && nb.entries.length ? nb.entries[nb.entries.length - 1] : null;

                if (st.stage === 'esquisse_prompt_entry') {
                  titleEl.innerText = '✍️ CHOISIS 1 SEUL MOT FACILE !';
                  contentEl.innerHTML = `
                    <input type="text" id="esqTextInput" maxlength="40" placeholder="Ex: SOLEIL, PIZZA, POISSON..." />
                    <button class="btn-primary" style="background:#10B981;color:#fff;" onclick="submitEsqText()">✅ Envoyer mon mot au voisin</button>
                  `;
                  return;
                }

                if (st.stage === 'esquisse_drawing') {
                  const secretText = lastEntry && lastEntry.promptText ? lastEntry.promptText : 'SOLEIL';
                  titleEl.innerText = `🎨 ESQUISSÉ : DESSINE CE MOT FACILE !`;
                  contentEl.innerHTML = `
                    <div style="background:#FFD700;border:3px solid #1A1A1A;border-radius:14px;padding:8px 12px;margin-bottom:8px;display:flex;justify-content:space-between;align-items:center;">
                      <div>
                        <div style="font-size:10px;font-weight:900;">1 SEUL MOT FACILE À DESSINER :</div>
                        <div style="font-size:18px;font-weight:900;">« ${secretText} »</div>
                      </div>
                      <button class="badge" style="background:#fff;cursor:pointer;" onclick="beep(650,60);sendMsg({action:'swap_secret_prompt'})">🔄 CHANGER</button>
                    </div>
                    <canvas id="esqPadCanvas" width="300" height="400" style="width:100%;max-width:300px;aspect-ratio:3/4;margin:0 auto;display:block;background:#fff;border:3px solid #1A1A1A;border-radius:14px;touch-action:none;"></canvas>
                    <div style="display:flex;gap:6px;justify-content:space-between;align-items:center;margin:8px 0;flex-wrap:wrap;">
                      ${['#111827','#E11D48','#FF8C42','#F59E0B','#10B981','#2563EB','#8E44AD'].map(c =>
                        `<button onclick="setPadColor('${c}')" style="width:28px;height:28px;border-radius:50%;background:${c};border:2.5px solid #1A1A1A;"></button>`
                      ).join('')}
                      <button class="badge" onclick="undoPadStroke()">↩️</button>
                      <button class="badge" onclick="clearPadCanvas()">🗑️</button>
                    </div>
                    <button class="btn-primary" style="background:#10B981;color:#fff;" onclick="submitEsqDrawing()">🚀 Envoyer mon dessin</button>
                  `;
                  initInteractivePad('esqPadCanvas', false);
                  return;
                }

                if (st.stage === 'esquisse_guessing') {
                  titleEl.innerText = '🕵️ MANCHE 2/3 : QUEL MOT LE VOISIN A-T-IL DESSINÉ ?';
                  contentEl.innerHTML = `
                    <canvas id="esqGuessPreview" width="300" height="400" style="width:100%;max-width:230px;aspect-ratio:3/4;margin:0 auto;display:block;background:#fff;border:3px solid #1A1A1A;border-radius:14px;"></canvas>
                    <input type="text" id="esqTextInput" maxlength="40" placeholder="Tape le mot (ex: SOLEIL, PIZZA...)" />
                    <button class="btn-primary" style="background:#10B981;color:#fff;" onclick="submitEsqText()">✅ Valider ce mot</button>
                  `;
                  if (lastEntry && lastEntry.drawing) {
                    drawVectorPreview('esqGuessPreview', lastEntry.drawing);
                  }
                  return;
                }
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

            // Vector Canvas & Draw Something JS Helpers
            let padStrokes = [];
            let padActivePts = [];
            let padColor = '#111827';
            let padCanvasID = '';
            let padLiveStream = false;
            let padLastSent = 0;

            function setPadColor(c) { padColor = c; beep(600, 30); }
            function undoPadStroke() {
              padStrokes.pop();
              redrawLocalPad();
              if (padLiveStream) sendMsg({ action: 'update_drawing_canvas', drawingCanvas: { strokes: padStrokes } });
            }
            function clearPadCanvas() {
              padStrokes = [];
              padActivePts = [];
              redrawLocalPad();
              if (padLiveStream) sendMsg({ action: 'update_drawing_canvas', drawingCanvas: { strokes: [] } });
            }
            function redrawLocalPad() {
              const all = padActivePts.length ? [...padStrokes, { colorHex: padColor, lineWidth: 7, points: padActivePts }] : padStrokes;
              drawVectorPreview(padCanvasID, { strokes: all });
            }
            function initInteractivePad(canvasID, liveStream) {
              padCanvasID = canvasID;
              padLiveStream = liveStream;
              padStrokes = [];
              padActivePts = [];
              const c = document.getElementById(canvasID);
              if (!c) return;
              const getPt = (e) => {
                const r = c.getBoundingClientRect();
                const t = e.touches ? e.touches[0] : e;
                return {
                  x: Math.round(Math.max(0, Math.min(1, (t.clientX - r.left) / r.width)) * 1000) / 1000,
                  y: Math.round(Math.max(0, Math.min(1, (t.clientY - r.top) / r.height)) * 1000) / 1000
                };
              };
              const start = (e) => { e.preventDefault(); padActivePts = [getPt(e)]; redrawLocalPad(); };
              const move = (e) => {
                if (!padActivePts.length) return;
                e.preventDefault();
                padActivePts.push(getPt(e));
                redrawLocalPad();
                const now = Date.now();
                if (padLiveStream && now - padLastSent > 150) {
                  padLastSent = now;
                  sendMsg({ action: 'update_drawing_canvas', drawingCanvas: { strokes: [...padStrokes, { colorHex: padColor, lineWidth: 7, points: padActivePts }] } });
                }
              };
              const end = (e) => {
                if (!padActivePts.length) return;
                e.preventDefault();
                padStrokes.push({ colorHex: padColor, lineWidth: 7, points: padActivePts });
                padActivePts = [];
                redrawLocalPad();
                if (padLiveStream) sendMsg({ action: 'update_drawing_canvas', drawingCanvas: { strokes: padStrokes } });
              };
              c.onmousedown = start; c.onmousemove = move; window.onmouseup = end;
              c.ontouchstart = start; c.ontouchmove = move; c.ontouchend = end;
            }
            function drawVectorPreview(canvasID, canvasData) {
              const c = document.getElementById(canvasID);
              if (!c || !canvasData) return;
              const ctx = c.getContext('2d');
              ctx.clearRect(0, 0, c.width, c.height);
              ctx.lineCap = 'round';
              ctx.lineJoin = 'round';
              const scale = Math.max(0.1, c.width / 300.0);
              for (const s of (canvasData.strokes || [])) {
                const pts = s.points || [];
                if (!pts.length) continue;
                ctx.strokeStyle = s.colorHex || '#111827';
                ctx.lineWidth = (s.lineWidth || 7) * scale;
                ctx.beginPath();
                ctx.moveTo(pts[0].x * c.width, pts[0].y * c.height);
                for (let i = 1; i < pts.length; i++) {
                  ctx.lineTo(pts[i].x * c.width, pts[i].y * c.height);
                }
                ctx.stroke();
              }
            }
            let rackSelectedIndices = [];
            let rackTargetLen = 0;
            let rackTargetWord = '';
            let rackTiles = [];
            let rackHintsUsed = 0;
            function initDrawSomethingRack(len, word, tiles) {
              rackSelectedIndices = [];
              rackTargetLen = len;
              rackTargetWord = (word || '').toUpperCase();
              rackTiles = tiles || [];
              rackHintsUsed = 0;
              renderDrawSomethingRack();
            }
            function buyDrawHint(categoryHint) {
              if (rackHintsUsed >= Math.max(1, rackTargetLen - 1)) return;
              rackHintsUsed += 1;
              beep(520, 70);
              sendMsg({ action: 'request_draw_hint' });
              const banner = document.getElementById('drawHintBanner');
              if (banner) {
                banner.style.display = 'block';
                banner.innerText = `💡 Catégorie : ${categoryHint} • ${rackHintsUsed} lettre(s) révélée(s) (-${rackHintsUsed * 300} pts)`;
              }
              const chosen = [];
              for (let pos = 0; pos < rackHintsUsed; pos++) {
                const ch = rackTargetWord[pos];
                const idx = rackTiles.findIndex((t, i) => !chosen.includes(i) && t.toUpperCase() === ch);
                if (idx >= 0) chosen.push(idx);
              }
              rackSelectedIndices = chosen;
              renderDrawSomethingRack();
            }
            function renderDrawSomethingRack() {
              const slotsEl = document.getElementById('drawSlotsRow');
              const gridEl = document.getElementById('drawTilesGrid');
              if (!slotsEl || !gridEl) return;
              let slotsHTML = '';
              for (let i = 0; i < rackTargetLen; i++) {
                const locked = i < rackHintsUsed;
                const letter = i < rackSelectedIndices.length ? rackTiles[rackSelectedIndices[i]] : '';
                const bg = locked ? '#8E44AD' : (letter ? '#FFD700' : '#FFF8F0');
                const col = locked ? '#FFFFFF' : '#1A1A1A';
                slotsHTML += `<button ${locked ? 'disabled' : ''} onclick="removeRackSlot(${i})" style="width:36px;height:42px;border-radius:10px;border:2.5px solid #1A1A1A;background:${bg};color:${col};font-size:19px;font-weight:900;">${letter}</button>`;
              }
              slotsEl.innerHTML = slotsHTML;
              gridEl.innerHTML = rackTiles.map((ch, idx) => {
                const used = rackSelectedIndices.includes(idx);
                return `<button ${used ? 'disabled' : ''} onclick="tapRackTile(${idx})" style="height:44px;border-radius:10px;border:2.5px solid #1A1A1A;background:${used ? '#eee' : '#2563EB'};color:${used ? '#aaa' : '#fff'};font-size:19px;font-weight:900;">${ch}</button>`;
              }).join('');
            }
            function removeRackSlot(pos) {
              if (pos >= rackHintsUsed && pos < rackSelectedIndices.length) {
                rackSelectedIndices.splice(pos, 1);
                renderDrawSomethingRack();
              }
            }
            function tapRackTile(idx) {
              if (rackSelectedIndices.includes(idx) || rackSelectedIndices.length >= rackTargetLen) return;
              beep(640, 40);
              rackSelectedIndices.push(idx);
              renderDrawSomethingRack();
              if (rackSelectedIndices.length === rackTargetLen) {
                const word = rackSelectedIndices.map(i => rackTiles[i]).join('');
                if (word === rackTargetWord) {
                  playVerdictSound(true);
                  sendMsg({ action: 'submit_draw_guess', textPayload: word });
                } else {
                  playVerdictSound(false);
                  setTimeout(() => { rackSelectedIndices = []; renderDrawSomethingRack(); }, 350);
                }
              }
            }
            function submitEsqText() {
              const el = document.getElementById('esqTextInput');
              const txt = el ? el.value.trim() : '';
              beep(720, 60);
              sendMsg({ action: 'submit_esquisse_text', textPayload: txt });
            }
            function submitEsqDrawing() {
              beep(720, 60);
              sendMsg({ action: 'submit_esquisse_drawing', drawingCanvas: { strokes: padStrokes } });
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
