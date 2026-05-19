//
//  InMemoryCache.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Foundation

public class InMemoryCache: Cache {
    private var stored: AppState?

    public init() {}

    public func save(state: AppState) throws {
        stored = state
    }

    public func load() throws -> AppState? {
        return stored
    }
}
