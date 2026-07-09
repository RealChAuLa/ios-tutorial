//
//  ContentView.swift
//  ios-tutorial
//

import SwiftUI
import Combine

// MARK: - Challenge Type

enum Challenge: CaseIterable, Equatable {
    case combo
    case trapColour
}

// MARK: - Content View

struct TapFrenzyView: View {
    @AppStorage("highScore_TapFrenzy") private var highScore = 0
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameActive = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var challengeTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    @State private var currentChallenge: Challenge = Challenge.allCases.randomElement()!

    var body: some View {
        if isGameActive {
            challengeView
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        isGameActive = false
                        if score > highScore { highScore = score }
                        let coords = LocationManager.shared.getLatLng()
                        GameSessionStore.save(GameSession(mode: "TapFrenzy", score: score, latitude: coords?.latitude, longitude: coords?.longitude))
                    }
                }
                .onReceive(challengeTimer) { _ in
                                    currentChallenge = Challenge.allCases
                                        .filter { $0 != currentChallenge }
                                        .randomElement()!
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
                challengeTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
                currentChallenge = Challenge.allCases.randomElement()!
                isGameActive = true
            }            .font(.headline)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            Text("High Score: \(highScore)").foregroundColor(.purple)
        }
    }

    // MARK: - Challenge Router

    @ViewBuilder
        var challengeView: some View {
            switch currentChallenge {
            case .combo:
                ComboChallengeView(score: $score, timeRemaining: $timeRemaining)
            case .trapColour:
                TrapColourChallengeView(score: $score, timeRemaining: $timeRemaining)
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

// MARK: - Challenge 2: Trap Colour (stub)

struct TrapColourChallengeView: View {
    @Binding var score: Int
    @Binding var timeRemaining: Int

    @State private var buttonColour: Color = .blue
    @State private var colourTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    // The three possible colours and what each means
    private let colours: [(color: Color, points: Int)] = [
        (.green, +3),   // bonus
        (.blue, +1),    // normal
        (.gray, -2),    // penalty
    ]

    var body: some View {
        VStack(spacing: 30) {
            GameHeader(timeRemaining: timeRemaining, score: score, label: "Trap Colour")

            // Hint legend
            HStack(spacing: 16) {
                Label("+3", systemImage: "circle.fill").foregroundColor(.green)
                Label("+1", systemImage: "circle.fill").foregroundColor(.blue)
                Label("-2", systemImage: "circle.fill").foregroundColor(.gray)
            }
            .font(.caption)

            Button(action: handleTap) {
                Text("TAP ME")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(buttonColour)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.3), value: buttonColour)
            }

            Text(hintText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onReceive(colourTimer) { _ in
            switchColour()
        }
    }

    // Show the player a hint based on current colour
    var hintText: String {
        switch buttonColour {
        case .green: return "Bonus! Tap fast!"
        case .gray:  return "Danger! Don't tap!"
        default:     return "Tap to score"
        }
    }

    func handleTap() {
        let points = colours.first { $0.color == buttonColour }?.points ?? 1
        score = max(0, score + points)   // floor at 0 so score can't go negative
    }

    func switchColour() {
        // Pick any colour except the one currently showing
        let next = colours
            .map { $0.color }
            .filter { $0 != buttonColour }
            .randomElement() ?? .blue
        buttonColour = next
    }
}

// MARK: - Preview

#Preview {
    TapFrenzyView()
}
