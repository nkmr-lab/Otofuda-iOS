import AVFoundation
import UIKit

extension ResultVC: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        tableCellHeight
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMusic = playMusics[indexPath.row]
        //        playMusic(music: selectedMusic)　// 自分の曲以外は再生できないのでとりあえず機能として外しておく
        if usingMusicMode == .preset {
            avPlayer = AVPlayer(url: URL(string: selectedMusic.previewURL!)!)
            avPlayer.volume = 1.0
            avPlayer.play()
        }
    }
}
