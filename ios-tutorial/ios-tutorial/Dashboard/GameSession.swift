import Foundation

// MARK: - Game Session Model
struct GameSession: Codable, Identifiable {
    let id: UUID
    let mode: String          // "TapFrenzy", "LightItUp", "QuizRush"
    let score: Int
    let timestamp: Date
    let latitude: Double?
    let longitude: Double?
    
    init(id: UUID = UUID(), mode: String, score: Int, timestamp: Date = Date(), latitude: Double? = nil, longitude: Double? = nil) {
        self.id = id
        self.mode = mode
        self.score = score
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Game Session Store
struct GameSessionStore {
    private static let storageKey = "gameSessions"
    
    /// Saves a completed game session to UserDefaults and posts a notification.
    static func save(_ session: GameSession) {
        var sessions = loadAll()
        sessions.append(session)
        
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
        
        // Notify observers (like DailyChallengeManager) that a game session was saved
        NotificationCenter.default.post(name: .gameSessionSaved, object: nil)
    }
    
    /// Loads all recorded game sessions from UserDefaults.
    static func loadAll() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let sessions = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return sessions
    }
    
    /// Returns sessions recorded during the current calendar day.
    static func sessionsToday() -> [GameSession] {
        let calendar = Calendar.current
        return loadAll().filter { calendar.isDateInToday($0.timestamp) }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let gameSessionSaved = Notification.Name("GameSessionSaved")
}
