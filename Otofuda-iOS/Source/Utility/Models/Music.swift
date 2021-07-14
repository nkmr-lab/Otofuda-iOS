import Foundation
import MediaPlayer
import AVFoundation

class Music: NSObject {

    var name: String

    var artist: String?

    var item: MPMediaItem?

    var previewURL: String?

    var storeURL: String?

    var isAnimating: Bool = false

    var isTapped: Bool = false

    var avPlayer: AVPlayer?

    var mpmusicPlayer: MPMusicPlayerController?

    var type: MusicType = .mpmusic

    var musicOwner: Int?

    var cardOwner: Int?

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
        let dict = [
            "name": name,
            "artist": artist ?? "なし",
            "musicOwner": musicOwner ?? 0,
            "previewURL": previewURL ?? "no url",
            "storeURL": storeURL ?? "no url"
        ] as [String : Any]
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
            guard let mpmusicPlayer = mpmusicPlayer else { return }
            mpmusicPlayer.play()
        case .avaudio:
            guard let avPlayer = avPlayer else { return }
            avPlayer.play()
        }
    }
    
}

enum MusicType {
    case mpmusic
    case avaudio
}
