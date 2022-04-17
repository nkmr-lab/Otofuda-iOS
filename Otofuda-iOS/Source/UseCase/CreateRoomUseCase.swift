
import Foundation
import UIKit.UIColor

public final class CreateRoomCase {
    private let userRepository: UsersRepository

    public init(userRepository: UsersRepository) {
        self.userRepository = userRepository
    }

    public func getMe() -> User? {
        guard let userId = userRepository.userId else {
            return nil
        }
        let myColor: UIColor = ColorList(index: 0).uiColor
        return .init(index: 0, name: userId, color: myColor)

    }
}
