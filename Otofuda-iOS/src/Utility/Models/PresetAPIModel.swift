
import PromiseKit
import Alamofire

final class PresetAPIModel {

    static let shared = PresetAPIModel()

    func request() -> Promise<String> {

        let url = PRESET_LIST_API_URL

        return Promise { seal in
            AF.request(url).responseString { response in
                switch response.result {
                case .success(let data):
                    print(data)
                    seal.fulfill(data)
                case .failure:
                    seal.reject(InternalError.loadFileFailed)
                }
            }
        }
    }

    // FIXME: これだとAPIごとに1Model作るごとになってしまい...面倒  
//    func get16() -> Promise<String> {
//        let url = Config.SELECT_MUSIC_API_URL
//
//        return Promise { seal in
//            Alamofire.request(url).responseString { response in
//                switch response.result {
//                case .success(let data):
//                    seal.fulfill(data)
//                case .failure:
//                    seal.reject(InternalError.loadFileFailed)
//       ////////////////////////////////////////////////

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
