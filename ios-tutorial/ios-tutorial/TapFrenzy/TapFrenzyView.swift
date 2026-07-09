//
//  TapFrenzyView.swift
//  ios-tutorial
//
//  TapFrenzy declarative UI: main view, challenge sub-views, and shared header.
//

import SwiftUI

// MARK: - Main View

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyViewModel()

    var body: some View {
        ZStack {
            AppBackground()
            
            VStack {
                if viewModel.isGameActive {
                    challengeView
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    gameOverView
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .padding()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isGameActive)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Game Over

    var gameOverView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.appBlue.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.appBlue)
            }
            .padding(.top, 8)
            
            Text("GAME OVER!")
                .font(.appFont(28))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Final Score")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.score)")
                        .font(.appFont(26))
                        .foregroundColor(.appBlue)
                }
                
                Divider()
                
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.appGold)
                        Text("High Score")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(viewModel.highScore)")
                        .font(.appFont(22))
                        .foregroundColor(.appPurple)
                }
            }
            .padding(18)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(16)
            
            VStack(spacing: 12) {
                Button("PLAY AGAIN") {
                    viewModel.playAgain()
                }
                .buttonStyle(AppButtonStyle(baseColor: .appBlue, shadowColor: .appBlueDark))
                
                ScoreShareButton(
                    gameTitle: "Tap Frenzy",
                    score: viewModel.score,
                    highScore: viewModel.highScore,
                    accentColor: .appPurple,
                    shadowColor: .appPurpleDark
                )
            }
            .padding(.top, 6)
        }
        .padding(24)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 20)
    }

    // MARK: - Challenge Router

    @ViewBuilder
    var challengeView: some View {
        switch viewModel.currentChallenge {
        case .combo:
            ComboChallengeView(viewModel: viewModel)
        case .trapColour:
            TrapColourChallengeView(viewModel: viewModel)
        }
    }
}

// MARK: - Shared Header

struct GameHeader: View {
    let timeRemaining: Int
    let score: Int
    let label: String

    var body: some View {
        HStack {
            // Time remaining pill
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 16, weight: .bold))
                Text("\(timeRemaining)s")
                    .font(.appFont(16))
            }
            .foregroundColor(timeRemaining <= 3 ? .appRed : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(timeRemaining <= 3 ? Color.appRed.opacity(0.15) : Color.primary.opacity(0.06))
            )

            Spacer()

            Text(label)
                .font(.appFont(20))
                .foregroundColor(.primary)

            Spacer()

            // Score pill
            HStack(spacing: 4) {
                Text("PTS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Text("\(score)")
                    .font(.appFont(18))
                    .foregroundColor(.appBlue)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.appBlue.opacity(0.12))
            )
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Challenge 1: Combo System

struct ComboChallengeView: View {
    @ObservedObject var viewModel: TapFrenzyViewModel

    var body: some View {
        VStack(spacing: 36) {
            GameHeader(timeRemaining: viewModel.timeRemaining, score: viewModel.score, label: "Combo Frenzy")

            // Multiplier badge
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(viewModel.comboMultiplier > 1 ? Color.appOrange.opacity(0.15) : Color.primary.opacity(0.05))
                    .frame(width: 180, height: 44)
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(viewModel.comboMultiplier > 1 ? .appOrange : .secondary)
                    Text("Multiplier: ×\(viewModel.comboMultiplier)")
                        .font(.appFont(16))
                        .foregroundColor(viewModel.comboMultiplier > 1 ? .appOrange : .secondary)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.comboMultiplier)

            Spacer()

            Button(action: { viewModel.comboTapped() }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: viewModel.comboMultiplier > 1
                                    ? [.appOrange.opacity(0.9), .appOrangeDark]
                                    : [.appBlue.opacity(0.9), .appBlueDark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 180, height: 180)
                        .shadow(color: (viewModel.comboMultiplier > 1 ? Color.appOrange : Color.appBlue).opacity(0.4), radius: 18, x: 0, y: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 3)
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 38, weight: .bold))
                        Text("TAP ME")
                            .font(.appFont(22))
                    }
                    .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(viewModel.comboMultiplier > 1 ? 1.03 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: viewModel.comboMultiplier)

            Spacer()

            Text("Tap inside the time gap to stack multipliers!")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
    }
}

// MARK: - Challenge 2: Trap Colour

struct TrapColourChallengeView: View {
    @ObservedObject var viewModel: TapFrenzyViewModel

    var body: some View {
        VStack(spacing: 36) {
            GameHeader(timeRemaining: viewModel.timeRemaining, score: viewModel.score, label: "Trap Colour")

            // Hint legend
            HStack(spacing: 14) {
                LegendBadge(text: "+3 Bonus", color: .appGreen)
                LegendBadge(text: "+1 Normal", color: .appBlue)
                LegendBadge(text: "-2 Trap!", color: .appRed)
            }

            Spacer()

            Button(action: { viewModel.trapColourTapped() }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [viewModel.buttonColour.opacity(0.95), viewModel.buttonColour],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 180, height: 180)
                        .shadow(color: viewModel.buttonColour.opacity(0.4), radius: 18, x: 0, y: 10)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 3)
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 38, weight: .bold))
                        Text("TAP ME")
                            .font(.appFont(22))
                    }
                    .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.buttonColour)

            Spacer()

            Text(viewModel.trapHintText)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(viewModel.buttonColour == .gray ? .appRed : .secondary)
                .padding(.bottom, 20)
        }
    }
}

struct LegendBadge: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    TapFrenzyView()
}
