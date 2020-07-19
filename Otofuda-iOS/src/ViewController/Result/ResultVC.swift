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

    var firebaseManager = FirebaseManager()

    let tableCellHeight: CGFloat = 60.0

    @IBOutlet weak var playedMusicTableV: UITableView! {
        didSet {
            playedMusicTableV.delegate = self
            playedMusicTableV.dataSource = self
            playedMusicTableV.register(cellType: ResultTableCell.self)
            playedMusicTableV.backgroundColor = .white
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializePlayer()
    }

    @IBAction func tapRestartBtn(_ sender: Any) {
        self.navigationController?.popToViewController(
            navigationController!.viewControllers[2], animated: true
        )
    }
}
