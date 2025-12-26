import SwiftUI

struct TodoListView: View {

    let deadline: DeadlineEntity
    @ObservedObject var viewModel: DeadlineListViewModel

    @State private var newTodoTitle = ""

    var body: some View {
        Section("Tasks") {

            ForEach(viewModel.todos(for: deadline), id: \.id) { todo in
                TodoRowView(todo: todo) {
                    viewModel.toggleTodo(todo)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    let todo = viewModel.todos(for: deadline)[$0]
                    viewModel.removeTodo(todo)
                }
            }

            HStack {
                TextField("New task", text: $newTodoTitle)

                Button("Add") {
                    guard !newTodoTitle.isEmpty else { return }
                    viewModel.addTodo(to: deadline, title: newTodoTitle)
                    newTodoTitle = ""
                }
            }
        }
    }
}
