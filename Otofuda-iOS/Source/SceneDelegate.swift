//
//  SceneDelegate.swift
//  Otofuda-iOS
//
//  Created by 新納真次郎 on 2020/07/09.
//  Copyright © 2020 新納真次郎. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        window.makeKeyAndVisible()

        let appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
    }

    func sceneDidDisconnect(_: UIScene) {
        // TODO: Firebaseのremove処理
    }

    func sceneDidBecomeActive(_: UIScene) {}

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
