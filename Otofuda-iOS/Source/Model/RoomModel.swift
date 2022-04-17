import Foundation
import OtofudaExtension
import OtofudaResource
import UIKit

enum RoomStatus: String {
    case menu
    case start
    case play
    case next
    case result
}

struct Room {
    var name: String
    var member: [UserModel] = []
    var status: RoomStatus = .menu
    var mode: [String: String] = [
        "playback": PlaybackMode.intro.rawValue,
        "score": ScoreMode.normal.rawValue,
        "usingMusic": UsingMusicMode.preset.rawValue,
        "cardCount": CardCountMode.fourAndFour.text,
    ]

    /// 探す画面のQRコードで表示するもの
    var qrUrl: String {
        return Urls.searchRoom.rawValue + "?roomID=\(name)"
    }

    /// QRコードのUIImage
    var qrImage: UIImage? {
        guard let qrImage = CIImage.generateQRImage(url: qrUrl) else { return nil }
        return UIImage(ciImage: qrImage)
    }

    init(name: String) {
        self.name = name
        member = []
    }

    init(name: String, member: [UserModel]) {
        self.name = name
        self.member = member
    }

    mutating func setMember(member: [UserModel]) {
        self.member = member
    }

    mutating func addMember(user: UserModel) {
        member.append(user)
    }

    func dict() -> [String: Any] {
        var dict = [String: Any]()
        var userArray: [String] = []

        for user in member {
            userArray.append(user.id)
        }

        dict = ["name": name, "member": userArray, "mode": mode, "status": status.rawValue]
        return dict
    }

    func url() -> String {
        "rooms/" + name + "/"
    }
}
