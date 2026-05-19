//
//  InMemoryCacheTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Testing
@testable import QuestLogCore

struct InMemoryCacheTests {
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
}
