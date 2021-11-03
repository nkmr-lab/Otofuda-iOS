import Combine
import OtofudaResource
import UIKit

final class TopVC: UIViewController, StoryboardLoadable {
    typealias ViewModel = TopVM

    // MARK: - IBOutlet

    @IBOutlet private var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.image = Asset.Images.topBackground.image
        }
    }

    @IBOutlet private var titleLogoView: UIImageView! {
        didSet {
            titleLogoView.image = Asset.Images.title.image
        }
    }

    @IBOutlet private var createButton: UIButton! {
        didSet {
            createButton.layer.cornerRadius = 8
            createButton.layer.shadowOffset = .init(width: 3, height: 3)
            createButton.layer.shadowColor = UIColor.black.cgColor
            createButton.layer.shadowOpacity = 0.5
        }
    }

    @IBOutlet private var searchButton: UIButton! {
        didSet {
            searchButton.layer.cornerRadius = 8
            searchButton.layer.borderWidth = 4
            searchButton.layer.shadowOffset = .init(width: 3, height: 3)
            searchButton.layer.shadowColor = UIColor.black.cgColor
            searchButton.layer.shadowOpacity = 0.5
            searchButton.layer.borderColor = Asset.Colors.subColorRed.color.cgColor
            searchButton.tapPublisher.sink { [weak self] _ in
                self?.buttonDidTapped.send(.search)
            }
            .store(in: &cancellables)
        }
    }

    // MARK: - Publishers

    let didLoad = PassthroughSubject<Void, Never>()
    let buttonDidTapped = PassthroughSubject<ViewModel.Button, Never>()

    // MARK: - Properties

    let environment: Environment
    private(set) var viewModel: TopVM
    private(set) var handler: ((Output) -> Void)?
    private var cancellables: [AnyCancellable] = []

    init?(coder: NSCoder, input _: Input, environment: Environment = .shared) {
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
        didLoad.send()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension TopVC: Bindable {
    func bind(to viewModel: TopVM) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        let input = ViewModel.Input(
            didLoad: didLoad.eraseToAnyPublisher(),
            buttonDidTapped: buttonDidTapped.eraseToAnyPublisher()
        )

        bindOutput(viewModel.transform(input: input))

        createButton.tapPublisher
            .sink { [weak self] _ in
                self?.buttonDidTapped.send(.create)
            }
            .store(in: &cancellables)

        searchButton.tapPublisher
            .sink { [weak self] _ in
                self?.buttonDidTapped.send(.search)
            }
            .store(in: &cancellables)
    }

    func bindOutput(_ output: TopVM.Output) {
        output.transition
            .sink { [weak self] transition in
                self?.handler?(transition)
            }
            .store(in: &cancellables)
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
