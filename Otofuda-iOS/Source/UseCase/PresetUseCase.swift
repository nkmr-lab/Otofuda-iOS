import RxSwift

final class PresetUseCase {
    private let api = ApiClient()

    func fetch() -> Single<PresetResponse> {
        api.get(path: PRESET_LIST_API_URL, request: nil)
    }

    //
    //    func load() -> Single<Preset> {
    //        return
    //    }

    func add() {}

    func remove() {}
}
