//
//  View.swift
//  ios-tutorial
//
//  TapFrenzy declarative UI: main view, challenge sub-views, and shared header.
//

import SwiftUI

// MARK: - Main View

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyViewModel()

    var body: some View {
        if viewModel.isGameActive {
            challengeView
        } else {
            gameOverView
        }
    }

    // MARK: - Game Over

    var gameOverView: some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle).bold()
            Text("Final Score: \(viewModel.score)")
                .font(.title)
            Button("Play Again") {
                viewModel.playAgain()
            }
            .font(.headline)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            Text("High Score: \(viewModel.highScore)").foregroundColor(.purple)
        }
        .toolbar(.hidden,for: .tabBar) //to hide the navbar
    }

    // MARK: - Challenge Router

    @ViewBuilder
    var challengeView: some View {
        switch viewModel.currentChallenge {
        case .combo:
            ComboChallengeView(viewModel: viewModel)
        case .trapColour:
            TrapColourChallengeView(viewModel: viewModel)
        }
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
    @ObservedObject var viewModel: TapFrenzyViewModel

    var body: some View {
        VStack(spacing: 30) {
            GameHeader(timeRemaining: viewModel.timeRemaining, score: viewModel.score, label: "Combo Frenzy")

            // Multiplier badge
            Text("Multiplier: ×\(viewModel.comboMultiplier)")
                .font(.title2).bold()
                .foregroundColor(viewModel.comboMultiplier > 1 ? .orange : .secondary)
                .animation(.easeInOut, value: viewModel.comboMultiplier)

            Button(action: { viewModel.comboTapped() }) {
                Text("TAP ME")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(viewModel.comboMultiplier > 1 ? Color.orange : Color.blue)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.2), value: viewModel.comboMultiplier)
            }

            Text("Tap fast to build your combo!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Challenge 2: Trap Colour

struct TrapColourChallengeView: View {
    @ObservedObject var viewModel: TapFrenzyViewModel

    var body: some View {
        VStack(spacing: 30) {
            GameHeader(timeRemaining: viewModel.timeRemaining, score: viewModel.score, label: "Trap Colour")

            // Hint legend
            HStack(spacing: 16) {
                Label("+3", systemImage: "circle.fill").foregroundColor(.green)
                Label("+1", systemImage: "circle.fill").foregroundColor(.blue)
                Label("-2", systemImage: "circle.fill").foregroundColor(.gray)
            }
            .font(.caption)

            Button(action: { viewModel.trapColourTapped() }) {
                Text("TAP ME")
                    .font(.title).bold()
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(viewModel.buttonColour)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.3), value: viewModel.buttonColour)
            }

            Text(viewModel.trapHintText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    TapFrenzyView()
}
