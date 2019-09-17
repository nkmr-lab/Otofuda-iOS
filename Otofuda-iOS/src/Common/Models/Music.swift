
import Foundation
import MediaPlayer

struct Music {
    var name: String!
    var item: MPMediaItem!
    
    init(name: String, item: MPMediaItem){
        self.name = name
        self.item = item
    }
    
    func dict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        return dict
    }
}
