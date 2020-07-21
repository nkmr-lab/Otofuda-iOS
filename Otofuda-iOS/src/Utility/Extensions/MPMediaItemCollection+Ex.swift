import Foundation
import MediaPlayer

extension MPMediaItemCollection {
    func musics() -> [Music] {
        var musics: [Music] = []
        for item in self.items {
            musics.append(item.music())
        }
        return musics
    }
}
