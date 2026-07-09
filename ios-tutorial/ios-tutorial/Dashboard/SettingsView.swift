//
//  SettingsView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//
import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notifHour") private var notifHour = 20
    @AppStorage("notifMinute") private var notifMinute = 0
    @AppStorage("locationEnabled") private var locationEnabled = false
    
    private var timeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                var components = DateComponents()
                components.hour = notifHour
                components.minute = notifMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                if let h = components.hour, let m = components.minute {
                    notifHour = h
                    notifMinute = m
                    if notificationsEnabled {
                        NotificationService.shared.scheduleDailyReminder(hour: h, minute: m)
                    }
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 18) {

                        // Profile avatar
                        VStack(spacing: 10) {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.appGreen, .appBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
                                .frame(width: 84, height: 84)
                                .overlay(Text("🦉").font(.system(size: 40)))
                                .shadow(color: .appGreen.opacity(0.4), radius: 10, x: 0, y: 6)

                            Text("Your Profile")
                                .font(.appFont(20))
                                .foregroundColor(.primary)  // adapts to dark mode
                        }
                        .padding(.top, 12)

                        // Settings rows
                        VStack(spacing: 2) {
                            // ── Notification Settings ──
                            VStack(spacing: 12) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.appGold.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "bell.fill")
                                            .foregroundColor(.appGold)
                                    }
                                    Text("Daily Challenge Reminder")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Toggle("", isOn: $notificationsEnabled)
                                        .tint(.appGreen)
                                        .labelsHidden()
                                        .onChange(of: notificationsEnabled) { _, newValue in
                                            if newValue {
                                                NotificationService.shared.requestPermission { granted in
                                                    if granted {
                                                        NotificationService.shared.scheduleDailyReminder(hour: notifHour, minute: notifMinute)
                                                    } else {
                                                        notificationsEnabled = false
                                                    }
                                                }
                                            } else {
                                                NotificationService.shared.cancelReminder()
                                            }
                                        }
                                }
                                
                                if notificationsEnabled {
                                    HStack {
                                        Text("Reminder Time")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 50)
                                        Spacer()
                                        DatePicker("", selection: timeBinding, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .tint(.appBlue)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    .padding(.bottom, 4)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .animation(.easeInOut(duration: 0.25), value: notificationsEnabled)
                            
                            Divider().padding(.leading, 64)
                            
                            // ── Location Tracking Settings ──
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.appPurple.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.appPurple)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Location Tracking")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text("Tag game sessions with your location for Maps")
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $locationEnabled)
                                        .tint(.appPurple)
                                        .labelsHidden()
                                        .onChange(of: locationEnabled) { _, newValue in
                                            if newValue {
                                                LocationManager.shared.requestPermission { granted in
                                                    if !granted {
                                                        locationEnabled = false
                                                    }
                                                }
                                            } else {
                                                LocationManager.shared.stopTracking()
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            
                            Divider().padding(.leading, 64)
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help",       color: .appGreen)
                        }
                        .glassCard(cornerRadius: 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)          // adapts to dark mode
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
}
