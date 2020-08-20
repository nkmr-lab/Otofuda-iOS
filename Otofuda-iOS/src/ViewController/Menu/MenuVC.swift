import UIKit
import PromiseKit
import Alamofire
import AVFoundation

protocol Menurotocol {
    func tappedPickBtn(_ sender: Any)
}

final class MenuVC: UIViewController, Menurotocol {

    let viewModel = PresetViewModel()

    var firebaseManager = FirebaseManager()

    var room: Room!

    var haveMusics: [Music] = []

    var isHost: Bool = false

    var me: User!

    @IBOutlet weak var blockV: UIView!

    var musicCounts: [Int] = []
    
    // モード
    var usingMusicMode: UsingMusicMode = .preset
    var scoreMode: ScoreMode = .normal
    var playbackMode: PlaybackMode = .intro

    // Segument
    @IBOutlet weak var usingMusicSegment: UISegmentedControl! {
        didSet {
            usingMusicSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        }
    }

    @IBOutlet weak var scoreSegument: UISegmentedControl! {
        didSet {
            scoreSegument.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        }
    }

    @IBOutlet weak var playbackSegument: UISegmentedControl! {
        didSet {
            playbackSegument.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        }
    }

    @IBOutlet weak var cardCountSegument: UISegmentedControl! {
        didSet {
            cardCountSegument.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        }

    }

    var selectedMusics: [Music] = []
    
    var playMusics: [Music] = []

    var cardLocations: [Int] = []

    var presets: [String] = []

    @IBOutlet weak var selectMusicTableV: UITableView! {
        didSet {
            selectMusicTableV.delegate = self
            selectMusicTableV.dataSource = self
            selectMusicTableV.register(cellType: SelectMusicTableCell.self)
            selectMusicTableV.backgroundColor = .white
        }
    }

    @IBOutlet weak var presetPickerV: UIPickerView! {
        didSet {
            presetPickerV.delegate = self
            presetPickerV.dataSource = self
            presetPickerV.backgroundColor = .white
            presetPickerV.tintColor = .black
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 戻るを不可能にする
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 後のどのユーザの楽曲を使うか判断する時に使う
        // TODO: この曲数をベースに次に進めるかどうかを判定する
        // TODO: 縛り曲の時そのアーティストの曲数もここにいれて, あるかどうかを判定する
        firebaseManager.post(path: room.url() + "musicCounts/\(me.index)", value: haveMusics.count)

        if isHost {
            observeMusicCounts()
        }
        else {
            displayBlockV()
            observeUI()
        }

        // スタートボタンが押されるのを監視
        observeStart()

        // 楽曲が準備できるのを監視
        preparedPlayMusics()

        firstly {
            PresetAPIModel.shared.request()
        }.then { data -> Promise<PresetResponse> in
            PresetAPIModel.shared.mapping(jsonStr: data)
        }.done { results in
            print("done")
            self.presets = []
            for result in results.list {
                self.presets.append(result.title)
                self.presetPickerV.reloadAllComponents()
            }
        }.catch { error in
            print(error)
        }

            // プリセットモードだったら
            if usingMusicSegment.selectedSegmentIndex == 0 {
                haveMusics = [] // FIXME: ここでデバイス内の楽曲がリセットされちゃうのでもう一度遊ぶ時ばぐる

                AF.request(SELECT_MUSIC_API_URL, method: .get, parameters: ["id": 2]).response { response in
                    guard let data = response.data else { return }
                    do {
                        let musicList: MusicList = try JSONDecoder().decode(MusicList.self, from: data)
                        let songs: [MusicList.Song] = musicList.songs
        //                let song = songs[0]
        //                guard let url = URL(string: song.previewURL) else { return }
        //                self.player = AVPlayer(url: url)
        //                self.player?.volume = 1.0
        //                self.player?.play()
        //                print(song.title, song.previewURL)
                        for song in songs {
                            let item = AVPlayerItem(url: URL(string: song.previewURL)!)
                            let music = Music(name: song.title, artist: song.artist, item: item)
                            music.previewURL = song.previewURL
                            self.haveMusics.append(music)
                        }
                    } catch {
                        print(error)
                    }
                }
            }

    }

    deinit {
        firebaseManager.deleteObserve(path: room.url() + "playMusics")
        firebaseManager.deleteObserve(path: room.url() + "status")
    }

    @IBAction func changedUsingMusicSeg(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            presetPickerV.isHidden = false
            usingMusicMode = .preset
        case 1:
            presetPickerV.isHidden = true
            usingMusicMode = .device
        default:
            break
        }
        firebaseManager.post(path: room.url() + "mode/usingMusic/", value: usingMusicMode.rawValue)
    }

    @IBAction func changedScoreSeg(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            scoreMode = .normal
        case 1:
            scoreMode = .bingo
        default:
            break
        }
        firebaseManager.post(path: room.url() + "mode/score/", value: scoreMode.rawValue)
    }

    @IBAction func changePlaybackSeg(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            playbackMode = .intro
        case 1:
            playbackMode = .random
        default:
            break
        }
        firebaseManager.post(path: room.url() + "mode/playback/", value: playbackMode.rawValue)
    }

    @IBAction func changeCardCountSeg(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            CARD_ROW_COUNT = 2
            CARD_CLM_COUNT = 2
            CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
        case 1:
            CARD_ROW_COUNT = 3
            CARD_CLM_COUNT = 3
            CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
        case 2:
            CARD_ROW_COUNT = 4
            CARD_CLM_COUNT = 4
            CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
        default:
            break
        }
    }
    @IBAction func tappedStartBtn(_ sender: Any) {

        print(usingMusicSegment.selectedSegmentIndex)

        switch usingMusicMode {
        case .preset:
            break
        case .device:
            break
        default:
            break
        }

        // そもそも持ち曲が16曲以上なければ何もしない
        if haveMusics.count < CARD_MAX_COUNT {
            print("16曲以下しかありません")
            return
        }

        // カードを並べる値をシャッフルする(左上から0,1,2...）
        self.cardLocations = [Int](0..<CARD_MAX_COUNT)
        cardLocations.shuffle()

        // 誰の曲を使うかを楽曲所持数に応じて決める
        var selectedPlayers: [Int] = []

        // itunesモードの時は再生者はずっと自分にする
        if usingMusicSegment.selectedSegmentIndex == 0 {
            selectedPlayers = Array(repeating: 0, count: CARD_MAX_COUNT)
        }

        while selectedPlayers.count < CARD_MAX_COUNT {
            // TODO: 所持数が0の人ばっかだと処理時間が長くなってしまうので要改善
            let selectedPlayer = Int.random(in: 0..<musicCounts.count)
            // 残りの楽曲所持数が1曲以上あったら
            if musicCounts[selectedPlayer] > 0 {
                // 一曲減らす
                musicCounts[selectedPlayer] = musicCounts[selectedPlayer] - 1
                // その人を追加してあげる
                selectedPlayers.append(selectedPlayer)
            }
        }

        firebaseManager.post(path: room.url() + "cardLocations", value: cardLocations)
        firebaseManager.post(path: room.url() + "selectedPlayers", value: selectedPlayers)

        room.status = .start
        firebaseManager.post(path: room.url() + "status", value: room.status.rawValue)

        firebaseManager.deleteObserve(path: room.url() + "musicCounts")
    }

    
}


extension MenuVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1

    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        presets.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return presets[row]
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        // 表示するラベルを生成する
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont(name: "", size: 40)
        label.text = presets[row]
        return label
    }
}
