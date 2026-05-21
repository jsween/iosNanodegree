//
//  Todo.swift
//  QuestLog
//
//  Created by Jonathan Sweeney on 5/17/26.
//

import Foundation

/// Represents a single quest (todo item) in the QuestLog app.
/// Each todo has a unique identifier, a title, and a completion status.
/// Conforms to Codable for persistence, Equatable for comparison, and CustomStringConvertible for display.
public struct Todo: Codable, CustomStringConvertible, Equatable {
    /// Unique identifier for this todo, generated at creation time
    public let id: UUID
    
    /// The title/name of the quest, automatically capitalized
    public var title: String
    
    /// Whether this quest has been completed
    public var isDone: Bool = false

    /// A formatted string representation showing completion status and title.
    /// Format: "✅ Quest Name" for completed or "⬜ Quest Name" for incomplete.
    public var description: String {
        let status = isDone ? "✅" : "⬜"
        return "\(status) \(title)"
    }

    /// Creates a new quest with the specified title and completion status.
    ///
    /// - Parameters:
    ///   - title: The name of the quest. Will be automatically capitalized.
    ///   - isDone: Whether the quest starts as completed. Defaults to false.
    ///
    /// - Note: A unique UUID is automatically generated for the `id` property.
    public init(title: String, isDone: Bool = false) {
        self.id = UUID()
        self.title = title.capitalized
        self.isDone = isDone
    }
}
