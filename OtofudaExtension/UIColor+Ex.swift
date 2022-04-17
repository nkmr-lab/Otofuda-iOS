import UIKit

extension UIColor {
    static func string(color: UIColor) -> String {
        switch color {
        case .black:
            return "black"
        case .darkGray:
            return "darkGray"
        case .blue:
            return "blue"
        default:
            break
        }
        return "none"
    }

    //        open class var black: UIColor { get } // 0.0 white
    //
    //        open class var darkGray: UIColor { get } // 0.333 white
    //
    //        open class var lightGray: UIColor { get } // 0.667 white
    //
    //        open class var white: UIColor { get } // 1.0 white
    //
    //        open class var gray: UIColor { get } // 0.5 white
    //
    //        open class var red: UIColor { get } // 1.0, 0.0, 0.0 RGB
    //
    //        open class var green: UIColor { get } // 0.0, 1.0, 0.0 RGB
    //
    //        open class var blue: UIColor { get } // 0.0, 0.0, 1.0 RGB
    //
    //        open class var cyan: UIColor { get } // 0.0, 1.0, 1.0 RGB
    //
    //        open class var yellow: UIColor { get } // 1.0, 1.0, 0.0 RGB
    //
    //        open class var magenta: UIColor { get } // 1.0, 0.0, 1.0 RGB
    //
    //        open class var orange: UIColor { get } // 1.0, 0.5, 0.0 RGB
    //
    //        open class var purple: UIColor { get } // 0.5, 0.0, 0.5 RGB
    //
    //        open class var brown: UIColor { get } // 0.6, 0.4, 0.2 RGB
    //    }
}
