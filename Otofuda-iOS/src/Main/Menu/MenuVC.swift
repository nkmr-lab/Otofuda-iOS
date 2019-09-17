
import UIKit

protocol Menurotocol {
}

enum RulePoint {
    case normal
    case othello
}

enum RulePlaying {
    case intro
    case sabi
    case random
}

final class MenuVC: UIViewController, Menurotocol {
    
    // ルール
    var rulePoint: RulePoint = .normal
    var rulePlaying: RulePlaying = .intro
    
    // Segument
    @IBOutlet weak var pointSegument: UISegmentedControl!
    @IBOutlet weak var playingSegument: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func changedPointSeg(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            rulePoint = .normal
        case 1:
            rulePoint = .othello
        default:
            break
        }
    }
    
    @IBAction func changePlayingSeg(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            rulePlaying = .intro
        case 1:
           rulePlaying = .sabi
        case 2:
            rulePlaying = .random
        default:
            break
        }
    }
    
}
