
import UIKit

final class ___VARIABLE_sceneName___Coordinator {
    typealias ViewController = ___VARIABLE_sceneName___VC

    private weak var navigator: UINavigationController?
    private weak var viewController: ViewController?
    private let environment: ViewController.Environment

    init(navigator: UINavigationController, input _: ViewController.Input, environment: ViewController.Environment = .shared) {
        self.navigator = navigator
        self.environment = environment
        viewController = .loadFromStoryboard(with: .init(), environment: environment)
        viewController?.output(output)
    }

    func start() {
        guard let viewController = viewController else { return }
        navigator?.pushViewController(viewController, animated: true)
    }

    private func output(_ output: ViewController.Output) {
        switch output {
        case .someTapped:
            // TODO: 処理を書く
            break
        }
    }
}
