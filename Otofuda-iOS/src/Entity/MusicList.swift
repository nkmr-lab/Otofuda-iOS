
import Foundation

struct MusicList: Codable {
    var result: String
    var musics: [Song]

    struct Song: Codable {
        var id: Int
        var title: String
        var artist: String
        var previewURL: String
        var storeURL: String
        var artworkURL: String
        var genere: String
        var releaseDate: String

        private enum CodingKeys: String, CodingKey {
            case id
            case title
            case artist
            case previewURL = "preview_url"
            case storeURL = "store_url"
            case artworkURL = "artwork_url"
            case genere = "genere"
            case releaseDate = "release_date"
        }
    }

    


}

