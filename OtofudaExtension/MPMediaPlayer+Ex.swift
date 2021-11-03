import Foundation
import MediaPlayer

public extension MPMusicPlayerController {
    func setMusic(item: MPMediaItem) {
        let collection = MPMediaItemCollection(items: [item])
        setQueue(with: collection)
    }
}
