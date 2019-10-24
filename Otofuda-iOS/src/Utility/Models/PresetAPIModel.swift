
import PromiseKit
import Alamofire

final class PresetAPIModel {

    static let shared = PresetAPIModel()

    func request() -> Promise<String> {

        let url = Config.list_api_url

        return Promise { seal in
            Alamofire.request(url).responseString { response in
                switch response.result {
                case .success(let data):
                    seal.fulfill(data)
                case .failure:
                    seal.reject(InternalError.loadFileFailed)
                }
            }
        }
    }

    func mapping(jsonStr: String) -> Promise<PresetResponse> {
        return Promise { seal in
            let data = jsonStr.data(using: .utf8)!
            guard let results = try? JSONDecoder().decode(PresetResponse.self, from: data) else {
                return seal.reject(InternalError.mapFailed)
            }
            seal.fulfill(results)
        }
    }
}

struct PresetResponse: Codable {
    var result: String
    var list: [Preset]
}

struct Preset: Codable {
    var id: String
    var title: String
    var music_list: String
}
