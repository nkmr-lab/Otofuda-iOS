import UIKit
import Lottie
import AVFoundation

class MuteAlertVC: UIViewController {

    var timer: Timer!
    
    let displayTime = 5.0 // FIXME: 普段は3秒ぐらい
    
    let animationSize = CGSize(width: 200, height: 200)

    @IBOutlet weak var muteAnimationV: UIView!
    
    var bellPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        displayAnimation()
        
        do {
            bellPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(
                    forResource: "Bell",
                    withExtension: "mp3"
                    )!
            )
            bellPlayer!.prepareToPlay()
            bellPlayer!.volume = 1.0
            bellPlayer!.play()
            bellPlayer!.numberOfLoops = 3
        } catch {
            print(error)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        timer = Timer.scheduledTimer(
            timeInterval: displayTime,
            target: self,
            selector: #selector(self.goNextVC),
            userInfo: nil,
            repeats: false
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bellPlayer = nil
    }
    
    
    func displayAnimation(){
        let animationV = AnimationView(name: "mute_animation")
        animationV.contentMode = .scaleAspectFit
        animationV.frame = CGRect(x: 0, y: 0, width: animationSize.width, height: animationSize.height)
        animationV.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 50)
        self.view.addSubview(animationV)
        animationV.animationSpeed = 1
        animationV.loopMode = .loop
        animationV.play()
    }

    @objc func goNextVC() {
        let storyboard = UIStoryboard(name: "Top", bundle: nil)
        let nextVC = storyboard.instantiateInitialViewController()
        nextVC!.modalTransitionStyle = .crossDissolve
        nextVC!.modalPresentationStyle = .fullScreen
        present(nextVC!, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let workingTimer = timer {
            workingTimer.invalidate()
        }
    }
}
