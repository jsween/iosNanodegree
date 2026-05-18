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
        let allTasks: [Todo] = tdm.fetchAll()
        #expect(allTasks.isEmpty)
    }

    @Test func addingATask() {
        tdm.addTodo(title: "Task1")
        #expect(tdm.fetchAll().count == 1)
    }

    @Test func fetchByIdReturnsWhenMatch() {
        tdm.addTodo(title: "T")
        let todoItem = tdm.fetchAll().first!
        let id = todoItem.id
        let fetchedTodo = tdm.fetchBy(id: id)
        #expect(todoItem == fetchedTodo)
    }

    @Test func fetchByIdReturnsNilWhenNoMatch() {
        tdm.addTodo(title: "T")
        let todoItem = Todo(title: "X")
        let fetchedTodo = tdm.fetchBy(id: todoItem.id)
        #expect(fetchedTodo == nil)
    }

    @Test func fetchAllReturnsAllTasks() {
        tdm.addTodo(title: "Task1")
        #expect(tdm.fetchAll().count == 1)
        tdm.addTodo(title: "Task2")
        #expect(tdm.fetchAll().count == 2)
        tdm.addTodo(title: "Task3")
        #expect(tdm.fetchAll().count == 3)
    }

    @Test func toggleIsDoneByUuid() {
        tdm.addTodo(title: "T")
        let todoItem = tdm.fetchAll().first!
        tdm.toggle(id: todoItem.id)
        var updated = tdm.fetchBy(id: todoItem.id)
        #expect(updated?.isDone == true)
        tdm.toggle(id: todoItem.id)
        updated = tdm.fetchBy(id: todoItem.id)
        #expect(updated?.isDone == false)
    }

    @Test func deleteById() {
        tdm.addTodo(title: "T")
        let todoItem = tdm.fetchAll().first!
        tdm.deleteBy(id: todoItem.id)
        #expect(tdm.fetchBy(id: todoItem.id) == nil)
    }

    @Test func deleteAll() {
        tdm.addTodo(title: "Task1")
        tdm.addTodo(title: "Task2")
        tdm.addTodo(title: "Task3")
        tdm.deleteAll()
        #expect(tdm.fetchAll().count == 0)
    }
}
