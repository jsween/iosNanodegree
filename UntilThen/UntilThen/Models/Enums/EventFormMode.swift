//
//  EventFormMode.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/23/26.
//

import Foundation

/// Determines whether EventForm is creating a new event or editing
enum EventFormMode: Hashable {
    case add
    case edit(Event)
}
