import XCTest
@testable import TodoList

class TodoItemJsonTests: XCTestCase {
    func testJsonImportanceNotUsual() {
        let importance = Importance.important
        let todoItem = TodoItem(text: "Test", importance: importance, deadlineDate: nil, isCompleted: false , creationDate: Date(), modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertEqual(json?[Keys.importance.rawValue] as? String , importance.rawValue)
    }
    
    func testJsonImportanceUsual() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: nil , isCompleted: false , creationDate: Date() , modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertNil(json?[Keys.importance.rawValue])
    }
    
    func testJsonDeadlineNil() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: nil , isCompleted: false , creationDate: Date() , modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertNil(json?[Keys.deadlineDate.rawValue])
    }
    
    func testJsonDeadlineNotNil() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: Date() , isCompleted: false , creationDate: Date() , modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertNotNil(json?[Keys.deadlineDate.rawValue])
    }
    
    func testJsonModificationNil() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: nil , isCompleted: false , creationDate: Date() , modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertNil(json?[Keys.modificationDate.rawValue])
    }
    
    func testJsonModificationNotNil() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: nil, isCompleted: false , creationDate: Date() , modificationDate: Date() )
        let json = todoItem.json as? [String:Any]
        XCTAssertNotNil(json?[Keys.modificationDate.rawValue])
    }
    
    
    func testParseWithoutImportance() {
        let json:[String:Any] = [
            Keys.id.rawValue:"test-id",
            Keys.text.rawValue:"Test",
            Keys.isCompleted.rawValue:false,
            Keys.creationDate.rawValue:Date().timeIntervalSince1970,
            Keys.deadlineDate.rawValue:Date().timeIntervalSince1970,
            Keys.modificationDate.rawValue:Date().timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json: json)
        XCTAssertEqual(todoItem?.importance, Importance.usual)
    }
    
    func testParseDeadlineNotNil(){
        let date = Date()
        let json:[String:Any]=[
            Keys.id.rawValue:"test-id",
            Keys.text.rawValue:"Test",
            Keys.isCompleted.rawValue:false,
            Keys.creationDate.rawValue:date.timeIntervalSince1970,
            Keys.deadlineDate.rawValue:date.timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json:json)
        XCTAssertNotNil(todoItem?.deadlineDate)
    }
    
    func testParseDeadlineEqual() {
        let date = Date()
        let json: [String: Any] = [
            Keys.id.rawValue:"test-id",
            Keys.text.rawValue:"Test",
            Keys.isCompleted.rawValue:false,
            Keys.creationDate.rawValue:date.timeIntervalSince1970,
            Keys.deadlineDate.rawValue:date.timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json: json)
        XCTAssertEqual(todoItem?.deadlineDate?.timeIntervalSince1970, date.timeIntervalSince1970)
    }
    
    
    func testParseModificationNil(){
        let json:[String:Any]=[
            Keys.id.rawValue:"test-id",
            Keys.text.rawValue:"Test",
            Keys.isCompleted.rawValue:false,
            Keys.creationDate.rawValue:Date().timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json:json)
        XCTAssertNil(todoItem?.modificationDate)
    }
    
    func testParseModificationNotNil(){
        let date = Date()
        let json:[String:Any]=[
            Keys.id.rawValue:"test-id",
            Keys.text.rawValue:"Test",
            Keys.isCompleted.rawValue:false,
            Keys.creationDate.rawValue:date.timeIntervalSince1970,
            Keys.modificationDate.rawValue:date.timeIntervalSince1970
        ]
        let todoItem=TodoItem.parse(json:json)
        XCTAssertNotNil(todoItem?.modificationDate)
    }
    
    func testParseModificationEqual(){
        let date = Date()
        let json:[String:Any]=[
            Keys.id.rawValue:"test-id",
            Keys.text.rawValue:"Test",
            Keys.isCompleted.rawValue:false,
            Keys.creationDate.rawValue:date.timeIntervalSince1970,
            Keys.modificationDate.rawValue:date.timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json:json)
        XCTAssertEqual(todoItem?.modificationDate?.timeIntervalSince1970, date.timeIntervalSince1970)
    }
}

