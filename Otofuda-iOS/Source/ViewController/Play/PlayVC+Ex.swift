import Firebase
import MediaPlayer
import UIKit

extension PlayVC {
    func initializeUI() {
        startBtn.isHidden = !isHost
    }

    func initializeVoice() {
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.volume = 1.0
        utterance.rate = 0.55
    }

    func initializePlayer() {
        player = .applicationQueuePlayer
        player.repeatMode = .one
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
            avPlayer.volume = 1.0
            avPlayer.play()

        case .device:
            guard let music = playMusics[currentIndex].item else { return }

            player.setMusic(item: music)
            player.play()

            switch playbackMode {
            case .intro:
                player.currentPlaybackTime = 0

            case .random:
                let randomDuration = Int.random(in: 0 ..< Int(music.playbackDuration) - 10)
                player.currentPlaybackTime = TimeInterval(randomDuration)
            }

            player.pause() // iOS13のバグ？でplay1回だけじゃ再生できない時があるがためのコード
            player.play()
        }
    }

    func finishGame() {
        switch usingMusicMode {
        case .preset:
            avPlayer?.pause()
            avPlayer = nil

        case .device:
            player?.stop()
            player = nil
        }

        if isHost {
            FirebaseManager.shared.deleteAllValuesAndObserve(path: room.url() + "tapped")
            FirebaseManager.shared.deleteAllValuesAndObserve(path: room.url() + "answearUser")

            FirebaseManager.shared.deleteAllValue(path: room.url() + "cardLocations")
            FirebaseManager.shared.deleteAllValue(path: room.url() + "selectedPlayers")
            FirebaseManager.shared.deleteAllValue(path: room.url() + "playMusics")
            FirebaseManager.shared.deleteAllValue(path: room.url() + "currentIndex")
        } else {
            FirebaseManager.shared.deleteObserve(path: room.url() + "tapped")
            FirebaseManager.shared.deleteObserve(path: room.url() + "answearUser")
        }

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    func goResultVC() {
        let storyboard = UIStoryboard(name: "Result", bundle: nil)
        let nextVC = storyboard.instantiateInitialViewController() as! ResultVC
        nextVC.room = room
        nextVC.playMusics = playMusics
        nextVC.me = me
        nextVC.isHost = isHost
        nextVC.usingMusicMode = usingMusicMode
        nextVC.scoreMode = scoreMode
        nextVC.tapTimeArray = tapTimeArray
        navigationController?.pushViewController(nextVC, animated: true)
    }

    func fireTimer() {
        countdownTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(countdown),
            userInfo: nil,
            repeats: true
        )
    }

    func displayCountdownV() {
        countdownLabel.text = "3"
        countdownV.frame = countdownV.frame
        countdownV.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countdownV)
        countdownV.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        countdownV.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        countdownV.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        countdownV.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    }

    func displayErrorV() {
        tapErrorV.frame = tapErrorV.frame
        tapErrorV.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tapErrorV)
        view.insertSubview(tapErrorV, belowSubview: startBtn)
        tapErrorV.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tapErrorV.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        tapErrorV.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        tapErrorV.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true
    }

    @objc func countdown() {
        countdownLabel.text = String(3 - count)
        if count == 3 {
            player.stop()

            isPlaying = true
            removeCountdonwV()
            countdownTimer.invalidate()
            count = 0

            let playMusic = playMusics[currentIndex]
            guard let musicOwner = playMusic.musicOwner else { return }

            if musicOwner == me.index {
                self.playMusic()
            }

            didPlayDate = Date()

            if isHost {
                FirebaseManager.shared.post(path: room.url() + "currentIndex", value: currentIndex)
                //                observeTapped()
            }

            tapErrorV.removeFromSuperview()
            //            observeAnswearUser()
            playingMusic = playMusics[currentIndex]

            navigationItem.title = String(currentIndex + 1) + "曲目"
            currentIndex += 1
        }
        count += 1
    }

    func removeCountdonwV() {
        countdownV.removeFromSuperview()
    }

    func observeRoomStatus() {
        FirebaseManager.shared.observe(path: room.url() + "status", completion: { snapshot in
            guard let status = snapshot.value as? String else {
                return
            }

            if status == RoomStatus.play.rawValue {
                self.isTapped = false
                self.displayCountdownV()
                self.fireTimer()
            } else if status == RoomStatus.menu.rawValue {
                self.finishGame()
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

    func observeTapped() {
        // ここにタップがメンバー数に到達したら，ステータスにtappedにする処理を書く
        FirebaseManager.shared.observe(path: room.url() + "tapped", completion: { snapshot in
            if snapshot.children.allObjects.count != self.room.member.count {
                return
            }

            if self.isHost {
                self.room.status = .next
                FirebaseManager.shared.post(path: self.room.url() + "status", value: self.room.status.rawValue)
                self.startBtn.isHidden = false
                self.isTapped = false
            }

            // 終了判定
            if self.currentIndex == CARD_MAX_COUNT {
                self.finishGame()
                self.goResultVC()
            }
        })
    }

    func observeAnswearUser() {
        FirebaseManager.shared.observe(path: room.url() + "answearUser", completion: { [self] snapshot in
            // FIXME: ここよく調べてみたらAndroidと同じように2回呼ばれてるので、後の一回だけを使う処理に書き換える

            if snapshot.children.allObjects.count == 0 {
                return
            }

            print(snapshot)

            var fastestUser: Int = -1
            var fastestTime = Int.max

            for item in snapshot.children {
                let snapshot = item as! DataSnapshot
                let dict = snapshot.value as! [String: Any]

                let userIndex = dict["userIndex"] as! Int
                let time = dict["time"] as! Int

                if time < fastestTime {
                    fastestUser = userIndex
                    fastestTime = time
                }
            }

            // 正解してたらカウントする
            if fastestUser == me.index {
                didTapDate = Date()
                let tapDuration = didTapDate.timeIntervalSince(didPlayDate)
                print("tapDuration: \(tapDuration)")
                tapTimeArray.append(Float(tapDuration))
            }

            // タップされた札の色をanswearUserにする
            let currentMusic = playMusics[currentIndex - 1]
            currentMusic.cardOwner = fastestUser
            currentMusic.isTapped = true
            currentMusic.isAnimating = true
            fudaCollectionV.reloadData()

            room.status = .next
            isPlaying = false
            isTapped = false

            // 終了判定
            if currentIndex == CARD_MAX_COUNT {
                // 現状より早い正解者が追加で現れるかもしれないので, 終了処理を3秒待つ
                if !isWaitingForFinish {
                    isWaitingForFinish = true
                    let dispatchTime = DispatchTime.now() + 3.0
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        finishGame()
                        goResultVC()
                    }
                }

                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.center = view.center
                activityIndicatorView.style = .large
                activityIndicatorView.color = .gray
                view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()

                return
            }

            if isHost { startBtn.isHidden = false }
        })
    }
}
