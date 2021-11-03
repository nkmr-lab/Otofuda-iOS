
import Foundation

public final class UserUseCase {
    private let userRepository: UsersRepository

    public init(userRepository: UsersRepository) {
        self.userRepository = userRepository
    }

    public var userId: String? {
        userRepository.userId
    }
}
