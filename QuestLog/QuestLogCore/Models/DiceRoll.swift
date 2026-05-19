//
//  DiceRoll.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation

/// Simulate 2 six-sided dice being rolled
public struct DiceRoll {
    public let die1: Int
    public let die2: Int
    public let isCritical: Bool
    public var total: Int {
        isCritical ? (die1 + die2) * 2 : die1 + die2
    }

    public static func roll2d6() -> DiceRoll {
        let die1 = Int.random(in: 1...6)
        let die2 = Int.random(in: 1...6)
        let isCritical = die1 == die2 // double roll = critical
        return DiceRoll(die1: die1, die2: die2, isCritical: isCritical)
    }
}
