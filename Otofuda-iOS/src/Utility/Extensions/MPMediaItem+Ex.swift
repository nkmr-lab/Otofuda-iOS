import UIKit
import MediaPlayer

extension MPMediaItem {
    func music() -> Music {
        guard let title = self.title else {
            let music = Music(name: "タイトルなし", item: self)
            return music
        }
        let music = Music(name: title, item: self)
        return music
    }
}
