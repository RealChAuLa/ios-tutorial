//
//  View.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-28.
//
import SwiftUI

struct QuizRushView: View {
    @State private var score = 0
    @State private var streak = 0
    @State private var currentIndex = 0
    
    // 1. The dummy data pulled straight from your JSON sample
    let dummyQuestions: [TriviaQuestion] = [
        TriviaQuestion(question: "Which of these holidays is NOT usually celebrated in the month of December?", correctAnswer: "Thanksgiving", incorrectAnswers: ["Christmas", "Kwanzaa", "Hanukkah"]),
        TriviaQuestion(question: "What step in cellular respiration forms ATP?", correctAnswer: "Oxidative Phosphorylation", incorrectAnswers: ["Glycolysis", "Pyruvate Oxidation", "Calvin Cycle"]),
        TriviaQuestion(question: "When was Pong released?", correctAnswer: "November 29, 1972", incorrectAnswers: ["March 29, 2017", "November 29, 1970", "December 14, 1974"]),
        TriviaQuestion(question: "What is the French word for &quot;fish&quot;?", correctAnswer: "poisson", incorrectAnswers: ["fiche", "escargot", "mer"]),
        TriviaQuestion(question: "What is the name of the poker hand containing three of a kind and a pair?", correctAnswer: "Full House", incorrectAnswers: ["Flush", "Straight", "High card"])
    ]
    
    // 2. Helper to get the current active question
    var currentQuestion: TriviaQuestion {
        dummyQuestions[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header: Stats
            HStack {
                Text("Question \(currentIndex + 1) of \(dummyQuestions.count)")
                    .fontWeight(.bold)
                Spacer()
                Text("Score: \(score) | Streak: \(streak)")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
            
            // Body: Question
            // Note: The API returns HTML entities (like &quot;). We will fix that formatting later in the polish phase.
            Text(currentQuestion.question)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
                // A unique ID forces the text to redraw properly if questions are identical length
                .id(currentIndex)
            
            Spacer()
            
            // Footer: Answer Buttons
            VStack(spacing: 15) {
                // We combine and shuffle the answers on the fly for this dummy view
                let allAnswers = (currentQuestion.incorrectAnswers + [currentQuestion.correctAnswer]).shuffled()
                
                ForEach(allAnswers, id: \.self) { answer in
                    Button(action: {
                        handleTap(on: answer)
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
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 3. Basic local logic to test the UX
    func handleTap(on answer: String) {
        if answer == currentQuestion.correctAnswer {
            score += 10
            streak += 1
        } else {
            streak = 0
            // The slides mention a small penalty for wrong taps
            score = max(0, score - 5)
        }
        
        // Advance to next question or loop back for testing
        if currentIndex < dummyQuestions.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
