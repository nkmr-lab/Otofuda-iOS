import UIKit

extension PlayVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let m = CARD_LAYOUT_MARGIN
        let surplusWidth = fudaCollectionV.bounds.width - m * CGFloat(CARD_CLM_COUNT + 1)
        let surplusHeight = fudaCollectionV.bounds.height - m * CGFloat(CARD_ROW_COUNT + 1)
        let cellWidth = surplusWidth / CGFloat(CARD_CLM_COUNT)
        let cellHeight = surplusHeight / CGFloat(CARD_ROW_COUNT)
        let size = CGSize(width: cellWidth, height: cellHeight)
        return size
    }
}
