//
//  SearchGroupViewController.swift
//  Otofuda-iOS
//
//  Created by nonaka on 2019/05/10.
//  Copyright © 2019 nkmr-lab. All rights reserved.
//

import UIKit
import AVFoundation

class SearchGroupVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var qrView: UIView!
    @IBOutlet weak var cameraView: UIView!
    var items: [String] = []
    let captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("サーチビューが起動されました")
        readQRCode()
    }

    func readQRCode() {
        // QRコードをマークするビュー
        qrView = UIView()
        qrView.layer.borderWidth = 4
        qrView.layer.borderColor = UIColor.red.cgColor
        qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        view.addSubview(qrView)

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
        let box = CGRect(x: cameraView.bounds.minX, y: cameraView.bounds.minY, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
        videoLayer?.frame = box
        videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill //短い方に合わせてアスペクト比を調整してくれる
        cameraView.layer.addSublayer(videoLayer!)

        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 複数のメタデータを検出できる

        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRコードのデータかどうかの確認
            if metadata.type == AVMetadataObject.ObjectType.qr {
                // 検出位置を取得
                let barCode = videoLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
                let box = CGRect(x: barCode.bounds.minX, y: barCode.bounds.minY + 150, width: (barCode.bounds.maxX - barCode.bounds.minX), height: barCode.bounds.maxY - barCode.bounds.minY)
                qrView!.frame = box

                if metadata.stringValue != nil {
                    // 検出データを取得
                    let strMetadata = metadata.stringValue!
                    print(strMetadata)
                }
            }
        }

    }

}
