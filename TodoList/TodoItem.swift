import Foundation

enum Importance: String {
    case unimportant = "неважная"
    case usual = "обычная"
    case important = "важная"
}

struct TodoItem {
    
    static let separator = ";"
    
    let id: String
    let text: String
    let importance: Importance
    let deadlineDate: Date?
    let isCompleted: Bool
    let creationDate: Date
    let modificationDate: Date?
    
    init(id: String = UUID().uuidString, text: String, importance: Importance, deadlineDate: Date?, isCompleted: Bool, creationDate: Date, modificationDate: Date?) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadlineDate = deadlineDate
        self.isCompleted = isCompleted
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}


extension TodoItem {
    var json: Any {
        var jsonDict: [String: Any] = [
            "id": id,
            "text": text,
            "isCompleted": isCompleted,
            "creationDate": creationDate.timeIntervalSince1970
        ]
        if importance.rawValue != Importance.usual.rawValue {
            jsonDict["importance"] = importance.rawValue
        }
        if let deadlineDate = deadlineDate {
            jsonDict["deadlineDate"] = deadlineDate.timeIntervalSince1970
        }
        if let modificationDate = modificationDate {
            jsonDict["modificationDate"] = modificationDate.timeIntervalSince1970
        }
        return jsonDict
    }
    
    var csv: String {
        var csvString = "\(id)\(TodoItem.separator)\(text)\(TodoItem.separator)\(isCompleted)\(TodoItem.separator)\(creationDate.timeIntervalSince1970)"
        if importance.rawValue != Importance.usual.rawValue {
            csvString += "\(TodoItem.separator)\(importance.rawValue)"
        } else {
            csvString += "\(TodoItem.separator)"
        }
        if let deadlineDate = deadlineDate {
            csvString += "\(TodoItem.separator)\(deadlineDate.timeIntervalSince1970)"
        } else {
            csvString += "\(TodoItem.separator)"
        }
        if let modificationDate = modificationDate {
            csvString += "\(TodoItem.separator)\(modificationDate.timeIntervalSince1970)"
        } else {
            csvString += "\(TodoItem.separator)"
        }
        return csvString
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let jsonDict = json as? [String: Any] else { return nil }
        
        guard let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let isCompleted = jsonDict["isCompleted"] as? Bool,
              let creationDateTimestamp = jsonDict["creationDate"] as? TimeInterval
        else { return nil }
        
        let importanceRawValue = jsonDict["importance"] as? String ?? Importance.usual.rawValue
        let importance = Importance(rawValue: importanceRawValue) ?? .usual
        
        let deadlineDate: Date?
        if let deadlineDateTimestamp = jsonDict["deadlineDate"] as? TimeInterval {
            deadlineDate = Date(timeIntervalSince1970: deadlineDateTimestamp)
        } else {
            deadlineDate = nil
        }
        
        let modificationDate: Date?
        if let modificationDateTimestamp = jsonDict["modificationDate"] as? TimeInterval {
            modificationDate = Date(timeIntervalSince1970: modificationDateTimestamp)
        } else {
            modificationDate = nil
        }
        
        
        return TodoItem(id: id, text: text, importance: importance, deadlineDate: deadlineDate, isCompleted: isCompleted, creationDate: Date(timeIntervalSince1970: creationDateTimestamp), modificationDate: modificationDate)
    }
    
    static func parse(csv: String) -> TodoItem? {
        let components = csv.components(separatedBy: TodoItem.separator)
        guard components.count == 7 else { return nil }
        guard let isCompleted = Bool(components[4]),
              let creationDateTimestamp = TimeInterval(components[5])
        else { return nil }
        let id = components[0]
        let text = components[1]
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
        
        
        return TodoItem(id: id, text: text, importance: importance, deadlineDate: deadlineDate, isCompleted: isCompleted, creationDate: Date(timeIntervalSince1970: creationDateTimestamp), modificationDate: modificationDate)
    }
}
