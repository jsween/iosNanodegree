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
    
    @Test func overwritesPreviousSave() throws {
        let cache = FileSystemCache(fileName: "test-overwritesPreviousSave.json")
        defer { try? cache.deleteFile() }
        
        // First save
        let state1 = AppState(todos: [Todo(title: "First")], health: 100)
        try cache.save(state: state1)
        
        // Second save should overwrite
        let state2 = AppState(todos: [Todo(title: "Second")], health: 50)
        try cache.save(state: state2)
        
        let loaded = try cache.load()
        #expect(loaded?.todos.count == 1)
        #expect(loaded?.todos.first?.title == "Second")
        #expect(loaded?.health == 50)
    }
    
    @Test func savesHealthCorrectly() throws {
        let cache = FileSystemCache(fileName: "test-savesHealthCorrectly.json")
        defer { try? cache.deleteFile() }
        
        let state = AppState(todos: [], health: 42)
        try cache.save(state: state)
        let loaded = try cache.load()
        #expect(loaded?.health == 42)
    }
    
    @Test func deleteFileRemovesCache() throws {
        let cache = FileSystemCache(fileName: "test-deleteFileRemovesCache.json")
        
        let state = AppState(todos: [Todo(title: "Test")], health: 100)
        try cache.save(state: state)
        
        // Verify file exists
        var loaded = try cache.load()
        #expect(loaded != nil)
        
        // Delete and verify it's gone
        try cache.deleteFile()
        loaded = try cache.load()
        #expect(loaded == nil)
    }
}
