import Foundation


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
        }
        else {
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
        
        
        return TodoItem(id: id, text: text, importance: importance, deadlineDate: deadlineDate, isCompleted: isCompleted, creationDate: Date(timeIntervalSince1970: creationDateTimestamp), modificationDate: modificationDate)
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
        
        
        return TodoItem(id: id, text: text, importance: importance, deadlineDate: deadlineDate, isCompleted: isCompleted, creationDate: Date(timeIntervalSince1970: creationDateTimestamp), modificationDate: modificationDate)
    }
}
