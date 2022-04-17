
import Combine
import CombineFirebaseFirestore
import FirebaseFirestore
import Foundation
import OtofudaEntity
import UIKit.UIDevice

public protocol UsersRepository: AnyObject {
    var userId: String? { get }
    func fetchAll() -> AnyPublisher<[UserEntity], Error>
}

public final class UsersRepositoryImpl: UsersRepository {
    public init() {}

    public var userId: String? {
        UIDevice.current.identifierForVendor!.uuidString
    }

    public func fetchAll() -> AnyPublisher<[UserEntity], Error> {
        return Firestore.firestore().collection("users").getDocuments(as: UserEntity.self)
    }
}
