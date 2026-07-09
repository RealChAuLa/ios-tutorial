//
//  MapViewModel.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-09.
//

import SwiftUI
import Combine
import MapKit

@MainActor
final class MapViewModel: ObservableObject {
    @Published var locatedSessions: [GameSession] = []
    @Published var highScoreIDs: Set<UUID> = []
    @Published var selectedSession: GameSession? = nil
    @Published var filterMode: String = "All"
    @Published var position: MapCameraPosition = .automatic
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLocatedSessions()
        
        NotificationCenter.default.publisher(for: .gameSessionSaved)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadLocatedSessions()
            }
            .store(in: &cancellables)
    }
    
    var filteredSessions: [GameSession] {
        if filterMode == "All" {
            return locatedSessions
        }
        return locatedSessions.filter { $0.mode == filterMode }
    }
    
    func loadLocatedSessions() {
        let all = GameSessionStore.loadAll()
        let located = all.filter { $0.latitude != nil && $0.longitude != nil }
        self.locatedSessions = located
        
        // Find high score session IDs for each game mode
        var topIDs = Set<UUID>()
        let modes = ["TapFrenzy", "LightItUp", "QuizRush"]
        for mode in modes {
            let modeSessions = located.filter { $0.mode == mode }
            if let best = modeSessions.max(by: { $0.score < $1.score }) {
                topIDs.insert(best.id)
            }
        }
        self.highScoreIDs = topIDs
        
        // Adjust camera position if we have sessions
        if !located.isEmpty && position == .automatic {
            if let first = located.first, let lat = first.latitude, let lon = first.longitude {
                position = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                ))
            }
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
    
    func colorDark(for mode: String) -> Color {
        switch mode {
        case "TapFrenzy": return .appBlueDark
        case "LightItUp": return .appGoldDark
        case "QuizRush": return .appGreenDark
        default: return .appPurpleDark
        }
    }
    
    func title(for mode: String) -> String {
        switch mode {
        case "TapFrenzy": return "Tap Frenzy"
        case "LightItUp": return "Light It Up"
        case "QuizRush": return "Quiz Rush"
        default: return mode
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
