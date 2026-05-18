//
//  Todo.swift
//  QuestLog
//
//  Created by Jonathan Sweeney on 5/17/26.
//

import Foundation

/// A single todo item with a unique ID, tiltle, and completion status
struct Todo {
    let id: UUID = UUID()
    var title: String
    var isDone: Bool = false
}
