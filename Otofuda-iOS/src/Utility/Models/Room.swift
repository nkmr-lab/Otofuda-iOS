import Foundation
import UIKit

enum RoomStatus: String {
    case menu   = "menu"
    case start  = "start"
    case play   = "play"
    case next   = "next"
    case result = "result"
}

struct Room {
    var name: String!
    var member: [User] = []
    var status: RoomStatus = .menu
    var mode: Dictionary<String, String> = [
        "playback": PlaybackMode.intro.rawValue,
        "score": ScoreMode.normal.rawValue
    ]

    init(name: String) {
        self.name = name
        self.member = []
    }

    init(name: String, member: [User]) {
        self.name = name
        self.member = member
    }
    
    mutating func setMember(member: [User]) {
        self.member = member
    }

    mutating func addMember(user: User) {
        self.member.append(user)
    }

    func dict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        var userArray: [String] = []

        for user in member {
            userArray.append(user.name)
        }

        dict = [ "name": name, "member": userArray, "mode": mode, "status": status.rawValue ]
        return dict
    }

    func url() -> String {
        return "rooms/" + name + "/"
    }
}
