//
//  AppState.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation

/// Represents the persisted state of the app, including all quests and the player's health.
public struct AppState: Codable {
    public var todos: [Todo]
    public var health: Int
}
