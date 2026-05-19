//
//  FileSystemCache.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Foundation

public class FileSystemCache: Cache {
    private let fileURL: URL

    public init(fileName: String = "quests.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appending(path: fileName)
    }
    
    public func save(todos: [Todo]) throws {
        let data = try JSONEncoder().encode(todos)
        try data.write(to: fileURL)
    }

    public func load() throws -> [Todo]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)

        return try JSONDecoder().decode([Todo].self, from: data)
    }

    public func deleteFile() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
