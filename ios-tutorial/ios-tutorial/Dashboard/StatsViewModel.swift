//
//  StatsViewModel.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//

import SwiftUI
import Combine

// MARK: - Game Stat Breakdown Model
struct GameStat: Identifiable {
    let id = UUID()
    let mode: String
    let title: String
    let subtitle: String
    let gamesPlayed: Int
    let highScore: Int
    let averageScore: Double
    let icon: String
    let color: Color
    let colorDark: Color
}

// MARK: - Daily Activity Bar Chart Model
struct DayActivity: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let tapCount: Int
    let lightCount: Int
    let quizCount: Int
    let label: String
    let isToday: Bool
}

// MARK: - Stats View Model
@MainActor
final class StatsViewModel: ObservableObject {
    
    @Published var totalGamesPlayed: Int = 0
    @Published var totalScore: Int = 0
    @Published var averageScore: Double = 0.0
    @Published var bestScore: Int = 0
    @Published var bestScoreGameTitle: String = "-"
    @Published var currentStreak: Int = 0
    @Published var gamesPlayedToday: Int = 0
    @Published var todaysTotalScore: Int = 0
    
    @Published var perGameStats: [GameStat] = []
    @Published var last7DaysActivity: [DayActivity] = []
    @Published var recentSessions: [GameSession] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadStats()
        
        // Refresh automatically whenever a game session is saved
        NotificationCenter.default.publisher(for: .gameSessionSaved)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadStats()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load & Compute Statistics
    func loadStats() {
        let allSessions = GameSessionStore.loadAll()
        let calendar = Calendar.current
        let today = Date()
        
        // 1. Overview Totals
        self.totalGamesPlayed = allSessions.count
        self.totalScore = allSessions.reduce(0) { $0 + $1.score }
        self.averageScore = totalGamesPlayed > 0 ? Double(totalScore) / Double(totalGamesPlayed) : 0.0
        
        // Best score overall (check both session history and stored high scores)
        let tapBest = UserDefaults.standard.integer(forKey: "highScore_TapFrenzy")
        let lightBest = UserDefaults.standard.integer(forKey: "highScore_lightItUp")
        let quizBest = UserDefaults.standard.integer(forKey: "highScore_QuizRush")
        
        var maxOverall = max(tapBest, max(lightBest, quizBest))
        var maxMode = "None"
        
        if maxOverall == tapBest && tapBest > 0 { maxMode = "TapFrenzy" }
        else if maxOverall == lightBest && lightBest > 0 { maxMode = "LightItUp" }
        else if maxOverall == quizBest && quizBest > 0 { maxMode = "QuizRush" }
        
        if let bestSession = allSessions.max(by: { $0.score < $1.score }), bestSession.score >= maxOverall {
            maxOverall = bestSession.score
            maxMode = bestSession.mode
        }
        
        self.bestScore = maxOverall
        self.bestScoreGameTitle = title(for: maxMode)
        
        // 2. Daily & Streak Info
        self.currentStreak = DailyChallengeManager.shared.streak
        let todaySessions = allSessions.filter { calendar.isDateInToday($0.timestamp) }
        self.gamesPlayedToday = todaySessions.count
        self.todaysTotalScore = todaySessions.reduce(0) { $0 + $1.score }
        
        // 3. Per-Game Breakdowns
        let modes = [
            ("TapFrenzy", "Tap Frenzy", "Fast reflex challenge", "hand.tap.fill", Color.appBlue, Color.appBlueDark, tapBest),
            ("LightItUp", "Light It Up", "Memory & pattern game", "bolt.fill", Color.appGold, Color.appGoldDark, lightBest),
            ("QuizRush", "Quiz Rush", "Test your knowledge", "brain.head.profile", Color.appGreen, Color.appGreenDark, quizBest)
        ]
        
        self.perGameStats = modes.map { mode, title, subtitle, icon, color, colorDark, storedBest in
            let gameSessions = allSessions.filter { $0.mode == mode }
            let count = gameSessions.count
            let sum = gameSessions.reduce(0) { $0 + $1.score }
            let avg = count > 0 ? Double(sum) / Double(count) : 0.0
            let sessionMax = gameSessions.map { $0.score }.max() ?? 0
            let best = max(storedBest, sessionMax)
            
            return GameStat(
                mode: mode,
                title: title,
                subtitle: subtitle,
                gamesPlayed: count,
                highScore: best,
                averageScore: avg,
                icon: icon,
                color: color,
                colorDark: colorDark
            )
        }
        
        // 4. Last 7 Days Activity (for bar chart)
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Short weekday (e.g., "Mon")
        
        var activity: [DayActivity] = []
        for offset in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                let isToday = calendar.isDateInToday(date)
                let daySessions = allSessions.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
                let tapCount = daySessions.filter { $0.mode == "TapFrenzy" }.count
                let lightCount = daySessions.filter { $0.mode == "LightItUp" }.count
                let quizCount = daySessions.filter { $0.mode == "QuizRush" }.count
                let label = isToday ? "Today" : formatter.string(from: date)
                
                activity.append(DayActivity(
                    date: date,
                    count: daySessions.count,
                    tapCount: tapCount,
                    lightCount: lightCount,
                    quizCount: quizCount,
                    label: label,
                    isToday: isToday
                ))
            }
        }
        self.last7DaysActivity = activity
        
        // 5. Recent Activity Feed (latest 10)
        self.recentSessions = Array(allSessions.sorted(by: { $0.timestamp > $1.timestamp }).prefix(10))
    }
    
    // MARK: - Helpers
    private func title(for mode: String) -> String {
        switch mode {
        case "TapFrenzy": return "Tap Frenzy"
        case "LightItUp": return "Light It Up"
        case "QuizRush": return "Quiz Rush"
        default: return "-"
        }
    }
    
    func color(for mode: String) -> Color {
        switch mode {
        case "TapFrenzy": return .appBlue
        case "LightItUp": return .appGold
        case "QuizRush": return .appGreen
        default: return .appPurple
        }
    }
    
    func icon(for mode: String) -> String {
        switch mode {
        case "TapFrenzy": return "hand.tap.fill"
        case "LightItUp": return "bolt.fill"
        case "QuizRush": return "brain.head.profile"
        default: return "gamecontroller.fill"
        }
    }
    
    func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: date, relativeTo: Date())
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}
