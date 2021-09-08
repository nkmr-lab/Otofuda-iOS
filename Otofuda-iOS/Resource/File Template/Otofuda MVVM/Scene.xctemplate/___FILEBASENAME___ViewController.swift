import Combine
import OtofudaExtension
import UIKit

final class ___VARIABLE_sceneName___VC: UIViewController, Instantiatable {

    typealias ViewModel = ___VARIABLE_sceneName___VM

    struct Input {
    }

    enum Output {
        case someTapped
    }

    // MARK: - IBOutlet Property

    // MARK: - UI Property

    // MARK: - Publisher Property
    private let didLoad = PassthroughSubject<Void, Never>()

    // MARK: - Other Property
    let input: Input
    let environment: Environment
    private let viewModel: ViewModel
    private var handler: ((Output) -> Void)?
    private var cancellables: [AnyCancellable] = []

    init?(coder: NSCoder, input: Input, environment: Environment = .shared) {
        self.input = input
        self.environment = environment
        self.viewModel = .init(environment: environment)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad(){
        super.viewDidLoad()
        bind(to: viewModel)
        didLoad.send()
    }

    private func bind(to viewModel: ViewModel) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        let output = viewModel.transform(
            input: .init(
                didLoad: didLoad.eraseToAnyPublisher()
            )
        )

        output.transition
            .sink { [weak self] transition in
                self?.handler?(transition)
            }
            .store(in: &cancellables)
    }

}

extension ___VARIABLE_sceneName___VC: Interactable {
    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
}
