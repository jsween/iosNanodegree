//
//  Todo.swift
//  QuestLog
//
//  Created by Jonathan Sweeney on 5/17/26.
//

import Foundation

/// A single todo item with a unique ID, tiltle, and completion status
public struct Todo: Codable, CustomStringConvertible, Equatable {
    public let id: UUID
    public var title: String
    public var isDone: Bool = false

    public var description: String {
        let status = isDone ? "✅" : "⬜"
        return "\(status) \(title)"
    }

    public init(title: String, isDone: Bool = false) {
        self.id = UUID()
        self.title = title.capitalized
        self.isDone = isDone
    }
}
