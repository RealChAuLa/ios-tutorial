//
//  ContentView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-06.
//

import SwiftUI
internal import Combine

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameActive = true
    
    var body: some View {
        // If game is running, show the game view
        if isGameActive {
            VStack(spacing: 50) {
                Text("Time: \(timeRemaining)s")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text("Tap Frenzy")
                    .font(.largeTitle)
                    .bold()
                
                Text("Score: \(score)")
                    .font(.title)
                
                Button(action: {
                    score += 1
                }) {
                    Text("TAP ME")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 150, height: 150)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    isGameActive = false
                }
            }
        } else {
            // Else, show the Game Over view
            VStack(spacing: 30) {
                Text("Game Over!")
                    .font(.largeTitle)
                    .bold()
                
                Text("Final Score: \(score)")
                    .font(.title)
                
                Button("Play Again") {
                    // Reset variables
                    score = 0
                    timeRemaining = 10
                    isGameActive = true
                }
                .font(.headline)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    ContentView()
}
