//
//  TodosManagerTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Testing
@testable import QuestLogCore

struct TodosManagerTests {

    var manager = TodosManager()

    @Test func initWithoutTasks() {
        let allTasks: [Todo] = manager.listTodos()
        #expect(allTasks.isEmpty)
    }

    @Test func addingATask() {
        manager.add("Task1")
        #expect(manager.listTodos().count == 1)
    }

    @Test func fetchByIdReturnsWhenMatch() {
        manager.add("T")
        let todoItem = manager.listTodos().first!
        let id = todoItem.id
        let fetchedTodo = manager.fetchBy(id: id)
        #expect(todoItem == fetchedTodo)
    }

    @Test func fetchByIdReturnsNilWhenNoMatch() {
        manager.add("T")
        let todoItem = Todo(title: "X")
        let fetchedTodo = manager.fetchBy(id: todoItem.id)
        #expect(fetchedTodo == nil)
    }

    @Test func fetchAllReturnsAllTasks() {
        manager.add("Task1")
        #expect(manager.listTodos().count == 1)
        manager.add("Task2")
        #expect(manager.listTodos().count == 2)
        manager.add("Task3")
        #expect(manager.listTodos().count == 3)
    }

    @Test func toggleIsDoneByUuid() {
        manager.add("T")
        var isDone = manager.toggleCompletion(at: 0)
        #expect(isDone == true)
        isDone = manager.toggleCompletion(at: 0)
        #expect(isDone == false)
    }

    @Test func deleteByIndex() {
        manager.add("T")
        #expect(manager.listTodos().count == 1)
        manager.deleteTodo(at: 0)
        #expect(manager.listTodos().isEmpty)
    }

    @Test func deleteAll() {
        manager.add("Task1")
        manager.add("Task2")
        manager.add("Task3")
        manager.deleteAll()
        #expect(manager.listTodos().count == 0)
    }

    @Test func penaltyReducesHealth() {
        let initial = manager.getHealth()
        manager.applyPenalty(10)
        #expect(manager.getHealth() == initial - 10)
    }

    @Test func healthFloorIsZero() {
        manager.applyPenalty(999)
        #expect(manager.getHealth() == 0)
    }
}
