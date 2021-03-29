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

    var presetLists: [PresetList] = []

    var presets: [Preset] = []

    var presetIndex = 0

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
//            presetPickerV.delegate = self
//            presetPickerV.dataSource = self
//            presetPickerV.backgroundColor = .white
//            presetPickerV.tintColor = .black
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 戻るを不可能にする
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        firebaseManager.observeSingle(path: room.url() + "mode/cardCount", completion: { snapshot in
            if let cardCountMode = snapshot.value as? String {
                switch cardCountMode {
                case "2x2":
                    self.cardCountSegument.selectedSegmentIndex = 0
                    CARD_ROW_COUNT = 2
                    CARD_CLM_COUNT = 2
                    CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
                case "3x3":
                    self.cardCountSegument.selectedSegmentIndex = 1
                    CARD_ROW_COUNT = 3
                    CARD_CLM_COUNT = 3
                    CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
                case "4x4":
                    self.cardCountSegument.selectedSegmentIndex = 2
                    CARD_ROW_COUNT = 4
                    CARD_CLM_COUNT = 4
                    CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
                default:
                    break
                }
            }
        })

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

        // FIXME: 表示されない
        // 読み込み中にアニメーションを表示させる
//        var activityIndicatorView = UIActivityIndicatorView()
//        activityIndicatorView.center = presetPickerV.center
//        activityIndicatorView.style = .large
//        activityIndicatorView.color = .gray
//        activityIndicatorView.startAnimating()
//        presetPickerV.addSubview(activityIndicatorView)
        
        // プリセットリストをAPIから取得して、テーブルに表示
        loadApiPresets()
        
        // スタートボタンが押されるのを監視
        observeStart()
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
        
        presetLists = []
        presets = []
        presetPickerV.selectRow(0, inComponent: 1, animated: true)
        presetPickerV.reloadAllComponents()
        
        var cardCount = "4x4"
        
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            CARD_ROW_COUNT = 2
            CARD_CLM_COUNT = 2
            CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
            cardCount = "2x2"
        case 1:
            CARD_ROW_COUNT = 3
            CARD_CLM_COUNT = 3
            CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
            cardCount = "3x3"
        case 2:
            CARD_ROW_COUNT = 4
            CARD_CLM_COUNT = 4
            CARD_MAX_COUNT = CARD_CLM_COUNT * CARD_ROW_COUNT
            cardCount = "4x4"
        default:
            break
        }
        
        firebaseManager.post(path: room.url() + "mode/cardCount/", value: cardCount)
        
        loadApiPresets()
    }
    @IBAction func tappedStartBtn(_ sender: Any) {

        print(usingMusicSegment.selectedSegmentIndex)

        switch usingMusicMode {
        case .preset:
            selectedMusics = []

            let row1 = presetPickerV.selectedRow(inComponent: 0)
            let row2 = presetPickerV.selectedRow(inComponent: 1)
            
            if presetLists.count-1 < row1 {
                return
            }
            
            if presetLists[row1].presets.count < row2 {
                return
            }
            
            let preset = presetLists[row1].presets[row2]

            print(SELECT_MUSIC_API_URL + "?id=\(preset.id)&count=\(CARD_MAX_COUNT)")

            AF.request(SELECT_MUSIC_API_URL, method: .get, parameters: ["id": preset.id, "count": CARD_MAX_COUNT]).response { response in
                guard let data = response.data else { return }
                do {
                    let musicList: MusicList = try JSONDecoder().decode(MusicList.self, from: data)
                    let songs: [MusicList.Song] = musicList.musics
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
    
    func loadApiPresets(){
        
        presetLists = []
        
        AF.request(PRESET_LIST_API_URL, method: .get, parameters: ["count": CARD_MAX_COUNT]).response { response in
            guard let data = response.data else { return }
            do {
                let presetsResponse: PresetsResponse = try JSONDecoder().decode(PresetsResponse.self, from: data)
                print(presetsResponse)
                for presetList in presetsResponse.list {
                    self.presetLists.append(presetList)
                }

                // データが読み込まれる前にpickerを生成しようとしちゃうので
                // 変だけどここでdelegateとdatasorceを指定してあげてる
                self.presetPickerV.delegate = self
                self.presetPickerV.dataSource = self
                self.presetPickerV.backgroundColor = .white
                self.presetPickerV.tintColor = .black

                self.presetPickerV.reloadAllComponents()
                
                print(self.presets)
            }
            catch {
                print(error)
            }
        }
    }
    
}


extension MenuVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2

    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return presetLists.count
        case 1:
            if presetLists.count > presetIndex {
                return presetLists[presetIndex].presets.count
            }
            return 0
        default:
            return 0
        }

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return presetLists[row].typeName
        case 1:
            return presetLists[presetIndex].presets[row].name
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        // 表示するラベルを生成する
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont(name: "", size: 50)

        switch component {
        case 0:
            label.text = presetLists[row].typeName
        case 1:
            label.text = presetLists[presetIndex].presets[row].name
        default:
            break
        }


        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            presetIndex = row
            pickerView.reloadComponent(1)
        }
    }
    
}
