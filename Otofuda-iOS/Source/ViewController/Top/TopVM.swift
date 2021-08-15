
import MediaPlayer

final class TopVM: ViewModel {
    private var firebaseManager = FirebaseManager()
    private var userMusics: [Music] = []
    private let useCase: AppUseCase

    init(environment: Environment) {
        useCase = AppUseCase(userRepository: environment.userRepository)
    }

    func transform(input _: Input) -> Output {
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

    public func createGroup() -> Room? {
        var room = Room(name: UUID().uuidString)
        let nowDate = Date.getCurrentDate()

        guard let userId = useCase.userId else {
            EmojiLogger.error("userId could not found!!")
            return nil
        }
        let me = User(index: 0, name: userId, color: ColorList(index: 0).uiColor)
        room.addMember(user: me)

        firebaseManager.post(path: room.url(), value: room.dict())
        firebaseManager.post(path: room.url() + "date", value: nowDate)

        return room
    }
}

extension TopVM {
    struct Input {}

    struct Output {}
}
