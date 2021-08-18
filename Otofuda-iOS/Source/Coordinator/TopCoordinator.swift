
import UIKit

final class TopCoordinator: Coordinator {
    private let navigation: UINavigationController
    private weak var viewController: TopVC?
    private let environment: Environment

    init(navigation: UINavigationController,
         environment: Environment)
    {
        self.navigation = navigation
        viewController = .loadFromStoryboard(with: .init(), environment: environment)
        self.environment = environment
    }

    func start() {
        guard let viewController = viewController else { return }
        viewController.output(output)
        navigation.pushViewController(viewController, animated: true)
    }

    private func output(_ output: TopVC.Output) {
        switch output {
        case .singlePlayButtonTapped:
            let nextCoordinator = CreateRoomCoordinator(navigator: navigation, environment: environment)
            nextCoordinator.start()
        case .multiPlayButtonTapped:
            break
        }
    }
}
