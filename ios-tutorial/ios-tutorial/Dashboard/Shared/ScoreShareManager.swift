//
//  ScoreShareManager.swift
//  ios-tutorial
//
//  Shared core feature for sharing game scores across all arcade modes.
//

import SwiftUI
import UIKit

// MARK: - Share Sheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Score Share Button Component
struct ScoreShareButton: View {
    let gameTitle: String
    let score: Int
    let highScore: Int
    var accentColor: Color = .appPurple
    var shadowColor: Color = .appPurpleDark
    
    @State private var showShareSheet = false
    
    private var shareMessage: String {
        if score >= highScore && score > 0 {
            return "NEW HIGH SCORE! I just scored \(score) pts in \(gameTitle) on Arcade! Can you beat my record?"
        } else {
            return "I just scored \(score) pts in \(gameTitle) on Arcade! My personal best is \(highScore) pts. Come challenge me!"
        }
    }
    
    var body: some View {
        Button {
            showShareSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 16, weight: .bold))
                Text("SHARE SCORE")
            }
        }
        .buttonStyle(AppButtonStyle(baseColor: accentColor, shadowColor: shadowColor))
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareMessage])
                .presentationDetents([.medium, .large])
        }
    }
}
