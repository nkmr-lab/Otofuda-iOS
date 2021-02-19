import UIKit
import Firebase

extension PlayVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let nowTime = NSDate().timeIntervalSince1970
//       １
//        firebaseManager.post(path: "rooms/iphone", value: nowTime)

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

        self.isTapped = true
        self.isPlaying = false
        
        let cell = collectionView.dequeueReusableCell(with: FudaCollectionCell.self,
                                                      for: indexPath)

        let tappedMusic = playMusics[cardLocations[indexPath.row]]

        // 正解
        if tappedMusic.name == playingMusic.name {
            self.room.status = .next
            self.firebaseManager.post(path: self.room.url() + "status", value: self.room.status.rawValue)
            self.tapSoundPlayer?.play()

            self.firebaseManager.post(path: self.room.url() + "answearUser/\(self.me.index)", value: ["time": Firebase.ServerValue.timestamp(), "userIndex": self.me.index])
        }
        // 不正解
        else {
            self.speech.speak(self.utterance)
            self.displayErrorV()
            self.view.makeToast(playMusics[currentIndex-1].name + " でした")
        }

        let dict: Dictionary<String, Any> = ["user": self.me.dict(), "music": tappedMusic.name]
        self.firebaseManager.post(path: self.room.url() + "tapped/\(self.me.index)", value: dict)
        

    }
}
