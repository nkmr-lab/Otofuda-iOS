
import UIKit

final class AppCoordinator: Coordinator {
    let window: UIWindow
    let rootViewController: UINavigationController
    private let topCoordinator: TopCoordinator
    let environment: Environment

    init(window: UIWindow, environment: Environment = .shared) {
        self.window = window
        rootViewController = UINavigationController()
        topCoordinator = TopCoordinator(navigation: rootViewController, environment: environment)
        self.window.rootViewController = rootViewController
        self.environment = environment
    }

    func start() {
        window.rootViewController = rootViewController
        topCoordinator.start()
        window.makeKeyAndVisible()
    }
}
