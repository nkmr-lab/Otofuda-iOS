
import UIKit

final class CreateRoomCoordinator: Coordinator {
    private let navigator: UINavigationController
    private weak var viewController: CreateRoomVC?
    private let environment: Environment

    init(navigator: UINavigationController, environment: Environment) {
        self.navigator = navigator
        self.environment = environment
        let viewController = CreateRoomVC.loadFromStoryboard(with: .init(), environment: environment)
        self.viewController = viewController
    }

    func start() {
        guard let viewController = viewController else { return }
        viewController.output(output)
        navigator.pushViewController(viewController, animated: true)
    }

    private func output(_ output: CreateRoomVC.Output) {
        switch output {
        case .create:
            print("あああ")
//            let nextCoordinator = CreateRoomCoordinator(navigator: navigation, environment: environment)
//            nextCoordinator.start()
        }
    }
}
