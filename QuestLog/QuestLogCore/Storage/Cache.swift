//
//  Cache.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Foundation

/// Protocol for persisting and loading AppState snapshots.
/// Implementations handle the storage mechanism (file system, memory, etc.)
/// while TodosManager handles the business logic and state management.
public protocol Cache {
    /// Saves a snapshot of the app state to persistent storage
    func save(state: AppState) throws

    /// Loads the most recent app state snapshot from persistent storage
    func load() throws -> AppState?
}
