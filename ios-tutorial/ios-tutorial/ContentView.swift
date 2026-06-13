//
//  ContentView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Tap Frenzy")
                .font(.title)
            
            Text("Score: 0")
                .font(.system(size: 32))
            
            Button(action: {}) {
                Text("TAP ME")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    ContentView()
}
