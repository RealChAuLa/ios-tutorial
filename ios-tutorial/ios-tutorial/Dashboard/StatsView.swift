//
//  StatsView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//
import SwiftUI

// MARK: - Stats View
struct StatsView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    StatsView()
}
