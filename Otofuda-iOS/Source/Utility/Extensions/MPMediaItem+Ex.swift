import UIKit
import MediaPlayer

extension MPMediaItem {
    func music() -> Music {
        guard let title = self.title,
            let artist = self.artist else {
                let music = Music(name: "タイトルなし", artist: "アーティスト名なし", item: self)
            return music
        }
        let music = Music(name: title, artist: artist, item: self)
        return music
    }

    // 自分の持っている楽曲の中から，曲名，アーティスト名をもとに曲を取得する関数
    static func getMediaItem(title: String, artist: String) -> MPMediaItem? {
        var rtnSong: MPMediaItem? = nil
        let query = MPMediaQuery.songs()

        guard let songs = query.items else {
            return nil
        }

        for song in songs {
            if song.title == title && song.artist == artist {
                rtnSong = song
            }
        }

        return rtnSong
    }
}
