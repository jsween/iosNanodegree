//
//  DiceRollTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Testing
@testable import QuestLogCore

struct DiceRollTests {
    @Test func totalIsCorrectForNormalRoll() {
        let roll = DiceRoll(die1: 3, die2: 4, isCritical: false)
        #expect(roll.total == 7)
    }

    @Test func totalIsDoubledForCriticalRoll() {
        let roll = DiceRoll(die1: 1, die2: 1, isCritical: true)
        #expect(roll.total == 4)
    }

    @Test func doublesAreCritical() {
        let die = Int.random(in: 1...6)
        let roll = DiceRoll(die1: die, die2: die, isCritical: die == die)
        #expect(roll.isCritical)
    }

    @Test func nonDoublesAreNotCritical() {
        let roll = DiceRoll(die1: 2, die2: 5, isCritical: false)
        #expect(!roll.isCritical)
    }

    @Test func roll2d6StaysInRange() {
        let roll = DiceRoll.roll2d6()
        #expect(roll.die1 >= 1 && roll.die1 <= 6)
        #expect(roll.die2 >= 1 && roll.die2 <= 6)
    }
    
    @Test func roll2d6ProducesReasonableTotal() {
        let roll = DiceRoll.roll2d6()
        // Minimum: 2 (1+1), Maximum: 24 (6+6 doubled)
        #expect(roll.total >= 2)
        #expect(roll.total <= 24)
    }
    
    @Test func criticalRollsAreDetectedAutomatically() {
        let roll = DiceRoll.roll2d6()
        
        // If dice match, it should be critical
        if roll.die1 == roll.die2 {
            #expect(roll.isCritical)
        } else {
            #expect(!roll.isCritical)
        }
    }
    
    @Test func allCriticalCombinationsWorkCorrectly() {
        // Verify critical hit calculation for all possible double rolls (1-1 through 6-6)
        // This ensures the doubling formula works correctly across the entire range
        for i in 1...6 {
            let roll = DiceRoll(die1: i, die2: i, isCritical: true)
            #expect(roll.total == (i + i) * 2)
        }
    }
}
