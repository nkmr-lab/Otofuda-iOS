
import Foundation

public struct RoomEntity: Codable, Identifiable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let memberRefs: [String]
    public let gameRefs: [String]
    public let owner: String
}
