import UIKit
import MediaPlayer
import Alamofire
import SwiftyJSON

protocol TopProtocol {
    func requestAuth()
    func loadMusics()
}

struct iTunesTopRSSResponse: Codable {
    var feed: iTunesTopRSSFeed
}

struct iTunesTopRSSFeed: Codable {
    var results: [iTunesTopMusic]
}

struct iTunesTopMusic: Codable {
    var artistName: String
    var name: String
}


final class TopVC: UIViewController, TopProtocol {

    // MARK: - Properties
    var haveMusics: [Music] = []
    
    var firebaseManager = FirebaseManager()
    
    var me: User!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let myColor: UIColor = COLORS[0]
        me = User(index: 0, name: appDelegate.uuid, color: myColor)

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
        var musics: [MPMediaItem] = []
        let albumsQuery = MPMediaQuery.albums()
        if let albums = albumsQuery.collections {
            for album in albums {
                for song in album.items {
                    musics.append(song)
                    haveMusics.append(Music(name: song.title ?? "不明", artist: song.artist ?? "不明",  item: song))
                }
            }
        }
    }
    
    func createGroup() -> Room {
        let roomID = String.getRandomStringWithLength(length: 6)
        let current_date = Date.getCurrentDate()
        
        var room = Room(name: roomID)
        room.addMember(user: me)
        firebaseManager.post(path: room.url(), value: room.dict() )
        firebaseManager.post(path: room.url() + "date", value: current_date)
        
        return room
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "single":
            let nextVC = segue.destination as! MenuVC
            nextVC.isSingleMode = true
            nextVC.room = createGroup()
            nextVC.isHost = true
            nextVC.haveMusics = self.haveMusics
            nextVC.me = me

            navigationController?.setNavigationBarHidden(false, animated: false)
        case "multi":
            let nextVC = segue.destination as! SearchGroupVC
            nextVC.haveMusics = haveMusics
        default:
            break
        }
    }

}
