
import Foundation

final class Environment {
    static let shared = Environment()

    let userRepository: UsersRepository

    init() {
        userRepository = UsersRepositoryImpl()
    }
}
