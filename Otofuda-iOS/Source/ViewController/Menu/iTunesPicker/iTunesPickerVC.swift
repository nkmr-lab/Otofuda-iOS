import AVFoundation
import PromiseKit
import UIKit

class iTunesPickerVC: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segumentView: UISegmentedControl!
    var selectedAttribute: String = "artistTerm"

    var player: AVPlayer!

    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(cellType: SearchResultCell.self)
            collectionView.backgroundColor = UIColor.clear
        }
    }

    var results: Results!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
