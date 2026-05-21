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
    /// Enforces the maximum quest limit (100 quests).
    private func add() {
        // Check if quest log is full
        if manager.isFull() {
            print("⚠️  Quest log is full! You have reached the maximum of \(TodosManager.maxQuests) quests.")
            print("Complete or delete some quests before adding new ones.")
            return
        }
        
        print("📜 What is the name of your quest?")
        print("> ", terminator: "")
        
        // Read user input and validate it's not empty
        guard let title = readLine(), !title.isEmpty else {
            print("Quest title cannot be empty. Enter a quest title to create a new one.")
            return
        }

        // Attempt to add the quest
        if manager.add(title) {
            let remaining = manager.remainingCapacity()
            print("🔥 Quest added! (\(remaining) slots remaining)")
        } else {
            // This shouldn't happen since we checked isFull() above, but defensive programming
            print("⚠️  Failed to add quest. Quest log is full.")
        }
    }

    /// Displays all quests in the quest log with their index numbers.
    /// Shows a message if no quests are available.
    /// Supports filtering with arguments: no arg = incomplete only, -all = all quests, -done = completed only
    /// Always displays the actual storage index for each quest.
    ///
    /// - Parameter filter: Optional filter string ("-all" or "-done")
    private func list(filter: String? = nil) {
        let allTodos = manager.listTodos()
        
        // Apply filter based on argument
        let todosWithIndices: [(index: Int, todo: Todo)]
        let filterDescription: String
        
        switch filter {
        case "-all":
            todosWithIndices = allTodos.enumerated().map { ($0, $1) }
            filterDescription = "all quests"
        case "-done":
            todosWithIndices = allTodos.enumerated().filter { $0.element.isDone }.map { ($0.offset, $0.element) }
            filterDescription = "completed quests"
        default:
            // Default: show incomplete only
            todosWithIndices = allTodos.enumerated().filter { !$0.element.isDone }.map { ($0.offset, $0.element) }
            filterDescription = "active quests"
        }
        
        // Check if there are any quests to display
        guard !todosWithIndices.isEmpty else {
            print("No \(filterDescription) found.")
            return
        }

        print("📜 Showing \(filterDescription):\n")
        
        // Print each quest with its actual storage index
        for (storageIndex, todo) in todosWithIndices {
            print(String(format: "[%02d] %@", storageIndex, todo.description))
        }
        
        // Show summary
        let incompleteCount = allTodos.filter { !$0.isDone }.count
        let completeCount = allTodos.filter { $0.isDone }.count
        print("\n📊 \(incompleteCount) active • \(completeCount) complete • \(manager.remainingCapacity()) slots remaining")
    }

    /// Toggles the completion status of a quest and applies health changes.
    /// - Completing a quest: rolls 2d6 and gains HP
    /// - Uncompleting a quest: rolls 2d6 and loses HP
    /// - Rolling doubles triggers critical effects (doubled damage/healing)
    /// Invalid input results in a 3 HP penalty.
    private func toggle() {
        // Ensure there are quests available
        guard !manager.listTodos().isEmpty else {
            print("No Quests to carry out yet. Add a quest first.")
            return
        }
        
        // Show all available quests for selection
        list(filter: "-all")
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
        list(filter: "-all")
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
        print("⚔️ Quest abandoned and forgotten.\n")
        
        // Clear screen and show updated active quests
        clearScreen()
        list()
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
        showHealth()

        while true {
            print("\nCommands: add, list [-all|-done], toggle, delete, help, exit")
            print("> ", terminator: "")

            // Read user input
            guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else {
                clearScreen()
                print("Unknown command. Minus 5 hp")
                manager.applyPenalty(5)
                showHealth()
                continue
            }
            
            // Split input into command and arguments
            let parts = input.split(separator: " ", maxSplits: 1).map { String($0).lowercased() }
            guard let commandString = parts.first,
                  let command = Command(rawValue: commandString) else {
                clearScreen()
                print("Unknown command. Minus 5 hp")
                manager.applyPenalty(5)
                showHealth()
                continue
            }
            
            let argument = parts.count > 1 ? parts[1] : nil
            
            // Clear screen before executing command
            clearScreen()

            // Execute the corresponding command handler
            switch command {
            case .add: add()
            case .list: list(filter: argument)
            case .toggle: toggle()
            case .delete: delete()
            case .help: explainRules()
            case .exit: exit()
            }
            
            // Show updated health after command execution
            showHealth()
        }
    }

    // MARK: - UI Helpers
    
    /// Displays the player's current health as a progress bar with color indicator.
    /// If health reaches 0, triggers respawn with 50 HP.
    private func showHealth() {
        let maxHealth = 100
        let barLength = 20
        
        // Ensure health is within valid bounds (0-100)
        let currentHealth = max(0, min(maxHealth, manager.health))

        // Calculate filled portion of health bar
        let filled = Int((Double(currentHealth) / Double(maxHealth)) * Double(barLength))
        let empty = max(0, barLength - filled)

        // Create visual health bar
        let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: empty)
        
        // Choose color based on health level
        let color = currentHealth > 60 ? "🟢" : currentHealth > 30 ? "🟡" : "🔴"
        
        print("\(color) [\(bar)] \(currentHealth)/\(maxHealth) HP")
        
        // Handle death and respawn
        if currentHealth == 0 {
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
        
        Commands:
          add             - Add a new quest
          list            - Show active quests (default)
          list -all       - Show all quests
          list -done      - Show completed quests only
          toggle          - Mark a quest complete/incomplete
          delete          - Remove a quest
          help            - Show these rules again
          exit            - Quit the adventure
        
        Type commands carefully, adventurer...
        --------------------------------
        """)
    }

    /// Clears the terminal screen for a cleaner interface
    private func clearScreen() {
        print(String(repeating: "\n", count: 100))
    }
}

// MARK: - Command

/// Available commands for interacting with the quest log application.
extension App {
    enum Command: String {
        case add, list, toggle, delete, help, exit
    }
}
