import AlamofireImage
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

    private var apiResponse: iTunesApiResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func searchMusic(keyword: String, attribute: String) {
        firstly {
            iTunesApi.shared.request(keyword: keyword, attribute: attribute)
        }.done { response in
            self.apiResponse = response
            self.collectionView.reloadData()
        }.catch { error in
            print(error)
        }
    }
}

// MARK: - DataSourc

extension iTunesPickerVC: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if let apiResponse = self.apiResponse,
           let topRankMusics = apiResponse.topRankMusics
        {
            return topRankMusics.count
        }

        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(with: SearchResultCell.self,
                                                      for: indexPath)

        guard let apiResponse = self.apiResponse,
              let topRankMusics = apiResponse.topRankMusics,
              let displayMusic = topRankMusics[safe: indexPath.row]
        else {
            EmojiLogger.error("apiResponse or topRankMusics is nil")
            fatalError()
        }

        cell.titleLabel.text = displayMusic.title
        cell.artistLabel.text = displayMusic.artist
        cell.albumLabel.text = displayMusic.album

        if let thumbnail = displayMusic.thumbnail,
           let url = URL(string: thumbnail)
        {
            cell.artworkUIV.af.setImage(withURL: url)
        }

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let apiResponse = self.apiResponse,
              let topRankMusics = apiResponse.topRankMusics,
              let selectedMusic = topRankMusics[safe: indexPath.row],
              let previewUrl = selectedMusic.previewURL,
              let url = URL(string: previewUrl)
        else {
            return
        }

        EmojiLogger.info("listening ... \(selectedMusic.title ?? "") (url: \(previewUrl))")
        player = AVPlayer(url: url)
        player?.play()
    }
}

// MARK: - FlowLayout

extension iTunesPickerVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize
    {
        let width = collectionView.bounds.width / 2 - 1
        let height = width + 80
        let size = CGSize(width: width, height: height)
        return size
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt _: Int) -> CGFloat
    {
        2
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat
    {
        2
    }
}

// MARK: - UISearchBarDelegate

extension iTunesPickerVC: UISearchBarDelegate {
    // 検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchMusic(keyword: searchBar.text!,
                    attribute: selectedAttribute)
    }

    @IBAction func segmentChanged(_: Any) {
        if segumentView.selectedSegmentIndex == 0 {
            selectedAttribute = "artistTerm"
        } else {
            selectedAttribute = "songTerm"
        }

        guard let keyword = searchBar.text else {
            return EmojiLogger.error("searchBar text is nil")
        }

        searchMusic(keyword: keyword, attribute: selectedAttribute)
    }
}
