#!/usr/bin/env python3
"""
Génère les 432 fichiers audio MP3 Studio (108 questions par décennie × 4 pistes :
prompt, _roast, _win, _ttmc) dans App/Resources/MeemawQuizzAudio/ avec :
- Voix FR : fr-FR-DeniseNeural (pitch=-8Hz, rate=-6%) — Profil B validé
- Voix EN : en-US-JennyNeural (pitch=-14Hz, rate=-8%) pour les titres/citations en anglais
- Phonétique : Meemaw -> Mimo, symboles mathématiques parlés, zéro re-compression basse fréquence.
"""
import asyncio
import json
import re
import subprocess
import tempfile
from pathlib import Path
import edge_tts

OUT_DIR = Path("/Users/xabi/DEV/MeemawQuizz/App/Resources/MeemawQuizzAudio")
QUESTIONS_JSON = Path("/tmp/decade_questions_108.json")

FR_VOICE = "fr-FR-DeniseNeural"
FR_PITCH = "-8Hz"
FR_RATE = "-6%"

EN_VOICE = "en-US-JennyNeural"
EN_PITCH = "-14Hz"
EN_RATE = "-8%"

WIN_PREFIXES = [
    "Bravo, dans le mille !",
    "Joli coup mon petit chou !",
    "Chapeau l'artiste, c'est la bonne réponse !",
    "Hop là, bien joué !",
    "Quel réflexe, c'est tout bon !",
    "Boum, exactement ça !",
]

# Expressions anglaises entre guillemets à prononcer avec JennyNeural
ENGLISH_QUOTES = {
    "tea for two",
    "the upside down",
    "boogie wonderland",
    "earth, wind & fire",
    "stayin' alive",
    "le freak",
    "if i had a hammer",
    "abbey road",
    "dancing queen",
    "young and sweet, only",
    "only seventeen",
    "you are the dancing queen, young and sweet, only seventeen !",
    "you are the dancing queen, young and sweet, only seventeen",
    "give me the night",
    "get lucky",
    "random access memories",
    "fidget spinner",
    "hand spinner",
    "bitcoin pizza day",
    "subprimes",
    "lehman brothers",
    "central perk",
    "central park",
    "friends",
    "stranger things",
    "squid game",
    "wii sports",
    "snake ii",
    "1,000 songs in your pocket",
}

EMOJI_RE = re.compile(
    "["
    "\U0001F300-\U0001F9FF"
    "\U00002600-\U000027BF"
    "\U0001FA00-\U0001FAFF"
    "\uFE0F"
    "]+",
    flags=re.UNICODE,
)


def normalize_fr_text(text: str) -> str:
    s = EMOJI_RE.sub("", text)
    s = re.sub(r"\b[Mm]eemaw\b", "Mimo", s)
    s = s.replace("3×3×3", "3 par 3 par 3")
    s = s.replace("3×3", "3 par 3")
    s = s.replace("m²", " mètres carrés ")
    s = s.replace("×", " fois ")
    s = s.replace("÷", " divisé par ")
    s = s.replace("‰", " pour mille ")
    s = s.replace("€", " euros ")
    s = s.replace("km/h", " kilomètres heure ")
    s = s.replace("L/100 km", " litres aux cent ")
    s = s.replace("mph", " miles à l'heure ")
    s = re.sub(r"\s+", " ", s).strip()
    return s


def split_bilingual_segments(text: str):
    """
    Découpe le texte autour des guillemets « ... » si le contenu entre guillemets
    est une citation ou un titre en anglais connu.
    Retourne une liste de tuples (lang, segment_text).
    """
    pattern = re.compile(r"«\s*([^»]+?)\s*»")
    segments = []
    last_idx = 0
    for m in pattern.finditer(text):
        before = text[last_idx:m.start()].strip()
        if before:
            segments.append(("fr", normalize_fr_text(before)))
        quoted = m.group(1).strip()
        clean_q = quoted.lower().strip(" !?.…")
        if clean_q in ENGLISH_QUOTES:
            segments.append(("en", EMOJI_RE.sub("", quoted).strip()))
        else:
            segments.append(("fr", normalize_fr_text(quoted)))
        last_idx = m.end()
    tail = text[last_idx:].strip()
    if tail:
        segments.append(("fr", normalize_fr_text(tail)))

    # Fusionne les segments consécutifs de même langue ou dépourvus de lettres/chiffres (ex: "?" ou "!")
    merged = []
    for lang, seg in segments:
        if not seg:
            continue
        if not re.search(r"[A-Za-z0-9À-ÿ]", seg):
            if merged:
                merged[-1] = (merged[-1][0], merged[-1][1] + " " + seg)
            continue
        if merged and merged[-1][0] == lang:
            merged[-1] = (lang, merged[-1][1] + " " + seg)
        else:
            merged.append((lang, seg))
    return merged


async def synth_single_segment(lang: str, text: str, out_mp3: Path):
    for attempt in range(4):
        try:
            if lang == "en":
                comm = edge_tts.Communicate(text, voice=EN_VOICE, pitch=EN_PITCH, rate=EN_RATE)
            else:
                comm = edge_tts.Communicate(text, voice=FR_VOICE, pitch=FR_PITCH, rate=FR_RATE)
            await comm.save(str(out_mp3))
            if out_mp3.exists() and out_mp3.stat().st_size > 200:
                return
        except Exception as e:
            if attempt == 3:
                raise e
            await asyncio.sleep(0.8 * (attempt + 1))


async def synth_track(text: str, out_mp3: Path, sem: asyncio.Semaphore):
    if out_mp3.exists() and out_mp3.stat().st_size > 1000:
        return
    async with sem:
        segments = split_bilingual_segments(text)
        if not segments:
            return
        if len(segments) == 1:
            await synth_single_segment(segments[0][0], segments[0][1], out_mp3)
            return

        # Multi-segment FR + EN : génère chaque partie puis concatène sans ré-échantillonner (24000 Hz 64k)
        tmp_files = []
        list_file = None
        try:
            for lang, seg_text in segments:
                tmp = tempfile.NamedTemporaryFile(suffix=".mp3", delete=False)
                tmp.close()
                tmp_path = Path(tmp.name)
                await synth_single_segment(lang, seg_text, tmp_path)
                tmp_files.append(tmp_path)

            lf = tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False, encoding="utf-8")
            for p in tmp_files:
                lf.write(f"file '{p}'\n")
            lf.close()
            list_file = Path(lf.name)

            subprocess.run(
                [
                    "ffmpeg", "-y",
                    "-f", "concat",
                    "-safe", "0",
                    "-i", str(list_file),
                    "-c", "copy",
                    str(out_mp3),
                ],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        finally:
            for p in tmp_files:
                p.unlink(missing_ok=True)
            if list_file:
                list_file.unlink(missing_ok=True)


async def main():
    questions = json.loads(QUESTIONS_JSON.read_text(encoding="utf-8"))
    sem = asyncio.Semaphore(8)
    jobs = []

    for idx, q in enumerate(questions):
        cue_id = f"q_{q['id']}"
        prompt_text = f"{q['title']}. {q['prompt']}"
        roast_text = f"{q['roast']} {q['explanation']}"
        win_prefix = WIN_PREFIXES[idx % len(WIN_PREFIXES)]
        win_text = f"{win_prefix} {q['explanation']}"
        ttmc_text = f"Tu te mets combien, de une à quatre étoiles, sur : {q['title']} ?"

        jobs.append(synth_track(prompt_text, OUT_DIR / f"{cue_id}.mp3", sem))
        jobs.append(synth_track(roast_text, OUT_DIR / f"{cue_id}_roast.mp3", sem))
        jobs.append(synth_track(win_text, OUT_DIR / f"{cue_id}_win.mp3", sem))
        jobs.append(synth_track(ttmc_text, OUT_DIR / f"{cue_id}_ttmc.mp3", sem))

    print(f"🎙️ Lancement de la génération de {len(jobs)} fichiers MP3 Studio (Profil B Denise + Jenny)...")
    completed = 0
    for coro in asyncio.as_completed(jobs):
        await coro
        completed += 1
        if completed % 40 == 0 or completed == len(jobs):
            print(f"  ✅ {completed}/{len(jobs)} fichiers générés", flush=True)

    print("✨ Tous les 432 fichiers audio des 108 questions par décennie sont prêts !")


if __name__ == "__main__":
    asyncio.run(main())
