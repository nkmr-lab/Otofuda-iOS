
import Combine

final class CreateRoomVM: ViewModel {
    typealias ViewOutput = CreateRoomVC.Output
    private let useCase: AppUseCase
    private var cancellables: [AnyCancellable] = []

    let transition = PassthroughSubject<ViewOutput, Never>()

    init(environment: Environment) {
        self.useCase = AppUseCase(userRepository: environment.userRepository)
    }

    func transform(input: Input) -> Output {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        input.didTappedButton
            .sink { [weak self] _ in
                self?.transition.send(.create)
            }
            .store(in: &cancellables)

        return .init(transition: transition.eraseToAnyPublisher())
    }
}

// MARK: - Private Functions
extension CreateRoomVM {
}

extension CreateRoomVM {
    struct Input {
        let didTappedButton: AnyPublisher<Void, Never>
    }

    struct Output {
        let transition: AnyPublisher<ViewOutput, Never>
    }
}
