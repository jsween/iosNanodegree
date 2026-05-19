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

    public init() {}

    /// Adds a new todo (quest item) with the given title
    public func add(_ title: String) {
        let todo = Todo(title: title)
        todos.append(todo)
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
    public func toggleCompletion(at index: UUID) {
        guard let idx = todos.firstIndex(where: { $0.id == index }) else { return }
        todos[idx].isDone.toggle()
    }

    /// Delete a todo item by its ID
    public func deleteTodo(at index: UUID) {
        todos.removeAll(where: { $0.id == index })
    }

    /// Delte all todo items
    public func deleteAll() {
        todos.removeAll()
    }
}
