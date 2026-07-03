//
//  View.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-28.
//
import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    
    var body: some View {
        Group {
            // NEW: Show the end screen if the game is over
            if viewModel.isGameOver {
                gameOverScreen
            } else {
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
                    if let currentQuestion = viewModel.currentQuestion {
                        gameLayout(for: currentQuestion)
                    }
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
    
    // NEW: The End Screen Layout
    private var gameOverScreen: some View {
        VStack(spacing: 30) {
            Text("Quiz Complete!")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            VStack(spacing: 10) {
                Text("Final Score")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text("\(viewModel.score)")
                    .font(.system(size: 60, weight: .bold))
            }
            
            Button(action: {
                Task { await viewModel.resetGame() }
            }) {
                Text("Play Again")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(width: 250, height: 60)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
    }
    
    // EXISTING: Your game layout (unchanged)
    @ViewBuilder
    func gameLayout(for question: TriviaQuestion) -> some View {
        VStack(spacing: 20) {
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
            
            Text(question.question)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
                .id(viewModel.currentIndex)
            
            Spacer()
            
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
