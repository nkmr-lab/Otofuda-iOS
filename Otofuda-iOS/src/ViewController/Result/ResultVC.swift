import UIKit
import MediaPlayer

protocol ResultProtocol {
    func playMusic(music: Music)
    func initializePlayer()
}

final class ResultVC: UIViewController, ResultProtocol {

    var room: Room!

    // 再生順
    var playMusics: [Music] = []

    var player: MPMusicPlayerController!

    var me: User!

    var isHost: Bool = false

    var firebaseManager = FirebaseManager()

    var scoreMode: ScoreMode = .normal

    let tableCellHeight: CGFloat = 60.0

    @IBOutlet weak var winnerLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!

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
            winnerLabel.text = "あなたの勝利"
        } else {
            winnerLabel.text = "あなたの敗北"
        }

    }

    @IBAction func tapRestartBtn(_ sender: Any) {
        firebaseManager.deleteAllValue(path: room.url() + "cardLocations")
        firebaseManager.deleteAllValue(path: room.url() + "selectedPlayers")
        firebaseManager.deleteAllValue(path: room.url() + "playMusics")
        firebaseManager.deleteAllValue(path: room.url() + "currentIndex")
        firebaseManager.post(path: room.url() + "status", value: RoomStatus.menu.rawValue)
        self.navigationController?.popToViewController(
            navigationController!.viewControllers[2], animated: true
        )
    }
}
