//
//  DeadlineCountdownApp.swift
//  DeadlineCountdown
//
//  Created by Артём Сиротин on 25.12.2025.
//

import SwiftUI
import CoreData

@main
struct DeadlineCountdownApp: App {
    
    static let appLaunchTime = Date() // время старта приложения
    let persistenceController = PersistenceController.shared
    
    init() {
        NotificationService.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                DeadlineListView()
                    .tabItem { Label("Active", systemImage: "list.bullet") }
                
                ArchivedDeadlineListView()
                    .tabItem { Label("Archive", systemImage: "archivebox") }
                
                MetricsView()
                        .tabItem { Label("Metrics", systemImage: "chart.bar") }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

