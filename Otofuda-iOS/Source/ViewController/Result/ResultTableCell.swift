import UIKit

class ResultTableCell: UITableViewCell {

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeBtn: UIButton!
    var badgeURL: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func prepareLabel(index: Int, music: Music) {
        indexLabel.text = String(index) + "."
        titleLabel.text = music.name
        artistLabel.text = music.artist
        badgeURL = music.storeURL
    }
    
    @IBAction func tappedBadge(_ sender: Any) {
        let url = URL(string: badgeURL)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
}
