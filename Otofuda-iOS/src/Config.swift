
import Foundation

class Config {
    static let fudaMaxCount = 16
    static let colors: [MyColor] = [.red, .blue, .green, .pink, .brown, .yellow, .orange]
    static let BASE_API_URL = "https://uniotto.org/api/"
    static let PRESET_LIST_API_URL = "https://uniotto.org/api/get_all_otofuda_list.php"
    static let SELECT_MUSIC_API_URL = "https://uniotto.org/api/get_rand16_itunes.php"
    static let ITUNES_TOP_RSS_URL = "https://rss.itunes.apple.com/api/v1/jp/apple-music/top-songs/all/100/explicit.json"
}
