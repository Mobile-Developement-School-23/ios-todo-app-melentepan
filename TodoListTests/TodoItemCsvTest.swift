import XCTest
@testable import TodoList

class TodoItemCsvTests: XCTestCase {
    
    func testCsvImportanceNotUsual() {
        let importance = Importance.important
        let todoItem = TodoItem(text: "Test", importance: importance, deadlineDate: nil, isCompleted: false, creationDate: Date(), modificationDate: nil )
        let csv = todoItem.csv
        XCTAssertEqual(csv.components(separatedBy: TodoItem.separator)[2], importance.rawValue)
    }
    
    func testCsvImportanceUsual() {
        let todoItem = TodoItem(text: "Test", importance: .usual, deadlineDate: nil, isCompleted: false, creationDate: Date(), modificationDate: nil )
        let csv = todoItem.csv
        XCTAssertEqual(csv.components(separatedBy: TodoItem.separator)[2], "")
    }
    
    func testCsvDeadlineNil() {
        let todoItem = TodoItem(text: "Test", importance: .usual, deadlineDate: nil, isCompleted: false, creationDate: Date(), modificationDate: nil )
        let csv = todoItem.csv
        XCTAssertEqual(csv.components(separatedBy: TodoItem.separator)[3], "")
    }
    
    func testCsvDeadlineNotNil() {
        let date = Date()
        let todoItem = TodoItem(text: "Test", importance: .usual, deadlineDate: date, isCompleted: false, creationDate: Date(), modificationDate: nil )
        let csv = todoItem.csv
        XCTAssertEqual(csv.components(separatedBy: TodoItem.separator)[3], String(date.timeIntervalSince1970))
    }
    
    func testCsvModificationNil() {
        let todoItem = TodoItem(text: "Test", importance: .usual, deadlineDate: nil, isCompleted: false, creationDate: Date(), modificationDate: nil )
        let csv = todoItem.csv
        XCTAssertEqual(csv.components(separatedBy: TodoItem.separator)[6], "")
    }
    
    func testCsvModificationNotNil() {
        let date = Date()
        let todoItem = TodoItem(text: "Test", importance: .usual, deadlineDate:nil, isCompleted:false, creationDate:date, modificationDate:date)
        let csv = todoItem.csv
        print(csv)
        XCTAssertEqual(csv.components(separatedBy: TodoItem.separator)[6], String(date.timeIntervalSince1970))
    }
    
    func testParseWithoutImportance() {
        let date = Date()
        let csv = "test-id\(TodoItem.separator)Test\(TodoItem.separator)\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)false\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)\(date.timeIntervalSince1970)"
        let todoItem = TodoItem.parse(csv: csv)
        XCTAssertEqual(todoItem?.importance, Importance.usual)
    }
    
    
    func testParseDeadlineNotNil(){
        let date = Date()
        let csv = "test-id\(TodoItem.separator)Test\(TodoItem.separator)\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)false\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)\(date.timeIntervalSince1970)"
        
        let todoItem = TodoItem.parse(csv:csv)
        XCTAssertNotNil(todoItem?.deadlineDate)
    }
    
    func testParseDeadlineEqual(){
        let date = Date()
        let csv = "test-id\(TodoItem.separator)Test\(TodoItem.separator)\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)false\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)\(date.timeIntervalSince1970)"
        let todoItem = TodoItem.parse(csv:csv)
        XCTAssertEqual(todoItem?.deadlineDate?.timeIntervalSince1970, date.timeIntervalSince1970)
    }
    
    func testParseModificationNil(){
        let date = Date()
        let csv="test-id\(TodoItem.separator)test\(TodoItem.separator)\(TodoItem.separator)\(date.timeIntervalSince1970)"
        let todoItem = TodoItem.parse(csv:csv)
        XCTAssertNil(todoItem?.modificationDate)
    }
    
    func testParseModificationNotNil(){
        let date = Date()
        let csv = "test-id\(TodoItem.separator)Test\(TodoItem.separator)\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)false\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)\(date.timeIntervalSince1970)"
        let todoItem = TodoItem.parse(csv:csv)
        XCTAssertNotNil(todoItem?.modificationDate)
    }
    
    func testParseModificationEqual(){
        let date = Date()
        let csv = "test-id\(TodoItem.separator)Test\(TodoItem.separator)\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)false\(TodoItem.separator)\(date.timeIntervalSince1970)\(TodoItem.separator)\(date.timeIntervalSince1970)"
        let todoItem = TodoItem.parse(csv:csv)
        XCTAssertEqual(todoItem?.modificationDate?.timeIntervalSince1970, date.timeIntervalSince1970)
    }
}