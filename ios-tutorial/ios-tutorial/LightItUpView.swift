//
//  LightItUpView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-14.
//

import SwiftUI
import Combine

struct LightItUpView: View {
    @State private var litIndex = 0
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var isGameActive = false   // ← changed to false
    @State private var hasStarted = false     // ← new
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var litTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 40) {
            if !hasStarted {
                Button("Start") { startGame() }
                    .font(.headline).padding()
                    .background(Color.green).foregroundColor(.white)
                    .cornerRadius(10)

            } else if isGameActive {
                Text("Score: \(score)").font(.title).bold()
                HStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(index == litIndex ? Color.yellow : Color.gray)
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                if index == litIndex { score += 1 } else { score -= 1 }
                            }
                    }
                }
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
            Text("Time: \(timeRemaining)s").foregroundColor(.red).font(.headline)
        }
        .onReceive(timer) { _ in
            guard isGameActive else { return }
            if timeRemaining > 0 { timeRemaining -= 1 }
            else { isGameActive = false }
        }
        .onReceive(litTimer) { _ in
            guard isGameActive else { return }
            litIndex = Int.random(in: 0..<3)
        }
    }

    func startGame() {
        score = 0
        timeRemaining = 60
        litIndex = 0
        hasStarted = true
        isGameActive = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        litTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    }
}

#Preview {
    LightItUpView()
}
