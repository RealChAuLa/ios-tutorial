//
//  ViewModel.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-03.
//
import Foundation
import SwiftUI
import Combine

// @MainActor ensures all UI updates happen on the main thread, which is required when updating Views from async network calls
@MainActor
final class QuizRushViewModel: ObservableObject {
    
    // The view-state enum exactly as requested in the slides
    enum ViewState {
        case loading, loaded, failed
    }
    
    @Published var state: ViewState = .loading
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    
    private let service = TriviaService()
    
    // Helper to safely get the current question
    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }
    
    // 1. Fetch data from the Service
    func load() async {
        state = .loading
        do {
            questions = try await service.fetchQuestions()
            state = .loaded
        } catch {
            print("Error fetching questions: \(error)")
            state = .failed
        }
    }
    
    // 2. Handle the game logic when a user taps an answer
    func handleAnswer(_ answer: String) {
        guard let current = currentQuestion else { return }
        
        if answer == current.correctAnswer {
            score += 10
            streak += 1
        } else {
            streak = 0
            score = max(0, score - 5)
        }
        
        // Advance to the next question if we haven't reached the end
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        }
    }
}
