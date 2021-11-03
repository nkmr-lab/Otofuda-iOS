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

    var haveMusics: [MusicModel] = []

    var items: [String] = []

    let captureSession = AVCaptureSession()

    var videoLayer: AVCaptureVideoPreviewLayer?

    // swiftlint:disable:next force_cast
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:disable:previous force_cast

    var isMatching = false

    var rooms: [Room] = []

    var me: UserModel!

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
        FirebaseManager.shared.deleteObserve(path: RoomURL.base.rawValue)
    }
}

extension SearchGroupVC {
    private func readQRCode() {
        // QRコードをマークするビュー
        qrV = UIView()
        qrV.layer.borderWidth = 4
        qrV.layer.borderColor = UIColor.red.cgColor
        qrV.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        view.addSubview(qrV)

        // 入力（背面カメラ）
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let videoInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)

        // 出力（メタデータ）
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)

        // QRコードを検出した際のデリゲート設定
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // QRコードの認識を設定
        metadataOutput.metadataObjectTypes = [.qr]

        // プレビュー表示
        videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let box = CGRect(
            x: cameraV.bounds.minX,
            y: cameraV.bounds.minY,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.width
        )
        videoLayer?.frame = box
        videoLayer?.videoGravity = .resizeAspectFill // 短い方に合わせてアスペクト比を調整してくれる
        cameraV.layer.addSublayer(videoLayer!)

        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
        }
    }

    private func enterRoom(room: Room) {
        if !isMatching {
            let current_date = Date.getCurrentDate()

            FirebaseManager.shared.post(path: room.url() + "date", value: current_date)

            let uuid = UIDevice.current.identifierForVendor!.uuidString

            FirebaseManager.shared.observeSingle(path: room.url() + "member", completion: { [weak self] snapshot in
                guard let self = self else { return }

                var isExist = false
                if let member = snapshot.value as? [String] {
                    for user in member {
                        if user == uuid {
                            isExist = isExist || true
                        }
                    }
                }

                if isExist {
                    self.goNextVC(room: room)
                    self.isMatching = true
                } else {
                    if var member = snapshot.value as? [String] {
                        self.me = UserModel(order: member.count)
                        member.append(self.appDelegate.uuid)

                        var users: [UserModel] = []
                        for (index, userId) in member.enumerated() {
                            users.append(UserModel(id: userId, order: index))
                        }
                        let updatedRoom = Room(name: room.name, member: users)

                        FirebaseManager.shared.post(path: room.url() + "member", value: member)
                        self.goNextVC(room: updatedRoom) // FIXME: 🐛たまに重複してnavigationに追加されることがある(8/3時点）
                        self.isMatching = true
                        return
                    }
                }
            })
        }
    }

    // https://uniotto.org/api/searchRoom.php?roomID=XXXXX → XXXXX にする
    private func cropURL(url: String) -> String {
        let separatedURL: [String] = url.components(separatedBy: "=")
        let roomID: String = separatedURL[1]
        return roomID
    }

    private func goNextVC(room: Room) {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let nextVC = storyboard.instantiateInitialViewController() as! MenuVC
        nextVC.modalTransitionStyle = .crossDissolve
        nextVC.room = room // TODO: メンバーを更新したRoomにする
        nextVC.haveMusics = haveMusics
        nextVC.isHost = false
        nextVC.me = me
        navigationController?.pushViewController(nextVC, animated: true)

        FirebaseManager.shared.deleteObserve(path: RoomURL.base.rawValue)
    }

    private func observeRooms() {
        FirebaseManager.shared.observe(path: RoomURL.base.rawValue, completion: { [weak self] snapshot in
            guard let self = self else { return }

            if let dbRooms = snapshot.value as? [String: Any] {
                self.rooms = []

                for dbRoom in dbRooms.keys {
                    guard let roomDict = dbRooms[dbRoom] as? [String: Any],
                          let roomName = roomDict["name"] as? String,
                          let member = roomDict["member"] as? [String]
                    else {
                        continue
                    }

                    var users: [UserModel] = []
                    for (index, userId) in member.enumerated() {
                        users.append(UserModel(id: userId, order: index))
                    }

                    self.rooms.append(Room(name: roomName, member: users))
                }
            }
        })
    }
}

extension SearchGroupVC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from _: AVCaptureConnection) {
        guard let metadataObjects = metadataObjects as? [AVMetadataMachineReadableCodeObject] else {
            return
        }

        for_meta: for metadataObj in metadataObjects {
            if metadataObj.type != AVMetadataObject.ObjectType.qr {
                continue
            }

            guard let metadataStr = metadataObj.stringValue else {
                continue
            }

            let url = cropURL(url: metadataStr)
            let qrRoom = Room(name: url)

            guard let barCode = videoLayer?.transformedMetadataObject(
                for: metadataObj
            ) as? AVMetadataMachineReadableCodeObject else {
                continue
            }

            let box = CGRect(
                x: barCode.bounds.minX + cameraV.frame.minX,
                y: barCode.bounds.minY + cameraV.frame.minY,
                width: barCode.bounds.width,
                height: barCode.bounds.height
            )

            qrV.frame = box

            for room in rooms {
                if room.name == qrRoom.name {
                    print("マッチング!!!") // FIXME: ここがどうやっても何度も出力されてしまう
                    enterRoom(room: qrRoom)
                    break for_meta
                }
            }
        }
    }
}
