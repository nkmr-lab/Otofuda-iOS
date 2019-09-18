
import Foundation
import AVFoundation

extension SearchGroupVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        
        // 複数のメタデータを検出できる
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRコードのデータかどうかの確認
            if metadata.type == AVMetadataObject.ObjectType.qr {
                // 検出位置を取得
                let barCode = videoLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
                let box = CGRect(
                    x: barCode.bounds.minX,
                    y: barCode.bounds.minY,
                    width: barCode.bounds.width,
                    height: barCode.bounds.height
                )
                qrV!.frame = box
                
                if metadata.stringValue != nil {
                    // 検出データを取得
                    let strMetadata = metadata.stringValue!
                    print(strMetadata)
                }
            }
        }
    }
    
}
