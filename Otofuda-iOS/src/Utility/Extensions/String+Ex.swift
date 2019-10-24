import Foundation

extension String {
    // ランダムな文字列の生成
    static func getRandomStringWithLength(length: Int) -> String {
        let alphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.count)
        return String((0..<length).map { _ -> Character in
            alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
        })
    }

}
