import AVFoundation
import UIKit

final class FudaCollectionCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var backgroundV: UIView!

    var isAnimating = false

    func animate() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(Double.pi / 180) * 360
        rotationAnimation.duration = 0.3
        rotationAnimation.repeatCount = 5
        layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}
