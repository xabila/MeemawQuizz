import AVFoundation
import Foundation

let preferredIdentifiers = [
    "com.apple.voice.premium.fr-FR.Audrey",
    "com.apple.voice.enhanced.fr-FR.Audrey",
    "com.apple.ttsbundle.Audrey-premium"
]

final class MeemawStudioSynthesizer {
    let voice: AVSpeechSynthesisVoice
    let synth = AVSpeechSynthesizer()
    let targetSampleRate: Double = 22050.0
    let aacSettings: [String: Any]

    init() {
        var resolved: AVSpeechSynthesisVoice?
        for id in preferredIdentifiers {
            if let v = AVSpeechSynthesisVoice(identifier: id) {
                resolved = v
                break
            }
        }
        if resolved == nil {
            resolved = AVSpeechSynthesisVoice.speechVoices().first(where: {
                $0.language.hasPrefix("fr") && $0.name.lowercased().contains("audrey")
            }) ?? AVSpeechSynthesisVoice(language: "fr-FR")
        }
        guard let v = resolved else {
            fputs("❌ No French voice available.\n", stderr)
            exit(1)
        }
        self.voice = v
        self.aacSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: targetSampleRate,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 48000,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        print("🎙️ Using Meemaw Voice: \(v.name) (\(v.identifier))")
    }

    func synthesizeToM4A(text: String, rate: Float = 0.51, outputURL: URL) throws {
        let spoken = text
            .replacingOccurrences(of: "Meemaw", with: "Mimeau")
            .replacingOccurrences(of: "meemaw", with: "mimeau")
            .replacingOccurrences(of: "Xabi", with: "Chabi")
            .replacingOccurrences(of: "xabi", with: "Chabi")
            .replacingOccurrences(of: "XABI", with: "Chabi")
            .replacingOccurrences(of: "Quoizzi-Quoissa", with: "Kouazi Kouassa")
            .replacingOccurrences(of: "___", with: "…")
            .replacingOccurrences(of: "💡", with: "")
            .replacingOccurrences(of: "÷", with: " divisé par ")
            .replacingOccurrences(of: "×", with: " fois ")

        let utterance = AVSpeechUtterance(string: spoken)
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0

        var collected: [AVAudioPCMBuffer] = []
        var isDone = false

        synth.write(utterance) { buffer in
            guard let pcm = buffer as? AVAudioPCMBuffer else { return }
            if pcm.frameLength == 0 {
                isDone = true
                return
            }
            if let copy = AVAudioPCMBuffer(pcmFormat: pcm.format, frameCapacity: pcm.frameLength) {
                copy.frameLength = pcm.frameLength
                copy.floatChannelData![0].update(from: pcm.floatChannelData![0], count: Int(pcm.frameLength))
                collected.append(copy)
            }
        }

        let start = Date()
        while !isDone && Date().timeIntervalSince(start) < 25.0 {
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.004))
        }

        guard !collected.isEmpty else { return }
        let totalFrames = collected.reduce(0) { $0 + $1.frameLength }
        let format = collected[0].format
        guard let combined = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else { return }
        combined.frameLength = totalFrames

        var offset: AVAudioFrameCount = 0
        for b in collected {
            combined.floatChannelData![0].advanced(by: Int(offset)).update(from: b.floatChannelData![0], count: Int(b.frameLength))
            offset += b.frameLength
        }

        if totalFrames > 500 {
            let ptr = combined.floatChannelData![0]
            var maxSample: Float = 0.0
            for i in 0..<Int(totalFrames) {
                let v = abs(ptr[i])
                if v > maxSample { maxSample = v }
            }
            if maxSample > 0.05 {
                let gain: Float = 0.89125 / maxSample
                for i in 0..<Int(totalFrames) { ptr[i] *= gain }
            }
        }

        try? FileManager.default.removeItem(at: outputURL)
        let audioFile = try AVAudioFile(forWriting: outputURL, settings: aacSettings)
        try audioFile.write(from: combined)
    }
}

// MARK: - Retro-Pop TV Jingle Generator (Synthesized Chords & Melodies)

struct NoteEvent {
    var freqs: [Double]
    var duration: Double
    var volume: Double
}

func writeSynthesizedJingleWAV(notes: [NoteEvent], to url: URL) throws {
    let sampleRate = 22050
    var pcm: [Int16] = []

    for note in notes {
        let count = max(1, Int(Double(sampleRate) * note.duration))
        for i in 0..<count {
            let t = Double(i) / Double(sampleRate)
            let norm = Double(i) / Double(count)
            // Attack-decay envelope
            let attack = min(1.0, norm / 0.08)
            let release = max(0.0, 1.0 - pow(norm, 1.8))
            let env = attack * release

            var sample = 0.0
            for f in note.freqs where f > 0 {
                // Warm electric organ + brass overtone
                let fundamental = sin(2.0 * .pi * f * t)
                let harmonic2 = 0.35 * sin(2.0 * .pi * (f * 2.0) * t)
                let harmonic3 = 0.15 * sin(2.0 * .pi * (f * 3.0) * t)
                sample += (fundamental + harmonic2 + harmonic3) / Double(note.freqs.count)
            }
            let val = max(-1.0, min(1.0, sample * env * note.volume))
            pcm.append(Int16(val * 30000.0))
        }
    }

    let dataSize = pcm.count * 2
    var wav = Data()
    wav.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
    var fileSize = UInt32(36 + dataSize).littleEndian
    wav.append(Data(bytes: &fileSize, count: 4))
    wav.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"
    wav.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // "fmt "
    var fmtSize = UInt32(16).littleEndian
    wav.append(Data(bytes: &fmtSize, count: 4))
    var format = UInt16(1).littleEndian
    wav.append(Data(bytes: &format, count: 2))
    var channels = UInt16(1).littleEndian
    wav.append(Data(bytes: &channels, count: 2))
    var sr = UInt32(sampleRate).littleEndian
    wav.append(Data(bytes: &sr, count: 4))
    var byteRate = UInt32(sampleRate * 2).littleEndian
    wav.append(Data(bytes: &byteRate, count: 4))
    var align = UInt16(2).littleEndian
    wav.append(Data(bytes: &align, count: 2))
    var bits = UInt16(16).littleEndian
    wav.append(Data(bytes: &bits, count: 2))
    wav.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
    var dSize = UInt32(dataSize).littleEndian
    wav.append(Data(bytes: &dSize, count: 4))
    pcm.withUnsafeBufferPointer { ptr in
        wav.append(UnsafeBufferPointer(
            start: UnsafeRawPointer(ptr.baseAddress)?.assumingMemoryBound(to: UInt8.self),
            count: dataSize
        ))
    }
    try wav.write(to: url)
}

// MARK: - Main Execution

@main
enum AudioGenMain {
    static func main() throws {
        let outDir = URL(fileURLWithPath: "/Users/xabi/DEV/MeemawQuizz/App/Resources/MeemawQuizzAudio")
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

        // 1. Generate TV Show Jingles & SFX
        print("🎵 Generating TV Show Jingles & SFX...")
        try writeSynthesizedJingleWAV(
            notes: [
                NoteEvent(freqs: [261.63, 329.63, 392.00], duration: 0.14, volume: 0.65),
                NoteEvent(freqs: [329.63, 392.00, 493.88], duration: 0.14, volume: 0.68),
                NoteEvent(freqs: [392.00, 493.88, 587.33], duration: 0.14, volume: 0.72),
                NoteEvent(freqs: [523.25, 659.25, 783.99, 1046.50], duration: 0.48, volume: 0.80)
            ],
            to: outDir.appendingPathComponent("jingle_intro.wav")
        )

        try writeSynthesizedJingleWAV(
            notes: [
                NoteEvent(freqs: [440.0, 554.37], duration: 0.11, volume: 0.75),
                NoteEvent(freqs: [587.33, 739.99], duration: 0.11, volume: 0.75),
                NoteEvent(freqs: [440.0, 554.37], duration: 0.11, volume: 0.75),
                NoteEvent(freqs: [880.0, 1108.73], duration: 0.35, volume: 0.85)
            ],
            to: outDir.appendingPathComponent("jingle_solo_siren.wav")
        )

        try writeSynthesizedJingleWAV(
            notes: [
                NoteEvent(freqs: [349.23, 440.00], duration: 0.12, volume: 0.65),
                NoteEvent(freqs: [392.00, 493.88], duration: 0.12, volume: 0.65),
                NoteEvent(freqs: [440.00, 554.37], duration: 0.12, volume: 0.70),
                NoteEvent(freqs: [523.25, 659.25], duration: 0.28, volume: 0.75)
            ],
            to: outDir.appendingPathComponent("jingle_couci.wav")
        )

        try writeSynthesizedJingleWAV(
            notes: [
                NoteEvent(freqs: [523.25, 659.25], duration: 0.12, volume: 0.75),
                NoteEvent(freqs: [659.25, 783.99], duration: 0.12, volume: 0.78),
                NoteEvent(freqs: [783.99, 1046.50], duration: 0.40, volume: 0.85)
            ],
            to: outDir.appendingPathComponent("sfx_correct.wav")
        )

        try writeSynthesizedJingleWAV(
            notes: [
                NoteEvent(freqs: [311.13, 293.66], duration: 0.18, volume: 0.70),
                NoteEvent(freqs: [233.08, 220.00], duration: 0.36, volume: 0.75)
            ],
            to: outDir.appendingPathComponent("sfx_wrong.wav")
        )

        try writeSynthesizedJingleWAV(
            notes: [
                NoteEvent(freqs: [783.99, 987.77], duration: 0.09, volume: 0.85),
                NoteEvent(freqs: [1046.50, 1318.51], duration: 0.22, volume: 0.90)
            ],
            to: outDir.appendingPathComponent("sfx_buzz.wav")
        )

        try writeSynthesizedJingleWAV(
            notes: [
                NoteEvent(freqs: [523.25, 659.25, 783.99], duration: 0.16, volume: 0.75),
                NoteEvent(freqs: [587.33, 739.99, 880.00], duration: 0.16, volume: 0.78),
                NoteEvent(freqs: [659.25, 830.61, 987.77], duration: 0.16, volume: 0.82),
                NoteEvent(freqs: [783.99, 987.77, 1174.66, 1567.98], duration: 0.65, volume: 0.88)
            ],
            to: outDir.appendingPathComponent("jingle_victory.wav")
        )

        // 2. Generate Meemaw Studio Voice Cues & Questions
        let synth = MeemawStudioSynthesizer()
        var count = 0

        for cue in MeemawPunchlines.studioCues {
            let url = outDir.appendingPathComponent(cue.filename)
            try synth.synthesizeToM4A(text: cue.text, outputURL: url)
            count += 1
        }

        let winPrefixes = [
            "Bravo, dans le mille !",
            "Joli coup mon petit chou !",
            "Chapeau l'artiste, c'est la bonne réponse !",
            "Hop là, bien joué !",
            "Quel réflexe, c'est tout bon !",
            "Boum, exactement ça !"
        ]

        let forceRegenerateIDs: Set<String> = [
            "q_FR_17", "q_FR_18", "q_FR_19", "q_FR_20",
            "q_MATH_17", "q_MATH_18", "q_MATH_19", "q_MATH_20",
            "q_CINE_19", "q_CINE_22", "q_CINE_25", "q_CINE_26", "q_CINE_27", "q_CINE_28",
            "q_MUS_25", "q_MUS_26", "q_MUS_27", "q_MUS_28", "q_MUS_29",
            "q_MUS_30", "q_MUS_31", "q_MUS_32", "q_MUS_33", "q_MUS_34",
            "q_JUK_01", "q_JUK_02", "q_JUK_03", "q_JUK_04", "q_JUK_05", "q_JUK_06",
            "q_JUK_07", "q_JUK_08", "q_JUK_09", "q_JUK_10", "q_JUK_11", "q_JUK_12",
            "q_CUL_17", "q_CUL_18", "q_CUL_19", "q_CUL_20", "q_CUL_21", "q_CUL_22",
            "q_ECO_17", "q_ECO_18", "q_ECO_19", "q_ECO_20"
        ]

        let allQuestions = QuestionBank.questions(for: .grandMix)
        for (idx, q) in allQuestions.enumerated() {
            let cueID = q.audioCueID ?? "q_\(q.id)"
            let force = forceRegenerateIDs.contains(cueID)

            let promptURL = outDir.appendingPathComponent("\(cueID).m4a")
            if force || !FileManager.default.fileExists(atPath: promptURL.path) {
                let fullSpoken = "\(q.funnyTitle). \(q.prompt)"
                try synth.synthesizeToM4A(text: fullSpoken, outputURL: promptURL)
            }

            let roastURL = outDir.appendingPathComponent("\(cueID)_roast.m4a")
            if force || !FileManager.default.fileExists(atPath: roastURL.path) {
                let fullRoast = "\(q.meemawRoastOnWrong) \(q.explanation)"
                try synth.synthesizeToM4A(text: fullRoast, outputURL: roastURL)
            }

            let winURL = outDir.appendingPathComponent("\(cueID)_win.m4a")
            if force || !FileManager.default.fileExists(atPath: winURL.path) {
                let prefix = winPrefixes[idx % winPrefixes.count]
                let fullWin = "\(prefix) \(q.explanation)"
                try synth.synthesizeToM4A(text: fullWin, outputURL: winURL)
            }

            let ttmcURL = outDir.appendingPathComponent("\(cueID)_ttmc.m4a")
            if force || !FileManager.default.fileExists(atPath: ttmcURL.path) {
                let ttmcText = "Tu te mets combien, de une à quatre étoiles, sur : \(q.funnyTitle) ?"
                try synth.synthesizeToM4A(text: ttmcText, outputURL: ttmcURL)
            }

            count += 4
        }

        let forceRegenerateDod: Set<String> = ["rac_MUS_2", "rac_CINE_2"]
        for dod in QuestionBank.allDisOrDatRounds {
            if let cueID = dod.audioCueID {
                let dodURL = outDir.appendingPathComponent("\(cueID).m4a")
                if forceRegenerateDod.contains(cueID) || !FileManager.default.fileExists(atPath: dodURL.path) {
                    let fullSpoken = "\(dod.funnyTitle). \(dod.prompt)"
                    try synth.synthesizeToM4A(text: fullSpoken, outputURL: dodURL)
                }
                count += 1
            }
        }

        print("✅ Successfully generated \(count) Meemaw studio .m4a voice files and 7 TV show jingles in \(outDir.path)")
    }
}
