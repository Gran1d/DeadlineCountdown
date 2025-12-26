import SwiftUI

struct DeadlineRowView: View {
    let deadline: DeadlineEntity
    @ObservedObject var viewModel: DeadlineListViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(deadline.title ?? "")
                    .font(.headline)
                Text(timeString(for: deadline))
                    .font(.subheadline)
                    .foregroundColor(color(for: deadline))
                Text(taskProgress(for: deadline))
                    .font(.caption)
                    .foregroundColor(taskProgressColor(for: deadline))
            }
            Spacer()
        }
        .padding(.vertical, 4)
        
    }
    
    private func timeString(for deadline: DeadlineEntity) -> String {
        let interval = viewModel.timeRemaining(for: deadline)
        if interval <= 0 { return "⏰ Passed" }
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
    }
    
    private func color(for deadline: DeadlineEntity) -> Color {
        let interval = viewModel.timeRemaining(for: deadline)
        switch interval {
        case let x where x <= 0: return .gray
        case 0..<3600: return .red
        case 3600..<86400: return .orange
        default: return .green
        }
    }
    
    private func taskProgress(for deadline: DeadlineEntity) -> String {
        let todos = viewModel.todos(for: deadline)
        guard !todos.isEmpty else { return "No tasks" }
        let completed = todos.filter { $0.isCompleted }.count
        return "\(completed) / \(todos.count) tasks"
    }

    private func taskProgressColor(for deadline: DeadlineEntity) -> Color {
        let todos = viewModel.todos(for: deadline)
        guard !todos.isEmpty else { return .secondary }
        let completed = todos.filter { $0.isCompleted }.count

        let progress = Double(completed) / Double(todos.count)
        switch progress {
        case 1.0:
            return .green
        case 0.5...:
            return .orange
        default:
            return .red
        }
    }

}
