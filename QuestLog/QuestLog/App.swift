//
//  App.swift
//  QuestLog
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Foundation
import QuestLogCore

class App {
    private let manager = TodosManager()

    private func add() {
        print("📜 What is the name of your quest?")
        print("> ", terminator: "")
        guard let title = readLine(), !title.isEmpty else {
            print("Quest title cannot be empty. Enter a quest title to create a new one.")
            return
        }

        manager.add(title)
        print("Quest added")
    }

    private func list() {
        let todos = manager.listTodos()
        guard !todos.isEmpty else {
            print("No quests found. Try adding one if you dare...")
            return
        }

        for (index, todo) in todos.enumerated() {
            print(String(format: "[%02d] %@", index, todo.description))
        }
    }

    private func toggle() {
        list()
        print("Enter the quest number to update its status...")
        print("> ", terminator: "")
        guard let input = readLine(),
              let index = Int(input),
              let isDone = manager.toggleCompletion(at: index) else {
            print("Invalid quest. Minus 3 damage.")
            manager.applyPenalty(3)
            return
        }

        let roll = manager.applyHealthRoll(isDone: isDone)
        printRollResult(isDone: isDone, roll: roll)
        showHealth()
    }

    private func printRollResult(isDone: Bool, roll: DiceRoll) {
        if isDone {
            if roll.isCritical {
                print("💥 CRITICAL HIT! Rolled \(roll.die1)+\(roll.die2) doubled to +\(roll.total) HP! Quest Complete.")
            } else {
                print("⚔️ Quest complete! Rolled \(roll.die1)+\(roll.die2) for +\(roll.total) HP!")
            }
        } else {
            if roll.isCritical {
                print("💀 BOTCHED! Rolled \(roll.die1)+\(roll.die2) doubled to -\(roll.total) HP!")
            } else {
                print("😓 Quest abandoned! Rolled \(roll.die1)+\(roll.die2) for -\(roll.total) HP!")
            }
        }
    }

    private func delete() {
        list()
        print("Enter the quest number to delete...")
        print("> ", terminator: "")
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

    private func exit() {
        print("🧙‍♂️ Until next time, adventurer. Farewell!")
        Foundation.exit(0)
    }

    public func run() {
        print("🏰 Welcome, adventurer! Your quest log awaits.")
        explainRules()

        while true {
            print("\nCommands: add, list, toggle, delete, exit")
            print("> ", terminator: "")

            guard let input = readLine(),
                  let command = Command(rawValue: input.lowercased()) else {
                print("Unknown command. Minus 5 hp")
                manager.applyPenalty(5)
                showHealth()
                continue
            }

            switch command {
            case .add: add()
            case .list: list()
            case .toggle: toggle()
            case .delete: delete()
            case .exit: exit()
            }
        }
    }

    private func showHealth() {
        let bar = String(repeating: "❤️", count: max(0, manager.health / 10))
        print("\(bar) HP: \(manager.health)/100")
        if manager.health == 0 {
            print("☠️ You have fallen, adventurer. Game over. ☠️")
            Foundation.exit(0)
        }
    }

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

// MARK: - Command
extension App {
    enum Command: String {
        case add, list, toggle, delete, exit
    }
}
