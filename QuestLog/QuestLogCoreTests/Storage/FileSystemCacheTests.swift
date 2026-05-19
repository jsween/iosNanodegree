//
//  FileSystemCacheTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Testing
@testable import QuestLogCore

struct FileSystemCacheTests {
    
    @Test func saveAndLoad() throws {
        let cache = FileSystemCache(fileName: "test-saveAndLoad.json")
        defer { try? cache.deleteFile() }

        let state = AppState(todos: [Todo(title: "Test")], health: 100)
        try cache.save(state: state)
        let loaded = try cache.load()
        #expect(loaded?.todos.count == 1)
    }

    @Test func loadReturnsNilWhenNoFile() throws {
        let cache = FileSystemCache(fileName: "test-loadReturnsNil.json")
        defer { try? cache.deleteFile() }
        
        let loaded = try cache.load()
        #expect(loaded == nil)
    }

    @Test func savedTodosMatchLoaded() throws {
        let cache = FileSystemCache(fileName: "test-savedTodosMatch.json")
        defer { try? cache.deleteFile() }

        let state = AppState(todos: [Todo(title: "Slay the dragon")], health: 100)
        try cache.save(state: state)
        let loaded = try cache.load()
        #expect(loaded?.todos.first?.title == state.todos.first?.title)
    }
}
