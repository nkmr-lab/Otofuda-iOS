import Foundation

extension NSObject {
    class var className: String {
        String(describing: self)
    }
}
