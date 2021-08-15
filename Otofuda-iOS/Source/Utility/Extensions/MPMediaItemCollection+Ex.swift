import Foundation
import MediaPlayer

extension MPMediaItemCollection {
    func musics() -> [Music] {
        var musics: [Music] = []
        for item in items {
            musics.append(item.music())
        }
        return musics
    }
}
