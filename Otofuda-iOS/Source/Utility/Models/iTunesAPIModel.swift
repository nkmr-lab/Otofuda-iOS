import Alamofire
import Foundation
import ObjectMapper
import PromiseKit

final class iTunesAPIModel {
    static let shared = iTunesAPIModel()

    func request(keyword: String, attribute: String) -> Promise<String> {
        let encKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let url = "http://itunes.apple.com/search?term=\(encKeyword)&country=jp&lang=ja_jp&media=music&entity=song&attribute=\(attribute)&limit=30"

        return Promise { seal in
            AF.request(url).responseString { response in
                switch response.result {
                case let .success(data):
                    seal.fulfill(data)

                case .failure:
                    seal.reject(InternalError.loadFileFailed)
                }
            }
        }
    }

    func mapping(jsonStr: String) -> Promise<Results> {
        Promise { seal in
            print(jsonStr)
            guard let results = Mapper<Results>().map(JSONString: jsonStr) else {
                return seal.reject(InternalError.mapFailed)
            }
            seal.fulfill(results)
        }
    }
}

enum InternalError: Error {
    case mapFailed
    case loadFileFailed
}

struct Results: Mappable {
    var results: [Result]?

    init?(map _: Map) {}

    mutating func mapping(map: Map) {
        results <- map["results"]
    }
}

struct Result: Mappable {
    var album = ""
    var title = ""
    var artist = ""
    var thumbnail = ""
    var previewURL = ""

    init?(map _: Map) {}

    mutating func mapping(map: Map) {
        album <- map["collectionName"]
        title <- map["trackName"]
        artist <- map["artistName"]
        thumbnail <- map["artworkUrl100"]
        previewURL <- map["previewUrl"]
    }
}
