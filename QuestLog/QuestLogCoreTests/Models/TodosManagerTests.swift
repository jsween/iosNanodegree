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
        let (manager, cache) = makeManagerAndCache(testName: "initWithoutTasks")
        defer { try? cache.deleteFile() }
        
        let allTasks: [Todo] = manager.listTodos()
        #expect(allTasks.isEmpty)
    }

    @Test func addingATask() {
        let (manager, cache) = makeManagerAndCache(testName: "addingATask")
        defer { try? cache.deleteFile() }
        
        manager.add("Task1")
        #expect(manager.listTodos().count == 1)
    }

    @Test func fetchByIdReturnsWhenMatch() {
        let (manager, cache) = makeManagerAndCache(testName: "fetchByIdReturnsWhenMatch")
        defer { try? cache.deleteFile() }
        
        manager.add("T")
        let todoItem = manager.listTodos().first!
        let id = todoItem.id
        let fetchedTodo = manager.fetchBy(id: id)
        #expect(todoItem == fetchedTodo)
    }

    @Test func fetchByIdReturnsNilWhenNoMatch() {
        let (manager, cache) = makeManagerAndCache(testName: "fetchByIdReturnsNilWhenNoMatch")
        defer { try? cache.deleteFile() }
        
        manager.add("T")
        let todoItem = Todo(title: "X")
        let fetchedTodo = manager.fetchBy(id: todoItem.id)
        #expect(fetchedTodo == nil)
    }

    @Test func fetchAllReturnsAllTasks() {
        let (manager, cache) = makeManagerAndCache(testName: "fetchAllReturnsAllTasks")
        defer { try? cache.deleteFile() }
        
        manager.add("Task1")
        #expect(manager.listTodos().count == 1)
        manager.add("Task2")
        #expect(manager.listTodos().count == 2)
        manager.add("Task3")
        #expect(manager.listTodos().count == 3)
    }

    @Test func toggleIsDoneByUuid() {
        let (manager, cache) = makeManagerAndCache(testName: "toggleIsDoneByUuid")
        defer { try? cache.deleteFile() }
        
        manager.add("T")
        var isDone = manager.toggleCompletion(at: 0)
        #expect(isDone == true)
        isDone = manager.toggleCompletion(at: 0)
        #expect(isDone == false)
    }

    @Test func deleteByIndex() {
        let (manager, cache) = makeManagerAndCache(testName: "deleteByIndex")
        defer { try? cache.deleteFile() }
        
        manager.add("T")
        #expect(manager.listTodos().count == 1)
        manager.deleteTodo(at: 0)
        #expect(manager.listTodos().isEmpty)
    }

    @Test func deleteAll() {
        let (manager, cache) = makeManagerAndCache(testName: "deleteAll")
        defer { try? cache.deleteFile() }
        
        manager.add("Task1")
        manager.add("Task2")
        manager.add("Task3")
        manager.deleteAll()
        #expect(manager.listTodos().count == 0)
    }

    @Test func penaltyReducesHealth() {
        let (manager, cache) = makeManagerAndCache(testName: "penaltyReducesHealth")
        defer { try? cache.deleteFile() }
        
        let initial = manager.getHealth()
        manager.applyPenalty(10)
        #expect(manager.getHealth() == initial - 10)
    }

    @Test func healthFloorIsZero() {
        let (manager, cache) = makeManagerAndCache(testName: "healthFloorIsZero")
        defer { try? cache.deleteFile() }
        
        manager.applyPenalty(999)
        #expect(manager.getHealth() == 0)
    }
    
    // MARK: - Health Roll Tests
    
    @Test func applyHealthRollIncreasesHealthWhenCompleted() {
        let (manager, cache) = makeManagerAndCache(testName: "applyHealthRollIncreasesHealthWhenCompleted")
        defer { try? cache.deleteFile() }
        
        let initialHealth = manager.getHealth()
        let roll = manager.applyHealthRoll(isDone: true)
        
        // Health should increase by at least the minimum roll (2)
        #expect(manager.getHealth() >= initialHealth)
        #expect(roll.total > 0)
    }
    
    @Test func applyHealthRollDecreasesHealthWhenAbandoned() {
        let (manager, cache) = makeManagerAndCache(testName: "applyHealthRollDecreasesHealthWhenAbandoned")
        defer { try? cache.deleteFile() }
        
        let initialHealth = manager.getHealth()
        let roll = manager.applyHealthRoll(isDone: false)
        
        // Health should decrease
        #expect(manager.getHealth() < initialHealth)
        #expect(roll.total > 0)
    }
    
    @Test func healthRollCannotReduceHealthBelowZero() {
        let (manager, cache) = makeManagerAndCache(testName: "healthRollCannotReduceHealthBelowZero")
        defer { try? cache.deleteFile() }
        
        // Reduce health to 5 HP - low enough that most rolls will exceed it
        manager.applyPenalty(95)
        #expect(manager.getHealth() == 5)
        
        // Rolling 2d6 (2-12 points) should bring health to 0, not negative
        // This validates the max(0, ...) clamp in applyHealthRoll
        _ = manager.applyHealthRoll(isDone: false)
        #expect(manager.getHealth() >= 0)
    }
    
    @Test func criticalRollDoublesTotal() {
        // Verify that critical hits properly double the dice total
        let normalRoll = DiceRoll(die1: 3, die2: 4, isCritical: false)
        let criticalRoll = DiceRoll(die1: 3, die2: 3, isCritical: true)
        
        #expect(normalRoll.total == 7)
        #expect(criticalRoll.total == 12) // (3+3) * 2
    }
    
    // MARK: - Respawn Tests
    
    @Test func respawnSetsHealthTo50() {
        let (manager, cache) = makeManagerAndCache(testName: "respawnSetsHealthTo50")
        defer { try? cache.deleteFile() }
        
        manager.applyPenalty(100) // Reduce to 0
        manager.respawn()
        #expect(manager.getHealth() == 50)
    }
    
    @Test func respawnCanBeCalledMultipleTimes() {
        let (manager, cache) = makeManagerAndCache(testName: "respawnCanBeCalledMultipleTimes")
        defer { try? cache.deleteFile() }
        
        manager.applyPenalty(100)
        manager.respawn()
        #expect(manager.getHealth() == 50)
        
        manager.applyPenalty(30)
        #expect(manager.getHealth() == 20)
        
        manager.respawn()
        #expect(manager.getHealth() == 50)
    }
    
    // MARK: - Persistence Tests
    
    @Test func addingTaskPersistsToCache() throws {
        let cache = FileSystemCache(fileName: "test-addingTaskPersists.json")
        defer { try? cache.deleteFile() }
        
        let manager = TodosManager(cache: cache)
        manager.add("Persistent Quest")
        
        // Load from cache directly to verify persistence
        let state = try cache.load()
        #expect(state?.todos.count == 1)
        #expect(state?.todos.first?.title == "Persistent Quest")
    }
    
    @Test func healthChangePersistsToCache() throws {
        let cache = FileSystemCache(fileName: "test-healthChangePersists.json")
        defer { try? cache.deleteFile() }
        
        let manager = TodosManager(cache: cache)
        manager.applyPenalty(25)
        
        // Verify health persisted
        let state = try cache.load()
        #expect(state?.health == 75)
    }
    
    @Test func statePersistedAfterRespawn() throws {
        let cache = FileSystemCache(fileName: "test-statePersistedAfterRespawn.json")
        defer { try? cache.deleteFile() }
        
        let manager = TodosManager(cache: cache)
        manager.applyPenalty(100)
        manager.respawn()
        
        let state = try cache.load()
        #expect(state?.health == 50)
    }
    
    @Test func loadsPreviousStateOnInit() throws {
        let cache = FileSystemCache(fileName: "test-loadsPreviousState.json")
        defer { try? cache.deleteFile() }
        
        // Create initial manager and add data
        let manager1 = TodosManager(cache: cache)
        manager1.add("Quest 1")
        manager1.applyPenalty(20)
        
        // Create new manager with same cache - should restore previous state
        // This simulates app restart behavior 
        let manager2 = TodosManager(cache: cache)
        #expect(manager2.listTodos().count == 1)
        #expect(manager2.getHealth() == 80)
    }
    
    // MARK: - Edge Case Tests
    
    @Test func toggleInvalidIndexReturnsNil() {
        let (manager, cache) = makeManagerAndCache(testName: "toggleInvalidIndexReturnsNil")
        defer { try? cache.deleteFile() }
        
        manager.add("Task")
        
        #expect(manager.toggleCompletion(at: -1) == nil)
        #expect(manager.toggleCompletion(at: 99) == nil)
    }
    
    @Test func fetchByInvalidIndexReturnsNil() {
        let (manager, cache) = makeManagerAndCache(testName: "fetchByInvalidIndexReturnsNil")
        defer { try? cache.deleteFile() }
        
        manager.add("Task")
        
        #expect(manager.fetchBy(index: -1) == nil)
        #expect(manager.fetchBy(index: 99) == nil)
    }
    
    @Test func deleteInvalidIndexDoesNothing() {
        let (manager, cache) = makeManagerAndCache(testName: "deleteInvalidIndexDoesNothing")
        defer { try? cache.deleteFile() }
        
        manager.add("Task")
        let countBefore = manager.listTodos().count
        
        manager.deleteTodo(at: -1)
        manager.deleteTodo(at: 99)
        
        #expect(manager.listTodos().count == countBefore)
    }
    
    @Test func fetchByIndexReturnsCorrectTodo() {
        let (manager, cache) = makeManagerAndCache(testName: "fetchByIndexReturnsCorrectTodo")
        defer { try? cache.deleteFile() }
        
        manager.add("First")
        manager.add("Second")
        manager.add("Third")
        
        let todo = manager.fetchBy(index: 1)
        #expect(todo?.title == "Second")
    }
    
    @Test func addingEmptyTitleStillCreatesTask() {
        let (manager, cache) = makeManagerAndCache(testName: "addingEmptyTitleStillCreatesTask")
        defer { try? cache.deleteFile() }
        
        // TodosManager doesn't validate title content - that's App's responsibility
        // This ensures we don't reject valid (if unusual) input at the model layer
        manager.add("")
        #expect(manager.listTodos().count == 1)
        #expect(manager.listTodos().first?.title == "")
    }
    
    @Test func multipleTogglesWorkCorrectly() {
        let (manager, cache) = makeManagerAndCache(testName: "multipleTogglesWorkCorrectly")
        defer { try? cache.deleteFile() }
        
        manager.add("Task")
        
        #expect(manager.toggleCompletion(at: 0) == true)
        #expect(manager.toggleCompletion(at: 0) == false)
        #expect(manager.toggleCompletion(at: 0) == true)
        #expect(manager.toggleCompletion(at: 0) == false)
    }
    
    // MARK: - Quest Limit Tests
    
    @Test func cannotAddMoreThan100Quests() {
        let (manager, cache) = makeManagerAndCache(testName: "cannotAddMoreThan100Quests")
        defer { try? cache.deleteFile() }
        
        // Add 100 quests (should succeed)
        for i in 1...100 {
            let success = manager.add("Quest \(i)")
            #expect(success, "Quest \(i) should have been added")
        }
        
        #expect(manager.listTodos().count == 100)
        #expect(manager.isFull())
        
        // Try to add the 101st quest (should fail)
        let failedAdd = manager.add("Quest 101")
        #expect(!failedAdd, "Should not be able to add 101st quest")
        #expect(manager.listTodos().count == 100)
    }
    
    @Test func isFullReturnsTrueAt100Quests() {
        let (manager, cache) = makeManagerAndCache(testName: "isFullReturnsTrueAt100Quests")
        defer { try? cache.deleteFile() }
        
        #expect(!manager.isFull())
        
        for i in 1...100 {
            manager.add("Quest \(i)")
        }
        
        #expect(manager.isFull())
    }
    
    @Test func isFullReturnsFalseBelow100Quests() {
        let (manager, cache) = makeManagerAndCache(testName: "isFullReturnsFalseBelow100Quests")
        defer { try? cache.deleteFile() }
        
        manager.add("Quest 1")
        #expect(!manager.isFull())
        
        for _ in 2...99 {
            manager.add("Quest")
        }
        
        #expect(!manager.isFull())
    }
    
    @Test func remainingCapacityCalculatesCorrectly() {
        let (manager, cache) = makeManagerAndCache(testName: "remainingCapacityCalculatesCorrectly")
        defer { try? cache.deleteFile() }
        
        #expect(manager.remainingCapacity() == 100)
        
        manager.add("Quest 1")
        #expect(manager.remainingCapacity() == 99)
        
        for _ in 2...50 {
            manager.add("Quest")
        }
        #expect(manager.remainingCapacity() == 50)
        
        for _ in 51...100 {
            manager.add("Quest")
        }
        #expect(manager.remainingCapacity() == 0) 
    }
    
    @Test func canAddQuestsAfterDeletingWhenFull() {
        let (manager, cache) = makeManagerAndCache(testName: "canAddQuestsAfterDeletingWhenFull")
        defer { try? cache.deleteFile() }
        
        // Fill to capacity
        for i in 1...100 {
            manager.add("Quest \(i)")
        }
        
        #expect(manager.isFull())
        
        // Try to add (should fail)
        #expect(!manager.add("Quest 101"))
        
        // Delete one quest
        manager.deleteTodo(at: 0)
        
        #expect(!manager.isFull())
        #expect(manager.remainingCapacity() == 1)
        
        // Now adding should work
        #expect(manager.add("Quest 101"))
        #expect(manager.isFull())
    }
    
    @Test func deleteAllResetsCapacity() {
        let (manager, cache) = makeManagerAndCache(testName: "deleteAllResetsCapacity")
        defer { try? cache.deleteFile() }
        
        // Fill to capacity
        for i in 1...100 {
            manager.add("Quest \(i)")
        }
        
        #expect(manager.isFull())
        #expect(manager.remainingCapacity() == 0)
        
        // Delete all
        manager.deleteAll()
        
        #expect(!manager.isFull())
        #expect(manager.remainingCapacity() == 100)
        
        // Should be able to add again
        #expect(manager.add("New Quest"))
    }
}
