import Foundation
import MediaPlayer
import AVFoundation

class Music: NSObject {

    var name: String!
    var artist: String!
    var item: MPMediaItem!
    var previewURL: String!
    var isAnimating: Bool = false
    var isTapped: Bool = false
    var avPlayer: AVPlayer!
    var mpmediaPlayer: AVPlayer!
    var type: MusicType = .mpmedia
    var musicOwner: Int!
    var cardOwner: Int!

    init(name: String, artist: String, item: MPMediaItem!) {
        self.name = name
        self.artist = artist
        self.item = item
    }

    func dict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict = ["name": name ?? "なし", "artist": artist ?? "なし", "musicOwner": musicOwner ?? 0, "previewURL": previewURL]
        return dict
    }

    // MPMediaItem用
    func set(item: MPMediaItem){
        self.item = item
    }

    // AVAudio用
    func set(previewURL: String){
        self.previewURL = previewURL
        self.avPlayer = AVPlayer(url: URL(string: previewURL)!)
    }

    func play(){
        switch type {
        case .mpmedia:
            mpmediaPlayer.play()
        case .avaudio:
            avPlayer.play()
        }
//        self.player.play()
    }
    
}

enum MusicType {
    case mpmedia
    case avaudio
}
