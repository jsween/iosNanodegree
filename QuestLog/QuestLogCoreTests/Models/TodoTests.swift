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
    
    @Test func descriptionShowsCheckmarkWhenDone() {
        let doneTask = Todo(title: "Complete", isDone: true)
        #expect(doneTask.description.contains("✅"))
        #expect(doneTask.description.contains("Complete"))
    }
    
    @Test func descriptionShowsEmptyBoxWhenNotDone() {
        let todoTask = Todo(title: "Incomplete", isDone: false)
        #expect(todoTask.description.contains("⬜"))
        #expect(todoTask.description.contains("Incomplete"))
    }
    
    @Test func equalityWorksCorrectly() {
        let task1 = Todo(title: "Same")
        let task2 = Todo(title: "Same")
        
        // Different UUIDs mean they're not equal
        #expect(task1 != task2)
        
        // Same instance is equal to itself
        #expect(task1 == task1)
    }
}
