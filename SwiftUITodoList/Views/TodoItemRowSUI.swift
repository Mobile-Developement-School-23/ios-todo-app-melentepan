import SwiftUI

struct TodoItemRow: View {
    var todoItem = TodoItem(text: "", importance: .usual, isCompleted: false)

    var body: some View {
        HStack {
            cellImageView
                .padding(.trailing, 12)
            VStack(alignment: .leading) {
                topLabel
                if todoItem.deadlineDate != nil {
                    bottomStackView
                }
            }
            Spacer()
        }
        .padding()
    }

    private var cellImageView: some View {
        var imageName: String = "none"
        if todoItem.isCompleted {
            imageName = "done"
        } else if todoItem.importance == .important {
            imageName = "important"
        }
        else {
            imageName = "none"
        }
        return Image(imageName)
    }

    private var topLabel: some View {
        let importanceSym: String
        switch todoItem.importance {
        case .important:
            importanceSym = "‼️ "
        case .unimportant:
            importanceSym = "↓ "
        default:
            importanceSym = ""
        }
        return Text(importanceSym + todoItem.text)
            .font(.system(size: 17))
            .strikethrough(todoItem.isCompleted, color: .black)
            .opacity(todoItem.isCompleted ? 0.3 : 1)
            .lineLimit(3)
    }

    private var bottomStackView: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .resizable()
                .frame(width: 13, height: 12)
            Text(dateString(from: todoItem.deadlineDate!))
                .font(.system(size: 15))
        }
        .opacity(0.3)
    }

    private func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return dateFormatter.string(from: date)
    }
}


struct TodoItemRowSUI_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemRow()
    }
}
