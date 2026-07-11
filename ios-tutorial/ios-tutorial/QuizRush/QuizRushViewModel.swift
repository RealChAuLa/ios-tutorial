//
//  ViewModel.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-03.
//
import Foundation
import SwiftUI
import Combine

@MainActor
final class QuizRushViewModel: ObservableObject {
    
    enum ViewState {
        case loading, loaded, failed
    }
    
    @Published var state: ViewState = .loading
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var highScore = UserDefaults.standard.integer(forKey: "highScore_QuizRush")
    @Published var isGameOver = false // NEW: Tracks if the round is finished
    @Published var hasStarted = false
    
    // Configuration properties
    @Published var selectedDifficulty: TriviaDifficulty = .any
    @Published var selectedCategory: TriviaCategory = .any
    @Published var selectedType: TriviaType = .any
    @Published var selectedAmount: Int = 10
    
    private let service = TriviaService()
    
    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }
    
    func startGame() async {
        currentIndex = 0
        score = 0
        streak = 0
        isGameOver = false
        hasStarted = true
        await load()
    }
    
    func load() async {
        state = .loading
        highScore = UserDefaults.standard.integer(forKey: "highScore_QuizRush")
        do {
            questions = try await service.fetchQuestions(
                amount: selectedAmount,
                category: selectedCategory,
                difficulty: selectedDifficulty,
                type: selectedType
            )
            state = .loaded
        } catch {
            print("Error fetching questions: \(error)")
            state = .failed
        }
    }
    
    func handleAnswer(_ answer: String) {
        guard let current = currentQuestion else { return }
        
        if answer == current.correctAnswer {
            score += 10
            streak += 1
        } else {
            streak = 0
            score = max(0, score - 5)
        }
        
        // Advance or end game
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isGameOver = true
            saveHighScore()
        }
    }
    
    // NEW: Save score to match the key in your HomeView
    private func saveHighScore() {
        let currentHighScore = UserDefaults.standard.integer(forKey: "highScore_QuizRush")
        if score > currentHighScore {
            UserDefaults.standard.set(score, forKey: "highScore_QuizRush")
            highScore = score
        } else {
            highScore = currentHighScore
        }
        let coords = LocationManager.shared.getLatLng()
        GameSessionStore.save(GameSession(mode: "QuizRush", score: score, latitude: coords?.latitude, longitude: coords?.longitude))
    }
    
    func resetToMenu() {
        isGameOver = false
        hasStarted = false
    }
    
    // NEW: Reset game state and pull questions again with current settings
    func resetGame() async {
        await startGame()
    }
}
