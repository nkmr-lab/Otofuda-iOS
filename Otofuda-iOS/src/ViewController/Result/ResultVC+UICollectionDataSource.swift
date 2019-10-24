import UIKit

extension ResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playingMusics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let music = playingMusics[indexPath.row]
        let cell = playedMusicTableV.dequeueReusableCell(
            with: ResultTableCell.self,
            for: indexPath
        )
        cell.prepareLabel(index: indexPath.row + 1, music: music)

        return cell
    }
}
