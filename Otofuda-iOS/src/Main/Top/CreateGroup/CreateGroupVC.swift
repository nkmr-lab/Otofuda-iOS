
import UIKit
import FirebaseDatabase

protocol CreateGropuProtocol {
    func generateQRCode(name: String)
}

class CreateGroupVC: UIViewController, CreateGropuProtocol {
    
    @IBOutlet weak var QRView: UIImageView!
    
    var room: Room!
    
    var firebaseManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let roomId = createGroup()
        generateQRCode(name: roomId)
    }
    
    func createGroup() -> String {
        let roomID = String.getRandomStringWithLength(length: 6)
        room = Room(name: roomID)
        firebaseManager.post(path: room.url(), value: room.dict() )
        return roomID
    }
    
    func generateQRCode(name: String) {
        let qrImage = CIImage.generateQRImage(url: "https://uniotto.org/api/searchRoom.php?roomID=\(name)")
        QRView.image = UIImage(ciImage: qrImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! MenuVC
        nextVC.room = room
    }

}


