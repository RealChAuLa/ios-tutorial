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
    @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(index == litIndex ? Color.green : Color.gray)
                    .frame(width: 100, height: 100)
                    .onTapGesture {litIndex = index
                    }
            }
        }
        .onReceive(timer) { _ in
            litIndex = Int.random(in: 0..<3)
        }
    }
}
#Preview {
    LightItUpView()
}
