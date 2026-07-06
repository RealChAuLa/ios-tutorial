//
//  MapView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//
import SwiftUI

// MARK: - Map / Game History Map
struct MapView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
            }
            .navigationTitle("Maps")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}



#Preview {
    MapView()
}
