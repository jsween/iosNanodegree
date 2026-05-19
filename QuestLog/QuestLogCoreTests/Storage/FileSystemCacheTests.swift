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

        let todos = [Todo(title: "Test")]
        try cache.save(todos: todos)
        let loaded = try cache.load()
        #expect(loaded?.count == 1)
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

        let todo = Todo(title: "Slay the dragon")
        try cache.save(todos: [todo])
        let loaded = try cache.load()
        #expect(loaded?.first?.title == todo.title)
    }
}
