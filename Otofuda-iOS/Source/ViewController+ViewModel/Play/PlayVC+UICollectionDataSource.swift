import OtofudaEntity
import UIKit

extension PlayVC: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        CARD_MAX_COUNT
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: FudaCollectionCell.self,
                                                      for: indexPath)
        cell.titleLabel.text = playMusics[cardLocations[indexPath.row]].name
        let cellMusic = playMusics[cardLocations[indexPath.row]]
        let owner = cellMusic.cardOwner ?? 0

        if cellMusic.isAnimating {
            cell.animate()
            cellMusic.isAnimating = false
        }

        if cellMusic.isTapped {
            cell.backgroundV.backgroundColor = ColorList(index: owner).uiColor
            cell.titleLabel.textColor = .white
        } else {
            cell.backgroundV.backgroundColor = .white
            cell.titleLabel.textColor = .black
        }

        return cell
    }
}
