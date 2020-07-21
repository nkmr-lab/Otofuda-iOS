import UIKit

extension PlayVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let nowTime = NSDate().timeIntervalSince1970

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

            self.firebaseManager.post(path: self.room.url() + "answearUser/\(self.me.index)", value: ["time": nowTime, "userIndex": self.me.index])
        }
        // 不正解
        else {
            self.speech.speak(self.utterance)
            self.displayErrorV()
        }

        firebaseManager.observeSingle(path: room.url() + "tapped", completion: { snapshot in
            if var tappedDict = snapshot.value as? [Dictionary<String, Any>] {
                let dict: Dictionary<String, Any> = ["user": self.me.dict(), "music": tappedMusic.name]
                tappedDict.append(dict)
                self.firebaseManager.post(path: self.room.url() + "tapped", value: tappedDict)
            } else {
                var tappedDict: [Dictionary<String, Any>] = []
                let dict: Dictionary<String, Any> = ["user": self.me.dict(), "music": tappedMusic.name]
                tappedDict.append(dict)
                self.firebaseManager.post(path: self.room.url() + "tapped", value: tappedDict)
            }
        })

    }
}
