//
//  NotificationService.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//

import Foundation
import UserNotifications

// MARK: - Notification Service
final class NotificationService {
    static let shared = NotificationService()
    
    private let notificationId = "dailyChallengeReminder"
    
    private init() {}
    
    /// Requests notification permission from the user.
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }
    
    /// Schedules a daily repeating local notification at the user's chosen hour and minute.
    func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        
        // Remove existing reminder before scheduling a new one
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge Ready!"
        content.body = "Your daily challenge awaits! Play now to keep your streak alive"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled daily reminder for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    /// Cancels the scheduled daily reminder notification.
    func cancelReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])
        print("Cancelled daily reminder notification.")
    }
}
