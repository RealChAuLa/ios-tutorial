//
//  ViewModel.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-14.
//

import SwiftUI
import Combine

@MainActor
final class LightItUpViewModel: ObservableObject {
    @AppStorage("highScore_lightItUp") var highScore = 0
    @Published var litIndices: Set<Int> = [0]
    @Published var score = 0
    @Published var timeRemaining = 60
    @Published var isGameActive = false
    @Published var hasStarted = false
    @Published var elapsed = 0
    @Published var levelIndex = 0
    
    private var timerCancellable: AnyCancellable?
    private var litTimerCancellable: AnyCancellable?
    
    var currentLevel: GameLevel { levels[levelIndex] }
    
    func startGame() {
        score = 0
        timeRemaining = 60
        litIndices = [0]
        elapsed = 0
        levelIndex = 0
        hasStarted = true
        isGameActive = true
        startTimers()
    }
    
    func cardTapped(at index: Int) {
        guard isGameActive else { return }
        if litIndices.contains(index) {
            score += 1
        } else {
            score -= 1
        }
    }
    
    private func startTimers() {
        stopTimers()
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleGameTimerTick()
            }
        
        startLitTimer(interval: levels[levelIndex].interval)
    }
    
    private func startLitTimer(interval: TimeInterval) {
        litTimerCancellable?.cancel()
        litTimerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleLitTimerTick()
            }
    }
    
    private func stopTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
        litTimerCancellable?.cancel()
        litTimerCancellable = nil
    }
    
    private func handleGameTimerTick() {
        guard isGameActive else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
            elapsed += 1

            // Check if level should change
            let newIndex: Int
            switch elapsed {
            case 0..<15:  newIndex = 0
            case 15..<30: newIndex = 1
            case 30..<45: newIndex = 2
            default:      newIndex = 3
            }

            if newIndex != levelIndex {
                levelIndex = newIndex
                litIndices = [0]   // reset lit position so no stale yellow square
                // Restart lit timer at new speed
                startLitTimer(interval: levels[newIndex].interval)
            }
        } else {
            isGameActive = false
            stopTimers()
            if score > highScore { highScore = score }
            let coords = LocationManager.shared.getLatLng()
            GameSessionStore.save(GameSession(mode: "LightItUp", score: score, latitude: coords?.latitude, longitude: coords?.longitude))
        }
    }
    
    private func handleLitTimerTick() {
        guard isGameActive else { return }
        let count = currentLevel.litCount
        let picks = Array((0..<currentLevel.cardCount).shuffled().prefix(count))
        litIndices = Set(picks)
    }
    
    deinit {
        timerCancellable?.cancel()
        litTimerCancellable?.cancel()
    }
}
