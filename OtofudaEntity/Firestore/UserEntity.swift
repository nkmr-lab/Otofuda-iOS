
import Foundation

public struct UserEntity: Codable, Identifiable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let lastLoginAt: Date
    public let iconUrl: String?
    public let level: Int
}
