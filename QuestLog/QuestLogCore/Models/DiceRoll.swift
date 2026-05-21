//
//  DiceRoll.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation

/// Represents the result of rolling two six-sided dice (2d6).
/// Supports critical hit mechanics where rolling doubles causes damage/healing to be doubled.
/// Used in the QuestLog game to determine health changes when completing or abandoning quests.
public struct DiceRoll {
    /// The value of the first die (1-6)
    public let die1: Int
    
    /// The value of the second die (1-6)
    public let die2: Int
    
    /// Whether this roll is a critical hit (both dice show the same value)
    public let isCritical: Bool
    
    /// The total value of the roll.
    /// For normal rolls, this is the sum of both dice.
    /// For critical rolls (doubles), this is the sum multiplied by 2.
    public var total: Int {
        isCritical ? (die1 + die2) * 2 : die1 + die2
    }

    /// Rolls two six-sided dice and determines if the result is critical.
    ///
    /// - Returns: A DiceRoll with random values for both dice.
    ///   The roll is marked as critical if both dice show the same number.
    ///
    /// Example results:
    /// - Roll (3, 5): normal roll, total = 8
    /// - Roll (4, 4): critical roll, total = 16 (doubled)
    public static func roll2d6() -> DiceRoll {
        // Generate random values for each die
        let die1 = Int.random(in: 1...6)
        let die2 = Int.random(in: 1...6)
        
        // Critical hit occurs when both dice match (doubles)
        let isCritical = die1 == die2
        
        return DiceRoll(die1: die1, die2: die2, isCritical: isCritical)
    }
}
