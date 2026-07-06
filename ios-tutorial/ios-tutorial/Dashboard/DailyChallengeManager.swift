import SwiftUI
import Combine

// MARK: - Daily Challenge Manager
@MainActor
final class DailyChallengeManager: ObservableObject {
    
    static let shared = DailyChallengeManager()
    
    @Published var todaysGameMode: String = "TapFrenzy"
    @Published var isCompletedToday: Bool = false
    @Published var streak: Int = 0
    @Published var todaysScore: Int = 0
    
    private let streakKey = "dc_streak"
    private let lastCompletedDateKey = "dc_lastCompletedDate"
    private let savedDayKey = "dc_savedDayString"
    private let savedGameKey = "dc_savedGameMode"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadDailyChallenge()
        updateStreakAndCompletion()
        
        // Listen for new game sessions being saved
        NotificationCenter.default.publisher(for: .gameSessionSaved)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStreakAndCompletion()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Daily Game Selection
    
    /// generate today's game or loads from storage for the current day.
    func loadDailyChallenge() {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: today)
        
        let defaults = UserDefaults.standard
        let savedDayString = defaults.string(forKey: savedDayKey)
        
        if savedDayString == todayString, let savedGame = defaults.string(forKey: savedGameKey) {
            self.todaysGameMode = savedGame
        } else {
            // Pick a random game for today!
            let games = ["TapFrenzy", "LightItUp", "QuizRush"]
            let randomGame = games.randomElement() ?? "TapFrenzy"
            self.todaysGameMode = randomGame
            
            defaults.set(todayString, forKey: savedDayKey)
            defaults.set(randomGame, forKey: savedGameKey)
        }
    }
    
    // MARK: - Streak & Completion Logic
    
    /// Checks today's game sessions and updates completion status and streak.
    func updateStreakAndCompletion() {
        loadDailyChallenge() // Ensure we're on the right day if midnight passed
        
        let sessionsToday = GameSessionStore.sessionsToday()
        let matchingSessions = sessionsToday.filter { $0.mode == todaysGameMode }
        
        let defaults = UserDefaults.standard
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Load current stored streak and last completed date
        var currentStreak = defaults.integer(forKey: streakKey)
        let lastCompletedInterval = defaults.double(forKey: lastCompletedDateKey)
        let lastCompletedDate = lastCompletedInterval > 0 ? Date(timeIntervalSince1970: lastCompletedInterval) : nil
        
        if let bestSession = matchingSessions.max(by: { $0.score < $1.score }) {
            self.isCompletedToday = true
            self.todaysScore = bestSession.score
            
            // If we haven't already marked today as completed in storage
            if let lastDate = lastCompletedDate {
                if !calendar.isDateInToday(lastDate) {
                    if calendar.isDateInYesterday(lastDate) {
                        currentStreak += 1
                    } else {
                        // Missed one or more days, reset streak to 1
                        currentStreak = 1
                    }
                    defaults.set(today.timeIntervalSince1970, forKey: lastCompletedDateKey)
                    defaults.set(currentStreak, forKey: streakKey)
                }
            } else {
                // First time ever completing a daily challenge
                currentStreak = 1
                defaults.set(today.timeIntervalSince1970, forKey: lastCompletedDateKey)
                defaults.set(currentStreak, forKey: streakKey)
            }
        } else {
            self.isCompletedToday = false
            self.todaysScore = 0
            
            // Check if streak should be reset due to missing yesterday
            if let lastDate = lastCompletedDate {
                if !calendar.isDateInToday(lastDate) && !calendar.isDateInYesterday(lastDate) {
                    currentStreak = 0
                    defaults.set(0, forKey: streakKey)
                }
            } else {
                currentStreak = 0
            }
        }
        
        self.streak = currentStreak
    }
    
    // MARK: - Helper UI Properties
    
    var gameTitle: String {
        switch todaysGameMode {
        case "TapFrenzy": return "Tap Frenzy"
        case "LightItUp": return "Light It Up"
        case "QuizRush": return "Quiz Rush"
        default: return "Daily Challenge"
        }
    }
    
    var gameSubtitle: String {
        switch todaysGameMode {
        case "TapFrenzy": return "Fast reflex challenge"
        case "LightItUp": return "Memory & pattern game"
        case "QuizRush": return "Test your knowledge"
        default: return "Special daily event"
        }
    }
    
    var gameIcon: String {
        switch todaysGameMode {
        case "TapFrenzy": return "hand.tap.fill"
        case "LightItUp": return "bolt.fill"
        case "QuizRush": return "brain.head.profile"
        default: return "star.fill"
        }
    }
    
    var gameColor: Color {
        switch todaysGameMode {
        case "TapFrenzy": return .appBlue
        case "LightItUp": return .appGold
        case "QuizRush": return .appGreen
        default: return .appPurple
        }
    }
    
    var gameColorDark: Color {
        switch todaysGameMode {
        case "TapFrenzy": return .appBlueDark
        case "LightItUp": return .appGoldDark
        case "QuizRush": return .appGreenDark
        default: return .appPurpleDark
        }
    }
    
    var destinationView: AnyView {
        switch todaysGameMode {
        case "TapFrenzy": return AnyView(TapFrenzyView())
        case "LightItUp": return AnyView(LightItUpView())
        case "QuizRush": return AnyView(QuizRushView())
        default: return AnyView(Text("Game Not Found"))
        }
    }
}
