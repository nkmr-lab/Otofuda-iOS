import Foundation
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
    var member: [User] = []
    var status: RoomStatus = .menu
    var mode: [String: String] = [
        "playback": PlaybackMode.intro.rawValue,
        "score": ScoreMode.normal.rawValue,
        "usingMusic": UsingMusicMode.preset.rawValue,
        "cardCount": CARD_COUNT_STRING,
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

    init(name: String, member: [User]) {
        self.name = name
        self.member = member
    }

    mutating func setMember(member: [User]) {
        self.member = member
    }

    mutating func addMember(user: User) {
        member.append(user)
    }

    func dict() -> [String: Any] {
        var dict = [String: Any]()
        var userArray: [String] = []

        for user in member {
            userArray.append(user.name)
        }

        dict = ["name": name, "member": userArray, "mode": mode, "status": status.rawValue]
        return dict
    }

    func url() -> String {
        "rooms/" + name + "/"
    }
}
