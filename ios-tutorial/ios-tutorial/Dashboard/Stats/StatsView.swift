//
//  StatsView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//

import SwiftUI

// MARK: - Stats View
struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var selectedDay: DayActivity? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // ── Header Row ──────────────────────────────────────
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Statistics")
                                    .font(.appFont(28))
                                    .foregroundColor(.primary)
                                Text("Your gameplay insights & progress")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        // ── Section 1: Overview Hero Cards ──────────────────
                        HStack(spacing: 12) {
                            StatHeroCard(
                                title: "Played",
                                value: "\(viewModel.totalGamesPlayed)",
                                icon: "gamecontroller.fill",
                                color: .appBlue,
                                colorDark: .appBlueDark
                            )
                            
                            StatHeroCard(
                                title: "Best Score",
                                value: "\(viewModel.bestScore)",
                                icon: "star.fill",
                                color: .appGold,
                                colorDark: .appGoldDark
                            )
                            
                            StatHeroCard(
                                title: "Streak",
                                value: "\(viewModel.currentStreak)",
                                icon: "flame.fill",
                                color: .appOrange,
                                colorDark: .appOrangeDark
                            )
                        }
                        
                        // ── Section 2: Weekly Activity Bar Chart ────────────
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                HStack(spacing: 8) {
                                    Text("This Week's Activity")
                                        .font(.appFont(18))
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                            }
                            
                            // Bar Chart
                            let maxCount = max(1, viewModel.last7DaysActivity.map { $0.count }.max() ?? 1)
                            
                            HStack(alignment: .bottom, spacing: 12) {
                                ForEach(viewModel.last7DaysActivity) { day in
                                    let isSelected = (selectedDay?.id == day.id)
                                    
                                    VStack(spacing: 8) {
                                        Text("\(day.count > 0 ? "\(day.count)" : "")")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(isSelected ? .primary : .secondary)
                                            .frame(height: 14)
                                        
                                        // Stacked Bar
                                        let totalBarHeight = max(8, CGFloat(day.count) / CGFloat(maxCount) * 110)
                                        
                                        ZStack {
                                            if day.count == 0 {
                                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .fill(Color.secondary.opacity(0.15))
                                            } else {
                                                VStack(spacing: 0) {
                                                    if day.quizCount > 0 {
                                                        Rectangle()
                                                            .fill(Color.appGreen)
                                                            .frame(height: totalBarHeight * CGFloat(day.quizCount) / CGFloat(day.count))
                                                    }
                                                    if day.lightCount > 0 {
                                                        Rectangle()
                                                            .fill(Color.appGold)
                                                            .frame(height: totalBarHeight * CGFloat(day.lightCount) / CGFloat(day.count))
                                                    }
                                                    if day.tapCount > 0 {
                                                        Rectangle()
                                                            .fill(Color.appBlue)
                                                            .frame(height: totalBarHeight * CGFloat(day.tapCount) / CGFloat(day.count))
                                                    }
                                                }
                                            }
                                        }
                                        .frame(height: totalBarHeight)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .stroke(isSelected ? Color.primary : (day.isToday ? Color.white.opacity(0.4) : Color.clear), lineWidth: isSelected ? 2 : 1)
                                        )
                                        .scaleEffect(isSelected ? 1.05 : 1.0)
                                        .shadow(color: isSelected ? Color.primary.opacity(0.25) : Color.clear, radius: 6, x: 0, y: 3)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedDay = isSelected ? nil : day
                                            }
                                        }
                                        
                                        Text(day.label)
                                            .font(.system(size: 12, weight: (day.isToday || isSelected) ? .bold : .medium, design: .rounded))
                                            .foregroundColor(isSelected ? .primary : (day.isToday ? .appPurple : .secondary))
                                    }
                                }
                            }
                            .frame(height: 160)
                            .padding(.top, 4)
                            
                            // Legend
                            HStack(spacing: 16) {
                                HStack(spacing: 5) {
                                    Circle().fill(Color.appBlue).frame(width: 8, height: 8)
                                    Text("Tap Frenzy").font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.secondary)
                                }
                                HStack(spacing: 5) {
                                    Circle().fill(Color.appGold).frame(width: 8, height: 8)
                                    Text("Light It Up").font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.secondary)
                                }
                                HStack(spacing: 5) {
                                    Circle().fill(Color.appGreen).frame(width: 8, height: 8)
                                    Text("Quiz Rush").font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.top, 4)
                            
                            // Interactive Breakdown Box
                            if let selected = selectedDay {
                                HStack(spacing: 12) {
                                    Text(selected.label == "Today" ? "Today's Breakdown:" : "\(selected.label) Breakdown:")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Circle().fill(Color.appBlue).frame(width: 8, height: 8)
                                        Text("\(selected.tapCount)")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                    }
                                    HStack(spacing: 4) {
                                        Circle().fill(Color.appGold).frame(width: 8, height: 8)
                                        Text("\(selected.lightCount)")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                    }
                                    HStack(spacing: 4) {
                                        Circle().fill(Color.appGreen).frame(width: 8, height: 8)
                                        Text("\(selected.quizCount)")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(uiColor: .secondarySystemBackground).opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(18)
                        .glassCard(cornerRadius: 22)
                        
                        // ── Section 3: Per-Game Breakdown Cards ─────────────
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Game Performance")
                                .font(.appFont(20))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                            
                            ForEach(viewModel.perGameStats) { stat in
                                GameStatCard(stat: stat, totalGames: viewModel.totalGamesPlayed)
                            }
                        }
                        
                        // ── Section 4: Recent Activity Feed ─────────────────
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Recent Games")
                                .font(.appFont(20))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 4)
                            
                            if viewModel.recentSessions.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "gamecontroller")
                                        .font(.system(size: 36))
                                        .foregroundColor(.secondary)
                                    Text("No games played yet!")
                                        .font(.appFont(16))
                                        .foregroundColor(.primary)
                                    Text("Jump into a game on the Home tab to start tracking your stats.")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(28)
                                .frame(maxWidth: .infinity)
                                .glassCard(cornerRadius: 20)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(viewModel.recentSessions) { session in
                                        HStack(spacing: 14) {
                                            ZStack {
                                                Circle()
                                                    .fill(viewModel.color(for: session.mode).opacity(0.18))
                                                    .frame(width: 42, height: 42)
                                                Image(systemName: viewModel.icon(for: session.mode))
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(viewModel.color(for: session.mode))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(session.mode == "TapFrenzy" ? "Tap Frenzy" : (session.mode == "LightItUp" ? "Light It Up" : "Quiz Rush"))
                                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                                    .foregroundColor(.primary)
                                                Text(viewModel.formatTimestamp(session.timestamp))
                                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 4) {
                                                Text("\(session.score)")
                                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                                    .foregroundColor(.primary)
                                                Text("pts")
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.secondary.opacity(0.12))
                                            .clipShape(Capsule())
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.5))
                                        )
                                    }
                                }
                                .padding(16)
                                .glassCard(cornerRadius: 22)
                            }
                        }
                        
                    }
                    .padding(20)
                }
                .onAppear {
                    viewModel.loadStats()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Stat Hero Pill Card
struct StatHeroCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let colorDark: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [color, colorDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                    .shadow(color: colorDark.opacity(0.4), radius: 6, x: 0, y: 3)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.appFont(20))
                    .foregroundColor(.primary)
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: 20, tint: color)
    }
}

// MARK: - Game Stat Card
struct GameStatCard: View {
    let stat: GameStat
    let totalGames: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [stat.color, stat.colorDark],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 60, height: 60)
                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 2))
                    .shadow(color: stat.colorDark.opacity(0.5), radius: 6, x: 0, y: 4)

                Image(systemName: stat.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Info Stack
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stat.title)
                            .font(.appFont(17))
                            .foregroundColor(.primary)
                        Text(stat.subtitle)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                // Progress Bar
                let proportion = totalGames > 0 ? CGFloat(stat.gamesPlayed) / CGFloat(totalGames) : 0.0
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [stat.color, stat.colorDark], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(8, geo.size.width * proportion), height: 6)
                    }
                }
                .frame(height: 6)
                
                // Stats Row
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.black)
                        Text("\(stat.gamesPlayed)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.black)
                        Text("\(stat.highScore)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Avg: \(Int(stat.averageScore))")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20, tint: stat.color)
    }
}

#Preview {
    StatsView()
}
