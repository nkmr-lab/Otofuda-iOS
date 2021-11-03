
import Foundation
import OtofudaEntity
import UIKit

public final class UserModel: Encodable, Identifiable {
    public var id: String
    public var order: Int
    public var color: ColorList

    public init(id: String = UIDevice.current.identifierForVendor!.uuidString, order: Int) {
        self.id = id
        self.order = order
        color = .init(index: order)
    }

    public func dict() -> [String: Any] {
        var dict = [String: Any]()
        dict = ["name": order]
        return dict
    }
}
