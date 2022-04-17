import MediaPlayer
import UIKit

public extension MPMediaItem {
    // 自分の持っている楽曲の中から，曲名，アーティスト名をもとに曲を取得する関数
    static func getMediaItem(title: String, artist: String) -> MPMediaItem? {
        let query = MPMediaQuery.songs()
        guard let musics = query.items else { return nil }
        return musics.first(where: { $0.title == title && $0.artist == artist })
    }
}
