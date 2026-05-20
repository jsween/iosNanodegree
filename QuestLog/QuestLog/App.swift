//
//  App.swift
//  QuestLog
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation
import QuestLogCore

/// Main application class that handles the command-line interface
/// for the QuestLog todo app with RPG-style mechanics.
class App {
    /// The manager responsible for todo operations, health tracking, and persistence
    private let manager = TodosManager()

    // MARK: - Command Handlers
    
    /// Prompts the user to add a new quest (todo item) to their quest log.
    /// Validates that the title is not empty before adding.
    private func add() {
        print("📜 What is the name of your quest?")
        print("> ", terminator: "")
        
        // Read user input and validate it's not empty
        guard let title = readLine(), !title.isEmpty else {
            print("Quest title cannot be empty. Enter a quest title to create a new one.")
            return
        }

        manager.add(title)
        print("Quest added")
    }

    /// Displays all quests in the quest log with their index numbers.
    /// Shows a message if no quests are available.
    private func list() {
        let todos = manager.listTodos()
        
        // Check if there are any quests to display
        guard !todos.isEmpty else {
            print("No quests found. Try adding one if you dare...")
            return
        }

        // Print each quest with a formatted index
        for (index, todo) in todos.enumerated() {
            print(String(format: "[%02d] %@", index, todo.description))
        }
    }

    /// Toggles the completion status of a quest and applies health changes.
    /// - Completing a quest: rolls 2d6 and gains HP
    /// - Uncompleting a quest: rolls 2d6 and loses HP
    /// - Rolling doubles triggers critical effects (doubled damage/healing)
    /// Invalid input results in a 3 HP penalty.
    private func toggle() {
        // Ensure there are quests available
        guard manager.listTodos().count > 0 else {
            print("No Quests to carry out yet. Add a quest first.")
            return
        }
        
        // Show available quests
        list()
        print("Enter the quest number to update its status...")
        print("> ", terminator: "")
        
        // Read and validate user input
        guard let input = readLine(),
              let index = Int(input),
              let isDone = manager.toggleCompletion(at: index) else {
            print("Invalid quest. Minus 3 damage.")
            manager.applyPenalty(3)
            return
        }

        // Roll dice and apply health changes
        let roll = manager.applyHealthRoll(isDone: isDone)
        printRollResult(isDone: isDone, roll: roll)
        showHealth()
    }

    /// Prints the result of a dice roll after toggling quest completion.
    /// Displays different messages based on whether the quest was completed or abandoned,
    /// and whether the roll was critical (doubles).
    ///
    /// - Parameters:
    ///   - isDone: Whether the quest was marked as complete (true) or incomplete (false)
    ///   - roll: The dice roll result containing die values and total
    private func printRollResult(isDone: Bool, roll: DiceRoll) {
        if isDone {
            // Quest completed - positive messages
            if roll.isCritical {
                print("💥 CRITICAL HIT! Rolled \(roll.die1)+\(roll.die2) doubled to +\(roll.total) HP! Quest Complete.")
            } else {
                print("⚔️ Quest complete! Rolled \(roll.die1)+\(roll.die2) for +\(roll.total) HP!")
            }
        } else {
            // Quest abandoned - negative messages
            if roll.isCritical {
                print("💀 BOTCHED! Rolled \(roll.die1)+\(roll.die2) doubled to -\(roll.total) HP!")
            } else {
                print("😓 Quest abandoned! Rolled \(roll.die1)+\(roll.die2) for -\(roll.total) HP!")
            }
        }
    }

    /// Deletes a quest from the quest log.
    /// Lists all quests, prompts for an index, and removes the selected quest.
    /// Invalid input results in a 3 HP penalty.
    private func delete() {
        list()
        print("Enter the quest number to delete...")
        print("> ", terminator: "")
        
        // Validate user input and quest existence
        guard let input = readLine(),
              let index = Int(input),
              manager.fetchBy(index: index) != nil else {
            print("Invalid quest. Minus 3 damage.")
            manager.applyPenalty(3)
            return
        }
        
        manager.deleteTodo(at: index)
        print("⚔️ Quest abandoned and forgotten.")
    }

    /// Exits the application with a farewell message.
    private func exit() {
        print("🧙‍♂️ Until next time, adventurer. Farewell!")
        Foundation.exit(0)
    }

    // MARK: - Main Loop
    
    /// Runs the main application loop.
    /// Displays welcome message, explains rules, and continuously prompts for commands
    /// until the user exits. Invalid commands result in a 5 HP penalty.
    public func run() {
        print("🏰 Welcome, adventurer! Your quest log awaits.")
        explainRules()

        while true {
            print("\nCommands: add, list, toggle, delete, exit")
            print("> ", terminator: "")

            // Read and parse user command
            guard let input = readLine(),
                  let command = Command(rawValue: input.lowercased()) else {
                print("Unknown command. Minus 5 hp")
                manager.applyPenalty(5)
                showHealth()
                continue
            }

            // Execute the corresponding command handler
            switch command {
            case .add: add()
            case .list: list()
            case .toggle: toggle()
            case .delete: delete()
            case .exit: exit()
            }
        }
    }

    // MARK: - UI Helpers
    
    /// Displays the player's current health as a progress bar with color indicator.
    /// If health reaches 0, triggers respawn with 50 HP.
    private func showHealth() {
        let maxHealth = 100
        let barLength = 20
        
        // Calculate filled portion of health bar
        let filled = Int((Double(manager.health) / Double(maxHealth)) * Double(barLength))
        let empty = barLength - filled

        // Create visual health bar
        let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: empty)
        
        // Choose color based on health level
        let color = manager.health > 60 ? "🟢" : manager.health > 30 ? "🟡" : "🔴"
        
        print("\(color) [\(bar)] \(manager.health)/\(maxHealth) HP")
        
        // Handle death and respawn
        if manager.health == 0 {
            print("☠️ You have fallen, adventurer... but the quests remain! ☠️")
            manager.respawn()
            print("🗡️ Respawned with 50 HP.")
            showHealth()
        }
    }

    /// Displays the game rules and mechanics to the player at startup.
    /// Explains the RPG-style quest completion system, dice rolling mechanics,
    /// and available commands.
    private func explainRules() {
        print("""
        ⚔️  QUEST LOG — HOW TO PLAY  ⚔️
        --------------------------------
        You are an adventurer managing quests (ToDo tasks).
        Complete quests to gain HP. Abandon them to suffer damage.
        
        🎲 Completing a quest rolls 2d6 for HP gain.
        💀 Abandoning a quest rolls 2d6 for HP loss.
        💥 Rolling doubles triggers a CRITICAL — damage is doubled!
        ☠️  Reach 0 HP and your adventure ends.
        
        Commands: add, list, toggle, delete, exit
        Type the command you wish to carry out carefully...
        --------------------------------
        """)
        showHealth()
    }
}

// MARK: - Command Enum

/// Available commands for interacting with the quest log application.
extension App {
    enum Command: String {
        case add, list, toggle, delete, exit
    }
}
