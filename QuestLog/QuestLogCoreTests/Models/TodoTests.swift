//
//  TodoTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Testing
@testable import QuestLogCore

struct TodoTests {

    var newTask = Todo(title: "first title")

    @Test func titleStoredCorrectly() {
        #expect(newTask.title == "First Title")
    }

    @Test func isDoneDefaultsFalse() {
        #expect(newTask.isDone == false)
    }

    @Test func isDoneTrueWhenPassedIn() {
        let doneTask = Todo(title: "Done Task", isDone: true)
        #expect(doneTask.isDone)
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
