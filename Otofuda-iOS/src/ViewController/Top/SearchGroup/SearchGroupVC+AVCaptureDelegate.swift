import Foundation
import UIKit
import AVFoundation

extension SearchGroupVC: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

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
            
            let url  = cropURL(url: metadataStr)
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
