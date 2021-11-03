import UIKit

@IBDesignable
class IBDesignableButton: UIButton {
    @IBInspectable var borderColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 1.0
    @IBInspectable var cornerRadius: CGFloat = 5.0
    @IBInspectable var shadowOffset = CGSize(width: 0.0, height: 2.0)
    @IBInspectable var shadowColor = UIColor.black
    @IBInspectable var shadowOpacity: CGFloat = 0.7
    @IBInspectable var maskToBounds: Bool = true

    override func draw(_: CGRect) {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.shadowOffset = shadowOffset
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = Float(shadowOpacity)
        layer.masksToBounds = maskToBounds
    }
}
