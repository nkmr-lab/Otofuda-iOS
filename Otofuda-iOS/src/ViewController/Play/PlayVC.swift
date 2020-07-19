import UIKit
import MediaPlayer

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

final class PlayVC: UIViewController, PlayProtocol {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var room: Room!
    
    var isHost: Bool = false

    var me: User!

    // 再生されている曲
    var playingMusic: Music!

    var currentIndex: Int = 0

    var player: MPMusicPlayerController!
    var tapSoundPlayer: AVAudioPlayer?

    var firebaseManager = FirebaseManager()
    
    var isTapped = false
    
    var isPlaying = false

    let speech = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: "お手つき")
    
    var countdownTimer: Timer!
    var count = 0

    var playMusics: [Music] = []
    var cardLocations: [Int] = []
    
    @IBOutlet var countdownV: UIView!
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var startBtn: UIButton! {
        didSet {
//            setupStartBtn(isEnabled: true)
        }
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()

        fudaCollectionV.reloadData()

        // 楽曲を止めずに効果音を鳴らすようにするために必要
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.ambient)
        } catch {
            print("error:", error)
        }
        
        print(audioSession.category.rawValue)

        initializeUI()
        initializeVoice()
        initializePlayer()
        initializeTapSoundPlayer()
        setupStartBtn(isEnabled: true)
        navigationItem.title = "1曲目"
        self.fudaCollectionV.reloadData()
        
        if !isHost {
            observeRoomStatus()
        }
    }

    deinit {
        player.stop() // FIXME: 🐛プレイヤー止まってない？
        player = nil
    }

    @IBAction func tapStartBtn(_ sender: Any) {
        if player.playbackState == .playing {
            player.stop()
        }
        
        if  currentIndex > CARD_MAX_COUNT {
            return
        }
        
        room.status = .play
        firebaseManager.post(path: room.url() + "status", value: room.status.rawValue)
        firebaseManager.deleteAllValuesAndObserve(path: room.url() + "tapped")
        firebaseManager.deleteAllValuesAndObserve(path: room.url() + "answearUser")
        
        displayCountdownV()
        fireTimer()

        // TODO: できればく非同期で3秒たったら〜ってやりたいので保留
//        playMusic()
//        setupStartBtn(isEnabled: false)
//        playingMusic = selectedMusics[currentIndex]
//        navigationItem.title = String(currentIndex) + "曲目"
//        currentIndex += 1
    }
    
}
