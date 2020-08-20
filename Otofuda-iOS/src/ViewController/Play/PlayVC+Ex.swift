import UIKit
import MediaPlayer
import Firebase

extension PlayVC {
    
    func initializeUI(){
        startBtn.isHidden = !isHost
    }

    func initializeVoice() {
        self.utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        self.utterance.volume = 1.0
        self.utterance.rate = 0.55
    }

    func initializePlayer() {
        self.player = .applicationQueuePlayer
        self.player.repeatMode = .one
    }

    func initializeTapSoundPlayer() {
        do {
            tapSoundPlayer = try AVAudioPlayer(
                contentsOf: Bundle.main.url(forResource: "tap_fuda",
                                            withExtension: "caf")!)
            tapSoundPlayer!.prepareToPlay()
        } catch {
            print(error)
        }
    }

    func playMusic() {

        switch usingMusicMode {
        case .preset:
            let music = playMusics[currentIndex]
            avPlayer = AVPlayer(url: URL(string: music.previewURL!)!)
            print("=============")
            avPlayer.volume = 1.0
            avPlayer.play()
            print("=============")
        case .device:
            guard let music = playMusics[currentIndex].item else { return }

            player.setMusic(item: music)
            player.play()

            switch playbackMode {
            case .intro:
                player.currentPlaybackTime = 0
            case .random:
                let randomDuration = Int.random(in: 0..<Int(music.playbackDuration) - 10)
                player.currentPlaybackTime = TimeInterval(randomDuration)
            }

            player.pause() // iOS13のバグ？でplay1回だけじゃ再生できない時があるがためのコード
            player.play()
        }
    }

    func finishGame() {
        player.stop()
        player = nil
        
        firebaseManager.deleteAllValuesAndObserve(path: room.url() + "tapped")
        firebaseManager.deleteAllValuesAndObserve(path: room.url() + "answearUser")

        let storyboard = UIStoryboard(name: "Result", bundle: nil)
        let nextVC = storyboard.instantiateInitialViewController() as! ResultVC
        nextVC.room = room
        nextVC.playMusics = playMusics
        nextVC.me = me
        nextVC.isHost = isHost
        nextVC.scoreMode = scoreMode
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func fireTimer(){
        countdownTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.countdown),
            userInfo: nil,
            repeats: true
        )
    }
    
    func displayCountdownV(){
        countdownLabel.text = "3"
        countdownV.frame = countdownV.frame
        countdownV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(countdownV)
        countdownV.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        countdownV.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        countdownV.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        countdownV.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
    }

    func displayErrorV(){
        tapErrorV.frame = tapErrorV.frame
        tapErrorV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tapErrorV)
        self.view.insertSubview(tapErrorV, belowSubview: startBtn)
        tapErrorV.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        tapErrorV.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        tapErrorV.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4).isActive = true
        tapErrorV.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.05).isActive = true
    }
    
    @objc func countdown(){
        countdownLabel.text = String(3 - count)
        if count == 3 {

            player.stop()
            
            self.isPlaying = true
            self.removeCountdonwV()
            countdownTimer.invalidate()
            count = 0

            let playMusic = playMusics[currentIndex]
            guard let musicOwner = playMusic.musicOwner else { return }
            
            if musicOwner == me.index {
                self.playMusic()
            }

            if isHost {
                firebaseManager.post(path: room.url() + "currentIndex", value: currentIndex)
                observeTapped()
            }

            tapErrorV.removeFromSuperview()
//            observeAnswearUser()
            playingMusic = playMusics[currentIndex]
            
            navigationItem.title = String(currentIndex + 1) + "曲目"
            currentIndex += 1
        }
        count += 1
    }
    
    func removeCountdonwV(){
        countdownV.removeFromSuperview()
    }
    
    func observeRoomStatus(){
        firebaseManager.observe(path: room.url() + "status", completion: { snapshot in
            guard let status = snapshot.value as? String else {
                return
            }
            
            if status == RoomStatus.play.rawValue {
                self.isTapped = false
                self.displayCountdownV()
                self.fireTimer()
            }
        })
    }
    
    func observeTapped(){
        // ここにタップがメンバー数に到達したら，ステータスにtappedにする処理を書く
        firebaseManager.observe(path: room.url() + "tapped", completion: { snapshot in
            guard let tappedDict = snapshot.value as? [Dictionary<String, Any>] else {
                return
            }
            
            if tappedDict.count == self.room.member.count {
                self.room.status = .next
                self.firebaseManager.post(path: self.room.url() + "status", value: self.room.status.rawValue)
                self.startBtn.isHidden = false
                self.isPlaying = false
                self.isTapped = false

                // TODO: observeしてるのがホストだけなので，終了処理がホストだけしか呼ばれてない
                // 終了判定
                if self.currentIndex == CARD_MAX_COUNT  {
                    self.finishGame()
                }
            }
        })
    }
    
    func observeAnswearUser(){
        firebaseManager.observe(path: room.url() + "answearUser", completion: { snapshot in

            if snapshot.children.allObjects.count == 0 {
                return
            }
            
            var fastestUser: Int = -1
            var fastestTime: Double = Double.greatestFiniteMagnitude

            for item in snapshot.children {
                let snapshot = item as! DataSnapshot
                let dict = snapshot.value as! [String: Any]

                let userIndex = dict["userIndex"] as! Int
                let time = dict["time"] as! Double

                if time < fastestTime {
                    fastestUser = userIndex
                    fastestTime = time
                }
            }

            // タップされた札の色をanswearUserにする
            let currentMusic = self.playMusics[self.currentIndex - 1]
            currentMusic.cardOwner = fastestUser
            currentMusic.isTapped = true
            currentMusic.isAnimating = true
            self.fudaCollectionV.reloadData()

            self.room.status = .next
            self.isPlaying = false
            self.isTapped = false
            if self.isHost { self.startBtn.isHidden = false }

            // 終了判定
            if self.currentIndex == CARD_MAX_COUNT  {
                self.finishGame()
            }
        })
    }
    

}
