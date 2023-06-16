import XCTest
@testable import TodoList

class TodoItemJsonTests: XCTestCase {
    func testJsonImportanceNotUsual() {
        let importance = Importance.important
        let todoItem = TodoItem(text: "Test", importance: importance, deadlineDate: nil, isCompleted: false , creationDate: Date(), modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertEqual(json?["importance"] as? String , importance.rawValue)
    }
    
    func testJsonImportanceUsual() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: nil , isCompleted: false , creationDate: Date() , modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertNil(json?["importance"])
    }
    
    func testJsonDeadlineNil() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: nil , isCompleted: false , creationDate: Date() , modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertNil(json?["deadlineDate"])
    }
    
    func testJsonDeadlineNotNil() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: Date() , isCompleted: false , creationDate: Date() , modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertNotNil(json?["deadlineDate"])
    }
    
    func testJsonModificationNil() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: nil , isCompleted: false , creationDate: Date() , modificationDate: nil )
        let json = todoItem.json as? [String:Any]
        XCTAssertNil(json?["modificationDate"])
    }
    
    func testJsonModificationNotNil() {
        let todoItem = TodoItem(text: "Test" , importance: .usual , deadlineDate: nil, isCompleted: false , creationDate: Date() , modificationDate: Date() )
        let json = todoItem.json as? [String:Any]
        XCTAssertNotNil(json?["modificationDate"])
    }
    
    
    func testParseWithoutImportance() {
        let json:[String:Any] = [
            "id":"test-id",
            "text":"Test",
            "isCompleted":false,
            "creationDate":Date().timeIntervalSince1970,
            "deadlineDate":Date().timeIntervalSince1970,
            "modificationDate":Date().timeIntervalSince1970,
        ]
        let todoItem = TodoItem.parse(json: json)
        XCTAssertEqual(todoItem?.importance, Importance.usual)
    }
    
    func testParseDeadlineNotNil(){
        let date = Date()
        let json:[String:Any]=[
            "id":"test-id",
            "text":"Test",
            "isCompleted":false,
            "creationDate":date.timeIntervalSince1970,
            "deadlineDate":date.timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json:json)
        XCTAssertNotNil(todoItem?.deadlineDate)
    }
    
    func testParseDeadlineEqual() {
        let date = Date()
        let json: [String: Any] = [
            "id": "test-id",
            "text": "Test",
            "isCompleted": false,
            "creationDate": date.timeIntervalSince1970,
            "deadlineDate": date.timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json: json)
        XCTAssertEqual(todoItem?.deadlineDate, date)
    }
    
    
    func testParseModificationNil(){
        let json:[String:Any]=[
            "id":"test-id",
            "text":"Test",
            "isCompleted":false,
            "creationDate":Date().timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json:json)
        XCTAssertNil(todoItem?.modificationDate)
    }
    
    func testParseModificationNotNil(){
        let date = Date()
        let json:[String:Any]=[
            "id":"test-id",
            "text":"Test",
            "isCompleted":false,
            "creationDate":date.timeIntervalSince1970,
            "modificationDate":date.timeIntervalSince1970
        ]
        let todoItem=TodoItem.parse(json:json)
        XCTAssertNotNil(todoItem?.modificationDate)
    }
    
    func testParseModificationEqual(){
        let date = Date()
        let json:[String:Any]=[
            "id":"test-id",
            "text":"Test",
            "isCompleted":false,
            "creationDate":date.timeIntervalSince1970,
            "modificationDate":date.timeIntervalSince1970
        ]
        let todoItem = TodoItem.parse(json:json)
        XCTAssertEqual(todoItem?.modificationDate, date)
    }
}

