import AVFoundation
import UIKit

extension iTunesPickerVC: UICollectionViewDataSource {
    func collectionView(_: UICollectionView,
                        numberOfItemsInSection _: Int) -> Int
    {
        if let results = self.results {
            return (results.results?.count)!
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(with: SearchResultCell.self,
                                                      for: indexPath)
        let result = results.results![indexPath.row]
        let strImg = result.thumbnail
        print(strImg)
        cell.titleLabel.text = result.title
        cell.artistLabel.text = result.artist
        cell.albumLabel.text = result.album
        if let url = URL(string: result.thumbnail) {
            cell.artworkUIV.af.setImage(withURL: url)
        }

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let result = results.results![indexPath.row]
        print("==================")
        print(result.previewURL)
        print("==================")
        player = AVPlayer(url: URL(string: result.previewURL)!)
        player?.play()
    }
}
