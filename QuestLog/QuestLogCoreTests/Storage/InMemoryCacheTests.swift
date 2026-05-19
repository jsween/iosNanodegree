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
        let todos = [Todo(title: "Test")]
        try cache.save(todos: todos)
        let loaded = try cache.load()
        #expect(loaded?.count == 1)
    }

    @Test func loadReturnsNilWhenEmpty() throws {
        let loaded = try cache.load()
        #expect(loaded == nil)
    }
}
