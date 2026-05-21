//
//  InMemoryCacheTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Testing
@testable import QuestLogCore

struct InMemoryCacheTests {
    // Note: Using a shared cache instance across tests
    // This is safe for InMemoryCache since tests run in isolation
    // and each test creates a fresh state
    let cache = InMemoryCache()

    @Test func saveAndLoad() throws {
        let state = AppState(todos: [Todo(title: "Test")], health: 100)
        try cache.save(state: state)
        let loaded = try cache.load()
        #expect(loaded?.todos.count == 1)
    }

    @Test func loadReturnsNilWhenEmpty() throws {
        let loaded = try cache.load()
        #expect(loaded == nil)
    }
    
    @Test func overwritesPreviousValue() throws {
        let state1 = AppState(todos: [Todo(title: "First")], health: 100)
        try cache.save(state: state1)
        
        let state2 = AppState(todos: [Todo(title: "Second")], health: 75)
        try cache.save(state: state2)
        
        let loaded = try cache.load()
        #expect(loaded?.todos.first?.title == "Second")
        #expect(loaded?.health == 75)
    }
    
    @Test func multipleSavesAndLoads() throws {
        for i in 1...5 {
            let state = AppState(todos: [Todo(title: "Task \(i)")], health: i * 10)
            try cache.save(state: state)
            
            let loaded = try cache.load()
            #expect(loaded?.todos.first?.title == "Task \(i)")
            #expect(loaded?.health == i * 10)
        }
    }
}
