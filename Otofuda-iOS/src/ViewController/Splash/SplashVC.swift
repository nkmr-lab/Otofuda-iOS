import UIKit

class SplashVC: UIViewController {

    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(self.goNextVC),
            userInfo: nil,
            repeats: false
        )
    }

    @objc func goNextVC() {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "MuteAlertVC")
        nextVC?.modalTransitionStyle = .crossDissolve
        nextVC?.modalPresentationStyle = .fullScreen
        present(nextVC!, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let workingTimer = timer {
            workingTimer.invalidate()
        }
    }
}
