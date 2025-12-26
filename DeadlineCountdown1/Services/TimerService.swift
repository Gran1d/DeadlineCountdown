import Foundation
import Combine

final class TimerService: ObservableObject {
    static let shared = TimerService()
    
    @Published var currentDate = Date()
    private var timer: Timer?
    
    private init() { start() }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.currentDate = Date()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
