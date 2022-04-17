
import Combine
import Foundation
import OtofudaEntity

public final class AppUseCase {
    private let userRepository: UsersRepository

    public init(userRepository: UsersRepository) {
        self.userRepository = userRepository
    }

    public var userId: String? {
        userRepository.userId
    }

    public func fetchAllUsers() -> AnyPublisher<[UserEntity], Error> {
        userRepository.fetchAll().eraseToAnyPublisher()
    }
}
