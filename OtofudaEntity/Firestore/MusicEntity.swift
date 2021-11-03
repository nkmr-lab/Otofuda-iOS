
import Foundation

public struct MusicEntity: Codable, Identifiable {
    public let id: String
    public let title: String
    public let artist: String
    public let index: Int
    public let position: Int
    public let previewUrl: String?
}
