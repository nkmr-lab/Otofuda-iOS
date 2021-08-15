import UIKit

class SelectMusicTableCell: UITableViewCell {
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func prepareLabel(music: Music) {
        artistLabel.text = music.item?.artist ?? "アーティスト名なし"
        titleLabel.text = music.item?.title ?? "タイトル名なし"
    }
}
