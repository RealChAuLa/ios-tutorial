//
//  LightItUpView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-14.
//

import SwiftUI

struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpViewModel()
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack {
                if !viewModel.hasStarted {
                    startScreen
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else if viewModel.isGameActive {
                    activeGameScreen
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    gameOverScreen
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .padding(16)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.hasStarted)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isGameActive)
        .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Start Screen
    private var startScreen: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.appGold.opacity(0.18))
                    .frame(width: 90, height: 90)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.appGold)
                    .shadow(color: .appGold.opacity(0.5), radius: 12, x: 0, y: 6)
            }
            .padding(.top, 10)
            
            VStack(spacing: 6) {
                Text("LIGHT IT UP")
                    .font(.appFont(28))
                    .foregroundColor(.primary)
                Text("Tap the lit lights fast!")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
                .padding(.horizontal, 20)
            
            HStack(spacing: 8) {
                Text("Highscore")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.highScore)")
                    .font(.appFont(24))
                    .foregroundColor(.appGold)
            }
            .padding(16)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(16)
            
            Button("START GAME") {
                viewModel.startGame()
            }
            .buttonStyle(AppButtonStyle(baseColor: .appGold, shadowColor: .appGoldDark))
            .padding(.top, 6)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Active Game Screen
    private var activeGameScreen: some View {
        VStack(spacing: 24) {
            // Header Bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 16, weight: .bold))
                    Text("\(viewModel.timeRemaining)s")
                        .font(.appFont(16))
                }
                .foregroundColor(viewModel.timeRemaining <= 3 ? .appRed : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(viewModel.timeRemaining <= 3 ? Color.appRed.opacity(0.15) : Color.primary.opacity(0.06))
                )
                
                Spacer()
                
                // Level Badge
                Text(viewModel.currentLevel.name.uppercased())
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.appGoldDark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.appGold.opacity(0.2))
                    .cornerRadius(12)
                
                Spacer()
                
                // Score Pill
                HStack(spacing: 4) {
                    Text("PTS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("\(viewModel.score)")
                        .font(.appFont(18))
                        .foregroundColor(.appGoldDark)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.appGold.opacity(0.15))
                )
            }
            .padding(.horizontal, 6)
            
            Spacer()
            
            // Grid
            let columns = Array(
                repeating: GridItem(.flexible(), spacing: 18),
                count: viewModel.currentLevel.cardCount <= 4 ? viewModel.currentLevel.cardCount : 3
            )
            
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(0..<viewModel.currentLevel.cardCount, id: \.self) { index in
                    let isLit = viewModel.litIndices.contains(index)
                    
                    Button {
                        viewModel.cardTapped(at: index)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(
                                    isLit
                                        ? AnyShapeStyle(LinearGradient(colors: [.appGold, .appOrange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        : AnyShapeStyle(Color.primary.opacity(0.07))
                                )
                                .frame(height: viewModel.currentLevel.cardCount <= 4 ? 140 : 115)
                                .shadow(color: isLit ? .appGold.opacity(0.55) : .black.opacity(0.05), radius: isLit ? 14 : 4, x: 0, y: isLit ? 6 : 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(isLit ? Color.white.opacity(0.6) : Color.white.opacity(0.15), lineWidth: 1.5)
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isLit ? 1.03 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isLit)
                }
            }
            .padding(16)
            .glassCard(cornerRadius: 24)
            
            Spacer()
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.appGold)
                    Text("Best: \(viewModel.highScore)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Tap lit tiles!")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
        }
    }
    
    // MARK: - Game Over Screen
    private var gameOverScreen: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.appGold.opacity(0.18))
                    .frame(width: 80, height: 80)
                Image(systemName: "bolt.slash.fill")
                    .font(.system(size: 38))
                    .foregroundColor(.appGold)
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
                        .foregroundColor(.appGoldDark)
                }
                
                Divider()
                
                HStack {
                    Text("Highscore")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
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
                    viewModel.startGame()
                }
                .buttonStyle(AppButtonStyle(baseColor: .appGold, shadowColor: .appGoldDark))
                
                ScoreShareButton(
                    gameTitle: "Light It Up",
                    score: viewModel.score,
                    highScore: viewModel.highScore,
                    accentColor: .appPurple,
                    shadowColor: .appPurpleDark
                )
            }
            .padding(.top, 6)
        }
    }
}

#Preview {
    LightItUpView()
}
