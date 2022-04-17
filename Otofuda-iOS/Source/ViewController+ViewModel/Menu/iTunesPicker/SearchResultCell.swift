import UIKit

final class SearchResultCell: UICollectionViewCell {
    @IBOutlet var artworkUIV: UIImageView!

    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
