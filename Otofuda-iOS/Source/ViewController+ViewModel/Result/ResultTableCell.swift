import UIKit

class ResultTableCell: UITableViewCell {
    @IBOutlet var indexLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var badgeBtn: UIButton!
    var badgeURL: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func prepareLabel(index: Int, music: MusicModel) {
        indexLabel.text = String(index) + "."
        titleLabel.text = music.name
        artistLabel.text = music.artist
        badgeURL = music.storeUrl
    }

    @IBAction func tappedBadge(_: Any) {
        let url = URL(string: badgeURL)
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
}
