import UIKit
import MediaPlayer
import AVFoundation

protocol ResultProtocol {
    func playMusic(music: Music)
    func initializePlayer()
}

final class ResultVC: UIViewController, ResultProtocol {

    var room: Room!

    // 再生順
    var playMusics: [Music] = []

    var player: MPMusicPlayerController!

    var avPlayer: AVPlayer!

    var me: User!

    var isHost: Bool = false

    var firebaseManager = FirebaseManager()

    var usingMusicMode: UsingMusicMode = .preset

    var scoreMode: ScoreMode = .normal

    let tableCellHeight: CGFloat = 120.0

    @IBOutlet weak var winnerLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var tapTimeArray: [Float] = []

    @IBOutlet weak var playedMusicTableV: UITableView! {
        didSet {
            playedMusicTableV.delegate = self
            playedMusicTableV.dataSource = self
            playedMusicTableV.register(cellType: ResultTableCell.self)
            playedMusicTableV.backgroundColor = .white
        }
    }

    @IBOutlet weak var restartBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

//        initializePlayer()
        
        
        // 戻るを不可能にする
        self.navigationItem.hidesBackButton = true

        if !isHost {
            restartBtn.isHidden = true
            observeRoomStatus()
        }
        
        // TODO: scoreModeがビンゴモードだった時の採点処理
        var eachScores = [Int](repeating: 0, count: room.member.count)
        for music in playMusics {
            if music.cardOwner != nil {
                eachScores[music.cardOwner] += 1
            }
        }
        scoreLabel.text = "\(eachScores[me.index])点"

        if eachScores[me.index] == eachScores.max() {
            if eachScores.filter({ $0 == eachScores.max() }).count > 1 {
                winnerLabel.text = "引き分け"
            } else {
                winnerLabel.text = "あなたの勝利"
            }
        } else {
            winnerLabel.text = "あなたの敗北"
        }
        
        // FIXME: 配列から平均を算出する関数作る
        // https://www.javaer101.com/ja/article/17499252.html
        var sumTapTime: Float = 0.0
        var avgTapTime: Float = 0.0
        for tapTime in tapTimeArray {
            sumTapTime += tapTime
        }
        
        if tapTimeArray.count != 0 {
            avgTapTime = sumTapTime / Float(tapTimeArray.count)
            timeLabel.text = "平均タップペース: \(avgTapTime) 秒"
        }

    }

    @IBAction func tapRestartBtn(_ sender: Any) {
        firebaseManager.post(path: room.url() + "status", value: RoomStatus.menu.rawValue)
        self.navigationController?.popToViewController(
            navigationController!.viewControllers[2], animated: true
        )
    }
}
