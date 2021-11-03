
import Foundation

public protocol Entity {
    static func decode(document: [String: Any]) -> Self?
}
