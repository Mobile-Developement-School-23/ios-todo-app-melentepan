import Foundation
import UIKit
import CocoaLumberjackSwift

extension TodoItem {
    var json: Any {
        var jsonDict: [String: Any] = [
            Keys.id.rawValue: id,
            Keys.text.rawValue: text,
            Keys.isCompleted.rawValue: isCompleted,
            Keys.creationDate.rawValue: creationDate.timeIntervalSince1970
        ]
        if importance.rawValue != Importance.usual.rawValue {
            jsonDict[Keys.importance.rawValue] = importance.rawValue
        }
        if let deadlineDate = deadlineDate {
            jsonDict[Keys.deadlineDate.rawValue] = deadlineDate.timeIntervalSince1970
        }
        if let modificationDate = modificationDate {
            jsonDict[Keys.modificationDate.rawValue] = modificationDate.timeIntervalSince1970
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
              let text = jsonDict[Keys.id.rawValue] as? String,
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
        textView.text = ""
        textView.textColor = .black
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
