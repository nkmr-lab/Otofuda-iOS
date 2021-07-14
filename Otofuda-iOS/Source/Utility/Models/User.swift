import Foundation
import UIKit

struct User {

    var index: Int

    var name: String

    var color: UIColor

    func dict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict = ["name": name]
        return dict
    }
}
