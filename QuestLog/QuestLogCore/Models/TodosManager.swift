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
    public func add(title: String) {
        let todo = Todo(title: title)
        todos.append(todo)
    }

    /// Fetches a todo (quest) by its ID or nil if not found
    public func fetchBy(id: UUID) -> Todo? {
        return todos.first(where: { $0.id == id })
    }

    /// Fetches all todos (quests)
    public func fetchAll() -> [Todo]{
        return todos
    }

    /// Toggles the completions status of task by its ID
    public func toggle(id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }
        todos[index].isDone.toggle()
    }

    /// Delete a todo item by its ID
    public func delete(id: UUID) {
        todos.removeAll(where: { $0.id == id })
    }

    /// Delte all todo items
    public func deleteAll() {
        todos.removeAll()
    }
}
