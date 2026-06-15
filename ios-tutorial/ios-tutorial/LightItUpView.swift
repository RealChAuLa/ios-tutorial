//
//  LightItUpView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-14.
//

import SwiftUI
import Combine

struct GameLevel {
    let cardCount: Int
    let litCount: Int
    let interval: TimeInterval
    let name: String
}

let levels: [GameLevel] = [
    GameLevel(cardCount: 3, litCount: 1, interval: 1.5, name: "L1"),
    GameLevel(cardCount: 4, litCount: 1, interval: 1.2, name: "L2"),
    GameLevel(cardCount: 6, litCount: 1, interval: 1.0, name: "L3"),
    GameLevel(cardCount: 9, litCount: 2, interval: 0.8, name: "L4"),
]

struct LightItUpView: View {
    @AppStorage("highScore_lightItUp") private var highScore = 0
    @State private var litIndices: Set<Int> = [0]
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var isGameActive = false   // ← changed to false
    @State private var hasStarted = false     // ← new
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var litTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    @State private var elapsed = 0
    @State private var levelIndex = 0

    var currentLevel: GameLevel { levels[levelIndex] }
    
    var body: some View {
        VStack(spacing: 40) {
            if !hasStarted {
                Text("High Score: \(highScore)").font(.headline).foregroundColor(.yellow)
                Button("Start") { startGame() }
                    .font(.headline).padding()
                    .background(Color.green).foregroundColor(.white)
                    .cornerRadius(10)
                
            } else if isGameActive {
                Text("Score: \(score)").font(.title).bold()
                
                let columns = Array(
                        repeating: GridItem(.flexible()),
                        count: currentLevel.cardCount <= 4 ? currentLevel.cardCount : 3
                    )
                
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(0..<currentLevel.cardCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(litIndices.contains(index) ? Color.yellow : Color.gray)
                            .frame(height: 125)
                            .onTapGesture {
                                if litIndices.contains(index) { score += 1 } else { score -= 1 }
                            }
                    }
                }
                .padding()
                
                HStack {
                    Text("Best: \(highScore)").foregroundColor(.purple)
                    Spacer()
                    Text("Time: \(timeRemaining)s").foregroundColor(.red)
                    Text(currentLevel.name).foregroundColor(.blue).bold()
                }
                .font(.headline)
                .padding(.horizontal)
                
            } else {
                VStack(spacing: 20) {
                    Text("Game Over!").font(.largeTitle).bold()
                    Text("Final Score: \(score)").font(.title)
                    Button("Play Again") { startGame() }
                        .font(.headline).padding()
                        .background(Color.blue).foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .onReceive(timer) { _ in
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
                    litTimer = Timer.publish(every: levels[newIndex].interval, on: .main, in: .common).autoconnect()
                }
            } else {
                isGameActive = false
                if score > highScore { highScore = score }
            }
        }
        .onReceive(litTimer) { _ in
            guard isGameActive else { return }
            let count = currentLevel.litCount
            let picks = Array((0..<currentLevel.cardCount).shuffled().prefix(count))
            litIndices = Set(picks)
        }
    }

    func startGame() {
        score = 0
        timeRemaining = 60
        litIndices = [0]
        elapsed = 0
        levelIndex = 0
        hasStarted = true
        isGameActive = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        litTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    }
}

#Preview {
    LightItUpView()
}
