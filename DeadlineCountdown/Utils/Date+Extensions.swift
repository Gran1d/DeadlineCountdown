import Foundation

extension Date {
    func timeRemaining(until date: Date) -> TimeInterval {
        return date.timeIntervalSince(self)
    }

    func isPast(_ date: Date) -> Bool {
        return self > date
    }
}
