import SwiftUI

struct DeadlineListView: View {

    @StateObject private var viewModel = DeadlineListViewModel()
    @State private var showAddScreen = false
    @State private var showFeedbackSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.activeDeadlines(), id: \.id) { deadline in
                    NavigationLink {
                        AddDeadlineView(viewModel: viewModel, deadlineToEdit: deadline)
                    } label: {
                        DeadlineRowView(deadline: deadline, viewModel: viewModel)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { viewModel.removeDeadline(viewModel.activeDeadlines()[ $0 ]) }
                }
            }
            .navigationTitle("Deadlines")
            .toolbar {
                Button {
                    showAddScreen = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddScreen) {
                AddDeadlineView(viewModel: viewModel)
            }
            .sheet(isPresented: $showFeedbackSheet) {
                FeedbackView { rating, text in
                    FeedbackManager.hasProvidedFeedback = true
                    print("Feedback received: \(rating) stars, text: \(text)")
                }
            }
            .onAppear {
                viewModel.onDeadlineAdded = {
                    if !FeedbackManager.hasProvidedFeedback {
                        showFeedbackSheet = true
                    }
                }
            }
        }
    }
}
