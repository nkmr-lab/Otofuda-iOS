import UIKit
import MediaPlayer

extension MenuVC {
 
    func observeUI() {
        firebaseManager.observe(path: room.url() + "mode", completion: { snapshot in
            if let modeDict = snapshot.value as? Dictionary<String, String> {
                guard let scoreMode = modeDict["score"] else { return }
                guard let playbackMode = modeDict["playback"] else { return }
                
                
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
            }
        })
    }

    func observeMusicCounts() {
        firebaseManager.observeSingle(path: room.url() + "musicCounts", completion: { snapshot in
            if let musicCounts = snapshot.value as? [Int] {
                self.musicCounts = musicCounts
            }
        })
    }

    func observeStart() {
        firebaseManager.observe(path: room.url() + "status", completion: { snapshot in
            if let status = snapshot.value as? String {
                if status == RoomStatus.start.rawValue {
                    self.firebaseManager.observeSingle(path: self.room.url(), completion: { snapshot in
                        guard let fbRoom = snapshot.value as? Dictionary<String,Any>,
                              let fbCardLocations = fbRoom["cardLocations"] as? [Int],
                              let fbSelectedPlayers = fbRoom["selectedPlayers"] as? [Int]
                            else { return }

                        var playCount = 0
                        self.haveMusics.shuffle()
                        for (index, selectedPlayer) in fbSelectedPlayers.enumerated() {
                            if selectedPlayer == self.me.index {
                                let music = self.haveMusics[playCount]
                                music.musicOwner = self.me.index
                                self.firebaseManager.post(path: self.room.url() + "playMusics/\(index)", value: music.dict())
                                playCount = playCount + 1
                            }
                        }

                        self.firebaseManager.deleteObserve(path: self.room.url() + "status")

                        self.cardLocations = fbCardLocations

                    })
                }
            }
        })
        
    }

    func preparedPlayMusics() {
        firebaseManager.observe(path: room.url() + "playMusics", completion: { [weak self] snapshot in
            guard let self = self else { return }
            self.playMusics = []

            if snapshot.children.allObjects.count == CARD_MAX_COUNT {
                guard let fbPlayMusics = snapshot.value as? [Dictionary<String, Any>] else { return }

                for (index, fbPlayMusic) in fbPlayMusics.enumerated() {
                    let name = fbPlayMusic["name"] as! String
                    let artist = fbPlayMusic["artist"] as! String
                    let musicOwner = fbPlayMusic["musicOwner"] as! Int
                    let previewURL = fbPlayMusic["previewURL"] as? String
                    let storeURL = fbPlayMusic["storeURL"] as? String

                    var mediaItem: MPMediaItem?
                    if musicOwner == self.me.index {
                        mediaItem = MPMediaItem.getMediaItem(title: name, artist: artist)
                    }

                    let music = Music(name: name, artist: artist, item: mediaItem)
                    music.previewURL = previewURL
                    music.storeURL = storeURL
                    music.musicOwner = musicOwner

                    self.playMusics.append(music)
                }

                self.firebaseManager.deleteObserve(path: self.room.url() + "playMusics")

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
        nextVC.scoreMode = scoreMode
        nextVC.me = me

        if !isHost {
            firebaseManager.deleteObserve(path: room.url() + "rule")
        }
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func displayBlockV(){
        blockV.frame = self.view.frame
        blockV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(blockV)
        
        blockV.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        blockV.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        blockV.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        blockV.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
    }
    
}
