import UIKit
import FirebaseDatabase

protocol CreateGropuProtocol {
    func createGroup() -> String
    func generateQRCode(name: String)
}

class CreateGroupVC: UIViewController, CreateGropuProtocol {

    // MARK: - IBOutlets
    
    @IBOutlet weak var qrView: UIImageView!

    // MARK: - Properties
    
    var firebaseManager = FirebaseManager()

    var haveMusics: [Music] = []

    var room: Room!
    
    var member: [User] = []
    
    private var myClosure: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        let roomId = createGroup()
        generateQRCode(name: roomId)
        observeMember()
    }
    
    deinit {
        print("であああああああああ")
        // FIXIME: ここが呼ばれないの！！！！！
        firebaseManager.deleteAllValue(path: room.url())
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
        removeObserveMember()
    }
    
    
}
