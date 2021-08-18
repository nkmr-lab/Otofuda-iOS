import Combine
import UIKit

final class TopVC: UIViewController, StoryboardLoadable {
    
    // MARK: - Properties
    let environment: Environment
    private(set) var viewModel: TopVM
    private(set) var handler: ((Output) -> Void)?
    private var cancellables: [AnyCancellable] = []

    init?(coder: NSCoder, input _: Input, environment: Environment) {
        self.environment = environment
        viewModel = .init(environment: environment)
        super.init(coder: coder)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction private func tappedSinglePlayButton(_: Any) {
        handler?(.singlePlayButtonTapped)
    }

    @IBAction private func tappedMultiPlayButton(_: Any) {
        handler?(.multiPlayButtonTapped)
    }
}

extension TopVC: Bindable {
    func bind(to viewModel: TopVM) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        let input = TopVM.Input()
        bindOutput(viewModel.transform(input: input))
    }

    func bindOutput(_: TopVM.Output) {

    }
}

extension TopVC: Injectable {
    struct Input {}

    func input(_: Input) {}
}

extension TopVC: Interactable {
    enum Output {
        case singlePlayButtonTapped
        case multiPlayButtonTapped
    }

    func output(_ handler: ((Output) -> Void)?) {
        self.handler = handler
    }
}
