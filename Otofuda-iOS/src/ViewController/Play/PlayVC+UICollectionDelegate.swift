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

        let tappedMusic = playMusics[cardLocations[indexPath.row]]

        
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
            
            // 正解
            if tappedMusic.name == playingMusic.name {
                self.firebaseManager.observeSingle(path: self.room.url() + "answearUser", completion: { snapshot2 in
                    if let answearUser = snapshot2.value as? Dictionary<Int, Double> {
                        // もう正解者がいた場合はなにもしない
                        return
                    }
                    else {
                        self.room.status = .next
                        self.firebaseManager.post(path: self.room.url() + "status", value: self.room.status.rawValue)
//                        tappedMusic.cardOwner = self.me.index
//                        tappedMusic.isAnimating = true
//                        tappedMusic.isTapped = true
                        self.tapSoundPlayer?.play()
//                        cell.animate()
//                        collectionView.reloadItems(at: [indexPath])

                        let nowTime = NSDate().timeIntervalSince1970
                        // TODO: 時間情報を書き込み
                        self.firebaseManager.post(path: self.room.url() + "answearUser/\(self.me.index)", value: ["time": nowTime, "userIndex": self.me.index])
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
        if currentIndex == CARD_MAX_COUNT - 1 {
            finishGame()
        }

    }
}
