import SwiftUI

struct ContentView: View {
    @State private var todoItems: [TodoItem] = [
        TodoItem(text: "Example 1\nExample 1\nExample 1\n", importance: .usual, isCompleted: false),
        TodoItem(text: "Example 2\nExample 2\nExample 2\n", importance: .important, isCompleted: false),
        TodoItem(text: "Example 3\nExample 3\nExample 3\n", importance: .important, isCompleted: true),
        TodoItem(text: "Example 4\nExample 4\nExample 4\n", importance: .important, deadlineDate: Date(), isCompleted: false),
        TodoItem(text: "Example 5\nExample 5\nExample 5\n", importance: .important, isCompleted: false),
        TodoItem(text: "Example 6\nExample 6\n", importance: .important, isCompleted: false),
        TodoItem(text: "Example 7", importance: .unimportant, isCompleted: false),
        TodoItem(text: "Example 8", importance: .important, isCompleted: false),
        TodoItem(text: "Example 9", importance: .important, isCompleted: false),
        TodoItem(text: "Example 10", importance: .important, isCompleted: false),
        TodoItem(text: "Example 11", importance: .usual, isCompleted: false),
        TodoItem(text: "Example 12", importance: .important, isCompleted: false),
        TodoItem(text: "Example 13", importance: .important, isCompleted: false),
        TodoItem(text: "Example 14", importance: .unimportant, isCompleted: false),
        TodoItem(text: "Example 15", importance: .important, isCompleted: false),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("Выполнено — 0")
                            .opacity(0.3)
                        Spacer()
                        Button("Показать") {
                        }
                    }
                    .padding(EdgeInsets(top: 18, leading: 16, bottom: 12, trailing: 16))
                }
                LazyVStack {
                    ForEach(todoItems) { todoItem in
                        TodoItemRow(todoItem: todoItem)
                        CustomDivider()
                    }
                    Button(action: {print("Create todoitem")}) {
                        Text("Новое")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 40)
                            .foregroundColor(.black)
                            .opacity(0.3)
                    }
                    .frame(height: 56)

                }
                .background(
                    Color.white
                        .cornerRadius(16)
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 56, trailing: 16))
            }
            .navigationTitle("Мои дела")
            .background(Color(red: 0.97, green: 0.97, blue: 0.95))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
