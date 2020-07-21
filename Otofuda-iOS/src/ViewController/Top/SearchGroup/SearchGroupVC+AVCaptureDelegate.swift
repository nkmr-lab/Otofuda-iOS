import Foundation
import UIKit
import AVFoundation

extension SearchGroupVC: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        guard let metadataObjects = metadataObjects as? [AVMetadataMachineReadableCodeObject] else {
            return
        }
        
        for metadataObj in metadataObjects {
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
                x: barCode.bounds.minX,
                y: barCode.bounds.minY + 150,
                width: barCode.bounds.width,
                height: barCode.bounds.height
            )
            
            qrV.frame = box
            
            for room in rooms {
                if room.name == qrRoom.name {
                    // マッチング!!!
                    enterRoom(room: qrRoom)
                    continue
                }
            }
            
        }
        
    }
    
    
}
