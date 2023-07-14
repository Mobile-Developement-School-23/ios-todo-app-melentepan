import Foundation
import SQLite
import CoreData
import CocoaLumberjackSwift

class FileCache {
    private(set) var todoItems: [TodoItem] = []

    var managedObjectContext: NSManagedObjectContext?

    func add(item: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[index] = item
        } else {
            todoItems.append(item)
        }
    }

    func remove(id: String) {
        todoItems.removeAll(where: { $0.id == id })
    }

    func saveCSV() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent("todoItems.csv")
        let csvString = todoItems.map { $0.csv }.joined(separator: "\n")
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("csvStringWriteError")
        }
    }

    func loadCSV(from fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        guard let csvString = String(data: data, encoding: .utf8) else { return }
        let lines = csvString.components(separatedBy: "\n")
        todoItems = lines.compactMap { TodoItem.parse(csv: $0) }
    }
}

// SQLITE

 extension FileCache {
    func save(item: TodoItem, dataBase: Connection) {
        let sql = item.sqlReplaceStatement
        do {
            try dataBase.run(sql)
        } catch {
            print("Error: \(error)")
        }
    }

    func insert(item: TodoItem, dataBase: Connection) {
        let todoItemsTable = Table("todoItems")
        let id = Expression<String>(Keys.id.rawValue)
        let text = Expression<String>(Keys.text.rawValue)
        let importance = Expression<String>(Keys.importance.rawValue)
        let isCompleted = Expression<Bool>(Keys.isCompleted.rawValue)
        let creationDate = Expression<Int>(Keys.creationDate.rawValue)
        let lastUpdatedBy = Expression<String>(Keys.lastUpdatedBy.rawValue)
        let deadlineDate = Expression<Int?>(Keys.deadlineDate.rawValue)
        let modificationDate = Expression<Int?>(Keys.modificationDate.rawValue)

        do {
            try dataBase.run(todoItemsTable.insert(
                id <- item.id,
                text <- item.text,
                importance <- item.importance.rawValue,
                isCompleted <- item.isCompleted,
                creationDate <- Int(item.creationDate.timeIntervalSince1970),
                lastUpdatedBy <- "iOS",
                deadlineDate <- item.deadlineDate.map { Int($0.timeIntervalSince1970) },
                modificationDate <- item.modificationDate.map { Int($0.timeIntervalSince1970) }
            ))
            DDLogDebug("SQL: Добавление todoItem")
        } catch {
            print("Error: insert(item:): \(error)")
        }
    }

    func update(item: TodoItem, dataBase: Connection) {
        let todoItemsTable = Table("todoItems")
        let id = Expression<String>(Keys.id.rawValue)
        let text = Expression<String>(Keys.text.rawValue)
        let importance = Expression<String>(Keys.importance.rawValue)
        let isCompleted = Expression<Bool>(Keys.isCompleted.rawValue)
        let creationDate = Expression<Int>(Keys.creationDate.rawValue)
        let lastUpdatedBy = Expression<String>(Keys.lastUpdatedBy.rawValue)
        let deadlineDate = Expression<Int?>(Keys.deadlineDate.rawValue)
        let modificationDate = Expression<Int?>(Keys.modificationDate.rawValue)

        do {
            try dataBase.run(todoItemsTable.filter(id == item.id).update(
                text <- item.text,
                importance <- item.importance.rawValue,
                isCompleted <- item.isCompleted,
                creationDate <- Int(item.creationDate.timeIntervalSince1970),
                lastUpdatedBy <- "iOS",
                deadlineDate <- item.deadlineDate.map { Int($0.timeIntervalSince1970) },
                modificationDate <- item.modificationDate.map { Int($0.timeIntervalSince1970) }
            ))
            DDLogDebug("SQL: Обновление todoItem")
        } catch {
            print("Error: update(item:)")
        }
    }

    func delete(item: TodoItem, dataBase: Connection) {
        let todoItemsTable = Table("todoItems")
        let id = Expression<String>(Keys.id.rawValue)

        do {
            try dataBase.run(todoItemsTable.filter(id == item.id).delete())
            DDLogDebug("SQL: Удаление todoItem")
        } catch {
            print("Error: delete(item:)")
        }
    }

    func load(dataBase: Connection) {
        let todoItems = Table("todoItems")
        let id = Expression<String>(Keys.id.rawValue)
        let text = Expression<String>(Keys.text.rawValue)
        let importance = Expression<String>(Keys.importance.rawValue)
        let isCompleted = Expression<Bool>(Keys.isCompleted.rawValue)
        let creationDate = Expression<Int>(Keys.creationDate.rawValue)
        let deadlineDate = Expression<Int?>(Keys.deadlineDate.rawValue)
        let modificationDate = Expression<Int?>(Keys.modificationDate.rawValue)

        do {
            self.todoItems.removeAll()
            for row in try dataBase.prepare(todoItems) {
                guard let importanceValue = Importance(rawValue: row[importance]) else { continue }
                self.todoItems.append(TodoItem(id: row[id],
                                               text: row[text],
                                               importance: importanceValue,
                                               deadlineDate: row[deadlineDate].map { Date(timeIntervalSince1970: TimeInterval($0)) },
                                               isCompleted: row[isCompleted],
                                               creationDate: Date(timeIntervalSince1970: TimeInterval(row[creationDate])),
                                               modificationDate: row[modificationDate].map { Date(timeIntervalSince1970: TimeInterval($0)) }))
            }
        } catch {
            print("Error: load()")
        }
    }
 }

// CoreData

// extension FileCache {
//    func save(item: TodoItem) {
//        guard let context = managedObjectContext else { return }
//        let entity = NSEntityDescription.entity(forEntityName: "TodoItemCoreData", in: context)!
//        let todoItem = NSManagedObject(entity: entity, insertInto: context)
//
//        todoItem.setValue(item.id, forKey: "id")
//        todoItem.setValue(item.text, forKey: "text")
//        todoItem.setValue(item.importance.rawValue, forKey: "importance")
//        todoItem.setValue(item.isCompleted, forKey: "isCompleted")
//        todoItem.setValue(Int(item.creationDate.timeIntervalSince1970), forKey: "creationDate")
//        todoItem.setValue("iOS", forKey: "lastUpdatedBy")
//        todoItem.setValue(item.deadlineDate.map { Int($0.timeIntervalSince1970) }, forKey: "deadlineDate")
//        todoItem.setValue(item.modificationDate.map { Int($0.timeIntervalSince1970) }, forKey: "modificationDate")
//
//        do {
//            try context.save()
//            DDLogDebug("CoreData: Сохранение todoItem")
//        } catch {
//            print("Ошибка при сохранении элемента: \(error)")
//        }
//    }
//
//    func insert(item: TodoItem) {
//        guard let context = managedObjectContext else { return }
//        let entity = NSEntityDescription.entity(forEntityName: "TodoItemCoreData", in: context)!
//        let todoItem = NSManagedObject(entity: entity, insertInto: context)
//
//        todoItem.setValue(item.id, forKey: "id")
//        todoItem.setValue(item.text, forKey: "text")
//        todoItem.setValue(item.importance.rawValue, forKey: "importance")
//        todoItem.setValue(item.isCompleted, forKey: "isCompleted")
//        todoItem.setValue(Int(item.creationDate.timeIntervalSince1970), forKey: "creationDate")
//        todoItem.setValue("iOS", forKey: "lastUpdatedBy")
//        todoItem.setValue(item.deadlineDate.map { Int($0.timeIntervalSince1970) }, forKey: "deadlineDate")
//        todoItem.setValue(item.modificationDate.map { Int($0.timeIntervalSince1970) }, forKey: "modificationDate")
//
//        do {
//            try context.save()
//            DDLogDebug("CoreData: Вставка todoItem")
//        } catch {
//            print("Ошибка при вставке элемента: \(error)")
//        }
//    }
//
//    func update(item: TodoItem) {
//        guard let context = managedObjectContext else { return }
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItemCoreData")
//
//        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
//
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let todoItem = results.first as? NSManagedObject {
//                todoItem.setValue(item.text, forKeyPath: "text")
//                todoItem.setValue(item.isCompleted, forKeyPath: "isCompleted")
//                todoItem.setValue(item.deadlineDate, forKeyPath: "deadlineDate")
//                todoItem.setValue(item.importance.rawValue, forKeyPath: "importance")
//                todoItem.setValue(item.modificationDate.map { Int($0.timeIntervalSince1970) }, forKeyPath: "modificationDate")
//
//                try context.save()
//                DDLogDebug("CoreData: Обновление todoItem")
//            }
//        } catch {
//            print("Ошибка при обновлении элемента: \(error)")
//        }
//    }
//
//    func delete(item: TodoItem) {
//        guard let context = managedObjectContext else { return }
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItemCoreData")
//
//        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
//
//        do {
//            let results = try context.fetch(fetchRequest)
//            if let todoItem = results.first as? NSManagedObject {
//                context.delete(todoItem)
//                try context.save()
//                DDLogDebug("CoreData: Удаление todoItem")
//            }
//        } catch {
//            print("Ошибка при удалении элемента: \(error)")
//        }
//    }
//
//    func load() {
//        guard let context = managedObjectContext else { return }
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItemCoreData")
//
//        do {
//            self.todoItems.removeAll()
//            let results = try context.fetch(fetchRequest)
//            for result in results {
//                guard let todoItem = result as? NSManagedObject else { continue }
//                guard let importanceValue = Importance(rawValue: todoItem.value(forKey: "importance") as? String ?? "") else { continue }
//                self.todoItems.append(TodoItem(id: todoItem.value(forKey: "id") as? String ?? "",
//                                               text: todoItem.value(forKey: "text") as? String ?? "",
//                                               importance: importanceValue,
//                                               deadlineDate: (todoItem.value(forKey: "deadlineDate") as? Int).map { Date(timeIntervalSince1970: TimeInterval($0)) },
//                                               isCompleted: todoItem.value(forKey: "isCompleted") as? Bool ?? false,
//                                               creationDate: Date(timeIntervalSince1970: TimeInterval(todoItem.value(forKey: "creationDate") as? Int ?? 0)),
//                                               modificationDate: (todoItem.value(forKey: "modificationDate") as? Int).map { Date(timeIntervalSince1970: TimeInterval($0)) }))
//            }
//            DDLogDebug("CoreData: Загрузка todoItemList")
//        } catch {
//            print("Error loading data: \(error)")
//        }
//    }
//
// }
