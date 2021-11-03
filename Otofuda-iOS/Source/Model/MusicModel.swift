import AVFoundation
import Foundation
import MediaPlayer
import OtofudaEntity

public final class MusicModel: NSObject {
    public private(set) var name: String
    public private(set) var artist: String?
    public private(set) var type: MusicType = .mpmusic
    public private(set) var avPlayer: AVPlayer?
    public private(set) var avItem: AVPlayerItem?
    public private(set) var mpMusicPlayer: MPMusicPlayerController?
    public private(set) var mpItem: MPMediaItem?

    public var previewUrl: String?
    public var storeUrl: String?
    public var musicOwner: Int?
    public var cardOwner: Int?
    public var isTapped: Bool = false
    public var isAnimating: Bool = false

    init(entity: MusicResponse) {
        name = entity.title
        artist = entity.artist
        previewUrl = entity.previewURL
        storeUrl = entity.storeURL
        type = .avaudio
        if let previewUrlString = previewUrl,
           let previewUrl = URL(string: previewUrlString)
        {
            avItem = AVPlayerItem(url: previewUrl)
            avPlayer = AVPlayer(playerItem: avItem)
        }
    }

    init(name: String, artist: String, item: MPMediaItem) {
        self.name = name
        self.artist = artist
        mpItem = item
    }

    public func dict() -> [String: Any] {
        return [
            "name": name,
            "artist": artist ?? "なし",
            "musicOwner": musicOwner ?? 0,
            "previewURL": previewUrl ?? NSNull(),
            "storeURL": storeUrl ?? "no url",
        ]
    }

    public func play() {
        switch type {
        case .mpmusic:
            guard let mpMusicPlayer = mpMusicPlayer else { return }
            mpMusicPlayer.play()
        case .avaudio:
            guard let avPlayer = avPlayer else { return }
            avPlayer.play()
        }
    }

    public enum MusicType {
        case mpmusic
        case avaudio
    }
}
