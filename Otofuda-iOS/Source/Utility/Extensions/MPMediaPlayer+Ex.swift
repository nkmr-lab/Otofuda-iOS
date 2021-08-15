import Foundation
import MediaPlayer

extension MPMusicPlayerController {
    func setMusic(item: MPMediaItem) {
        let collection = MPMediaItemCollection(items: [item])
        setQueue(with: collection)
    }
}
