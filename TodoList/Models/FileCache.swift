import Foundation

class FileCache {
    private(set) var todoItems: [TodoItem] = []
    
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
    
    func saveJSON() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent("todoItems.json")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: todoItems.map { $0.json }) else {
            print("JSONSerializationError")
            return
        }
        do {
            try jsonData.write(to: fileURL)
        } catch {
            print("jsonDataWriteError")
        }
    }
    
    func loadJSON(from fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: data)
        guard let jsonArray = json as? [[String: Any]] else { return }
        todoItems = jsonArray.compactMap { TodoItem.parse(json: $0) }
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
