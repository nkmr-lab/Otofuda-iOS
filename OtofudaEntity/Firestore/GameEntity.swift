
import Foundation

public struct GameEntity: Codable, Identifiable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let playMode: PlayModeEntity
    public let scoreMode: ScoreModeEntity
    public let musicMode: MusicModeEntity
    public let cardCountMode: CardCountMode
    public let presetRef: String
    public let gameRefs: [String]
    public let owner: String
    public let playingIndex: Int

    public enum ScoreModeEntity: String, CaseIterable, Codable {
        case normal
        case bingo

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = type(of: self).init(rawValue: rawValue) ?? .normal
        }
    }

    public enum PlayModeEntity: String, CaseIterable, Codable {
        case intro
        case random

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = type(of: self).init(rawValue: rawValue) ?? .random
        }
    }

    public enum MusicModeEntity: String, CaseIterable, Codable {
        case preset
        case device

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = type(of: self).init(rawValue: rawValue) ?? .preset
        }
    }

    public enum CardCountMode: String, CaseIterable, Codable {
        case twoAndTow = "2x2"
        case threeAndThree = "3x3"
        case fourAndFour = "4x4"

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = type(of: self).init(rawValue: rawValue) ?? .fourAndFour
        }
    }
}
