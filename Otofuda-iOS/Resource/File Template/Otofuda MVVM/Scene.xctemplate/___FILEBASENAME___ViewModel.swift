
import Combine
import OtofudaEntity
import OtofudaUseCase

final class ___VARIABLE_sceneName___VM: ViewModel {
    typealias ViewController = ___VARIABLE_sceneName___VC
    typealias Transition = ViewController.Output

//    private let useCase: ___VARIABLE_sceneName___UseCase
    private let environment: Environment
    private let transition = PassthroughSubject<Transition, Never>()
    private var cancellables: [AnyCancellable] = []

    init(environment: PocketEnvironment = .shared) {
        self.environment = environment
//         self.useCase = .init(itineraryRepository: environment.itineraryRepository)
    }

    func transform(input: Input) -> Output {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        return .init(
            transition: transition.eraseToAnyPublisher()
        )
    }
}

extension ___VARIABLE_sceneName___VM {
    struct Input {
        let didLoad: AnyPublisher<Void, Never>
    }

    struct Output {
        let transition: AnyPublisher<Transition, Never>
    }
}
