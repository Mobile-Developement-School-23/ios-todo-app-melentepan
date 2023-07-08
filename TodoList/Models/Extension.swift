import Foundation
import UIKit
import CocoaLumberjackSwift

extension TodoItem {
    var json: Any {
        var jsonDict: [String: Any] = [:]
        jsonDict[Keys.id.rawValue] = self.id
        jsonDict[Keys.text.rawValue] = self.text
        jsonDict[Keys.importance.rawValue] = importance.rawValue
        jsonDict[Keys.isCompleted.rawValue] = self.isCompleted
        jsonDict[Keys.creationDate.rawValue] = Int(creationDate.timeIntervalSince1970)
        jsonDict[Keys.modificationDate.rawValue] = self.modificationDate
        jsonDict[Keys.lastUpdatedBy.rawValue] = "iOS"

        if let deadlineDate = self.deadlineDate {
            jsonDict[Keys.deadlineDate.rawValue] = Int(deadlineDate.timeIntervalSince1970)
        }
        if let modificationDate = self.modificationDate {
            jsonDict[Keys.modificationDate.rawValue] = Int(modificationDate.timeIntervalSince1970)
        } else {
            jsonDict[Keys.modificationDate.rawValue] = Int(creationDate.timeIntervalSince1970)
        }
        return jsonDict
    }

    var csv: String {
        var csvString = "\(id)\(TodoItem.separator)\(text)\(TodoItem.separator)"
        if importance != .usual {
            csvString += "\(importance.rawValue)\(TodoItem.separator)"
        } else {
            csvString += "\(TodoItem.separator)"
        }

        if let deadlineDate = deadlineDate {
            csvString += "\(deadlineDate.timeIntervalSince1970)\(TodoItem.separator)"
        } else {
            csvString += "\(TodoItem.separator)"
        }
        csvString += "\(isCompleted)\(TodoItem.separator)\(creationDate.timeIntervalSince1970)\(TodoItem.separator)"
        if let modificationDate = modificationDate {
            csvString += "\(modificationDate.timeIntervalSince1970)\(TodoItem.separator)"
        } else {
            csvString += "\(TodoItem.separator)"
        }
        return csvString
    }

    static func parse(json: Any) -> TodoItem? {
        guard let jsonDict = json as? [String: Any] else { return nil }

        guard let id = jsonDict[Keys.id.rawValue] as? String,
              let text = jsonDict[Keys.text.rawValue] as? String,
              let isCompleted = jsonDict[Keys.isCompleted.rawValue] as? Bool,
              let creationDateTimestamp = jsonDict[Keys.creationDate.rawValue] as? TimeInterval
        else { return nil }

        let importanceRawValue = jsonDict[Keys.importance.rawValue] as? String ?? Importance.usual.rawValue
        let importance = Importance(rawValue: importanceRawValue) ?? .usual

        let deadlineDate: Date?
        if let deadlineDateTimestamp = jsonDict[Keys.deadlineDate.rawValue] as? TimeInterval {
            deadlineDate = Date(timeIntervalSince1970: deadlineDateTimestamp)
        } else {
            deadlineDate = nil
        }

        let modificationDate: Date?
        if let modificationDateTimestamp = jsonDict[Keys.modificationDate.rawValue] as? TimeInterval {
            modificationDate = Date(timeIntervalSince1970: modificationDateTimestamp)
        } else {
            modificationDate = nil
        }

        let creationDate = Date(timeIntervalSince1970: creationDateTimestamp)

        return TodoItem(id: id, text: text, importance: importance, deadlineDate: deadlineDate, isCompleted: isCompleted, creationDate: creationDate, modificationDate: modificationDate)
    }

    static func parse(csv: String) -> TodoItem? {
        let components = csv.components(separatedBy: TodoItem.separator)

        guard components.count == 7 else { return nil }
        guard let isCompleted = Bool(components[4]),
              let creationDateTimestamp = TimeInterval(components[5])
        else { return nil }

        var id = components[0]
        id = id.isEmpty ? UUID().uuidString : id
        let text = components[1]
        guard !text.isEmpty else { return nil }

        let importanceRawValue = components[2]
        let importance = Importance(rawValue: importanceRawValue) ?? .usual

        let deadlineDate: Date?
        if let deadlineDateTimestamp = TimeInterval(components[3]) {
            deadlineDate = Date(timeIntervalSince1970: deadlineDateTimestamp)
        } else {
            deadlineDate = nil
        }

        let modificationDate: Date?
        if let modificationDateTimestamp = TimeInterval(components[6]) {
            modificationDate = Date(timeIntervalSince1970: modificationDateTimestamp)
        } else {
            modificationDate = nil
        }

        let creationDate = Date(timeIntervalSince1970: creationDateTimestamp)

        return TodoItem(id: id, text: text, importance: importance, deadlineDate: deadlineDate, isCompleted: isCompleted, creationDate: creationDate, modificationDate: modificationDate)
    }
}

extension TodoItemViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = .lightGray
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }

    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completeIsShow ? fileCache.todoItems.count : fileCache.todoItems.filter { !$0.isCompleted }.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            fatalError("The dequeued cell is not an instance of TableViewCell.")
        }
        cell.todoItem = completeIsShow ? fileCache.todoItems[indexPath.row] : fileCache.todoItems.filter { !$0.isCompleted }[indexPath.row]
        confgireCell(cell: cell)
        return cell
    }

    func confgireCell(cell: TableViewCell) {
        cell.fileCache = fileCache
        cell.setCompleteImage()
        cell.setText()
        cell.setDeadline()
        cell.setTextEffects()
        cell.accessoryType = .disclosureIndicator
        cell.isUserInteractionEnabled = true
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 16, height: 16))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        } else {
            let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 0, height: 0))
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {
            fatalError("The cell at the given index path is not an instance of TableViewCell.")
        }

        let deleteAction = UIContextualAction(style: .normal, title: "") { (_, _, completionHandler) in
            self.deleteToDoItemFromServer(todoItem: cell.todoItem)
            self.fileCache.remove(id: cell.todoItem.id)

            UIView.animate(withDuration: 0.3) {
                cell.layer.opacity = 0
            } completion: { _ in
                tableView.reloadData()
                self.labelCountOfComplete.text = "Выполнено — \(self.fileCache.todoItems.filter({$0.isCompleted == true}).count)"
            }

            DDLogDebug("Удаление ячейки \(indexPath.row)")

            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)
        deleteAction.image = UIImage(named: "trash")

        let changeAction = UIContextualAction(style: .normal, title: "") { (_, _, completionHandler) in
            guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {
                fatalError("The cell at the given index path is not an instance of TableViewCell.")
            }
            let todoItem = cell.todoItem

            let newTodoItemVC = TodoItemViewController(mainVC: self, statusOfVC: .change, todoItem: todoItem)
            let newTodoItemNavVC = UINavigationController(rootViewController: newTodoItemVC)
            self.present(newTodoItemNavVC, animated: true)

            DDLogDebug("Изменение ячейки \(indexPath.row)")

            completionHandler(true)
        }

        changeAction.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1)
        changeAction.image = UIImage(named: "info")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, changeAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionDo = UIContextualAction(style: .normal, title: "") { (_, _, completionHandler) in
            guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else {
                fatalError("The cell at the given index path is not an instance of TableViewCell.")
            }
            cell.setComplete()
            self.labelCountOfComplete.text = "Выполнено — \(self.fileCache.todoItems.filter({$0.isCompleted == true}).count)"

            DDLogDebug("Изменение isCompleted ячейки \(indexPath.row)")

            completionHandler(true)
            if !self.completeIsShow {
                tableView.reloadData()
            }
        }

        actionDo.backgroundColor = UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1)
        actionDo.image = UIImage(named: "check")

        let configuration = UISwipeActionsConfiguration(actions: [actionDo])
        return configuration
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let todoItem = self.completeIsShow ? self.fileCache.todoItems[indexPath.row] : self.fileCache.todoItems.filter { !$0.isCompleted }[indexPath.row]
            let todoItemVC = TodoItemViewController(mainVC: self, statusOfVC: .change, todoItem: todoItem)
            return todoItemVC
        })
        return configuration
    }

    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let todoItemVC = animator.previewViewController as? TodoItemViewController else { return }
        animator.addCompletion {
            let todoItemNavVC = UINavigationController(rootViewController: todoItemVC)
            self.present(todoItemNavVC, animated: true)
        }
    }
}

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var currentDataTask: URLSessionDataTask?

        return try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                currentDataTask = URLSession.shared.dataTask(with: urlRequest) { data, responce, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let responce = responce {
                        continuation.resume(returning: (data, responce))
                    } else {
                        continuation.resume(throwing: NSError(domain: "invalidData", code: 322)
                        )
                    }
                }
                currentDataTask?.resume()
            }
        } onCancel: { [weak currentDataTask] in
            currentDataTask?.cancel()
        }
    }
}

    extension DefaultNetworkingService {
        func createRequest(subdirectory: String, method: HTTPMethods) throws -> URLRequest {
            guard let url = URL(string: "\(baseURL)\(subdirectory)") else { throw NetworkingError.urlError }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue.uppercased()
            if method != .get {
                request.addValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
            }
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            DDLogInfo("Create \(method.rawValue.uppercased()) request")
            return request
        }

        func parseAllTodoItemsFromData(data: Data) throws -> [TodoItem] {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let revision = jsonArray["revision"] as? Int,
                  let list = jsonArray["list"] as? [[String: Any]]
            else {
                throw NetworkingError.decodeError
            }
            var todoItemsFromData: [TodoItem] = []
            for item in list {
                guard let todoItem = TodoItem.parse(json: item) else { throw NetworkingError.decodeError }
                todoItemsFromData.append(todoItem)
            }
            self.revision = revision
            return todoItemsFromData
        }

        func parseOneTodoItemFromData(data: Data) throws -> TodoItem {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let revision = jsonArray["revision"] as? Int,
                  let element = jsonArray["element"] as? [String: Any],
                  let todoItem = TodoItem.parse(json: element)
            else { throw URLError(.cannotDecodeContentData) }
            self.revision = revision
            DDLogInfo("revision = \(self.revision)")
            return todoItem
        }
    }
