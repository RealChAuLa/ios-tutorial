//
//  ViewModel.swift
//  ios-tutorial
//
//  TapFrenzy state engine: timers, score, challenge rotation, and persistence.
//

import SwiftUI
import Combine

@MainActor
final class TapFrenzyViewModel: ObservableObject {
    @AppStorage("highScore_TapFrenzy") var highScore = 0

    @Published var score = 0
    @Published var timeRemaining = 10
    @Published var isGameActive = false
    @Published var hasStarted = false
    @Published var currentChallenge: Challenge = Challenge.allCases.randomElement()!

    // Combo state
    @Published var comboMultiplier = 1
    private var lastTapTime: Date = .distantPast

    // Trap Colour state
    @Published var buttonColour: Color = .blue

    private var gameTimerCancellable: AnyCancellable?
    private var challengeTimerCancellable: AnyCancellable?
    private var colourTimerCancellable: AnyCancellable?

    // MARK: - Computed

    var trapHintText: String {
        switch buttonColour {
        case .green: return "Bonus! Tap fast!"
        case .gray:  return "Danger! Don't tap!"
        default:     return "Tap to score"
        }
    }

    // MARK: - Game Lifecycle

    init() {
        // Timers start on startGame()
    }

    func startGame() {
        score = 0
        timeRemaining = 10
        comboMultiplier = 1
        lastTapTime = .distantPast
        buttonColour = .blue
        currentChallenge = Challenge.allCases.randomElement()!
        hasStarted = true
        isGameActive = true
        startTimers()
    }

    func playAgain() {
        score = 0
        timeRemaining = 10
        comboMultiplier = 1
        lastTapTime = .distantPast
        buttonColour = .blue
        currentChallenge = Challenge.allCases.randomElement()!
        hasStarted = true
        isGameActive = true
        startTimers()
    }

    // MARK: - Tap Actions

    func comboTapped() {
        guard isGameActive else { return }
        let now = Date()
        let gap = now.timeIntervalSince(lastTapTime)

        if gap <= comboWindow {
            comboMultiplier += 1
        } else {
            comboMultiplier = 1
        }

        score += comboMultiplier
        lastTapTime = now
    }

    func trapColourTapped() {
        guard isGameActive else { return }
        let points = trapColourRules.first { $0.color == buttonColour }?.points ?? 1
        score = max(0, score + points)
    }

    // MARK: - Timers

    private func startTimers() {
        stopTimers()

        // 1-second game countdown
        gameTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.handleGameTick() }

        // 5-second challenge rotation
        challengeTimerCancellable = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.rotateChallenge() }

        // 2-second trap colour switch
        colourTimerCancellable = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.switchColour() }
    }

    private func stopTimers() {
        gameTimerCancellable?.cancel()
        gameTimerCancellable = nil
        challengeTimerCancellable?.cancel()
        challengeTimerCancellable = nil
        colourTimerCancellable?.cancel()
        colourTimerCancellable = nil
    }

    private func handleGameTick() {
        guard isGameActive else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            isGameActive = false
            stopTimers()
            if score > highScore { highScore = score }
            let coords = LocationManager.shared.getLatLng()
            GameSessionStore.save(GameSession(mode: "TapFrenzy", score: score, latitude: coords?.latitude, longitude: coords?.longitude))
        }
    }

    private func rotateChallenge() {
        guard isGameActive else { return }
        currentChallenge = Challenge.allCases
            .filter { $0 != currentChallenge }
            .randomElement()!
        // Reset sub-challenge state on rotation
        comboMultiplier = 1
        lastTapTime = .distantPast
        buttonColour = .blue
    }

    private func switchColour() {
        guard isGameActive, currentChallenge == .trapColour else { return }
        let next = trapColourRules
            .map { $0.color }
            .filter { $0 != buttonColour }
            .randomElement() ?? .blue
        buttonColour = next
    }

    deinit {
        gameTimerCancellable?.cancel()
        challengeTimerCancellable?.cancel()
        colourTimerCancellable?.cancel()
    }
}
