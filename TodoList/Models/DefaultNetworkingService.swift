import Foundation
import CocoaLumberjackSwift

protocol NetworkingService {
    func getTodoItemList() async throws -> [TodoItem]
    func patchTodoItemsList(todoItemsLocal: [TodoItem]) async throws -> [TodoItem]
    func getTodoItemElement(id: String) async throws -> TodoItem
    func postTodoItemElement(todoItemLocal: TodoItem) async throws -> TodoItem
    func putTodoItemElement(todoItemLocal: TodoItem) async throws -> TodoItem
    func deleteTodoItemElement(id: String) async throws -> TodoItem
}

class DefaultNetworkingService: NetworkingService {

    let token = "unsympathising"
    let baseURL = "https://beta.mrdekk.ru/todobackend"
    var revision = 0

    func getTodoItemList() async throws -> [TodoItem] {
        let request = try createRequest(subdirectory: "/list", method: .get)
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let todoItemsFromData = try parseAllTodoItemsFromData(data: data)
        DDLogInfo("Get todoList array")
        return todoItemsFromData
    }

    func patchTodoItemsList(todoItemsLocal: [TodoItem]) async throws -> [TodoItem] {
        var request = try createRequest(subdirectory: "/list", method: .patch)
        request.httpBody = try JSONSerialization.data(withJSONObject: ["list": todoItemsLocal.map({ $0.json })])
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let todoItemsFromData = try parseAllTodoItemsFromData(data: data)
        DDLogInfo("Patch todoList array")
        return todoItemsFromData
    }

    func getTodoItemElement(id: String) async throws -> TodoItem {
        let request = try createRequest(subdirectory: "/list/\(id)", method: .get)
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {throw NetworkingError.notFound}
        let todoItemFromData = try parseOneTodoItemFromData(data: data)
        DDLogInfo("Get todoList element")
        return todoItemFromData
    }

    func postTodoItemElement(todoItemLocal: TodoItem) async throws -> TodoItem {
        var request = try createRequest(subdirectory: "/list", method: .post)
        request.httpBody = try JSONSerialization.data(withJSONObject: ["element": todoItemLocal.json])
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 400 {throw NetworkingError.revisionError}
        let todoItemFromData = try parseOneTodoItemFromData(data: data)
        DDLogInfo("Post todoList element")
        return todoItemFromData
    }

    func putTodoItemElement(todoItemLocal: TodoItem) async throws -> TodoItem {
        var request = try createRequest(subdirectory: "/list/\(todoItemLocal.id)", method: .put)
        request.httpBody = try JSONSerialization.data(withJSONObject: ["element": todoItemLocal.json])
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {throw NetworkingError.notFound}
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 400 {throw NetworkingError.revisionError}
        let todoItemFromData = try parseOneTodoItemFromData(data: data)
        DDLogInfo("Put todoList element")
        return todoItemFromData
    }

    func deleteTodoItemElement(id: String) async throws -> TodoItem {
        let request = try createRequest(subdirectory: "/list/\(id)", method: .delete)
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {throw NetworkingError.notFound}
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 400 {throw NetworkingError.revisionError}
        let todoItemFromData = try parseOneTodoItemFromData(data: data)
        DDLogInfo("Delete todoList element")
        return todoItemFromData
    }
}
