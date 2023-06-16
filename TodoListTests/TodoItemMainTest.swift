import XCTest
@testable import TodoList

class TodoItemTests: XCTestCase {
    
    func testNormalInit() {
        let id = "testID"
        let text = "testText"
        let importance = Importance.important
        let deadlineDate = Date()
        let isCompleted = true
        let creationDate = Date()
        let modificationDate = Date()
        
        let todoItem = TodoItem(id: id, text: text, importance: importance, deadlineDate: deadlineDate, isCompleted: isCompleted, creationDate: creationDate, modificationDate: modificationDate)
        
        XCTAssertEqual(todoItem.id, id)
        XCTAssertEqual(todoItem.text, text)
        XCTAssertEqual(todoItem.importance, importance)
        XCTAssertEqual(todoItem.deadlineDate, deadlineDate)
        XCTAssertEqual(todoItem.isCompleted, isCompleted)
        XCTAssertEqual(todoItem.creationDate, creationDate)
        XCTAssertEqual(todoItem.modificationDate, modificationDate)
    }
    
    func testInitWithoutIdDeadlineModificationDates() {
        let text = "testText"
        let importance = Importance.important
        let isCompleted = true
        let creationDate = Date()
        
        let todoItem = TodoItem(text: text, importance: importance, deadlineDate: nil, isCompleted: isCompleted, creationDate: creationDate, modificationDate: nil)
        
        XCTAssertNotNil(todoItem.id)
        XCTAssertEqual(todoItem.text, text)
        XCTAssertEqual(todoItem.importance, importance)
        XCTAssertNil(todoItem.deadlineDate)
        XCTAssertEqual(todoItem.isCompleted, isCompleted)
        XCTAssertEqual(todoItem.creationDate, creationDate)
        XCTAssertNil(todoItem.modificationDate)
    }
    
    func testIdIsUnique() {
        let todoItem1 = TodoItem(text: "Test1", importance: .usual, deadlineDate: nil, isCompleted: false, creationDate: Date(), modificationDate: nil)
        let todoItem2 = TodoItem(text: "Test2", importance: .important, deadlineDate: nil, isCompleted: true, creationDate: Date(), modificationDate: nil)
        XCTAssertNotEqual(todoItem1.id, todoItem2.id)
    }
    
    
}
