
import UIKit
import AVFoundation

final class FudaCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var backgroundV: UIView!
    
    var isAnimating = false
    
    var tapSoundPlayer: AVAudioPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func soundTap(){
     
        do {
            tapSoundPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "otofuda_get", withExtension: "wav")!)
            tapSoundPlayer!.volume = 1.0
            tapSoundPlayer!.prepareToPlay()
            tapSoundPlayer!.play()
        } catch {
            print(error)
        }
    }
    
    func animate(){
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(Double.pi / 180) * 360
        rotationAnimation.duration = 0.3
        rotationAnimation.repeatCount = 5
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}
