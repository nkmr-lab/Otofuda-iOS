import SwiftyJSON

struct PresetResponse: ResponseEntity {
    var json: JSON
    var presets: [Preset]

    init(_ json: JSON) {
        self.json = json

        let jsonData = json["data"].arrayValue

        presets = jsonData.compactMap { data in
            let id = data["id"].intValue
            let name = data["name"].stringValue
            let count = data["count"].intValue

            return Preset(id: id, name: name, count: count)
        }
    }
}
