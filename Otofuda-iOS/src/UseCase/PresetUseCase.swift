
import RxSwift

protocol PresetUseCaseProtocol {
//    func fetch() -> Single<PresetResponse>
    func add()
//    func load()
    func remove()
}

final class PresetUseCase: PresetUseCaseProtocol {

    private let api = ApiClient()

//    func fetch() -> Single<PresetResponse> {
//        return api.get(path: Config.PRESET_LIST_API_URL, request: nil)
//    }

//    func load() -> Single<Preset> {
//        return
//    }

    func add() {
    }

    func remove() {
    }
}
