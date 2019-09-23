import UIKit
import MediaPlayer

extension MenuVC {
    func prepareUI() {
        if isHost {
//            blockV.isHidden = true
        } else {
//            blockV.isHidden = false
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
                if status == "play" {
                    self.goNextVC()
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
        //        nextVC.isHost = false
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
            
            for i in 0..<16 {
                rangeMusics.append(shuffledMusics[i])
            }
            
            let playingMusics: [Music] = rangeMusics.shuffled()
            let arrangeMusics: [Music] = rangeMusics.shuffled()
        
            return (playingMusics, arrangeMusics)
    }
    
}
