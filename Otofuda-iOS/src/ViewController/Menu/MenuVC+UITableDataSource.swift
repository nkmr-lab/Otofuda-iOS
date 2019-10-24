import UIKit

extension MenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMusics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let music = selectedMusics[indexPath.row]
        let cell = selectMusicTableV.dequeueReusableCell(
            with: SelectMusicTableCell.self,
            for: indexPath
        )
        cell.prepareLabel(music: music)

        return cell
    }

}
