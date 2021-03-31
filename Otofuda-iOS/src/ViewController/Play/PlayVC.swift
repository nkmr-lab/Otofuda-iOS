import UIKit
import MediaPlayer
import Toast

protocol PlayProtocol {
    func fireTimer()
    func displayCountdownV()
    func removeCountdonwV()
    func tapStartBtn(_ sender: Any)
    func initializeUI()
    func initializeVoice()
    func initializePlayer()
    func playMusic()
    func finishGame()
}

final class PlayVC: UIViewController, UINavigationControllerDelegate, PlayProtocol {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var room: Room!
    
    var isHost: Bool = false

    var me: User!

    // 再生されている曲
    var playingMusic: Music!

    var currentIndex: Int = 0

    var player: MPMusicPlayerController!
    var avPlayer: AVPlayer!
    var tapSoundPlayer: AVAudioPlayer?

    var firebaseManager = FirebaseManager()
    
    var isTapped = false
    
    var isPlaying = false
    
    var isWaitingForFinish = false

    let speech = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: "お手つき")
    
    var countdownTimer: Timer!
    var count = 0

    var playMusics: [Music] = []
    var cardLocations: [Int] = []

    var usingMusicMode: UsingMusicMode = .preset
    var scoreMode: ScoreMode = .normal
    var playbackMode: PlaybackMode = .intro

    var didPlayDate = Date()
    var didTapDate = Date()
    
    @IBOutlet var countdownV: UIView!
    
    @IBOutlet var tapErrorV: UIView!
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var startBtn: UIButton!

    var tapTimeArray: [Float] = []

    @IBOutlet weak var fudaCollectionV: UICollectionView! {
        didSet {
            fudaCollectionV.delegate = self
            fudaCollectionV.dataSource = self
            fudaCollectionV.register(cellType: FudaCollectionCell.self)
            fudaCollectionV.backgroundColor = .white
            let layout = UICollectionViewFlowLayout()
            let m = CARD_LAYOUT_MARGIN
            layout.sectionInset = UIEdgeInsets(top: m, left: m, bottom: m, right: m)
            layout.minimumInteritemSpacing = m
            layout.minimumLineSpacing = m
            fudaCollectionV.collectionViewLayout = layout
        }
    }

    @IBOutlet weak var myColorV: UIView! {
        didSet {
            myColorV.backgroundColor = me.color
        }
    }

    @IBOutlet weak var badgeV: UIView! {
        didSet {
            switch usingMusicMode {
            case .preset:
                badgeV.isHidden = false
            case .device:
                badgeV.isHidden = true
            }
        }
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        // ホスト以外は戻るを不可能にする
        if !isHost {
            self.navigationItem.hidesBackButton = true
        } else {
            self.navigationItem.hidesBackButton = false
        }

        navigationController?.delegate = self


        fudaCollectionV.reloadData()

        // 楽曲を止めずに効果音を鳴らすようにするために必要
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback, options: .mixWithOthers)
        } catch {
            print("error:", error)
        }


        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        print(audioSession.category.rawValue)

        initializeUI()
        initializeVoice()
        initializePlayer()
        initializeTapSoundPlayer()
        if isHost { startBtn.isHidden = false }
        navigationItem.title = "1曲目"
        self.fudaCollectionV.reloadData()
        
        if !isHost {
            observeRoomStatus()
        }

        observeTapped()
        observeAnswearUser()
    }

    deinit {
        player?.stop() // FIXME: 🐛プレイヤー止まってない？
        player = nil
    }

    @IBAction func tapStartBtn(_ sender: Any) {
        if player.playbackState == .playing {
            player.stop()
        }
        
        if  currentIndex > CARD_MAX_COUNT {
            return
        }

        if isHost { self.startBtn.isHidden = true }
        
        room.status = .play
        firebaseManager.post(path: room.url() + "status", value: room.status.rawValue)
        firebaseManager.deleteAllValue(path: room.url() + "tapped")
        firebaseManager.deleteAllValue(path: room.url() + "answearUser")
        
        displayCountdownV()
        fireTimer()

        // TODO: できればく非同期で3秒たったら〜ってやりたいので保留
//        playMusic()
//        setupStartBtn(isEnabled: false)
//        playingMusic = selectedMusics[currentIndex]
//        navigationItem.title = String(currentIndex) + "曲目"
//        currentIndex += 1
    }

    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        // 動画を最初に巻き戻す
        guard let currentItem = avPlayer.currentItem else { return }
        currentItem.seek(to: CMTime.zero, completionHandler: nil)
        avPlayer.play()
        print("おわったよ！！！！")
    }

    @IBAction func tappedBadge(_ sender: Any) {
        if currentIndex == 0 { return }
        let url = URL(string: playMusics[currentIndex-1].storeURL)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }

    // 戻るが押された時の処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is MenuVC {
            firebaseManager.post(path: room.url() + "status", value: RoomStatus.menu.rawValue)
            finishGame()
        }
    }
}
