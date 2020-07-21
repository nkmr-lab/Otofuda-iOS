import UIKit

class ResultTableCell: UITableViewCell {

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func prepareLabel(index: Int, music: Music) {
        indexLabel.text = String(index) + "."
        artistLabel.text = music.item.artist!
        titleLabel.text = music.item.title!
    }
}
