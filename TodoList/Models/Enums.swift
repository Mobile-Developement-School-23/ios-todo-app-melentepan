import Foundation

enum Keys: String {
    case id = "id"
    case text = "text"
    case importance = "importance"
    case deadlineDate = "deadline"
    case isCompleted = "done"
    case creationDate = "created_at"
    case modificationDate = "changed_at"
    case lastUpdatedBy = "last_updated_by"
}

enum Importance: String {
    case unimportant = "low"
    case usual = "basic"
    case important = "important"
}

enum StatusVC {
    case creation
    case change
}

enum NetworkingError: Error {
    case urlError
    case decodeError
    case notFound
    case revisionError
}

enum HTTPMethods: String {
    case get
    case patch
    case post
    case put
    case delete
}
