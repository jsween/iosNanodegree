//
//  Todo.swift
//  QuestLog
//
//  Created by Jonathan Sweeney on 5/17/26.
//

import Foundation

/// A single todo item with a unique ID, tiltle, and completion status
public struct Todo: Equatable {
    public let id: UUID = UUID()
    public var title: String
    public var isDone: Bool = false

    public init(title: String) {
        self.title = title.capitalized
    }
}
