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
}
