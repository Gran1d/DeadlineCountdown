import SwiftUI

struct TodoRowView: View {

    let todo: TodoItemEntity
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.isCompleted ? .green : .gray)
                .onTapGesture {
                    onToggle()
                }

            Text(todo.title ?? "")
                .strikethrough(todo.isCompleted)
                .foregroundColor(todo.isCompleted ? .secondary : .primary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
