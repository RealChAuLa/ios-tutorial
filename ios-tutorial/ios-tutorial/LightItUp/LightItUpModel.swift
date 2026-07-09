//
//  Model.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-06-14.
//

import Foundation

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
