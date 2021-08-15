
import Foundation
import UIKit.UIColor

public enum ColorList: Int, CaseIterable {
    case red = 0
    case blue = 1
    case green = 2
    case purple = 3
    case brown = 4
    case yellow = 5

    public init(index: Int) {
        switch index % ColorList.allCases.count {
        case ColorList.red.rawValue:
            self = .red
        case ColorList.blue.rawValue:
            self = .blue
        case ColorList.green.rawValue:
            self = .green
        case ColorList.purple.rawValue:
            self = .purple
        case ColorList.brown.rawValue:
            self = .brown
        case ColorList.yellow.rawValue:
            self = .yellow
        default:
            self = .red
        }
    }

    var uiColor: UIColor {
        switch self {
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        case .purple:
            return .purple
        case .brown:
            return .brown
        case .yellow:
            return .yellow
        }
    }
}
