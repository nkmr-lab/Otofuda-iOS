
import Foundation

extension Date {
    
    static func getCurrentDate() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M-d-H-m"
        return formatter.string(from: now)
    }
    
}
