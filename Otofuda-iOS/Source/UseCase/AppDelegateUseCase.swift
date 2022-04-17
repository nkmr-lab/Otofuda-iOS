
import Foundation
import Firebase

public final class AppDelegateUseCase {

    public var connectedRef: DatabaseReference

    public var isOnline: Bool = false

    public init() {
        self.connectedRef = Database
            .database()
            .reference(withPath: ".info/connected")
    }

    /// 接続状態の変化を監視するメソッド
    public func observeConnectRef() {
        connectedRef.observe(.value, with: { [weak self] snapshot in
            guard let isConnected = snapshot.value as? Bool else { return }
            if isConnected {
                // TODO: 接続復活した時の処理
                EmojiLogger.info("Connected to Firebase Realtime Database!")
                self?.isOnline = isConnected
            } else {
                // TODO: 接続切れたた時の処理
                // アラート出したりする
                EmojiLogger.info("Disconnected to Firebase Realtime Database!")
            }
        })
    }


}
