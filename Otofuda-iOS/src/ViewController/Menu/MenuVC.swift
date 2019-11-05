import UIKit
import PromiseKit

protocol Menurotocol {
    func tappedPickBtn(_ sender: Any)
    func prepareUI()
}

enum RulePoint: String {
    case normal  = "normal"
    case othello = "othello"
}

enum RulePlaying: String {
    case intro = "intro"
    case sabi  = "sabi"
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
    
    var playingMusics: [Music] = []
    var arrangeMusics: [Music] = []

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
        prepareUI()

//        viewModel.

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
            rulePoint = .othello
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
            rulePlaying = .sabi
        case 2:
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
            if haveMusics.count < Config.fudaMaxCount {
                print("16曲以下しかありません")
               return
            }
            
            // 選択曲が16曲以下だったら水増しする
            if selectedMusics.count < Config.fudaMaxCount {
                let shuffledMusics = haveMusics.shuffled()
                let diffCount = Config.fudaMaxCount - selectedMusics.count
                for i in 0..<diffCount {
                    selectedMusics.append( shuffledMusics[i] )
                }
            }
                        
            let shuffledTapleMusics = getShuffledMusic(selectedMusics: selectedMusics)
            let playingMusics = shuffledTapleMusics.playingMusics
            let arrangeMusics = shuffledTapleMusics.arrangeMusics
            
            // FirebaseにPOST処理
            var dictPlayingMusics: [Dictionary<String, Any>] = []
            for music in playingMusics {
                dictPlayingMusics.append(music.dict())
            }
            var dictArrangeMusics: [Dictionary<String, Any>] = []
            for music in arrangeMusics {
                dictArrangeMusics.append(music.dict())
            }
            firebaseManager.post(path: room.url() + "playingMusics", value: dictPlayingMusics)
            firebaseManager.post(path: room.url() + "arrangeMusics", value: dictArrangeMusics)
            
            let nextVC = segue.destination as! PlayVC
            nextVC.room = room
            nextVC.playingMusics = playingMusics
            nextVC.arrangeMusics = arrangeMusics
            nextVC.isHost = self.isHost
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

//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return presets[row]
//    }

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
