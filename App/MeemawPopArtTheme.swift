import AVFoundation
import MeemawQuizzCore
import SwiftUI
import UIKit

// MARK: - Meemaw TV Quiz Show Studio Design System (Aligned with App Icon: Royal Studio Blue, Spotlight Gold & Copper Amber)

enum PopArt {
    static let studioNavy = Color(hex: "#111E48")
    static let studioNavyDeep = Color(hex: "#081029")
    static let studioRoyal = Color(hex: "#1E3A8A")
    static let studioGoldRim = Color(hex: "#FDE68A")
    static let orange = Color(hex: "#F97316")      // Warm Copper-Amber ("QUIZ" card & Meemaw hair)
    static let orangeLight = Color(hex: "#FB923C")
    static let cream = Color(hex: "#FFFDF8")       // Clean Warm Ivory surface
    static let ink = Color(hex: "#0F172A")         // Deep Studio Navy-Black border
    static let white = Color.white
    static let greenSuccess = Color(hex: "#10B981")
    static let redError = Color(hex: "#E11D48")    // TV Buzzer Crimson Red
    static let yellow = Color(hex: "#FBBF24")      // Spotlight Gold (Microphone, Bow Tie & Marquee)
    static let cyan = Color(hex: "#0284C7")        // Studio Rim Light Blue
    static let purple = Color(hex: "#1D4ED8")      // Harmonized Royal Studio Blue (replaces neon purple)
    static let pink = Color(hex: "#E11D48")        // Harmonized Buzzer Red (replaces neon candy pink)
    static let blue = Color(hex: "#2563EB")        // Meemaw Blazer Royal Blue

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
            // Cohesive TV Studio Royal Blue background matching the MeemawQuizz App Icon
            LinearGradient(
                colors: [
                    Color(hex: "#1E3A8A"),
                    Color(hex: "#132356"),
                    Color(hex: "#0A1330")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle Golden Marquee Spotlight Glow at top center (like the App Icon arch)
            RadialGradient(
                colors: [
                    PopArt.yellow.opacity(0.28),
                    PopArt.orange.opacity(0.10),
                    Color.clear
                ],
                center: .top,
                startRadius: 8,
                endRadius: 420
            )
            .ignoresSafeArea()

            // Left & Right TV Studio Stage Rim Lights
            RadialGradient(
                colors: [
                    PopArt.cyan.opacity(0.18),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 10,
                endRadius: 320
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    PopArt.orange.opacity(0.15),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 340
            )
            .ignoresSafeArea()

            HalftonePattern(dotColor: PopArt.yellow.opacity(0.065), dotSize: 3.5, spacing: 18)
                .drawingGroup()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Studio Timer Progress Bar (Impeccable Live Countdown)

struct StudioTimerProgressBar: View {
    let timeRemaining: Int
    var maxTime: Int = 20
    var height: CGFloat = 10

    private var fraction: CGFloat {
        guard maxTime > 0 else { return 0 }
        return min(1.0, max(0.0, CGFloat(timeRemaining) / CGFloat(maxTime)))
    }

    private var barColor: Color {
        if timeRemaining <= 5 {
            return PopArt.redError
        } else if timeRemaining <= 10 {
            return PopArt.yellow
        } else {
            return PopArt.greenSuccess
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(PopArt.ink.opacity(0.16))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [barColor.opacity(0.9), barColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(height, geo.size.width * fraction))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .animation(.easeOut(duration: 0.35), value: timeRemaining)
            }
            .overlay(
                Capsule()
                    .strokeBorder(PopArt.ink, lineWidth: 2)
            )
        }
        .frame(height: height)
    }
}

// MARK: - Comic Card & Button Styles

struct PopArtCard<Content: View>: View {
    var cornerRadius: CGFloat = 22
    var borderWidth: CGFloat = 3.5
    var backgroundColor: Color = .white
    var shadowOffset: CGFloat = 6
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .overlay(
                        // Subtle top inner specular highlight for tactile enameled studio plaque feel
                        RoundedRectangle(cornerRadius: max(4, cornerRadius - borderWidth), style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.55), Color.white.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: 1.5
                            )
                            .padding(borderWidth * 0.75)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(PopArt.ink)
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
                    .overlay(
                        RoundedRectangle(cornerRadius: max(4, cornerRadius - 3), style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.42), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: 1.5
                            )
                            .padding(2.5)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(PopArt.ink)
                            .offset(y: configuration.isPressed ? 1 : 5)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(PopArt.ink, lineWidth: 3)
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.68), value: configuration.isPressed)
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
            if isSpeaking {
                Circle()
                    .stroke(PopArt.yellow.opacity(0.65), lineWidth: 3)
                    .frame(width: size + 8, height: size + 8)
                    .shadow(color: PopArt.yellow.opacity(0.5), radius: 8)
            }

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
                .strokeBorder(
                    LinearGradient(
                        colors: [PopArt.studioGoldRim, PopArt.yellow, PopArt.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .frame(width: size - 5, height: size - 5)

            Circle()
                .strokeBorder(PopArt.ink, lineWidth: 3.5)
                .frame(width: size, height: size)

            if isSpeaking {
                HStack(spacing: 2) {
                    Image(systemName: "waveform")
                        .font(.system(size: max(9, size * 0.12), weight: .black))
                        .foregroundStyle(.white)
                }
                .padding(max(4, size * 0.06))
                .background(PopArt.redError, in: Circle())
                .overlay(Circle().strokeBorder(PopArt.ink, lineWidth: 2))
                .offset(x: 2, y: 2)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: size, height: size)
        .animation(.spring(response: 0.28, dampingFraction: 0.75), value: isSpeaking)
    }
}
