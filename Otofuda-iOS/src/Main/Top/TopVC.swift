import UIKit
import MediaPlayer

protocol TopProtocol {
    func requestAuth()
    func loadMusics()
}

final class TopVC: UIViewController, TopProtocol {

    // MARK: - Properties
    var haveMusics: [Music] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuth()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func requestAuth() {
        MPMediaLibrary.requestAuthorization { status in
            if status == .authorized {
                self.loadMusics()
            } else {
                // denyされているときの処理を書く
                self.loadMusics()
            }
        }
    }

    func loadMusics() {

        let songsQuery = MPMediaQuery.songs()

        // 一曲もなければリターンする
        guard let songs = songsQuery.collections else {
            return
        }

        var musics: [MPMediaItem] = []
        let albumsQuery = MPMediaQuery.albums()
        if let albums = albumsQuery.collections {
            for album in albums {
                for song in album.items {
                    musics.append(song)
                    haveMusics.append(Music(name: song.title ?? "不明", item: song))
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "create":
            let nextVC = segue.destination as! CreateGroupVC
            nextVC.haveMusics = haveMusics
        case "search":
            let nextVC = segue.destination as! SearchGroupVC
            nextVC.haveMusics = haveMusics
        default:
            break
        }
    }

}
