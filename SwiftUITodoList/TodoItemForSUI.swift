import Foundation

struct TodoItem: Identifiable {

    static let separator = ";"

    let id: String
    var text: String
    var importance: Importance
    var deadlineDate: Date?
    var isCompleted: Bool
    let creationDate: Date
    var modificationDate: Date?

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
