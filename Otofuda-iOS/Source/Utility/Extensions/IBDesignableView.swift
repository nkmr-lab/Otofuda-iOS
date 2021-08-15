import UIKit

// 右カラムのAttributes Inspectorで設定した値がリアルタイムで適用される
// classの前のここに書く
@IBDesignable

class IBDesignableView: UIView {
    // 今回はボタンの枠線の色，太さ，ボタンの角を丸める設定をいじってみる
    // 以下の変数宣言でこれらがデフォルトの値になる
    @IBInspectable var borderColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 1.0
    @IBInspectable var cornerRadius: CGFloat = 5.0
    @IBInspectable var shadowOffset = CGSize(width: 0.0, height: 2.0)
    @IBInspectable var shadowColor = UIColor.black
    @IBInspectable var shadowOpacity: CGFloat = 0.7
    @IBInspectable var maskToBounds: Bool = true

    // Attributes Inspectorで設定した値を反映
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
