//
//  TodosManagerPerformanceTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/20/26.
//

import Testing
import Foundation
@testable import QuestLogCore

/// Performance tests to ensure TodosManager operations remain fast at scale.
struct TodosManagerPerfTests {
    
    // MARK: - Helper Methods
    
    /// Creates a manager pre-loaded with the specified number of quests
    func makeManagerWithQuests(count: Int, testName: String) -> (TodosManager, InMemoryCache) {
        let cache = InMemoryCache()
        let manager = TodosManager(cache: cache)
        
        for i in 1...count {
            manager.add("Quest \(i)")
        }
        
        return (manager, cache)
    }
    
    /// Measures execution time of a block and returns duration in seconds
    func measure(_ block: () -> Void) -> TimeInterval {
        let start = Date()
        block()
        let end = Date()
        return end.timeIntervalSince(start)
    }
    
    // MARK: - Performance Tests at Scale
    
    @Test func addingQuestsAtMaxScale() {
        let cache = InMemoryCache()
        let manager = TodosManager(cache: cache)
        
        let duration = measure {
            // Add 100 quests (maximum design capacity)
            for i in 1...100 {
                manager.add("Quest \(i)")
            }
        }
        
        // All 100 additions should complete in under 1 second
        // This ensures the app remains responsive even when hitting the limit
        #expect(duration < 1.0, "Adding 100 quests took \(duration)s (expected < 1.0s)")
        #expect(manager.listTodos().count == 100)
    }
    
    @Test func listingAllQuestsAtMaxScale() {
        let (manager, _) = makeManagerWithQuests(count: 100, testName: "listingAllQuests")
        
        let duration = measure {
            // List all 100 quests
            _ = manager.listTodos()
        }
        
        // Listing should be near-instantaneous (< 10ms)
        // This is a simple array access, so should be very fast
        #expect(duration < 0.01, "Listing 100 quests took \(duration)s (expected < 0.01s)")
    }
    
    @Test func fetchingByIndexAtMaxScale() {
        let (manager, _) = makeManagerWithQuests(count: 100, testName: "fetchingByIndex")
        
        let duration = measure {
            // Fetch all quests by index
            for i in 0..<100 {
                _ = manager.fetchBy(index: i)
            }
        }
        
        // 100 index lookups should be very fast (< 10ms)
        // Array index access is O(1)
        #expect(duration < 0.01, "100 index fetches took \(duration)s (expected < 0.01s)")
    }
    
    @Test func fetchingByIdAtMaxScale() {
        let (manager, _) = makeManagerWithQuests(count: 100, testName: "fetchingById")
        let todos = manager.listTodos()
        
        let duration = measure {
            // Fetch all quests by UUID
            for todo in todos {
                _ = manager.fetchBy(id: todo.id)
            }
        }
        
        // 100 UUID lookups involve linear search, but should still be fast (< 50ms)
        // first(where:) is O(n) but with n=100, should be acceptable
        #expect(duration < 0.05, "100 UUID fetches took \(duration)s (expected < 0.05s)")
    }
    
    @Test func togglingCompletionAtMaxScale() {
        let (manager, _) = makeManagerWithQuests(count: 100, testName: "togglingCompletion")
        
        let duration = measure {
            // Toggle all quests
            for i in 0..<100 {
                _ = manager.toggleCompletion(at: i)
            }
        }
        
        // 100 toggles with persistence should complete in under 2 seconds
        // Each toggle triggers a persist() call to InMemoryCache
        #expect(duration < 2.0, "100 toggles took \(duration)s (expected < 2.0s)")
        
        // Verify all were toggled
        let allComplete = manager.listTodos().allSatisfy { $0.isDone }
        #expect(allComplete)
    }
    
    @Test func deletingQuestsAtMaxScale() {
        let (manager, _) = makeManagerWithQuests(count: 100, testName: "deletingQuests")
        
        let duration = measure {
            // Delete all quests from the end (most efficient)
            for i in 0..<100 {
                manager.deleteTodo(at: 99 - i)
            }
        }
        
        // Deleting 100 quests should complete in under 2 seconds
        #expect(duration < 2.0, "Deleting 100 quests took \(duration)s (expected < 2.0s)")
        #expect(manager.listTodos().isEmpty)
    }
    
    @Test func deleteAllAtMaxScale() {
        let (manager, _) = makeManagerWithQuests(count: 100, testName: "deleteAll")
        
        let duration = measure {
            manager.deleteAll()
        }
        
        // deleteAll() should be instant regardless of size (< 10ms)
        #expect(duration < 0.01, "deleteAll with 100 quests took \(duration)s (expected < 0.01s)")
        #expect(manager.listTodos().isEmpty)
    }
    
    @Test func applyingHealthRollsAtScale() {
        let cache = InMemoryCache()
        let manager = TodosManager(cache: cache)
        
        let duration = measure {
            // Apply 100 health rolls (50 gains, 50 losses)
            for i in 0..<100 {
                _ = manager.applyHealthRoll(isDone: i % 2 == 0)
            }
        }
        
        // 100 dice rolls with RNG should be fast (< 100ms)
        #expect(duration < 0.1, "100 health rolls took \(duration)s (expected < 0.1s)")
    }
    
    @Test func mixedOperationsAtScale() {
        let cache = InMemoryCache()
        let manager = TodosManager(cache: cache)
        
        let duration = measure {
            // Simulate realistic mixed usage: add, list, toggle, delete
            for i in 0..<25 {
                manager.add("Quest \(i)")
                _ = manager.listTodos()
                if i > 0 {
                    _ = manager.toggleCompletion(at: i - 1)
                }
            }
            
            // Delete some quests
            for _ in 0..<10 {
                manager.deleteTodo(at: 0)
            }
            
            // Add more
            for i in 25..<50 {
                manager.add("Quest \(i)")
            }
        }
        
        // Mixed operations should feel responsive (< 500ms)
        #expect(duration < 0.5, "Mixed operations took \(duration)s (expected < 0.5s)")
    }
    
    // MARK: - Persistence Performance Tests
    
    @Test func fileSystemPersistenceAtMaxScale() throws {
        let cache = FileSystemCache(fileName: "test-perfMaxScale.json")
        defer { try? cache.deleteFile() }
        
        let manager = TodosManager(cache: cache)
        
        // Add 100 quests - each triggers a file write
        let duration = measure {
            for i in 1...100 {
                manager.add("Quest \(i)")
            }
        }
        
        // File I/O is slower, but should still be acceptable (< 5 seconds)
        // This is the real bottleneck - disk writes
        #expect(duration < 5.0, "100 file writes took \(duration)s (expected < 5.0s)")
        
        // Verify persistence
        let state = try cache.load()
        #expect(state?.todos.count == 100)
    }
    
    @Test func loadingMaxScaleFromDisk() throws {
        let cache = FileSystemCache(fileName: "test-perfLoadMaxScale.json")
        defer { try? cache.deleteFile() }
        
        // Pre-populate cache with 100 quests
        let todos = (1...100).map { Todo(title: "Quest \($0)") }
        let state = AppState(todos: todos, health: 100)
        try cache.save(state: state)
        
        // Measure load time
        let duration = measure {
            _ = TodosManager(cache: cache)
        }
        
        // Loading 100 quests from disk should be fast (< 100ms)
        #expect(duration < 0.1, "Loading 100 quests from disk took \(duration)s (expected < 0.1s)")
    }
    
    // MARK: - Memory Tests
    
    @Test func memoryUsageAtMaxScale() {
        let cache = InMemoryCache()
        let manager = TodosManager(cache: cache)
        
        // Add 100 quests
        for i in 1...100 {
            manager.add("Quest \(i) with a reasonably long description to simulate real usage")
        }
        
        // Get all todos - verify we can hold them in memory
        let todos = manager.listTodos()
        #expect(todos.count == 100)
        
        // Each Todo has: UUID (16 bytes) + String + Bool (~1 byte)
        // 100 todos should use < 50KB of memory (very reasonable)
        // This test doesn't measure memory directly, but ensures no crashes
        
        // Perform multiple operations to ensure memory is stable
        for i in 0..<100 {
            _ = manager.fetchBy(index: i)
            _ = manager.toggleCompletion(at: i)
        }
        
        #expect(manager.listTodos().count == 100)
    }
    
    // MARK: - Edge Case Performance
    
    @Test func worstCaseScenario() {
        let cache = InMemoryCache()
        let manager = TodosManager(cache: cache)
        
        let duration = measure {
            // Add 100 quests
            for i in 1...100 {
                manager.add("Quest \(i)")
            }
            
            // Toggle all (100 operations)
            for i in 0..<100 {
                _ = manager.toggleCompletion(at: i)
            }
            
            // Fetch by UUID (worst case - linear search each time)
            let todos = manager.listTodos()
            for todo in todos {
                _ = manager.fetchBy(id: todo.id)
            }
            
            // Apply penalties
            for _ in 0..<100 {
                manager.applyPenalty(1)
            }
            
            // Delete all
            manager.deleteAll()
        }
        
        // Even worst-case usage should complete in under 5 seconds
        #expect(duration < 5.0, "Worst-case scenario took \(duration)s (expected < 5.0s)")
    }
    
    // MARK: - Regression Tests
    
    @Test func performanceDoesNotDegradeWithRepeatedUse() {
        let cache = InMemoryCache()
        let manager = TodosManager(cache: cache)
        
        var durations: [TimeInterval] = []
        
        // Perform the same operation 10 times
        for _ in 0..<10 {
            let duration = measure {
                // Add 50 quests
                for i in 1...50 {
                    manager.add("Quest \(i)")
                }
                
                // Delete all
                manager.deleteAll()
            }
            durations.append(duration)
        }
        
        // Ensure performance doesn't degrade over iterations
        // Last iteration should not be significantly slower than first
        let firstDuration = durations.first!
        let lastDuration = durations.last!
        
        // Allow for 50% variance due to system load, but catch major degradation
        #expect(lastDuration < firstDuration * 1.5,
                "Performance degraded: first=\(firstDuration)s, last=\(lastDuration)s")
    }
}
