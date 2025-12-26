import SwiftUI
import CoreData
import UIKit
import Foundation

// MARK: - MetricsView
struct MetricsView: View {

    @StateObject private var viewModel = DeadlineListViewModel()
    @State private var sessionStart = Date()
    @State private var sessionLength: TimeInterval = 0
    @State private var showFeedbackSheet = false

    var body: some View {
        NavigationStack {
            List {
                // Device Info
                Section("Device Info") {
                    Text("Model: \(DeviceInfo.model)")
                    Text("Name: \(DeviceInfo.name)")
                    Text("System: \(DeviceInfo.systemName) \(DeviceInfo.systemVersion)")
                    Text("Screen: \(DeviceInfo.screenResolution)")
                }

                // Performance Metrics
                Section("Performance Metrics") {
                    Text("App start time: \(DeadlineCountdownApp.appLaunchTime.formatted())")
                    Text("Session length: \(Int(sessionLength)) s")
                }

                // Stability Metrics
                Section("Stability Metrics") {
                    Text("CoreData Errors: \(AppMetrics.coreDataErrors)")
                }

                // Memory Metrics
                Section("Memory Metrics") {
                    Text("Used memory: \(usedMemory()) MB")
                }

                // Functionality Metrics
                Section("Functionality Metrics") {
                    Text("Active Deadlines: \(viewModel.activeDeadlines().count)")
                    Text("Archived Deadlines: \(viewModel.archivedDeadlines().count)")
                }

                // User Feedback
                Section("User Feedback") {
                    Button("Send Feedback") {
                        showFeedbackSheet = true
                    }
                }
                
                Section("Task Metrics") {
                    Text("Total tasks: \(viewModel.totalTodoCount())")
                    Text("Completed tasks: \(viewModel.completedTodoCount())")

                    let total = viewModel.totalTodoCount()
                    if total > 0 {
                        let percent = Int(Double(viewModel.completedTodoCount()) / Double(total) * 100)
                        Text("Completion rate: \(percent)%")
                    }

                    Text("Deadlines with 100% tasks done: \(viewModel.deadlinesWithAllTasksCompleted())")
                }

            }
            .navigationTitle("App Metrics")
            .onAppear {
                sessionStart = Date()
                // Автопоказ Feedback после добавления дедлайна
                print("Has user provided feedback? \(FeedbackManager.hasProvidedFeedback)")
                viewModel.onDeadlineAdded = {
                    if !FeedbackManager.hasProvidedFeedback {
                        showFeedbackSheet = true
                    }
                }
            }
            .onDisappear {
                sessionLength = Date().timeIntervalSince(sessionStart)
            }
            .sheet(isPresented: $showFeedbackSheet) {
                FeedbackView { rating, text in
                    FeedbackManager.hasProvidedFeedback = true
                    print("Feedback received: \(rating) stars, text: \(text)")
                }
            }
        }
    }
}
