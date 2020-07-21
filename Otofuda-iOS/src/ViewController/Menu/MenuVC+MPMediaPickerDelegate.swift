import UIKit
import MediaPlayer

extension MenuVC: MPMediaPickerControllerDelegate {

    @IBAction func tappedPickBtn(_ sender: Any) {
        let picker = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = true // 複数選択可
        present(picker, animated: true, completion: nil)
    }

    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        selectedMusics = mediaItemCollection.musics()
        selectMusicTableV.reloadData()
        dismiss(animated: true, completion: nil)
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }

}
