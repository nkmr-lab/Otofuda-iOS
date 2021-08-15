import MediaPlayer
import UIKit

extension MenuVC: MPMediaPickerControllerDelegate {
    @IBAction func tappedPickBtn(_: Any) {
        let picker = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = true // 複数選択可
        present(picker, animated: true, completion: nil)
    }

    func mediaPicker(_: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        selectedMusics = mediaItemCollection.musics()
        selectMusicTableV.reloadData()
        dismiss(animated: true, completion: nil)
    }

    func mediaPickerDidCancel(_: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}
