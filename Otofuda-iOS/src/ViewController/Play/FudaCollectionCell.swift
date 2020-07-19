import UIKit
import AVFoundation

final class FudaCollectionCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var backgroundV: UIView!

    var isAnimating = false

    func animate() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(Double.pi / 180) * 360
        rotationAnimation.duration = 0.3
        rotationAnimation.repeatCount = 5
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}
