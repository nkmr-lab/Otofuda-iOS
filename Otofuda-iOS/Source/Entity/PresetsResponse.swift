import Foundation

struct PresetsResponse: Codable {
    let result: String
    let list: [PresetList]
}
