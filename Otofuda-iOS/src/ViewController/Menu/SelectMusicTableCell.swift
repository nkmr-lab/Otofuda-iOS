import UIKit

class SelectMusicTableCell: UITableViewCell {

    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func prepareLabel(music: Music) {
        artistLabel.text = music.item.artist!
        titleLabel.text = music.item.title!
    }
}
