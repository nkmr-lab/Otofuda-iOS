
import Foundation
import UIKit.UIDevice

public protocol UsersRepository: AnyObject {
    var userId: String? { get }
}

public final class UsersRepositoryImpl: UsersRepository {
    public init() {}

    public var userId: String? {
        UIDevice.current.identifierForVendor!.uuidString
    }
}
