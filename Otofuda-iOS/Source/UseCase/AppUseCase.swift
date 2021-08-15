
import Foundation

public final class AppUseCase {
    private let userRepository: UsersRepository

    public init(userRepository: UsersRepository) {
        self.userRepository = userRepository
    }

    public var userId: String? {
        userRepository.userId
    }
}
