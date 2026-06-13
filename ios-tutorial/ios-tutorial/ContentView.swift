//
//  ContentView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-06.
//

import SwiftUI

struct ContentView: View {
    @State var score = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Tap Frenzy")
                .font(.title)
            
            Text("Score: \(score)")
                .font(.system(size: 32))
            
            Spacer()
            
            Button(action: {
                score += 1
            }) {
                Text("TAP ME")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    ContentView()
}
