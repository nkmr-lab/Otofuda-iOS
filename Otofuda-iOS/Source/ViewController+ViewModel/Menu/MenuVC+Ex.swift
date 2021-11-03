import MediaPlayer
import UIKit

extension MenuVC {
    func setting() {
        // カードを並べる値をシャッフルする(左上から0,1,2...）
        cardLocations = [Int](0 ..< CARD_MAX_COUNT)
        cardLocations.shuffle()

        // 誰の曲を使うかを楽曲所持数に応じて決める
        var selectedPlayers: [Int] = []

        // itunesモードの時は再生者はずっと自分にする
        if usingMusicSegment.selectedSegmentIndex == 0 {
            selectedPlayers = Array(repeating: 0, count: CARD_MAX_COUNT)
        }

        while selectedPlayers.count < CARD_MAX_COUNT {
            // TODO: 所持数が0の人ばっかだと処理時間が長くなってしまうので要改善
            let selectedPlayer = Int.random(in: 0 ..< musicCounts.count)
            // 残りの楽曲所持数が1曲以上あったら
            if musicCounts[selectedPlayer] > 0 {
                // 一曲減らす
                musicCounts[selectedPlayer] = musicCounts[selectedPlayer] - 1
                // その人を追加してあげる
                selectedPlayers.append(selectedPlayer)
            }
        }

        FirebaseManager.shared.post(path: room.url() + "cardLocations", value: cardLocations)
        FirebaseManager.shared.post(path: room.url() + "selectedPlayers", value: selectedPlayers)

        room.status = .start
        FirebaseManager.shared.post(path: room.url() + "status", value: room.status.rawValue)

        FirebaseManager.shared.deleteObserve(path: room.url() + "musicCounts")
    }

    func observeUI() {
        FirebaseManager.shared.observe(path: room.url() + "mode", completion: { snapshot in
            if let modeDict = snapshot.value as? [String: String] {
                guard let usingMusicMode = modeDict["usingMusic"] else { return }
                guard let scoreMode = modeDict["score"] else { return }
                guard let playbackMode = modeDict["playback"] else { return }
                guard let cardCountMode = modeDict["cardCount"] else { return }

                switch usingMusicMode {
                case "preset":
                    self.usingMusicSegment.selectedSegmentIndex = 0
                    self.presetPickerV.isHidden = false
                case "device":
                    self.usingMusicSegment.selectedSegmentIndex = 1
                    self.presetPickerV.isHidden = true

                default:
                    break
                }

                switch scoreMode {
                case "normal":
                    self.scoreSegument.selectedSegmentIndex = 0
                    self.scoreMode = .normal
                case "bingo":
                    self.scoreSegument.selectedSegmentIndex = 1
                    self.scoreMode = .bingo

                default:
                    break
                }

                switch playbackMode {
                case "intro":
                    self.playbackSegument.selectedSegmentIndex = 0
                    self.playbackMode = .intro
                case "random":
                    self.playbackSegument.selectedSegmentIndex = 1
                    self.playbackMode = .random

                default:
                    break
                }

                switch cardCountMode {
                case "2x2":
                    self.cardCountSegument.selectedSegmentIndex = 0
                    CARD_ROW_COUNT = 2
                    CARD_CLM_COUNT = 2
                    CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
                case "3x3":
                    self.cardCountSegument.selectedSegmentIndex = 1
                    CARD_ROW_COUNT = 3
                    CARD_CLM_COUNT = 3
                    CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
                case "4x4":
                    self.cardCountSegument.selectedSegmentIndex = 2
                    CARD_ROW_COUNT = 4
                    CARD_CLM_COUNT = 4
                    CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT

                default:
                    break
                }
            }
        })
    }

    func observeMusicCounts() {
        FirebaseManager.shared.observeSingle(path: room.url() + "musicCounts", completion: { snapshot in
            if let musicCounts = snapshot.value as? [Int] {
                self.musicCounts = musicCounts
            }
        })
    }

    func observeStart() {
        FirebaseManager.shared.observe(path: room.url() + "status", completion: { snapshot in
            if let status = snapshot.value as? String {
                if status == RoomStatus.start.rawValue {
                    print(self.room.url())
                    print("observeStartが発火するタイミング")

                    FirebaseManager.shared.observeSingle(path: self.room.url(), completion: { snapshot in
                        self.preparedPlayMusics()

                        guard let fbRoom = snapshot.value as? [String: Any] else {
                            print("fbRoomがありませんでした")
                            return
                        }
                        print("fbRoomがありました")
                        guard let fbCardLocations = fbRoom["cardLocations"] as? [Int] else {
                            print("fbCardLocationsがありませんでした")
                            return
                        }
                        print("fbCardLocationsがありました")
                        guard let fbSelectedPlayers = fbRoom["selectedPlayers"] as? [Int] else {
                            print("fbSelectedPlayersがありあませんでした")
                            return
                        }
                        var playCount = 0
                        self.selectedMusics.shuffle()
                        for (index, selectedPlayer) in fbSelectedPlayers.enumerated() {
                            if selectedPlayer == self.me.order {
                                let music = self.selectedMusics[playCount]
                                music.musicOwner = self.me.order
                                FirebaseManager.shared.post(path: self.room.url() + "playMusics/\(index)", value: music.dict())
                                playCount = playCount + 1
                            }
                        }

                        FirebaseManager.shared.deleteObserve(path: self.room.url() + "status")

                        self.cardLocations = fbCardLocations

                        print("=========")
                        print(fbCardLocations)
                    })
                }
            }
        })
    }

    func preparedPlayMusics() {
        FirebaseManager.shared.observe(path: room.url() + "playMusics", completion: { [weak self] snapshot in
            guard let self = self else { return }
            self.playMusics = []

            print("preparedMusicが発火するタイミング")

            if snapshot.children.allObjects.count == CARD_MAX_COUNT {
                guard let fbPlayMusics = snapshot.value as? [[String: Any]] else { return }

                for fbPlayMusic in fbPlayMusics {
                    let name = fbPlayMusic["name"] as! String
                    let artist = fbPlayMusic["artist"] as! String
                    let musicOwner = fbPlayMusic["musicOwner"] as! Int
                    let previewURL = fbPlayMusic["previewURL"] as? String
                    let storeURL = fbPlayMusic["storeURL"] as? String

                    var mediaItem: MPMediaItem?
                    if musicOwner == self.me.order {
                        mediaItem = MPMediaItem.getMediaItem(title: name, artist: artist)
                    }

                    let music = MusicModel(name: name, artist: artist, item: mediaItem!)
                    music.previewUrl = previewURL
                    music.storeUrl = storeURL
                    music.musicOwner = musicOwner

                    self.playMusics.append(music)
                }

                FirebaseManager.shared.deleteObserve(path: self.room.url() + "playMusics")

                self.goNextVC() // FIXME: 2度目の時ここが5回呼ばれてる
            }
        })
    }

    func goNextVC() {
        let storyboard = UIStoryboard(name: "Play", bundle: nil)
        let nextVC = storyboard.instantiateInitialViewController() as! PlayVC
        nextVC.modalTransitionStyle = .crossDissolve
        nextVC.room = room
        nextVC.isHost = isHost
        nextVC.playMusics = playMusics
        nextVC.cardLocations = cardLocations
        nextVC.usingMusicMode = usingMusicMode
        nextVC.scoreMode = scoreMode
        nextVC.playbackMode = playbackMode

        nextVC.me = me

        if !isHost {
            FirebaseManager.shared.deleteObserve(path: room.url() + "rule")
        }

        navigationController?.pushViewController(nextVC, animated: true)
    }

    func displayBlockV() {
        blockV.frame = view.frame
        blockV.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blockV)

        blockV.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        blockV.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        blockV.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        blockV.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
}
