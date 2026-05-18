//
//  Todo.swift
//  QuestLog
//
//  Created by Jonathan Sweeney on 5/17/26.
//

import Foundation

struct Todo {
    let id: UUID = UUID()
    var title: String
    var isDone: Bool = false
}
