import UIKit
import FirebaseDatabase

protocol CreateGropuProtocol {
    func createGroup() -> String
    func generateQRCode(name: String)
}

class CreateGroupVC: UIViewController, CreateGropuProtocol {

    // MARK: - IBOutlets
    
    @IBOutlet weak var qrView: UIImageView!

    @IBOutlet weak var memberCountLabel: UILabel! {
        didSet {
            memberCountLabel.text = "現在の人数　　1　　人"
        }
    }

    // MARK: - Properties
    
    var firebaseManager = FirebaseManager()

    var haveMusics: [Music] = []

    var room: Room!
    
    var member: [User] = []

    var me: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: ネットワークに繋がっているかの確認をラベルで表示

        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let myColor: UIColor = COLORS[0]
        me = User(index: 0, name: appDelegate.uuid, color: myColor)

        let roomId = createGroup()
        generateQRCode(name: roomId)
        observeMember()
  
    }
    
    deinit {
        firebaseManager.deleteAllValue(path: room.url())
        removeObserveMember()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! MenuVC
        room.setMember(member: member)
        nextVC.room = room
        nextVC.isHost = true
        nextVC.haveMusics = self.haveMusics
        nextVC.me = me
        removeObserveMember()
    }
    
    
}
