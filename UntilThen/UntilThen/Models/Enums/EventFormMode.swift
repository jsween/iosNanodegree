//
//  EventFormMode.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/23/26.
//

import Foundation

/// Determines whether EventForm is creating a new event or editing
enum EventFormMode {
    case add
    case edit(Event)
}

// Manually implement Hashable for navigation
extension EventFormMode: Hashable {
    static func == (lhs: EventFormMode, rhs: EventFormMode) -> Bool {
        switch (lhs, rhs) {
        case (.add, .add):
            return true
        case (.edit(let lhsEvent), .edit(let rhsEvent)):
            return lhsEvent.id == rhsEvent.id
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .add:
            hasher.combine("add")
        case .edit(let event):
            hasher.combine("edit")
            hasher.combine(event.id)
        }
    }
}
