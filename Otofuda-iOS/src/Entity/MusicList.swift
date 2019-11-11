
import Foundation

struct MusicList: Codable {
    var result: String
    var songs: [Song]
}

struct Song: Codable {
    var id: Int
    var title: String
    var artist: String
    var previewURL: String
    var genere: String
    var release_date: String
}
