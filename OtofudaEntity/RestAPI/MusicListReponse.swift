
import Foundation

public struct MusicListResponse: Codable {
    public var result: String
    public var musics: [MusicResponse]
}

public struct MusicResponse: Codable, Identifiable {
    public var id: Int
    public var title: String
    public var artist: String
    public var previewURL: String
    public var storeURL: String
    public var artworkURL: String
    public var genere: String
    public var releaseDate: String

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case previewURL = "preview_url"
        case storeURL = "store_url"
        case artworkURL = "artwork_url"
        case genere
        case releaseDate = "release_date"
    }
}
