import Foundation

class FeedbackManager {
    private static let key = "hasProvidedFeedback"

    static var hasProvidedFeedback: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
