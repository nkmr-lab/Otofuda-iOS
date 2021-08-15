import AVFoundation
import CoreData
import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let uuid: String = UIDevice.current.identifierForVendor!.uuidString
    var connectedRef: DatabaseReference? = nil
    var isOnline: Bool = false

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // 接続状態の変化を監視する
        self.connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef?.observe(.value, with: { [weak self] snapshot in
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

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient)
        } catch {
            print("error:", error)
        }
        return true
    }

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Otofuda-iOS")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
