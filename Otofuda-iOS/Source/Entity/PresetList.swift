//
//  PresetType.swift
//  Otofuda-iOS
//
//  Created by 新納真次郎 on 2020/09/07.
//  Copyright © 2020 nkmr-lab. All rights reserved.
//

import Foundation

struct PresetList: Codable {
    var id: Int
    var typeName: String
    var presets: [Preset]

    private enum CodingKeys: String, CodingKey {
        case id
        case typeName = "type_name"
        case presets
    }
}
