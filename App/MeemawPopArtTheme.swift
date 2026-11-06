import AVFoundation
import MeemawQuizzCore
import SwiftUI
import UIKit

// MARK: - Meemaw TV Quiz Show Studio Design System (Aligned with App Icon: Royal Studio Blue, Spotlight Gold & Copper Amber)

enum PopArt {
    static let studioNavy = Color(hex: "#121A2F")
    static let studioRoyal = Color(hex: "#1B2A4A")
    static let orange = Color(hex: "#D97736")      // Warm Terracotta-Amber (refined, non-neon)
    static let orangeLight = Color(hex: "#E8955B")
    static let cream = Color(hex: "#F6F4EE")       // Soft Warm Alabaster surface
    static let ink = Color(hex: "#182235")         // Deep Slate-Navy text & border (softer than pure black)
    static let white = Color(hex: "#FCFBF8")       // Warm Ivory-White (no harsh screen glare)
    static let greenSuccess = Color(hex: "#238A66") // Refined Sage-Emerald
    static let redError = Color(hex: "#C84B5F")    // Softened Coral-Crimson
    static let yellow = Color(hex: "#F2CD78")      // Soft Champagne Gold (replaces loud bright yellow)
    static let cyan = Color(hex: "#3A7CA5")        // Calm Steel-Blue
    static let purple = Color(hex: "#4A588A")      // Muted Slate-Indigo
    static let pink = Color(hex: "#B85672")        // Muted Rose-Berry
    static let blue = Color(hex: "#385E9D")        // Calm Studio Blue

    static func color(for playerColor: PlayerColor) -> Color {
        Color(hex: playerColor.hex)
    }

    @MainActor
    static func triggerLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 140, 66)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Halftone Comic Dot Pattern

struct HalftonePattern: View {
    var dotColor: Color = .black.opacity(0.07)
    var dotSize: CGFloat = 4
    var spacing: CGFloat = 14

    var body: some View {
        Canvas { context, size in
            let rows = Int(size.height / spacing) + 1
            let cols = Int(size.width / spacing) + 1
            for row in 0..<rows {
                for col in 0..<cols {
                    let x = CGFloat(col) * spacing + (row.isMultiple(of: 2) ? spacing / 2 : 0)
                    let y = CGFloat(row) * spacing
                    let rect = CGRect(x: x - dotSize / 2, y: y - dotSize / 2, width: dotSize, height: dotSize)
                    context.fill(Circle().path(in: rect), with: .color(dotColor))
                }
            }
        }
    }
}

struct PopArtTVBackground: View {
    var roundKind: QuizRoundKind

    var body: some View {
        ZStack {
            // Calm, deep velvet studio navy background (Impeccable quieter palette)
            LinearGradient(
                colors: [
                    Color(hex: "#192642"),
                    Color(hex: "#111A2E"),
                    Color(hex: "#0B1120")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Gentle, understated warm top ambient light
            RadialGradient(
                colors: [
                    PopArt.yellow.opacity(0.11),
                    PopArt.orange.opacity(0.04),
                    Color.clear
                ],
                center: .top,
                startRadius: 10,
                endRadius: 360
            )
            .ignoresSafeArea()

            HalftonePattern(dotColor: PopArt.white.opacity(0.025), dotSize: 3, spacing: 20)
                .drawingGroup()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Comic Card & Button Styles

struct PopArtCard<Content: View>: View {
    var cornerRadius: CGFloat = 18
    var borderWidth: CGFloat = 2
    var backgroundColor: Color = PopArt.white
    var shadowOffset: CGFloat = 3
    @ViewBuilder let content: Content

    var body: some View {
        let effectiveBorder = min(2.2, borderWidth)
        let effectiveShadow = min(3.5, shadowOffset)
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(PopArt.ink.opacity(0.45))
                            .offset(x: 0, y: effectiveShadow)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(PopArt.ink.opacity(0.82), lineWidth: effectiveBorder)
            )
    }
}

struct PopArtActionButtonStyle: ButtonStyle {
    var backgroundColor: Color = PopArt.orange
    var foregroundColor: Color = PopArt.ink
    var cornerRadius: CGFloat = 15

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(PopArt.ink.opacity(0.45))
                            .offset(y: configuration.isPressed ? 1 : 3)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(PopArt.ink.opacity(0.82), lineWidth: 2)
            )
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
                    PopArt.triggerLightHaptic()
                }
            }
    }
}

// MARK: - Smooth Meemaw Video Loop Player (Single Layer, Zero Flicker, Single Character)

struct MascotVideoLoopView: UIViewRepresentable {
    let url: URL
    var isPlaying: Bool = true
    var rate: Float = 0.72

    func makeUIView(context: Context) -> MascotPlayerUIView {
        let view = MascotPlayerUIView()
        view.configure(url: url, isPlaying: isPlaying, rate: rate)
        return view
    }

    func updateUIView(_ uiView: MascotPlayerUIView, context: Context) {
        uiView.configure(url: url, isPlaying: isPlaying, rate: rate)
    }

    static func dismantleUIView(_ uiView: MascotPlayerUIView, coordinator: ()) {
        uiView.tearDown()
    }
}

@MainActor
final class MascotPlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var currentURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.pixelBufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(url: URL, isPlaying: Bool, rate: Float) {
        if currentURL != url {
            tearDown()
            currentURL = url
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            let qp = AVQueuePlayer()
            qp.isMuted = true
            qp.preventsDisplaySleepDuringVideoPlayback = false
            qp.defaultRate = rate
            looper = AVPlayerLooper(player: qp, templateItem: item)
            queuePlayer = qp
            playerLayer.player = qp
            // Advance to first frame immediately so layer is ready even when paused
            qp.playImmediately(atRate: rate)
            if !isPlaying {
                qp.pause()
            }
            return
        }
        guard let queuePlayer else { return }
        if isPlaying {
            if queuePlayer.timeControlStatus != .playing {
                queuePlayer.playImmediately(atRate: rate)
            }
        } else {
            if queuePlayer.timeControlStatus == .playing {
                queuePlayer.pause()
            }
        }
    }

    func tearDown() {
        queuePlayer?.pause()
        looper?.disableLooping()
        looper = nil
        queuePlayer = nil
        playerLayer.player = nil
        currentURL = nil
    }
}

// MARK: - Meemaw Guest Star Animated Avatar (Single Stable Portrait / Video Loop)

struct MeemawGuestStarAvatar: View {
    let pose: String
    let isSpeaking: Bool
    var size: CGFloat = 130

    private static let talkVideoURL: URL? = MeemawShowAudioEngine.shared.resolveAudioURL(
        named: "meemaw_dictation_talk_talk.mov"
    )

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [PopArt.yellow, PopArt.orange],
                        center: .center,
                        startRadius: 4,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)

            if let url = Self.talkVideoURL {
                MascotVideoLoopView(url: url, isPlaying: isSpeaking, rate: 0.72)
                    .frame(width: size - 8, height: size - 8)
                    .clipShape(Circle())
            } else {
                Image("meemaw_salut")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size - 8, height: size - 8)
                    .clipShape(Circle())
            }

            Circle()
                .strokeBorder(PopArt.ink, lineWidth: 4)
                .frame(width: size, height: size)

            if isSpeaking {
                Text("🎙️")
                    .font(.system(size: max(12, size * 0.16)))
                    .padding(4)
                    .background(PopArt.redError, in: Circle())
                    .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2))
                    .offset(x: 2, y: 2)
            }
        }
        .frame(width: size, height: size)
    }
}
