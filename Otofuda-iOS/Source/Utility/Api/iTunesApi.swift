import Alamofire
import Foundation
import PromiseKit

// TODO: ApiClientを使ってあげる
final class iTunesApi {
    static let shared = iTunesApi()
    private let baseUrl = "http://itunes.apple.com/search"

    enum ApiError: Error {
        case mapFailed
        case loadFileFailed
        case encodeFailed
        case urlError
        case responseError
    }

    func request(keyword: String,
                 attribute: String,
                 country: String = "jp",
                 lang: String = "ja_jp",
                 media: String = "music",
                 entity: String = "song") -> Promise<iTunesApiResponse>
    {
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return Promise { seal in seal.reject(ApiError.encodeFailed) }
        }

        let params: [String: Any] = [
            "term": encodedKeyword,
            "country": country,
            "lang": lang,
            "media": media,
            "entity": entity,
            "attribute": attribute,
            "limit": 30,
        ]

        let optionalUrl = URL(string: baseUrl)
        guard let url = optionalUrl else {
            return Promise { seal in seal.reject(ApiError.urlError) }
        }

        let optionalComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard var components = optionalComponents else {
            return Promise { seal in seal.reject(ApiError.urlError) }
        }

        let queryItems = params.map { key, value -> URLQueryItem in
            URLQueryItem(name: key, value: String(describing: value))
        }
        components.queryItems = queryItems

        return Promise { seal in
            AF.request(components).response { response in
                switch response.result {
                case let .success(data):
                    guard let data = data else {
                        return seal.reject(ApiError.responseError)
                    }
                    guard let results = try? JSONDecoder().decode(iTunesApiResponse.self, from: data) else {
                        return seal.reject(ApiError.mapFailed)
                    }
                    seal.fulfill(results)

                case .failure:
                    seal.reject(ApiError.loadFileFailed)
                }
            }
        }
    }
}

struct iTunesApiResponse: Codable {
    let topRankMusics: [TopRankMusic]?

    enum CodingKeys: String, CodingKey {
        case topRankMusics = "results"
    }
}

struct TopRankMusic: Codable {
    let album: String?
    let title: String?
    let artist: String?
    let thumbnail: String?
    let previewURL: String?
}
