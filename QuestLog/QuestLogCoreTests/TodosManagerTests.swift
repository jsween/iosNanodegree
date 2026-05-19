//
//  TodosManagerTests.swift
//  QuestLogCoreTests
//
//  Created by Jonathan Sweeney on 5/18/26.
//

import Testing
@testable import QuestLogCore

struct TodosManagerTests {

    var tdm = TodosManager()

    @Test func initWithoutTasks() {
        let allTasks: [Todo] = tdm.listTodos()
        #expect(allTasks.isEmpty)
    }

    @Test func addingATask() {
        tdm.add("Task1")
        #expect(tdm.listTodos().count == 1)
    }

    @Test func fetchByIdReturnsWhenMatch() {
        tdm.add("T")
        let todoItem = tdm.listTodos().first!
        let id = todoItem.id
        let fetchedTodo = tdm.fetchBy(id: id)
        #expect(todoItem == fetchedTodo)
    }

    @Test func fetchByIdReturnsNilWhenNoMatch() {
        tdm.add("T")
        let todoItem = Todo(title: "X")
        let fetchedTodo = tdm.fetchBy(id: todoItem.id)
        #expect(fetchedTodo == nil)
    }

    @Test func fetchAllReturnsAllTasks() {
        tdm.add("Task1")
        #expect(tdm.listTodos().count == 1)
        tdm.add("Task2")
        #expect(tdm.listTodos().count == 2)
        tdm.add("Task3")
        #expect(tdm.listTodos().count == 3)
    }

    @Test func toggleIsDoneByUuid() {
        tdm.add("T")
        let todoItem = tdm.listTodos().first!
        tdm.toggleCompletion(at: todoItem.id)
        var updated = tdm.fetchBy(id: todoItem.id)
        #expect(updated?.isDone == true)
        tdm.toggleCompletion(at: todoItem.id)
        updated = tdm.fetchBy(id: todoItem.id)
        #expect(updated?.isDone == false)
    }

    @Test func deleteById() {
        tdm.add("T")
        let todoItem = tdm.listTodos().first!
        tdm.deleteTodo(at: todoItem.id)
        #expect(tdm.fetchBy(id: todoItem.id) == nil)
    }

    @Test func deleteAll() {
        tdm.add("Task1")
        tdm.add("Task2")
        tdm.add("Task3")
        tdm.deleteAll()
        #expect(tdm.listTodos().count == 0)
    }
}
