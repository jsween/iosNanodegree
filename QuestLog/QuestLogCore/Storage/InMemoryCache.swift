//
//  InMemoryCache.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Foundation

public class InMemoryCache: Cache {
    private var stored: [Todo] = []

    public init() {}

    public func save(todos: [Todo]) throws {
        stored = todos
    }

    public func load() throws -> [Todo]? {
        return stored.isEmpty ? nil : stored
    }
}
