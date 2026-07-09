//
//  Model.swift
//  ios-tutorial
//
//  TapFrenzy game rules, types, and constants.
//

import SwiftUI

// MARK: - Challenge Type

enum Challenge: CaseIterable, Equatable {
    case combo
    case trapColour
}

// MARK: - Trap Colour Rules

struct TrapColourRule {
    let color: Color
    let points: Int
}

let trapColourRules: [TrapColourRule] = [
    TrapColourRule(color: .green, points: +3),   // bonus
    TrapColourRule(color: .blue,  points: +1),   // normal
    TrapColourRule(color: .gray,  points: -2),   // penalty
]

// MARK: - Combo Constants

let comboWindow: TimeInterval = 0.5
