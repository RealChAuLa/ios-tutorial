//
//  View.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-28.
//
import SwiftUI

struct QuizRushView: View {
    // Connects the View to the ViewModel
    @StateObject private var viewModel = QuizRushViewModel()
    
    var body: some View {
        Group {
            // Switch based on the current network state
            switch viewModel.state {
            case .loading:
                ProgressView("Loading Trivia...")
                    .scaleEffect(1.5)
                
            case .failed:
                VStack(spacing: 20) {
                    Text("Failed to load questions.")
                        .font(.headline)
                    Button("Retry") {
                        Task { await viewModel.load() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .loaded:
                // unwrap the current question to  UI
                if let currentQuestion = viewModel.currentQuestion {
                    gameLayout(for: currentQuestion)
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        // Fetches data automatically when the view appears
        .task {
            await viewModel.load()
        }
    }
    
    // seperated  the UI layout into a helper function to keep the switch statement clean
    @ViewBuilder
    func gameLayout(for question: TriviaQuestion) -> some View {
        VStack(spacing: 20) {
            // Header: Stats
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .fontWeight(.bold)
                Spacer()
                Text("Score: \(viewModel.score) | Streak: \(viewModel.streak)")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
            
            // Body: Question
            Text(question.question)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
                .id(viewModel.currentIndex)
            
            Spacer()
            
            // Footer: Answer Buttons
            VStack(spacing: 15) {
                let allAnswers = (question.incorrectAnswers + [question.correctAnswer]).shuffled()
                
                ForEach(allAnswers, id: \.self) { answer in
                    Button(action: {
                        viewModel.handleAnswer(answer)
                    }) {
                        Text(answer)
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
