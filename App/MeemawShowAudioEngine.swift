@preconcurrency import AVFoundation
import AudioToolbox
import Foundation
import Observation
import UIKit

/// Moteur Audio 2-Tier du Show MeemawQuizz :
/// 1. Priorité 1 : Fichiers `.m4a` Studio pré-générés avec la voix Audrey Premium de Meemaw.
/// 2. Priorité 2 : Synthèse vocale dynamique en direct (`AVSpeechSynthesizer` voix féminine Audrey) pour lire les pseudos des joueurs.
/// 3. Jingles TV rétro-pop (`jingle_intro.wav`, `jingle_solo_siren.wav`, `jingle_couci.wav`, `jingle_victory.wav`, `sfx_buzz.wav`, `sfx_correct.wav`, `sfx_wrong.wav`) + musique d'ambiance douce.
enum BackgroundMusicMood: String {
    case chillLobby = "The_Quiet_Podium.mp3"
    case fastAction = "Velvet_Strategy.mp3"
}

@Observable
@MainActor
final class MeemawShowAudioEngine: NSObject {
    static let shared = MeemawShowAudioEngine()

    private(set) var isMeemawSpeaking: Bool = false
    private(set) var currentMood: BackgroundMusicMood = .chillLobby
    var isMusicMuted: Bool = false {
        didSet {
            if isMusicMuted {
                bgMusicPlayer?.pause()
            } else {
                startBackgroundGroove(ducked: isMeemawSpeaking)
            }
        }
    }

    private var voicePlayer: AVAudioPlayer?
    private var jinglePlayer: AVAudioPlayer?
    private var preloadedJingles: [String: AVAudioPlayer] = [:]
    private var bgMusicPlayer: AVAudioPlayer?
    private var activeBgTrackFilename: String?
    private let synthesizer = AVSpeechSynthesizer()
    private var cachedFrenchVoice: AVSpeechSynthesisVoice?
    private var didResolveVoice = false
    private var onVoiceCompletion: (() -> Void)?
    private var audioSessionReady = false

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func ensureAudioSession() {
        guard !audioSessionReady else { return }
        audioSessionReady = true
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.allowAirPlay, .mixWithOthers])
        try? session.setActive(true)
        preloadCommonJingles()
    }

    private func preloadCommonJingles() {
        let common = [
            "jingle_intro.wav",
            "jingle_solo_siren.wav",
            "jingle_couci.wav",
            "jingle_victory.wav",
            "sfx_buzz.wav",
            "sfx_correct.wav",
            "sfx_wrong.wav"
        ]
        for file in common where preloadedJingles[file] == nil {
            if let url = resolveAudioURL(named: file),
               let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                preloadedJingles[file] = player
            }
        }
    }

    func resolveAudioURL(named filename: String) -> URL? {
        let ns = filename as NSString
        let ext = ns.pathExtension
        let base = ns.deletingPathExtension

        if let url = Bundle.main.url(forResource: base, withExtension: ext, subdirectory: "MeemawQuizzAudio") {
            return url
        }
        if let url = Bundle.main.url(forResource: base, withExtension: ext) {
            return url
        }
        if let res = Bundle.main.resourceURL {
            let direct = res.appendingPathComponent("MeemawQuizzAudio").appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: direct.path) {
                return direct
            }
        }
        let devPath = "/Users/xabi/DEV/MeemawQuizz/App/Resources/MeemawQuizzAudio/\(filename)"
        if FileManager.default.fileExists(atPath: devPath) {
            return URL(fileURLWithPath: devPath)
        }
        return nil
    }

    func setMusicMood(_ mood: BackgroundMusicMood) {
        currentMood = mood
        startBackgroundGroove(ducked: isMeemawSpeaking)
    }

    func startBackgroundGroove(ducked: Bool = false) {
        ensureAudioSession()
        guard !isMusicMuted else { return }
        let targetVol: Float = ducked ? 0.08 : (currentMood == .fastAction ? 0.30 : 0.25)
        let desiredFilename = currentMood.rawValue

        if let player = bgMusicPlayer, activeBgTrackFilename == desiredFilename {
            if !player.isPlaying {
                player.volume = targetVol
                player.play()
            } else {
                player.setVolume(targetVol, fadeDuration: 0.45)
            }
            return
        }

        bgMusicPlayer?.stop()
        bgMusicPlayer = nil
        guard let url = resolveAudioURL(named: desiredFilename),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.numberOfLoops = -1
        player.volume = targetVol
        player.prepareToPlay()
        player.play()
        bgMusicPlayer = player
        activeBgTrackFilename = desiredFilename
    }

    func playJingle(_ filename: String, volume: Float = 0.85) {
        ensureAudioSession()
        if let cached = preloadedJingles[filename] {
            cached.stop()
            cached.currentTime = 0
            cached.volume = volume
            cached.play()
            jinglePlayer = cached
            return
        }
        guard let url = resolveAudioURL(named: filename),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.volume = volume
        player.prepareToPlay()
        player.play()
        preloadedJingles[filename] = player
        jinglePlayer = player
    }

    /// Joue un fichier `.m4a` studio pré-généré de Meemaw (100% voix Audrey Premium studio, zéro voix robotique iOS).
    func playMeemawStudioOrFallback(
        studioFilename: String?,
        fallbackText: String,
        completion: (() -> Void)? = nil
    ) {
        ensureAudioSession()
        stopVoiceOnly()
        onVoiceCompletion = completion
        startBackgroundGroove(ducked: true)

        if let studioFilename,
           let url = resolveAudioURL(named: studioFilename),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.delegate = self
            player.volume = 1.0
            player.prepareToPlay()
            isMeemawSpeaking = true
            player.play()
            voicePlayer = player
            return
        }

        // Never use the robotic iOS compact TTS voice; finish cleanly if a file is not found.
        finishVoiceTurn()
    }

    /// Synthèse vocale dynamique avec la voix féminine Audrey (pour prononcer les pseudos des joueurs en direct).
    func speakDynamicPlayerCallout(_ text: String, completion: (() -> Void)? = nil) {
        ensureAudioSession()
        stopVoiceOnly()
        onVoiceCompletion = completion
        startBackgroundGroove(ducked: true)
        speakDynamicAudrey(text)
    }

    func stopVoiceOnly() {
        onVoiceCompletion = nil
        voicePlayer?.stop()
        voicePlayer = nil
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isMeemawSpeaking = false
    }

    func triggerControllerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.impactOccurred()
        AudioServicesPlaySystemSound(1104)
    }

    private func speakDynamicAudrey(_ text: String) {
        let spoken = text
            .replacingOccurrences(of: "Meemaw", with: "Mimeau")
            .replacingOccurrences(of: "meemaw", with: "mimeau")
            .replacingOccurrences(of: "Xabi", with: "Chabi")
            .replacingOccurrences(of: "xabi", with: "Chabi")
            .replacingOccurrences(of: "XABI", with: "Chabi")
            .replacingOccurrences(of: "Quoizzi-Quoissa", with: "Kouazi Kouassa")
            .replacingOccurrences(of: "___", with: "…")

        let utterance = AVSpeechUtterance(string: spoken)
        if !didResolveVoice {
            didResolveVoice = true
            let preferred = [
                "com.apple.voice.premium.fr-FR.Audrey",
                "com.apple.voice.enhanced.fr-FR.Audrey",
                "com.apple.ttsbundle.Audrey-premium"
            ]
            for id in preferred {
                if let v = AVSpeechSynthesisVoice(identifier: id) {
                    cachedFrenchVoice = v
                    break
                }
            }
            if cachedFrenchVoice == nil {
                cachedFrenchVoice = AVSpeechSynthesisVoice.speechVoices().first(where: {
                    $0.language.hasPrefix("fr") && ($0.name.lowercased().contains("audrey") || $0.gender == .female)
                }) ?? AVSpeechSynthesisVoice(language: "fr-FR")
            }
        }
        utterance.voice = cachedFrenchVoice
        utterance.rate = 0.52
        isMeemawSpeaking = true
        synthesizer.speak(utterance)
    }

    private func finishVoiceTurn() {
        isMeemawSpeaking = false
        startBackgroundGroove(ducked: false)
        let cb = onVoiceCompletion
        onVoiceCompletion = nil
        cb?()
    }
}

extension MeemawShowAudioEngine: AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            if player === self.voicePlayer {
                self.finishVoiceTurn()
            }
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.finishVoiceTurn()
        }
    }
}
