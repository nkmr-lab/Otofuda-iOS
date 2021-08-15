import Foundation

public struct AppleMusicTopRssResponse: Codable {
    let feed: Feed

    struct Feed: Codable {
        let results: [TopMusic]
    }

    struct TopMusic: Codable {
        let artistName: String
        let name: String
    }
}
