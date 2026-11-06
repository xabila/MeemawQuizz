import AVFoundation
import MeemawQuizzCore
import SwiftUI
import UIKit

// MARK: - Meemaw TV Quiz Show Studio Design System (100% Aligned with App Icon: Royal Studio Blue, Marquee Gold, Copper-Orange & Buzzer Red)

enum PopArt {
    static let studioDeep = Color(hex: "#050E30")  // Deep Midnight Stage Blue (bottom of App Icon)
    static let studioNavy = Color(hex: "#0B1D56")  // Mid Royal Studio Blue (App Icon backdrop)
    static let studioRoyal = Color(hex: "#173B9A") // Bright Royal Studio Blue (top of App Icon)
    static let goldTrim = Color(hex: "#D99B38")    // Warm Brass/Gold Trim (App Icon marquee arch & lapels)
    static let orange = Color(hex: "#F26B1D")      // Warm Copper-Orange (Meemaw hair & "QUIZ" card in App Icon)
    static let orangeLight = Color(hex: "#FB8C3E")
    static let cream = Color(hex: "#FFFBF2")       // Warm Champagne Ivory surface
    static let ink = Color(hex: "#081438")         // Deep Royal Navy-Black border
    static let white = Color(hex: "#FFFFFF")       // Crisp Studio White (Meemaw shirt collar)
    static let greenSuccess = Color(hex: "#10B981") // Emerald Green (Green card in Meemaw's hand)
    static let redError = Color(hex: "#E11D48")    // Glossy TV Buzzer Crimson Red (App Icon desk buzzer)
    static let yellow = Color(hex: "#F5C451")      // Spotlight Marquee Gold (Microphone, Bow Tie & Arch bulbs)
    static let cyan = Color(hex: "#0EA5E9")        // Podium Rim Cyan-Blue (App Icon glowing desk rim)
    static let purple = Color(hex: "#1E40AF")      // Deep Royal Blazer Blue (replaces off-brand purple)
    static let pink = Color(hex: "#D92332")        // Studio Buzzer Red (replaces off-brand neon pink)
    static let blue = Color(hex: "#1D4ED8")        // Meemaw Glitter Royal Blue Blazer

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
            // Exact App Icon Royal TV Studio Blue gradient (#173B9A -> #0B1D56 -> #050E30)
            LinearGradient(
                colors: [
                    PopArt.studioRoyal,
                    PopArt.studioNavy,
                    PopArt.studioDeep
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Top Golden Marquee Arch Spotlight Glow (matching the App Icon's golden bulb arch)
            RadialGradient(
                colors: [
                    PopArt.yellow.opacity(0.28),
                    PopArt.orange.opacity(0.12),
                    Color.clear
                ],
                center: .top,
                startRadius: 12,
                endRadius: 380
            )
            .ignoresSafeArea()

            // Bottom Podium Cyan Rim Glow (matching the App Icon's glowing cyan studio desk)
            RadialGradient(
                colors: [
                    PopArt.cyan.opacity(0.18),
                    PopArt.blue.opacity(0.08),
                    Color.clear
                ],
                center: .bottom,
                startRadius: 10,
                endRadius: 320
            )
            .ignoresSafeArea()

            HalftonePattern(dotColor: PopArt.white.opacity(0.04), dotSize: 3.5, spacing: 18)
                .drawingGroup()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Studio Card & Button Styles (App Icon Gold & Royal Navy Trim)

struct PopArtCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var borderWidth: CGFloat = 2.5
    var backgroundColor: Color = PopArt.white
    var shadowOffset: CGFloat = 4
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(PopArt.ink.opacity(0.65))
                            .offset(x: 0, y: shadowOffset)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(PopArt.ink, lineWidth: borderWidth)
            )
    }
}

struct PopArtActionButtonStyle: ButtonStyle {
    var backgroundColor: Color = PopArt.orange
    var foregroundColor: Color = PopArt.ink
    var cornerRadius: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(PopArt.ink.opacity(0.7))
                            .offset(y: configuration.isPressed ? 1 : 3.5)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(PopArt.ink, lineWidth: 2.2)
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

// MARK: - Meemaw Guest Star Animated Avatar (App Icon Golden Marquee Stage Ring)

struct MeemawGuestStarAvatar: View {
    let pose: String
    let isSpeaking: Bool
    var size: CGFloat = 130

    private static let talkVideoURL: URL? = MeemawShowAudioEngine.shared.resolveAudioURL(
        named: "meemaw_dictation_talk_talk.mov"
    )

    private var poseBadgeEmoji: String {
        if isSpeaking { return "🎙️" }
        if pose.contains("boxing") { return "🥊" }
        if pose.contains("trophy") || pose.contains("celebrate") || pose.contains("victory") { return "🏆" }
        if pose.contains("vitesse") { return "⚡️" }
        if pose.contains("duel") { return "🎯" }
        return "🎙️"
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Outer App Icon Golden Marquee Arch Ring
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FFE082"), PopArt.yellow, PopArt.goldTrim],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: PopArt.yellow.opacity(isSpeaking ? 0.55 : 0.25), radius: isSpeaking ? 8 : 4, y: 2)

            // Inner Royal Studio Blue & Gold Halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [PopArt.yellow, PopArt.orange, PopArt.studioRoyal],
                        center: .center,
                        startRadius: 2,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size - 8, height: size - 8)

            if let url = Self.talkVideoURL {
                MascotVideoLoopView(url: url, isPlaying: isSpeaking, rate: 0.72)
                    .frame(width: size - 10, height: size - 10)
                    .clipShape(Circle())
            } else {
                Image("meemaw_studio_icon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size - 10, height: size - 10)
                    .clipShape(Circle())
            }

            // Crisp Studio Ring Border
            Circle()
                .strokeBorder(PopArt.ink, lineWidth: max(2.5, size * 0.032))
                .frame(width: size, height: size)

            // Inner Gold Pinstripe
            Circle()
                .strokeBorder(PopArt.yellow, lineWidth: max(1.5, size * 0.02))
                .frame(width: size - 5, height: size - 5)

            // Studio Mic / Pose Badge
            Text(poseBadgeEmoji)
                .font(.system(size: max(12, size * 0.17)))
                .padding(max(4, size * 0.045))
                .background(isSpeaking ? PopArt.redError : PopArt.blue, in: Circle())
                .overlay(Circle().strokeBorder(PopArt.yellow, lineWidth: 2))
                .shadow(color: PopArt.ink.opacity(0.5), radius: 2, y: 1)
                .offset(x: 2, y: 2)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Meemaw 3D Studio Character Artwork (App Icon, Boxing Referee, Score Clipboard, Trophy)

struct MeemawPoseIllustration: View {
    var assetName: String = "meemaw_studio_icon"
    var size: CGFloat = 72
    var isCircularStage: Bool = false

    var body: some View {
        if isCircularStage {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .strokeBorder(PopArt.yellow, lineWidth: 2.5)
                )
                .shadow(color: PopArt.ink.opacity(0.45), radius: 4, y: 2)
        } else {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: PopArt.ink.opacity(0.35), radius: 3, y: 2)
        }
    }
}
