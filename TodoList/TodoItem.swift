import Foundation

struct TodoItem {
    
    static let separator = ";"
    
    let id: String
    let text: String
    let importance: Importance
    let deadlineDate: Date?
    let isCompleted: Bool
    let creationDate: Date
    let modificationDate: Date?
    
    init(id: String = UUID().uuidString, text: String, importance: Importance, deadlineDate: Date? = nil, isCompleted: Bool, creationDate: Date = Date(), modificationDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadlineDate = deadlineDate
        self.isCompleted = isCompleted
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}
