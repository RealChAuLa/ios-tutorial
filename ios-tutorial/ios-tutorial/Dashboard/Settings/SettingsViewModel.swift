//
//  SettingsViewModel.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-11.
//
import SwiftUI
import Combine
import LocalAuthentication

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("notificationsEnabled") var notificationsEnabled = false
    @AppStorage("notifHour") var notifHour = 20
    @AppStorage("notifMinute") var notifMinute = 0
    @AppStorage("locationEnabled") var locationEnabled = false
    
    @Published var showClearConfirmation = false
    
    var timeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                var components = DateComponents()
                components.hour = self.notifHour
                components.minute = self.notifMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                if let h = components.hour, let m = components.minute {
                    self.notifHour = h
                    self.notifMinute = m
                    if self.notificationsEnabled {
                        NotificationService.shared.scheduleDailyReminder(hour: h, minute: m)
                    }
                }
            }
        )
    }
    
    func handleNotificationToggle(newValue: Bool) {
        if newValue {
            NotificationService.shared.requestPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    NotificationService.shared.scheduleDailyReminder(hour: self.notifHour, minute: self.notifMinute)
                } else {
                    self.notificationsEnabled = false
                }
            }
        } else {
            NotificationService.shared.cancelReminder()
        }
    }
    
    func handleLocationToggle(newValue: Bool) {
        if newValue {
            LocationManager.shared.requestPermission { [weak self] granted in
                guard let self = self else { return }
                if !granted {
                    self.locationEnabled = false
                }
            }
        } else {
            LocationManager.shared.stopTracking()
        }
    }
    
    func authenticateAndClear() {
        let context = LAContext()
        var error: NSError?
        
        // .deviceOwnerAuthentication ,Face ID Touch ID device passcode fallback
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Confirm identity to permanently delete all game data."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, authError in
                if success {
                    DispatchQueue.main.async {
                        self?.clearAllGameData()
                    }
                } else if let error = authError {
                    print("Authentication failed: \(error.localizedDescription)")
                }
            }
        } else {
            // If biometrics/passcode is not set up on device, clear directly
            clearAllGameData()
        }
    }
    
    private func clearAllGameData() {
        // Clear stored game sessions and notify observers
        GameSessionStore.clearAll()
        
        // Clear high scores
        UserDefaults.standard.removeObject(forKey: "highScore_lightItUp")
        UserDefaults.standard.removeObject(forKey: "highScore_LightItUp")
        UserDefaults.standard.removeObject(forKey: "highScore_TapFrenzy")
        UserDefaults.standard.removeObject(forKey: "highScore_QuizRush")
        
        // Clear daily challenge streak and history
        UserDefaults.standard.removeObject(forKey: "dc_streak")
        UserDefaults.standard.removeObject(forKey: "dc_lastCompletedDate")
        UserDefaults.standard.removeObject(forKey: "dc_savedDayString")
        UserDefaults.standard.removeObject(forKey: "dc_savedGameMode")
        
        // Trigger UI & Daily Challenge refresh
        Task { @MainActor in
            DailyChallengeManager.shared.updateStreakAndCompletion()
            NotificationCenter.default.post(name: .gameSessionSaved, object: nil)
        }
    }
}
