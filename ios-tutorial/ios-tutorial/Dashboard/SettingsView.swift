//
//  SettingsView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//
import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
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
                            SettingsRow(icon: "person.fill",           title: "Profile",       color: .appBlue)
                            Divider().padding(.leading, 64)
                            SettingsRow(icon: "bell.fill",             title: "Notifications", color: .appGold)
                            Divider().padding(.leading, 64)
                            SettingsRow(icon: "lock.fill",             title: "Privacy",       color: .appPurple)
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
