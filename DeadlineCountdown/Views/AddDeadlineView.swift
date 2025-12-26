import SwiftUI

struct AddDeadlineView: View {
    
    @ObservedObject var viewModel: DeadlineListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State var title = ""
    @State var dueDate = Date()
    @State var remindBefore: Int16 = 10
    
    var deadlineToEdit: DeadlineEntity? = nil
    
    init(viewModel: DeadlineListViewModel, deadlineToEdit: DeadlineEntity? = nil) {
        self.viewModel = viewModel
        self.deadlineToEdit = deadlineToEdit
        if let edit = deadlineToEdit {
            _title = State(initialValue: edit.title ?? "")
            _dueDate = State(initialValue: edit.dueDate ?? Date())
            _remindBefore = State(initialValue: edit.remindBefore)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                DatePicker("Deadline", selection: $dueDate)
                Stepper(value: $remindBefore, in: 0...1440, step: 5) {
                    Text("Напомнить за \(remindBefore) минут")
                }
            }
            .navigationTitle(deadlineToEdit == nil ? "New Deadline" : "Edit Deadline")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let edit = deadlineToEdit {
                            viewModel.updateDeadline(edit, title: title, dueDate: dueDate, remindBefore: remindBefore)
                        } else {
                            viewModel.addDeadline(title: title, dueDate: dueDate, remindBefore: remindBefore)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
