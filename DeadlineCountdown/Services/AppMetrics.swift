import Foundation

class AppMetrics {
    static var coreDataErrors = 0
    
    static func logError(_ error: Error) {
        coreDataErrors += 1
        print("CoreData Error: \(error.localizedDescription)")
    }
}
