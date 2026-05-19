//
//  TodosManagerTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Testing
@testable import QuestLogCore

struct TodosManagerTests {
    
    /// Helper to create an isolated TodosManager with its own cache file
    /// Returns a tuple of (manager, cache) where cache should be cleaned up with defer
    func makeManagerAndCache(testName: String) -> (manager: TodosManager, cache: FileSystemCache) {
        let cache = FileSystemCache(fileName: "test-\(testName).json")
        let manager = TodosManager(cache: cache)
        return (manager, cache)
    }

    @Test func initWithoutTasks() {
        let cache = FileSystemCache(fileName: "test-initWithoutTasks.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        let allTasks: [Todo] = manager.listTodos()
        #expect(allTasks.isEmpty)
    }

    @Test func addingATask() {
        let cache = FileSystemCache(fileName: "test-addingATask.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        manager.add("Task1")
        #expect(manager.listTodos().count == 1)
    }

    @Test func fetchByIdReturnsWhenMatch() {
        let cache = FileSystemCache(fileName: "test-fetchByIdReturnsWhenMatch.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        manager.add("T")
        let todoItem = manager.listTodos().first!
        let id = todoItem.id
        let fetchedTodo = manager.fetchBy(id: id)
        #expect(todoItem == fetchedTodo)
    }

    @Test func fetchByIdReturnsNilWhenNoMatch() {
        let cache = FileSystemCache(fileName: "test-fetchByIdReturnsNilWhenNoMatch.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        manager.add("T")
        let todoItem = Todo(title: "X")
        let fetchedTodo = manager.fetchBy(id: todoItem.id)
        #expect(fetchedTodo == nil)
    }

    @Test func fetchAllReturnsAllTasks() {
        let cache = FileSystemCache(fileName: "test-fetchAllReturnsAllTasks.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        manager.add("Task1")
        #expect(manager.listTodos().count == 1)
        manager.add("Task2")
        #expect(manager.listTodos().count == 2)
        manager.add("Task3")
        #expect(manager.listTodos().count == 3)
    }

    @Test func toggleIsDoneByUuid() {
        let cache = FileSystemCache(fileName: "test-toggleIsDoneByUuid.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        manager.add("T")
        var isDone = manager.toggleCompletion(at: 0)
        #expect(isDone == true)
        isDone = manager.toggleCompletion(at: 0)
        #expect(isDone == false)
    }

    @Test func deleteByIndex() {
        let cache = FileSystemCache(fileName: "test-deleteByIndex.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        manager.add("T")
        #expect(manager.listTodos().count == 1)
        manager.deleteTodo(at: 0)
        #expect(manager.listTodos().isEmpty)
    }

    @Test func deleteAll() {
        let cache = FileSystemCache(fileName: "test-deleteAll.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        manager.add("Task1")
        manager.add("Task2")
        manager.add("Task3")
        manager.deleteAll()
        #expect(manager.listTodos().count == 0)
    }

    @Test func penaltyReducesHealth() {
        let cache = FileSystemCache(fileName: "test-penaltyReducesHealth.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        let initial = manager.getHealth()
        manager.applyPenalty(10)
        #expect(manager.getHealth() == initial - 10)
    }

    @Test func healthFloorIsZero() {
        let cache = FileSystemCache(fileName: "test-healthFloorIsZero.json")
        defer { try? cache.deleteFile() }
        let manager = TodosManager(cache: cache)
        
        manager.applyPenalty(999)
        #expect(manager.getHealth() == 0)
    }
}
