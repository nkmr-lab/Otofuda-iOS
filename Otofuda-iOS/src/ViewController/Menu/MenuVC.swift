import UIKit
import PromiseKit

protocol Menurotocol {
    func tappedPickBtn(_ sender: Any)
    func prepareUI()
}

enum RulePoint: String {
    case normal  = "normal"
    case bingo = "bingo"
}

enum RulePlaying: String {
    case intro = "intro"
    case random = "random"
}

final class MenuVC: UIViewController, Menurotocol {

    let viewModel = PresetViewModel()

    var firebaseManager = FirebaseManager()

    var room: Room!

    var haveMusics: [Music] = []

    var isHost: Bool = false

    var me: User!

    @IBOutlet weak var blockV: UIView!
    // ルール
    var rulePoint: RulePoint = .normal
    var rulePlaying: RulePlaying = .intro

    // Segument
    @IBOutlet weak var pointSegument: UISegmentedControl! {
        didSet {
            pointSegument.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .selected)
        }
    }
    @IBOutlet weak var playingSegument: UISegmentedControl! {
        didSet {
            playingSegument.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .selected)
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

        // 後のどのユーザの楽曲を使うか判断する時に使う
        firebaseManager.post(path: room.url() + "musicCount/\(me.index)", value: haveMusics.count)

        prepareUI()

        firstly {
            PresetAPIModel.shared.request()
        }.then { data -> Promise<PresetResponse> in
            PresetAPIModel.shared.mapping(jsonStr: data)
       }.done { results in
            print("done")

            for result in results.list {
                self.presets.append(result.title)
                self.presetPickerV.reloadAllComponents()
            }
       }.catch { error in
            print(error)
        }
    }

    @IBAction func changedPointSeg(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            rulePoint = .normal
        case 1:
            rulePoint = .bingo
        default:
            break
        }
        firebaseManager.post(path: room.url() + "rule/point/", value: rulePoint.rawValue)
    }

    @IBAction func changePlayingSeg(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            rulePlaying = .intro
        case 1:
            rulePlaying = .random
        default:
            break
        }
        firebaseManager.post(path: room.url() + "rule/playing/", value: rulePlaying.rawValue)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {

            // そもそも持ち曲が16曲以上なければ何もしない
            // TODO: セグエなのでリターンしただけでは強制的に遷移してしまうので今後改善
            if haveMusics.count < CARD_MAX_COUNT {
                print("16曲以下しかありません")
                return
            }

            // カードを並べる値をシャッフルする(左上から0,1,2...）
            self.cardLocations = [Int](0..<CARD_MAX_COUNT)
            cardLocations.shuffle()

            firebaseManager.post(path: room.url() + "cardLocations", value: cardLocations)
            
            // 選択曲が16曲以下だったら水増しする
            if selectedMusics.count < CARD_MAX_COUNT {
                let shuffledMusics = haveMusics.shuffled()
                let diffCount = CARD_MAX_COUNT - selectedMusics.count
                for i in 0..<diffCount {
                    selectedMusics.append( shuffledMusics[i] )
                }
            }

            // シャッフルして16曲に絞る
            // TODO: みんなの楽曲にする
            let shuffledMusic = selectedMusics.shuffled()[0..<CARD_MAX_COUNT]

            // FirebaseにPOST処理
            var sendPlayMusics: [Dictionary<String, Any>] = []

            for music in shuffledMusic {
                sendPlayMusics.append(music.dict())
                playMusics.append(music)
            }

            firebaseManager.post(path: room.url() + "playMusics", value: sendPlayMusics)
            
            let nextVC = segue.destination as! PlayVC
            nextVC.room = room
            nextVC.isHost = self.isHost
            nextVC.playMusics = playMusics
            nextVC.cardLocations = cardLocations
            nextVC.me = me
            room.status = .start

            firebaseManager.post(path: room.url() + "status", value: room.status.rawValue)
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
