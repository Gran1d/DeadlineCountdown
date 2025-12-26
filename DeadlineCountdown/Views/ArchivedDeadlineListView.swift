import SwiftUI

struct ArchivedDeadlineListView: View {
    
    @StateObject private var viewModel = DeadlineListViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.archivedDeadlines(), id: \.id) { deadline in
                    DeadlineRowView(deadline: deadline, viewModel: viewModel)
                }
                .onDelete { indexSet in
                    indexSet.forEach { viewModel.removeDeadline(viewModel.archivedDeadlines()[ $0 ]) }
                }
            }
            .navigationTitle("Archive")
            .onAppear {
                viewModel.archivePastDeadlines()
            }
        }
    }
}
