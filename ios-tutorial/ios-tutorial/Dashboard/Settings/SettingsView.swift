//
//  SettingsView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//
import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Settings")
                                    .font(.appFont(28))
                                    .foregroundColor(.primary)
                                Text("Customize your preferences")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        // Settings rows
                        VStack(spacing: 2) {
                            // ── Notification Settings
                            VStack(spacing: 12) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.appGold.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "bell.fill")
                                            .foregroundColor(.appGold)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Daily Challenge Reminder")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text("Get a reminder to complete your daily challenge")
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $viewModel.notificationsEnabled)
                                        .tint(.appGreen)
                                        .labelsHidden()
                                        .onChange(of: viewModel.notificationsEnabled) { _, newValue in
                                            viewModel.handleNotificationToggle(newValue: newValue)
                                        }
                                }
                                
                                if viewModel.notificationsEnabled {
                                    HStack {
                                        Text("Reminder Time")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 50)
                                        Spacer()
                                        DatePicker("", selection: viewModel.timeBinding, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                            .tint(.appBlue)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    .padding(.bottom, 4)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .animation(.easeInOut(duration: 0.25), value: viewModel.notificationsEnabled)
                            
                            Divider().padding(.leading, 64)
                            
                            // ── Location Tracking Settings
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
                                    Toggle("", isOn: $viewModel.locationEnabled)
                                        .tint(.appGreen)
                                        .labelsHidden()
                                        .onChange(of: viewModel.locationEnabled) { _, newValue in
                                            viewModel.handleLocationToggle(newValue: newValue)
                                        }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            
                            Divider().padding(.leading, 64)
                            
                            // Clear All Game Data
                            Button {
                                viewModel.showClearConfirmation = true
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.red.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Clear All Game Data")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.red)
                                        Text("Reset high scores, streaks, and map history")
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                        }
                        .glassCard(cornerRadius: 20)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .alert("Clear All Game Data?", isPresented: $viewModel.showClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear Data", role: .destructive) {
                    viewModel.authenticateAndClear()
                }
            } message: {
                Text("This will permanently delete All your game data This action cannot be undone.")
            }
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
                .foregroundColor(.primary)
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
