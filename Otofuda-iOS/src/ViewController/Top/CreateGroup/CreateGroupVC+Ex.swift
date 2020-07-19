
import UIKit

extension CreateGroupVC {
    
    func createGroup() -> String {
        let roomID = String.getRandomStringWithLength(length: 6)
        let current_date = Date.getCurrentDate()
        room = Room(name: roomID)
        room.addMember(user: me)
        firebaseManager.post(path: room.url(), value: room.dict() )
        firebaseManager.post(path: room.url() + "date", value: current_date)
        return roomID
    }
    
    func generateQRCode(name: String) {
        let qrImage = CIImage.generateQRImage(url: "https://uniotto.org/api/searchRoom.php?roomID=\(name)")
        qrView.image = UIImage(ciImage: qrImage)
    }
    
    func observeMember(){
        firebaseManager.observe(path: room.url() + "member", completion: { [weak self] snapshot in

            // deinitを呼びたいので強参照させないようにしている
            guard let wself = self else {
                return
            }

            guard let member = snapshot.value as? [String] else {
                return
            }
            
            wself.member = []
            for i in 0..<member.count {
                let user = member[i]
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                let myColor = COLORS[i]
                
                wself.member.append(User(index: i, name: user, color: myColor))
            }
        })
    }
    
    func removeObserveMember(){
        firebaseManager.deleteObserve(path: room.url() + "member")
    }
    
}
