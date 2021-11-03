
import Foundation

public struct PresetApiResponse: Codable {
    public let result: String
    public let list: [PresetListResponse]
}

public struct PresetListResponse: Codable, Identifiable {
    public let id: Int
    public let typeName: String
    public let presets: [PresetResponse]

    private enum CodingKeys: String, CodingKey {
        case id
        case typeName = "type_name"
        case presets
    }
}

public struct PresetResponse: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var count: Int
}
