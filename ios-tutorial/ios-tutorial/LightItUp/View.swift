//
//  View.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-14.
//

import SwiftUI

struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            if !viewModel.hasStarted {
                Text("High Score: \(viewModel.highScore)").font(.headline).foregroundColor(.yellow)
                Button("Start") { viewModel.startGame() }
                    .font(.headline).padding()
                    .background(Color.green).foregroundColor(.white)
                    .cornerRadius(10)
                
            } else if viewModel.isGameActive {
                Text("Score: \(viewModel.score)").font(.title).bold()
                
                let columns = Array(
                        repeating: GridItem(.flexible()),
                        count: viewModel.currentLevel.cardCount <= 4 ? viewModel.currentLevel.cardCount : 3
                    )
                
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(0..<viewModel.currentLevel.cardCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.litIndices.contains(index) ? Color.yellow : Color.gray)
                            .frame(height: 125)
                            .onTapGesture {
                                viewModel.cardTapped(at: index)
                            }
                    }
                }
                .padding()
                
                HStack {
                    Text("Best: \(viewModel.highScore)").foregroundColor(.purple)
                    Spacer()
                    Text("Time: \(viewModel.timeRemaining)s").foregroundColor(.red)
                    Text(viewModel.currentLevel.name).foregroundColor(.blue).bold()
                }
                .font(.headline)
                .padding(.horizontal)
                
            } else {
                VStack(spacing: 20) {
                    Text("Game Over!").font(.largeTitle).bold()
                    Text("Final Score: \(viewModel.score)").font(.title)
                    Button("Play Again") { viewModel.startGame() }
                        .font(.headline).padding()
                        .background(Color.blue).foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    LightItUpView()
}
