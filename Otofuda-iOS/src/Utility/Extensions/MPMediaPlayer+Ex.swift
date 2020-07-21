import Foundation
import MediaPlayer

extension MPMusicPlayerController {
    func setMusic(item: MPMediaItem) {
        let collection = MPMediaItemCollection(items: [item])
        self.setQueue(with: collection)
    }
}
