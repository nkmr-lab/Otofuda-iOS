import UIKit

extension ResultVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playMusics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let music = playMusics[indexPath.row]
        let cell = playedMusicTableV.dequeueReusableCell(
            with: ResultTableCell.self,
            for: indexPath
        )
        cell.prepareLabel(index: indexPath.row + 1, music: music)
        switch usingMusicMode {
        case .preset:
            cell.badgeBtn.isHidden = false
        case .device:
            cell.badgeBtn.isHidden = true
        }

        return cell
    }
}
