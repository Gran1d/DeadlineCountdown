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
}
