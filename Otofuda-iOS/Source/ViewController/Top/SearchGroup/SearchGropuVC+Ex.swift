import Foundation
import UIKit
import AVFoundation

extension SearchGroupVC: SearchGroupProtocol {

    func readQRCode() {

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
            width:  UIScreen.main.bounds.size.width,
            height:  UIScreen.main.bounds.size.width
        )
        videoLayer?.frame = box
        videoLayer?.videoGravity = .resizeAspectFill //短い方に合わせてアスペクト比を調整してくれる
        cameraV.layer.addSublayer(videoLayer!)

        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
        }
    }
    
    func enterRoom(room: Room) {
        if !isMatching {
            let current_date = Date.getCurrentDate()
            
            firebaseManager.post(path: room.url() + "date", value: current_date)
            
            let uuid = UIDevice.current.identifierForVendor!.uuidString
            
            firebaseManager.observeSingle(path: room.url() + "member", completion: { [weak self] (snapshot) in
                guard let self = self else { return }

                var isExist: Bool = false
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
                        self.me = User(index: member.count, name: self.appDelegate.uuid, color: COLORS[ member.count])
                        member.append( self.appDelegate.uuid )

                        var users: [User] = []
                        for (index, user) in member.enumerated() {
                            users.append( User(index: index, name: user, color: COLORS[index]) )
                        }
                        let updatedRoom = Room(name: room.name, member: users)

                        self.firebaseManager.post(path: room.url() + "member", value: member)
                        self.goNextVC(room: updatedRoom) // FIXME: 🐛たまに重複してnavigationに追加されることがある(8/3時点）
                        self.isMatching = true
                        return
                    }
                }
            })
            
        }
    }

    // https://uniotto.org/api/searchRoom.php?roomID=XXXXX → XXXXX にする
    func cropURL(url: String) -> String {
        let separatedURL: [String] = url.components(separatedBy: "=")
        let roomID: String = separatedURL[1]
        return roomID
    }

    func goNextVC(room: Room) {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let nextVC = storyboard.instantiateInitialViewController() as! MenuVC
        nextVC.modalTransitionStyle = .crossDissolve
        nextVC.room = room // TODO: メンバーを更新したRoomにする
        nextVC.haveMusics = self.haveMusics
        nextVC.isHost = false
        nextVC.me = me
        navigationController?.pushViewController(nextVC, animated: true)

        firebaseManager.deleteObserve(path: RoomURL.base.rawValue)
    }
    
    func observeRooms(){
        firebaseManager.observe(path: RoomURL.base.rawValue, completion: { [weak self] snapshot in
            guard let self = self else { return }

            if let dbRooms = snapshot.value as? Dictionary<String, Any> {
                self.rooms = []
                
                for dbRoom in dbRooms.keys {
                    
                    guard let roomDict = dbRooms[dbRoom] as? Dictionary<String, Any>,
                          let roomName = roomDict["name"] as? String,
                          let member = roomDict["member"] as? [String] else {
                            continue
                    }

                    var users: [User] = []
                    for (index, user) in member.enumerated() {
                        users.append( User(index: index, name: user, color: COLORS[index]) )
                    }
                    
                    self.rooms.append(Room(name: roomName, member: users))
                }
            }
        })
    }

}
