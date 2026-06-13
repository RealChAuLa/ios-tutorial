//
//  ContentView.swift
//  ios-tutorial
//

import SwiftUI
import Combine

// MARK: - Challenge Type

enum Challenge {
    case combo
}

// MARK: - Content View

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameActive = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let currentChallenge: Challenge = .combo

    var body: some View {
        if isGameActive {
            challengeView
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        isGameActive = false
                    }
                }
        } else {
            gameOverView
        }
    }

    // MARK: - Game Over

    var gameOverView: some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle).bold()
            Text("Final Score: \(score)")
                .font(.title)
            Button("Play Again") {
                score = 0
                timeRemaining = 10
                timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                resetChallengeState()
                isGameActive = true
            }
            .font(.headline)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    // MARK: - Challenge Router

    @ViewBuilder
    var challengeView: some View {
        switch currentChallenge {
        case .combo:        ComboChallengeView(score: $score, timeRemaining: $timeRemaining)
        }
    }

    func resetChallengeState() {
        // Each challenge view manages its own state via @State,
        // so it resets automatically when the view is recreated on Play Again.
    }
}

// MARK: - Shared Header

struct GameHeader: View {
    let timeRemaining: Int
    let score: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text("Time: \(timeRemaining)s")
                .font(.headline)
                .foregroundColor(.red)
            Text(label)
                .font(.largeTitle).bold()
            Text("Score: \(score)")
                .font(.title)
        }
    }
}

// MARK: - Challenge 1: Combo System

struct ComboChallengeView: View {
    @Binding var score: Int
    @Binding var timeRemaining: Int

    // Tracks when the last tap happened
    @State private var lastTapTime: Date = .distantPast
    // Current multiplier (1×, 2×, 3× …)
    @State private var multiplier: Int = 1

    // How long the player has to tap again to keep the combo alive (seconds)
    private let comboWindow: TimeInterval = 0.5

    var body: some View {
        VStack(spacing: 30) {
            GameHeader(timeRemaining: timeRemaining, score: score, label: "Combo Frenzy")

            // Multiplier badge
            Text("Multiplier: ×\(multiplier)")
                .font(.title2).bold()
                .foregroundColor(multiplier > 1 ? .orange : .secondary)
                .animation(.easeInOut, value: multiplier)

            Button(action: handleTap) {
                Text("TAP ME")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(multiplier > 1 ? Color.orange : Color.blue)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.2), value: multiplier)
            }

            Text("Tap fast to build your combo!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    func handleTap() {
        let now = Date()
        let gap = now.timeIntervalSince(lastTapTime)

        if gap <= comboWindow {
            // Within window → increase multiplier
            multiplier += 1
        } else {
            // Too slow → reset combo
            multiplier = 1
        }

        score += multiplier
        lastTapTime = now
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
