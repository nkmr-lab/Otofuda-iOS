
import Foundation
import SwiftyJSON

protocol ResponseEntity {
    var json: JSON { get }
    init(_ json: JSON)
}
