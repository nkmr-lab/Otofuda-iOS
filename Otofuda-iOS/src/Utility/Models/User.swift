import Foundation

struct User {
    var name: String!
    var musics: [Music]
    var color: MyColor!

    func dict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict = ["name": name, "musics": "musics", "color": color.rawValue]
        return dict
    }
}
