import UIKit

extension MenuVC: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        selectedMusics.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let music = selectedMusics[indexPath.row]
        let cell = selectMusicTableV.dequeueReusableCell(
            with: SelectMusicTableCell.self,
            for: indexPath
        )
        cell.prepareLabel(music: music)

        return cell
    }
}
