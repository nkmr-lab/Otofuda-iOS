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

    var presets: [Preset] = []

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


        AF.request(PRESET_LIST_API_URL, method: .get, parameters: ["count": CARD_MAX_COUNT]).response { response in
            guard let data = response.data else { return }
            do {
                let presets: PresetList = try JSONDecoder().decode(PresetList.self, from: data)
                self.presets = []


                
                for preset in presets.list {
                    self.presets.append(preset)
                    self.presetPickerV.reloadAllComponents()
                }
            }
            catch {
                print(error)
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
            selectedMusics = []

            let preset = presets[presetPickerV.selectedRow(inComponent: 0)]

            AF.request(SELECT_MUSIC_API_URL, method: .get, parameters: ["id": preset.id]).response { response in
                guard let data = response.data else { return }
                do {
                    let musicList: MusicList = try JSONDecoder().decode(MusicList.self, from: data)
                    let songs: [MusicList.Song] = musicList.songs
                    for song in songs {
                        let item = AVPlayerItem(url: URL(string: song.previewURL)!)
                        let music = Music(name: song.title, artist: song.artist, item: item)
                        music.previewURL = song.previewURL
                        music.storeURL = song.storeURL
                        self.selectedMusics.append(music)
                    }
                    self.setting()
                } catch {
                   print(error)
                }

            }
        case .device:
            selectedMusics = haveMusics
            // そもそも持ち曲が16曲以上なければ何もしない
            if selectedMusics.count < CARD_MAX_COUNT {
                print("16曲以下しかありません")
                return
            }

            setting()
        }

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
        return presets[row].title
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        // 表示するラベルを生成する
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont(name: "", size: 50)
        label.text = presets[row].title
        return label
    }
    
}
