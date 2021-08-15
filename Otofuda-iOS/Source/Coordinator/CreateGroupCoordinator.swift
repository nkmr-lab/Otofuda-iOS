
import UIKit

final class CreateGroupCoordinator: Coordinator {
    private let navigator: UINavigationController
    private weak var viewController: CreateGroupVC?
    private let environment: Environment

    init(navigator: UINavigationController, environment: Environment) {
        self.navigator = navigator
        self.environment = environment
        let viewController = CreateGroupVC.loadFromStoryboard(with: .init(), environment: environment)
        self.viewController = viewController
    }

    func start() {
        guard let viewController = viewController else { return }
        navigator.pushViewController(viewController, animated: true)
    }
}
