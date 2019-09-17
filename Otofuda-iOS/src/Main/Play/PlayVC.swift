
import UIKit
import MediaPlayer

protocol PlayProtocol {
    func tapExitBtn(_ sender: Any)
    func initializePlayer()
    func loadMusic()
    func selectRandomMusics()
    func arrangeMusics()
    func playMusic()
}

final class PlayVC: UIViewController, PlayProtocol {
    
    var musics: [Music] = []
    var arrangedMusics: [Music] = []
    var currentIndex: Int = 0
    let fudaMaxCount = 16
    var player: MPMusicPlayerController!
    
    @IBOutlet weak var fudaCollectionV: UICollectionView! {
        didSet {
            fudaCollectionV.delegate = self
            fudaCollectionV.dataSource = self
            fudaCollectionV.register(cellType: FudaCollectionCell.self)
            fudaCollectionV.backgroundColor = UIColor.clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePlayer()
        loadMusic()
        selectRandomMusics()
        arrangeMusics()
        playMusic()
    }
    
    // グループを作成するボタン
    @IBAction func tapExitBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

