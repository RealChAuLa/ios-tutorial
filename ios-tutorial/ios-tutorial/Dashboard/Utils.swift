//
//  utils.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//
import SwiftUI

// MARK: - App Color Palette
extension Color {
    static let appGreen      = Color(red: 88/255,  green: 204/255, blue: 2/255)
    static let appGreenDark  = Color(red: 63/255,  green: 158/255, blue: 0/255)
    static let appBlue       = Color(red: 28/255,  green: 176/255, blue: 246/255)
    static let appBlueDark   = Color(red: 15/255,  green: 130/255, blue: 190/255)
    static let appPurple     = Color(red: 206/255, green: 130/255, blue: 255/255)
    static let appPurpleDark = Color(red: 160/255, green: 90/255,  blue: 210/255)
    static let appGold       = Color(red: 255/255, green: 200/255, blue: 0/255)
    static let appGoldDark   = Color(red: 230/255, green: 165/255, blue: 0/255)
    static let appRed        = Color(red: 255/255, green: 75/255,  blue: 75/255)
    static let appRedDark    = Color(red: 220/255, green: 50/255,  blue: 50/255)
}

// MARK: - Rounded Heavy Font
extension Font {
    /// Chunky rounded font used throughout the app.
    static func appFont(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

extension UIFont {
    static func appRounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }
}

// MARK: - Liquid Glass Card Modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 22
    var tint: Color = .clear

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.7), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 8)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 22, tint: Color = .clear) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, tint: tint))
    }
}

// MARK: - 3D Press Button Style
/// Usage: Button("Continue") { }.buttonStyle(AppButtonStyle(baseColor: .appGreen, shadowColor: .appGreenDark))
struct AppButtonStyle: ButtonStyle {
    var baseColor: Color
    var shadowColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appFont(16))
            .textCase(.uppercase)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(shadowColor)
                        .offset(y: configuration.isPressed ? 0 : 5)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(colors: [baseColor.opacity(0.95), baseColor],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(.white.opacity(0.35), lineWidth: 1)
                        )
                        .offset(y: configuration.isPressed ? 5 : 0)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Ambient Background
struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color.appGreen.opacity(0.08), Color.appBlue.opacity(0.06), Color(uiColor: .systemBackground)]
                : [Color.appGreen.opacity(0.10), Color.appBlue.opacity(0.08), Color(uiColor: .systemBackground)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
