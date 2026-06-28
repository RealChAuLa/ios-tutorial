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
    @State private var questionNumber = 1
    
    // Hardcoded dummy data to visualize the UI
    let dummyQuestion = "Who invented the World Wide Web?"
    let dummyAnswers = ["Bill Gates", "Steve Jobs", "Tim Berners-Lee", "Mark Zuckerberg"].shuffled()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header: Stats
            HStack {
                Text("Question \(questionNumber) of 10")
                    .fontWeight(.bold)
                Spacer()
                Text("Score: \(score) | Streak: \(streak)")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
            
            // Body: Question
            Text(dummyQuestion)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Footer: Answer Buttons
            VStack(spacing: 15) {
                ForEach(dummyAnswers, id: \.self) { answer in
                    Button(action: {
                        // for testing tap
                        print("User tapped: \(answer)")
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
}

#Preview {
    NavigationStack {
        QuizRushView()
    }
}
