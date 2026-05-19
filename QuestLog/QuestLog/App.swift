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
            print(String(format: "[%-02d] %@", index, todo.description))
        }
    }

    private func toggle() {
        list()
        print("Enter the quest number to update its status...")
        guard let input = readLine(),
              let index = Int(input),
              let isDone = manager.toggleCompletion(at: index) else {
            print("Invalid quest. Minus 3 damage.")
            manager.health -= 3
            return
        }

        let roll = manager.applyHealthRoll(isDone: isDone)

        if isDone {
            if roll.isCritical {
                print("💥 CRITICAL HIT! Rolled \(roll.die1)+\(roll.die2) doubled to +\(roll.total) HP! Quest Copmlete.")
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
        print("❤️ Health: \(manager.health)")
    }

    private func delete() {
        list()
        print("Enter the quest number to delete...")
        guard let input = readLine(),
              let index = Int(input),
              manager.fetchBy(index: index) != nil else {
            print("Invalid quest. Minus 3 damage.")
            manager.health -= 3
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
        print("(Quests are todo items)")

        while true {
            print("\nCommands: add, list, toggle, delete, exit")
            print("> ", terminator: "")

            guard let input = readLine(),
                  let command = Command(rawValue: input.lowercased()) else {
                print("Unknown command. Try again.")
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
}

// MARK: - Command
extension App {
    enum Command: String {
        case add, list, toggle, delete, exit
    }
}
