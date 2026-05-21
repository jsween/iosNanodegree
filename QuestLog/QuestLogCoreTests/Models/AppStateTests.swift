//
//  AppStateTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/20/26.
//

import Foundation
import Testing
@testable import QuestLogCore

struct AppStateTests {
    
    @Test func appStateInitializesCorrectly() {
        let todos = [Todo(title: "Test Task")]
        let state = AppState(todos: todos, health: 75)
        
        #expect(state.todos.count == 1)
        #expect(state.health == 75)
    }
    
    @Test func appStateIsEquatable() {
        let todo1 = Todo(title: "Task")
        let todo2 = Todo(title: "Task")
        
        let state1 = AppState(todos: [todo1], health: 100)
        let state2 = AppState(todos: [todo1], health: 100) // Same todo instance
        let state3 = AppState(todos: [todo2], health: 100) // Different todo instance
        let state4 = AppState(todos: [todo1], health: 50)  // Different health
        
        // Same todos and health should be equal
        #expect(state1 == state2)
        
        // Different todos should not be equal (different UUIDs)
        #expect(state1 != state3)
        
        // Different health should not be equal
        #expect(state1 != state4)
    }
    
    @Test func appStatePropertiesAreImmutable() {
        let todos = [Todo(title: "Original")]
        let state = AppState(todos: todos, health: 100)
        
        // Properties should be 'let' constants
        // This test verifies the design - the code below would fail to compile
        // if properties were mutable:
        // state.health = 50  // Cannot assign to property: 'health' is a 'let' constant
        // state.todos = []   // Cannot assign to property: 'todos' is a 'let' constant
        
        #expect(state.health == 100)
        #expect(state.todos.count == 1)
    }
    
    @Test func appStateWithEmptyTodos() {
        let state = AppState(todos: [], health: 50)
        
        #expect(state.todos.isEmpty)
        #expect(state.health == 50)
    }
    
    @Test func appStateWithMultipleTodos() {
        let todos = [
            Todo(title: "First"),
            Todo(title: "Second"),
            Todo(title: "Third")
        ]
        let state = AppState(todos: todos, health: 80)
        
        #expect(state.todos.count == 3)
        #expect(state.todos[0].title == "First")
        #expect(state.todos[1].title == "Second")
        #expect(state.todos[2].title == "Third")
    }
    
    @Test func appStateWithZeroHealth() {
        let state = AppState(todos: [], health: 0)
        #expect(state.health == 0)
    }
    
    @Test func appStateWithMaxHealth() {
        let state = AppState(todos: [], health: 100)
        #expect(state.health == 100)
    }
    
    @Test func appStateCodableRoundTrip() throws {
        let todos = [
            Todo(title: "Quest 1", isDone: true),
            Todo(title: "Quest 2", isDone: false)
        ]
        let originalState = AppState(todos: todos, health: 65)
        
        // Encode to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalState)
        
        // Decode back
        let decoder = JSONDecoder()
        let decodedState = try decoder.decode(AppState.self, from: data)
        
        // Verify all properties match
        #expect(decodedState.health == originalState.health)
        #expect(decodedState.todos.count == originalState.todos.count)
        #expect(decodedState.todos[0].title == originalState.todos[0].title)
        #expect(decodedState.todos[0].isDone == originalState.todos[0].isDone)
    }
}
