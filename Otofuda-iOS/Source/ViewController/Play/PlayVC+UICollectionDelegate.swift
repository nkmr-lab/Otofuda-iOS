import Firebase
import UIKit

extension PlayVC: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // もうタップしてたら何もしない
        if isTapped {
            print("isTappped!!!!!!!")
            return
        }

        // まだ再生中じゃなければ何もしない
        if !isPlaying {
            print("isPlaying!!!!!!")
            return
        }

        guard let playingMusic = playingMusic else {
            print("isNotPlayingMusic!!!!!")
            return
        }

        isTapped = true
        isPlaying = false

        let tappedMusic = playMusics[cardLocations[indexPath.row]]

        // 正解
        if tappedMusic.name == playingMusic.name {
            room.status = .next
            firebaseManager.post(path: room.url() + "status", value: room.status.rawValue)
            tapSoundPlayer?.play()

            firebaseManager.post(path: room.url() + "answearUser/\(me.index)", value: ["time": Firebase.ServerValue.timestamp(), "userIndex": me.index])
        }
        // 不正解
        else {
            speech.speak(utterance)
            displayErrorV()
            view.makeToast(playMusics[currentIndex - 1].name + " でした")
        }

        let dict: [String: Any] = ["user": me.dict(), "music": tappedMusic.name]
        firebaseManager.post(path: room.url() + "tapped/\(me.index)", value: dict)
    }
}
