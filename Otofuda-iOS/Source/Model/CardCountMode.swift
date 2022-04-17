import Foundation

enum CardCountMode: CaseIterable {
    case twoAndTwo
    case threeAndThree
    case fourAndFour

    var text: String {
        switch self {
        case .twoAndTwo:
            return "2x2"
        case .threeAndThree:
            return "3x3"
        case .fourAndFour:
            return "4x4"
        }
    }
}
