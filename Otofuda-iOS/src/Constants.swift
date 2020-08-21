//
//  Constants.swift
//  Otofuda-iOS
//
//  Created by 新納真次郎 on 2020/07/07.
//  Copyright © 2020 nkmr-lab. All rights reserved.
//

import Foundation
import UIKit

var CARD_CLM_COUNT = 4
var CARD_ROW_COUNT = 4
var CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
let CARD_LAYOUT_MARGIN: CGFloat = 5.0

let COLORS: [UIColor] = [.red, .blue, .green, .purple, .brown, .yellow, .orange]

// API関係
let BASE_API_URL = "https://uniotto.org/api/"
let PRESET_LIST_API_URL = "https://uniotto.org/api/get_all_otofuda_list.php?count=16"
let SELECT_MUSIC_API_URL = "https://uniotto.org/api/get_rand16_itunes.php"
let ITUNES_TOP_RSS_URL = "https://rss.itunes.apple.com/api/v1/jp/apple-music/top-songs/all/100/explicit.json"
