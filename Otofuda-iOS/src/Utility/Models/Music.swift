import Foundation
import MediaPlayer
import AVFoundation

class Music: NSObject {

    var name: String!

    var artist: String!

    var item: MPMediaItem!

    var previewURL: String!

    var storeURL: String!

    var isAnimating: Bool = false

    var isTapped: Bool = false

    var avPlayer: AVPlayer!

    var mpmusicPlayer: MPMusicPlayerController!

    var type: MusicType = .mpmusic

    var musicOwner: Int!

    var cardOwner: Int!

    init(name: String, artist: String, item: MPMediaItem!) {
        self.name = name
        self.artist = artist
        self.item = item
    }

    init(name: String, artist: String, item: AVPlayerItem!) {
        self.name = name
        self.artist = artist
        self.avPlayer = AVPlayer(playerItem: item)
    }

    func dict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict = ["name": name ?? "なし", "artist": artist ?? "なし", "musicOwner": musicOwner ?? 0, "previewURL": previewURL, "storeURL": storeURL]
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
        case .mpmusic:
            mpmusicPlayer.play()
        case .avaudio:
            avPlayer.play()
        }
//        self.player.play()
    }
    
}

enum MusicType {
    case mpmusic
    case avaudio
}
