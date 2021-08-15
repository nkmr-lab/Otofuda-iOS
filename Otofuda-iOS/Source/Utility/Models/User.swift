import Foundation
import UIKit

struct User {
    var index: Int

    var name: String

    var color: UIColor

    func dict() -> [String: Any] {
        var dict = [String: Any]()
        dict = ["name": name]
        return dict
    }
}
