//
//  ContentView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-06.
//

import SwiftUI

struct ContentView: View {
    @State var score = 0
    @State var timeRemaining = 10
    @State var isGameActive = true
    
    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Text("Tap Frenzy")
                    .font(.title)
                Spacer()
                Text("Time: \(timeRemaining)s")
                    .font(.headline)
            }
            .padding()
            
            Text("Score: \(score)")
                .font(.system(size: 32))
            
            Spacer()
            
            Button(action: {
                if isGameActive {
                    score += 1
                }
            }) {
                Text("TAP ME")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .disabled(!isGameActive)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .onReceive(Timer.publish(every: 1).autoconnect()) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isGameActive = false
            }
        }
    }
}

#Preview {
    ContentView()
}
