
import Combine
import MediaPlayer
import OtofudaEntity

final class TopVM: ViewModel {
    typealias ViewController = TopVC
    typealias Transition = TopVC.Output
    private var userMusics: [MusicModel] = []
    private let useCase: AppUseCase

    private var cancellables: [AnyCancellable] = []

    init(environment: Environment) {
        useCase = AppUseCase(userRepository: environment.userRepository)
    }

    func transform(input: Input) -> Output {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        let transition = PassthroughSubject<Transition, Never>()

        input.buttonDidTapped
            .sink { button in
                switch button {
                case .create:
                    print("ああああ")
                    transition.send(.singlePlayButtonTapped)
                case .search:
                    transition.send(.multiPlayButtonTapped)
                }
            }
            .store(in: &cancellables)

        requestMediaLibraryAuth(completion: { [weak self] in
            guard let self = self else { return }
            self.userMusics = self.loadMusics()
        })

        let users = input.didLoad
            .setFailureType(to: Error.self)
            .flatMap { [weak self] _ -> AnyPublisher<[UserEntity], Error> in
                guard let self = self else { return Fail(error: CouldNotFoundSelf()).eraseToAnyPublisher() }
                return self.useCase.fetchAllUsers()
            }
            .eraseToAnyPublisher()

        users.sink { completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                EmojiLogger.info("失敗しました")
                print(error)
            }
        } receiveValue: { users in
            EmojiLogger.info("取れました！")
            print(users)
        }
        .store(in: &cancellables)

        return .init(
            transition: transition.eraseToAnyPublisher()
        )
    }
}

// MARK: - Private Functions

extension TopVM {
    private func requestMediaLibraryAuth(completion: (() -> Void)? = nil) {
        MPMediaLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                completion?()
            default:
                EmojiLogger.error("Media Library Auth Error")
            }
        }
    }

    private func loadMusics() -> [MusicModel] {
        var musics: [MusicModel] = []
        guard let albums = MPMediaQuery.albums().collections else { return [] }
        for album in albums {
            for song in album.items {
                guard let songTitle = song.title, let songArtist = song.artist else { continue }
                musics.append(MusicModel(name: songTitle, artist: songArtist, item: song))
            }
        }
        return musics
    }
}

extension TopVM {
    public enum Button {
        case create
        case search
    }

    struct Input {
        let didLoad: AnyPublisher<Void, Never>
        let buttonDidTapped: AnyPublisher<Button, Never>
    }

    struct Output {
        let transition: AnyPublisher<Transition, Never>
    }

    struct CouldNotFoundSelf: Error {}
}
