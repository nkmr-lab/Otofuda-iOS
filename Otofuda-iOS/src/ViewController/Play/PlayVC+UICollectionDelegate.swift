import UIKit

extension PlayVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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
        
        let cell = collectionView.dequeueReusableCell(with: FudaCollectionCell.self,
                                                      for: indexPath)
        
        let tappedMusic = arrangeMusics[indexPath.row]

        let me = User(name: appDelegate.uuid, musics: [], color: .red)
        
        firebaseManager.observeSingle(path: room.url() + "tapped", completion: { snapshot in
            if var tappedDict = snapshot.value as? [Dictionary<String, Any>] {
                let dict: Dictionary<String, Any> = ["user": me.dict(), "music": tappedMusic.name]
                tappedDict.append(dict)
                self.firebaseManager.post(path: self.room.url() + "tapped", value: tappedDict)
            } else {
                var tappedDict: [Dictionary<String, Any>] = []
                let dict: Dictionary<String, Any> = ["user": me.dict(), "music": tappedMusic.name]
                tappedDict.append(dict)
                self.firebaseManager.post(path: self.room.url() + "tapped", value: tappedDict)
            }
            
            // 正解
            if tappedMusic.name == playingMusic.name {
                self.firebaseManager.observeSingle(path: self.room.url() + "answearUser", completion: { snapshot2 in
                    if let answearUser = snapshot2.value as? Dictionary<String, Any> {
                        // なにもしない
                        return
                    }
                    else {
                        self.room.status = .next
                        self.firebaseManager.post(path: self.room.url() + "status", value: self.room.status.rawValue)
                        tappedMusic.isAnimating = true
                        tappedMusic.isTapped = true
                        cell.soundTap()
                        cell.animate()
                        collectionView.reloadItems(at: [indexPath])
                        self.firebaseManager.post(path: self.room.url() + "answearUser", value: me.dict())
                    }
                })
            }
            // 不正解
            else {
                self.speech.speak(self.utterance)
            }
            
            self.isTapped = true
            self.isPlaying = false
        })

        // 終了判定
        if currentIndex == Config.fudaMaxCount - 1 {
            finishGame()
        }

    }
}
