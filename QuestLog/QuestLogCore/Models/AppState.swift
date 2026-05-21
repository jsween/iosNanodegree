//
//  AppState.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation

/// Represents a snapshot of the app's persisted state.
/// This is a data transfer object used for serialization to/from the cache.
/// The TodosManager converts between its internal state and this structure.
public struct AppState: Codable {
    public var todos: [Todo]
    public var health: Int
    
    public init(todos: [Todo], health: Int) {
        self.todos = todos
        self.health = health
    }
}
