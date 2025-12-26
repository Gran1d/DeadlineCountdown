import UIKit

struct DeviceInfo {
    static var model: String { UIDevice.current.model }
    static var name: String { UIDevice.current.name }
    static var systemVersion: String { UIDevice.current.systemVersion }
    static var systemName: String { UIDevice.current.systemName }
    static var screenResolution: String {
        let scale = UIScreen.main.scale
        let size = UIScreen.main.bounds.size
        return "\(Int(size.width * scale)) x \(Int(size.height * scale))"
    }
}
