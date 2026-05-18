//
//  TodosManager.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation

import Testing
@testable import QuestLogCore

struct TodosManagerTests {

    var newTask = Todo(title: "first title")

    @Test func titleStoredCorrectly() {
        #expect(newTask.title == "First Title")
    }

    @Test func isDoneDefaultsFalse() {
        #expect(newTask.isDone == false)
    }

    @Test mutating func isDoneCanBeToggled() {
        newTask.isDone.toggle()
        #expect(newTask.isDone)
    }

    @Test func idIsUnique() {
        let anotherTask = Todo(title: "another title")
        #expect(newTask.id != anotherTask.id)
    }
}
