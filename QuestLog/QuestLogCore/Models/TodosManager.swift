//
//  TodosManager.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation

/// Manages the collection of todos (quests) and the player's health.
/// This is the main business logic layer that coordinates between in-memory state
/// and persistent storage via a Cache. Handles quest CRUD operations, health tracking,
/// dice rolling mechanics, and automatic persistence after state changes.
///
/// **Quest Limit:** Maximum of 100 active quests to ensure performance and usability.
public class TodosManager {
    /// Maximum number of quests allowed in the quest log
    public static let maxQuests = 100
    
    /// The in-memory collection of all quests
    private var todos: [Todo] = []
    
    /// The player's current health points (0-100).
    /// Readable externally but can only be modified through this class's methods.
    public private(set) var health: Int = 100
    
    /// The cache implementation used for persisting app state
    private let cache: Cache

    /// Creates a new TodosManager with the specified cache.
    /// Automatically loads any previously saved state from the cache.
    ///
    /// - Parameter cache: The cache implementation to use for persistence.
    ///   Defaults to FileSystemCache for production use.
    public init(cache: Cache = FileSystemCache()) {
        self.cache = cache
        
        // Attempt to load saved state from cache
        let state = try? cache.load()
        self.todos = state?.todos ?? []
        self.health = state?.health ?? 100
    }

    /// Persists the current in-memory state to the cache.
    /// Creates an AppState snapshot and saves it via the cache.
    /// Called automatically after any state-modifying operation.
    public func persist() {
        try? cache.save(state: AppState(todos: todos, health: health))
    }

    /// Adds a new quest with the given title to the quest log.
    /// Automatically persists after adding.
    ///
    /// - Parameter title: The name of the new quest
    /// - Returns: `true` if the quest was added, `false` if the quest log is full (100 quests)
    @discardableResult
    public func add(_ title: String) -> Bool {
        // Enforce maximum quest limit
        guard todos.count < Self.maxQuests else {
            return false
        }
        
        todos.append(Todo(title: title))
        persist()
        return true
    }

    /// Fetches a quest by its unique identifier.
    ///
    /// - Parameter id: The UUID of the quest to find
    /// - Returns: The matching Todo if found, nil otherwise
    public func fetchBy(id: UUID) -> Todo? {
        return todos.first(where: { $0.id == id })
    }

    /// Fetches a quest by its position in the list.
    ///
    /// - Parameter index: The zero-based index of the quest
    /// - Returns: The Todo at the specified index, or nil if the index is invalid
    public func fetchBy(index: Int) -> Todo? {
        guard index >= 0 && index < todos.count else { return nil }
        return todos[index]
    }

    /// Returns all quests in the quest log.
    ///
    /// - Returns: An array of all Todo items
    public func listTodos() -> [Todo] {
        return todos
    }
    
    /// Checks if the quest log is at maximum capacity.
    ///
    /// - Returns: `true` if the quest log has 100 quests, `false` otherwise
    public func isFull() -> Bool {
        return todos.count >= Self.maxQuests
    }
    
    /// Returns the number of remaining quest slots.
    ///
    /// - Returns: The number of quests that can still be added (0-100)
    public func remainingCapacity() -> Int {
        return max(0, Self.maxQuests - todos.count)
    }

    /// Toggles the completion status of the quest at the specified index.
    /// Automatically persists after toggling.
    ///
    /// - Parameter index: The zero-based index of the quest to toggle
    /// - Returns: The new completion status (true if now complete, false if now incomplete),
    ///   or nil if the index is invalid
    public func toggleCompletion(at index: Int) -> Bool? {
        guard index >= 0 && index < todos.count else { return nil }
        todos[index].isDone.toggle()
        persist()
        return todos[index].isDone
    }

    /// Rolls 2d6 and applies the result to the player's health.
    /// - If isDone is true: adds the roll total to health (quest completed)
    /// - If isDone is false: subtracts the roll total from health (quest abandoned)
    /// - Critical rolls (doubles) cause the amount to be doubled
    /// - Health is clamped to a minimum of 0
    ///
    /// Automatically persists after applying the roll.
    ///
    /// - Parameter isDone: Whether the quest was completed (true) or abandoned (false)
    /// - Returns: The DiceRoll result containing die values, critical status, and total
    public func applyHealthRoll(isDone: Bool) -> DiceRoll {
        // Roll the dice
        let roll = DiceRoll.roll2d6()
        
        // Apply health change (positive for completion, negative for abandonment)
        // Ensure health doesn't go below 0
        health = max(0, health + (isDone ? roll.total : -roll.total))
        persist()
        
        return roll
    }

    /// Deletes the quest at the specified index.
    /// Automatically persists after deletion.
    ///
    /// - Parameter index: The zero-based index of the quest to delete
    /// - Note: Does nothing if the index is invalid
    public func deleteTodo(at index: Int) {
        guard index >= 0 && index < todos.count else { return }
        todos.remove(at: index)
        persist()
    }

    /// Deletes all quests from the quest log.
    /// Automatically persists after deletion.
    public func deleteAll() {
        todos.removeAll()
        persist()
    }

    /// Applies a health penalty for invalid user actions.
    /// Health is clamped to a minimum of 0.
    /// Automatically persists after applying the penalty.
    ///
    /// - Parameter amount: The amount of health to subtract
    public func applyPenalty(_ amount: Int) {
        health = max(0, health - amount)
        persist()
    }

    /// Gets the player's current health value.
    ///
    /// - Returns: The current health points (0-100)
    public func getHealth() -> Int {
        health
    }

    /// Respawns the player with 50 HP after death.
    /// Called when health reaches 0 to allow the player to continue.
    /// Automatically persists after respawning.
    public func respawn() {
        health = 50
        persist()
    }
}
