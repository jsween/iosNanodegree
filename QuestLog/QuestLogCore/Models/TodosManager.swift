//
//  TodosManager.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation

/// Manages the collection of todos (quests), including adding, listing, toggling, and deleting.
public class TodosManager {
    private var todos: [Todo] = []
    public private(set) var health: Int = 100
    private let cache: Cache

    public init(cache: Cache = FileSystemCache()) {
        self.cache = cache
        let state = try? cache.load()
        self.todos = state?.todos ?? []
        self.health = state?.health ?? 100
    }

    /// Persist cached todo items helper
    public func persist() {
        try? cache.save(state: AppState(todos: todos, health: health))
    }

    /// Adds a new todo (quest item) with the given title
    public func add(_ title: String) {
        todos.append(Todo(title: title))
        persist()
    }

    /// Fetches a todo (quest) by its ID or nil if not found
    public func fetchBy(id: UUID) -> Todo? {
        return todos.first(where: { $0.id == id })
    }

    /// Fetches a todo (quest) by its Index or nil if index is not valid
    public func fetchBy(index: Int) -> Todo? {
        guard index >= 0 && index < todos.count else { return nil }
        return todos[index]
    }

    /// Fetches all todos (quests)
    public func listTodos() -> [Todo] {
        return todos
    }

    /// Toggles the completions status of task by its ID
    public func toggleCompletion(at index: Int) -> Bool? {
        guard index >= 0 && index < todos.count else { return nil }
        todos[index].isDone.toggle()
        persist()
        return todos[index].isDone
    }

    /// Returns the dice roll: if critical and amount of points
    public func applyHealthRoll(isDone: Bool) -> DiceRoll {
        let roll = DiceRoll.roll2d6()
        health = max(0, health + (isDone ? roll.total : -roll.total)) // double if critical
        persist()
        return roll
    }

    /// Delete a todo item by its ID
    public func deleteTodo(at index: Int) {
        guard index >= 0 && index < todos.count else { return }
        todos.remove(at: index)
        persist()
    }

    /// Delete all todo items
    public func deleteAll() {
        todos.removeAll()
        persist()
    }

    /// Apply penalty to incorrect input
    public func applyPenalty(_ amount: Int) {
        health = max(0, health - amount)
        persist()
    }

    /// Get health status
    public func getHealth() -> Int {
        health
    }

    /// Respawns a character
    public func respawn() {
        health = 50
        persist()
    }
}
