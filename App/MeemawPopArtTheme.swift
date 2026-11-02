import AVFoundation
import MeemawQuizzCore
import SwiftUI
import UIKit

// MARK: - Meemaw Pop-Art TV Show Design System

enum PopArt {
    static let orange = Color(hex: "#FF8C42")
    static let orangeLight = Color(hex: "#FFA64D")
    static let cream = Color(hex: "#FFF8F0")
    static let ink = Color(hex: "#1A1A1A")
    static let white = Color.white
    static let greenSuccess = Color(hex: "#10B981")
    static let redError = Color(hex: "#E11D48")
    static let yellow = Color(hex: "#FFD700")
    static let cyan = Color(hex: "#00ACC1")
    static let purple = Color(hex: "#8E44AD")
    static let pink = Color(hex: "#FF4D94")
    static let blue = Color(hex: "#2563EB")

    static func color(for playerColor: PlayerColor) -> Color {
        Color(hex: playerColor.hex)
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

    private var topColor: Color {
        switch roundKind {
        case .cashSpeed: Color(hex: "#FFF3E0")
        case .tuTeMetsCombien: Color(hex: "#FEF9C3")
        case .jukeboxExpress: Color(hex: "#FCE7F3")
        case .drawSomething: Color(hex: "#ECFDF5")
        case .leSolo: Color(hex: "#FFE4E8")
        case .couciCouca: Color(hex: "#FFF8E1")
        case .quoizziQuoissa: Color(hex: "#E0F7FA")
        case .esquisseTeleArabe: Color(hex: "#F3E8FF")
        case .finaleDouble: Color(hex: "#F3E5F5")
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [topColor, PopArt.cream],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HalftonePattern(dotColor: PopArt.orange.opacity(0.09), dotSize: 4, spacing: 16)
                .drawingGroup()
                .ignoresSafeArea()
        }
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
            .animation(.spring(response: 0.2, dampingFraction: 0.72), value: configuration.isPressed)
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
