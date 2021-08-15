import AVFoundation
import UIKit

protocol SearchGroupProtocol {
    func readQRCode()
    func enterRoom(room: Room)
    func observeRooms()
}

class SearchGroupVC: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var cameraV: UIView!

    // MARK: - Properties

    var qrV: UIView!

    var haveMusics: [Music] = []

    var items: [String] = []

    let captureSession = AVCaptureSession()

    var videoLayer: AVCaptureVideoPreviewLayer?

    var firebaseManager = FirebaseManager()

    // swiftlint:disable:next force_cast
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:disable:previous force_cast

    var isMatching = false

    var rooms: [Room] = []

    var me: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        observeRooms()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        readQRCode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firebaseManager.deleteObserve(path: RoomURL.base.rawValue)
    }
}
