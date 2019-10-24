import UIKit

extension ResultVC {

    func initializePlayer() {
        self.player = .applicationMusicPlayer
        self.player.repeatMode = .none
    }

    func playMusic(music: Music) {
        player.setMusic(item: music.item!)
        player.play()
    }
}
