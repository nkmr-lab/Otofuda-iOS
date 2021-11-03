import AVFoundation
import MediaPlayer
import UIKit

protocol ResultProtocol {
    func playMusic(music: MusicModel)
    func initializePlayer()
}

final class ResultVC: UIViewController, ResultProtocol {
    var room: Room!

    // 再生順
    var playMusics: [MusicModel] = []

    var player: MPMusicPlayerController!

    var avPlayer: AVPlayer!

    var me: UserModel!

    var isHost = false

    var usingMusicMode: UsingMusicMode = .preset

    var scoreMode: ScoreMode = .normal

    let tableCellHeight: CGFloat = 120.0

    @IBOutlet var winnerLabel: UILabel!

    @IBOutlet var scoreLabel: UILabel!

    @IBOutlet var timeLabel: UILabel!

    var tapTimeArray: [Float] = []

    @IBOutlet var playedMusicTableV: UITableView! {
        didSet {
            playedMusicTableV.delegate = self
            playedMusicTableV.dataSource = self
            playedMusicTableV.register(cellType: ResultTableCell.self)
            playedMusicTableV.backgroundColor = .white
        }
    }

    @IBOutlet var restartBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        //        initializePlayer()

        // 戻るを不可能にする
        navigationItem.hidesBackButton = true

        if !isHost {
            restartBtn.isHidden = true
            observeRoomStatus()
        }

        // TODO: scoreModeがビンゴモードだった時の採点処理
        var eachScores = [Int](repeating: 0, count: room.member.count)
        for music in playMusics {
            if let cardOwner = music.cardOwner {
                eachScores[cardOwner] += 1
            }
        }
        scoreLabel.text = "\(eachScores[me.order])点"

        if eachScores[me.order] == eachScores.max() {
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

    @IBAction func tapRestartBtn(_: Any) {
        FirebaseManager.shared.post(path: room.url() + "status", value: RoomStatus.menu.rawValue)
        navigationController?.popToViewController(
            navigationController!.viewControllers[2], animated: true
        )
    }
}
