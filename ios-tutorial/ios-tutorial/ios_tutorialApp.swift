//
//  ios_tutorialApp.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-06.
//

import SwiftUI

@main
struct ios_tutorialApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// navbar view (TabView)
struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.shadowColor = .clear

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = UIColor(Color.appGreen)
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.appGreen),
            .font: UIFont.appRounded(ofSize: 11, weight: .bold)
        ]
        itemAppearance.normal.iconColor = UIColor.secondaryLabel
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.appRounded(ofSize: 11, weight: .semibold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }

            MapView()
                .tabItem { Label("Map", systemImage: "map.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(.appGreen)
    }
}
