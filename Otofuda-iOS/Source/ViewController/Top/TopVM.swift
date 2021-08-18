
import Combine
import MediaPlayer

final class TopVM: ViewModel {
    private var userMusics: [Music] = []
    private let useCase: AppUseCase
    private var cancellables: [AnyCancellable] = []

    init(environment: Environment) {
        useCase = AppUseCase(userRepository: environment.userRepository)
    }

    func transform(input _: Input) -> Output {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        requestMediaLibraryAuth(completion: { [weak self] in
            guard let self = self else { return }
            self.userMusics = self.loadMusics()
        })

        return .init()
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

    private func loadMusics() -> [Music] {
        var musics: [Music] = []
        guard let albums = MPMediaQuery.albums().collections else { return [] }
        for album in albums {
            for song in album.items {
                guard let songTitle = song.title, let songArtist = song.artist else { continue }
                musics.append(Music(name: songTitle, artist: songArtist, item: song))
            }
        }
        return musics
    }
}

extension TopVM {
    struct Input {}

    struct Output {}
}
