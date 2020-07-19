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
                case "bingo":
                    self.pointSegument.selectedSegmentIndex = 1
                default:
                    break
                }

                switch playingRule {
                case "intro":
                    self.playingSegument.selectedSegmentIndex = 0
                case "random":
                    self.playingSegument.selectedSegmentIndex = 1
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
                        guard let fbPlayMusics = fbRoom["playMusics"] as? [Dictionary<String, Any>] else {
                            print(" fbPlayMusicsがありません")
                            return
                        }
                        guard let fbCardLocations = fbRoom["cardLocations"] as? [Int] else {
                            print("fbCardLocationsがありません")
                            return
                        }
                        
                        for fbPlayMusic in fbPlayMusics {
                            let name = fbPlayMusic["name"] as! String // TODO: タイトルがないときに落ちる
                            let music = Music(name: name, item: nil)
                            self.playMusics.append(music)
                        }

                        self.cardLocations = fbCardLocations
                
                        
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
        nextVC.isHost = isHost
        nextVC.playMusics = playMusics
        nextVC.cardLocations = cardLocations
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
    
}
