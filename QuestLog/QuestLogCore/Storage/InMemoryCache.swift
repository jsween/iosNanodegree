//
//  InMemoryCache.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Foundation

/// A Cache implementation that stores AppState in memory only.
/// Data is lost when the object is deallocated or the app terminates.
/// This is primarily used for testing to avoid disk I/O and file cleanup.
public class InMemoryCache: Cache {
    /// The stored app state snapshot, or nil if nothing has been saved yet
    private var stored: AppState?

    /// Creates a new in-memory cache with no initial state
    public init() {}

    /// Saves the app state to memory.
    /// This simply stores a reference to the state in the `stored` property.
    ///
    /// - Parameter state: The AppState snapshot to store
    /// - Note: This cannot actually throw errors, but conforms to the Cache protocol
    public func save(state: AppState) throws {
        stored = state
    }

    /// Loads the app state from memory.
    ///
    /// - Returns: The most recently saved AppState, or nil if nothing has been saved
    /// - Note: This cannot actually throw errors, but conforms to the Cache protocol
    public func load() throws -> AppState? {
        return stored
    }
}
