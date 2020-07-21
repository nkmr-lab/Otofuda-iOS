import Foundation
import UIKit

extension CIImage {
    // QRコードを生成
    static func generateQRImage(url: String) -> CIImage {
        let data = url.data(using: String.Encoding.utf8)!
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])!
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        let qrImage = qr.outputImage!.transformed(by: sizeTransform)
        return qrImage
    }

}
