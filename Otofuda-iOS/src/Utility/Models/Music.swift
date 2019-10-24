import Foundation
import MediaPlayer

class Music: NSObject {

    var name: String!
    var item: MPMediaItem!
    var isAnimating: Bool = false
    var isTapped: Bool = false

    init(name: String, item: MPMediaItem!) {
        self.name = name
        self.item = item
    }

    func dict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict = ["name": name ?? "なし", "artist": item.artist ?? "なし", "genere": item.genre ?? "なし"]
        return dict
    }
    
}
