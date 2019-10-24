import UIKit
import MediaPlayer

extension MenuVC {
    func prepareUI() {
        if isHost {
        }
        else {
            displayBlockV()
            observeUI()
            observeStart()
        }
    }

    func observeUI() {
        firebaseManager.observe(path: room.url() + "rule", completion: { snapshot in 
            if let ruleDict = snapshot.value as? Dictionary<String, String> {
                guard let pointRule = ruleDict["point"] else { return }
                guard let playingRule = ruleDict["playing"] else { return }
                
                switch pointRule {
                case "normal":
                    self.pointSegument.selectedSegmentIndex = 0
                case "othello":
                    self.pointSegument.selectedSegmentIndex = 1
                default:
                    break
                }

                switch playingRule {
                case "intro":
                    self.playingSegument.selectedSegmentIndex = 0
                case "sabi":
                    self.playingSegument.selectedSegmentIndex = 1
                case "random":
                    self.playingSegument.selectedSegmentIndex = 2
                default:
                    break
                }
            }
        })
    }

    func observeStart() {
        firebaseManager.observe(path: room.url() + "status", completion: { snapshot in
            if let status = snapshot.value as? String {
                if status == RoomStatus.start.rawValue {
                    self.firebaseManager.observeSingle(path: self.room.url(), completion: { snapshot in
                        guard let fbRoom = snapshot.value as? Dictionary<String,Any> else {
                            print("fbRoomがありません")
                            return
                        }
                        guard let fbPlayingMusics = fbRoom["playingMusics"] as? [Dictionary<String, Any>] else {
                            print("fbPlayingMusicsがありません")
                            return
                        }
                        guard let fbArrangeMusics = fbRoom["arrangeMusics"] as? [Dictionary<String, Any>] else {
                            print("fbArrangeMusicsがありません")
                            return
                        }
                        
                        for fbPlayingMusic in fbPlayingMusics {
                            let name = fbPlayingMusic["name"] as! String // TODO: タイトルがないときに落ちる
                            let music = Music(name: name, item: nil)
                            self.playingMusics.append(music)
                        }
                        
                        for fbArrangeMusic in fbArrangeMusics {
                            let name = fbArrangeMusic["name"] as! String // TODO: タイトルがないときに落ちる
                            let music = Music(name: name, item: nil)
                            self.arrangeMusics.append(music)
                        }
                        
                        self.goNextVC()
                    })
                }
            }
        })
        
    }

    func goNextVC() {
        let storyboard = UIStoryboard(name: "Play", bundle: nil)
        let nextVC = storyboard.instantiateInitialViewController() as! PlayVC
        nextVC.modalTransitionStyle = .crossDissolve
        nextVC.room = room
        nextVC.isHost = self.isHost
        nextVC.playingMusics = self.playingMusics
        nextVC.arrangeMusics = self.arrangeMusics
        nextVC.me = me
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func displayBlockV(){
        blockV.frame = self.view.frame
        blockV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(blockV)
        
        blockV.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        blockV.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        blockV.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        blockV.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1.0).isActive = true
    }
    
    func getShuffledMusic(selectedMusics: [Music]) -> (
        playingMusics: [Music], arrangeMusics:[Music]) {
            
            let shuffledMusics = selectedMusics.shuffled()
            var rangeMusics: [Music] = []
            
            for i in 0..<Config.fudaMaxCount {
                rangeMusics.append(shuffledMusics[i])
            }
            
            let playingMusics: [Music] = rangeMusics.shuffled()
            let arrangeMusics: [Music] = rangeMusics.shuffled()
        
            return (playingMusics, arrangeMusics)
    }
    
}
