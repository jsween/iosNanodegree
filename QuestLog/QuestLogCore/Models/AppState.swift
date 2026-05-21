//
//  AppState.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation

/// Represents an immutable snapshot of the app's persisted state.
/// This is a data transfer object used for serialization to/from the cache.
/// The TodosManager converts between its internal state and this structure.
/// Properties are read-only to ensure snapshots cannot be modified after creation.
public struct AppState: Codable, Equatable {
    /// The collection of todos at the time of the snapshot
    public let todos: [Todo]
    
    /// The player's health points at the time of the snapshot
    public let health: Int
    
    /// Creates an immutable snapshot of the app state.
    ///
    /// - Parameters:
    ///   - todos: The current collection of quests
    ///   - health: The current health value
    public init(todos: [Todo], health: Int) {
        self.todos = todos
        self.health = health
    }
}
