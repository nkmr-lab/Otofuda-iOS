

import SwiftyJSON

struct PresetResponse: ResponseEntity {
    var json: JSON
    var presets: [Preset]

    init(_ json: JSON) {
        self.json = json

        let jsonData = json["data"].arrayValue

        self.presets = jsonData.compactMap({ data in
            let id    = data["id"].intValue
            let title = data["title"].stringValue
            let music_list = data["music_list"].stringValue
            let thumb_url = data["thumb_url"].stringValue

            return Preset(id: id, title: title, music_list: music_list, thumb_url: thumb_url)
        })
    }
}
