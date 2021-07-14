
import Foundation

protocol RequestEntity {
    func parameterize() -> [String: Any]
}
