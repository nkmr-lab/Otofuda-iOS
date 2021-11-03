import UIKit

class SelectMusicTableCell: UITableViewCell {
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func prepareLabel(music: MusicModel) {
        artistLabel.text = music.mpItem?.artist ?? "アーティスト名なし"
        titleLabel.text = music.mpItem?.title ?? "タイトル名なし"
    }
}
