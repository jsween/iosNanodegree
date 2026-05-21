//
//  FileSystemCache.swift
//  QuestLogCore
//
//  Created by Jonathan Sweeney on 5/19/26.
//

import Foundation

/// A Cache implementation that persists AppState to the file system as JSON.
/// This is the production cache that maintains data between app launches.
public class FileSystemCache: Cache {
    /// The file URL where the app state JSON is stored
    private let fileURL: URL

    /// Creates a new file system cache that writes to the specified file.
    ///
    /// - Parameter fileName: The name of the JSON file to store in the documents directory.
    ///   Defaults to "quests.json".
    public init(fileName: String = "quests.json") {
        // Get the documents directory for the current user
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appending(path: fileName)
    }
    
    /// Saves the app state to disk as JSON.
    ///
    /// - Parameter state: The AppState snapshot to persist
    /// - Throws: Encoding errors or file system errors if the save fails
    public func save(state: AppState) throws {
        // Encode the state to JSON data
        let data = try JSONEncoder().encode(state)
        
        // Write the data to the file (overwrites existing file)
        try data.write(to: fileURL)
    }

    /// Loads the app state from disk.
    ///
    /// - Returns: The decoded AppState if a file exists, or nil if no saved state is found
    /// - Throws: Decoding errors or file system errors if loading fails
    public func load() throws -> AppState? {
        // Check if the file exists before attempting to load
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        // Read the JSON data from the file
        let data = try Data(contentsOf: fileURL)

        // Decode and return the AppState
        return try JSONDecoder().decode(AppState.self, from: data)
    }

    /// Deletes the saved state file from disk.
    /// This is primarily used for testing and cleanup purposes.
    ///
    /// - Throws: File system errors if deletion fails
    public func deleteFile() throws {
        // Only attempt to delete if the file exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
