import UIKit

extension ResultVC: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        playMusics.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
