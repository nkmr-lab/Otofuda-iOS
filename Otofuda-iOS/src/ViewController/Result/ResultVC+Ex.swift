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

    func observeRoomStatus() {
        firebaseManager.observe(path: room.url() + "status", completion: { snapshot in
            if let status = snapshot.value as? String {
                if status == RoomStatus.menu.rawValue {
                    self.firebaseManager.deleteObserve(path: self.room.url() + "status")
                    self.navigationController?.popToViewController(
                        self.navigationController!.viewControllers[2], animated: true
                    )
                }
            }
        })
    }
}
