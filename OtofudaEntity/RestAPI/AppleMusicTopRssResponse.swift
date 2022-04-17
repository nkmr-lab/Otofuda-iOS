
import Foundation

public struct AppleMusicTopRssResponse: Codable {
    public let feed: Feed

    public struct Feed: Codable {
        public let results: [TopMusic]
    }

    public struct TopMusic: Codable {
        let artistName: String
        let name: String
    }
}
