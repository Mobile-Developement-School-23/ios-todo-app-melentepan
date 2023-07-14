import Foundation
import CoreData

extension TodoItemCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemCoreData> {
        return NSFetchRequest<TodoItemCoreData>(entityName: "TodoItemCoreData")
    }

    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var priority: String
    @NSManaged public var deadline: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var dateCreated: Date
    @NSManaged public var dateModified: Date?

}
