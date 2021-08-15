import Combine
import UIKit

final class TopVC: UIViewController, StoryboardLoadable {
    @IBOutlet private var singlePlayButton: UIButton!
    @IBOutlet private var multiPlayButton: UIButton!

    private let viewModel: TopVM
    let environment: Environment
    private var handler: ((Output) -> Void)?

    private var cancellables: [AnyCancellable] = []

    init?(coder: NSCoder, input _: Input, environment: Environment) {
        self.environment = environment
        viewModel = .init(environment: environment)
        super.init(coder: coder)
    }

    @available(*, unavailable)
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

    private func bind(to viewModel: TopVM) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        bindOutput(viewModel.transform(input: createInput()))
    }

    private func bindOutput(_: TopVM.Output) {}

    private func createInput() -> TopVM.Input {
        .init()
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
