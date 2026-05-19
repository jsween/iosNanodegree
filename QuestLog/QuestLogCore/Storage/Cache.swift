//
//  Cache.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Foundation

public protocol Cache {
    func save(state: AppState) throws
    func load() throws -> AppState?
}
