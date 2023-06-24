import Foundation

enum Keys: String {
    case id
    case text
    case importance
    case deadlineDate
    case isCompleted
    case creationDate
    case modificationDate
}

enum Importance: String {
    case unimportant = "неважная"
    case usual = "обычная"
    case important = "важная"
}
