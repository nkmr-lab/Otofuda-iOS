import UIKit

extension ResultVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMusic = playMusics[indexPath.row]
//        playMusic(music: selectedMusic)　// 自分の曲以外は再生できないのでとりあえず機能として外しておく
    }

}
