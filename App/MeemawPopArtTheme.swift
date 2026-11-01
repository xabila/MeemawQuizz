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
        case .leSolo: Color(hex: "#FFE4E8")
        case .couciCouca: Color(hex: "#E0F7FA")
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

// MARK: - Meemaw Guest Star Animated Avatar

struct MeemawGuestStarAvatar: View {
    let pose: String
    let isSpeaking: Bool
    var size: CGFloat = 130

    private var resolvedAssetName: String {
        let candidates = [
            pose,
            "meemaw_salut",
            "meemaw_fun",
            "meemaw_holding_trophy",
            "meemaw_boxing_referee",
            "meemaw_duel_challenge",
            "meemaw_vitesse"
        ]
        for name in candidates where UIImage(named: name) != nil {
            return name
        }
        return "meemaw_salut"
    }

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
                .overlay(
                    Circle().strokeBorder(PopArt.ink, lineWidth: 4.5)
                )
                .shadow(color: PopArt.ink, radius: 0, x: 0, y: 6)

            Image(resolvedAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: size - 10, height: size - 10)
                .clipShape(Circle())
                .scaleEffect(isSpeaking ? 1.05 : 1.0)
                .animation(
                    isSpeaking
                        ? .easeInOut(duration: 0.28).repeatForever(autoreverses: true)
                        : .default,
                    value: isSpeaking
                )

            if isSpeaking {
                Text("🎙️ ON AIR")
                    .font(.system(size: max(10, size * 0.09), weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(PopArt.redError, in: Capsule())
                    .overlay(Capsule().strokeBorder(PopArt.ink, lineWidth: 2))
                    .offset(x: 4, y: 4)
            }
        }
    }
}
