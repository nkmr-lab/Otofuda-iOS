import Foundation
import UIKit

public extension CIImage {
    // QRコードを生成
    static func generateQRImage(url: String) -> CIImage? {
        guard let data = url.data(using: String.Encoding.utf8),
              let ciFilter = CIFilter(name: "CIQRCodeGenerator",
                                      parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])
        else { return nil }
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        let qrImage = ciFilter.outputImage?.transformed(by: sizeTransform)
        return qrImage
    }
}
