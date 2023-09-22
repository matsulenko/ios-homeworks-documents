//
//  SceneDelegate.swift
//  Documents
//
//  Created by Matsulenko on 01.09.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        let fileManagerVC = FileManagerViewController(loggedIn: false)
        let settingsVC = SettingsViewController()
        
        fileManagerVC.tabBarItem = UITabBarItem(title: "Cписок файлов", image: UIImage(systemName: "folder.fill"), tag: 0)
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 1)
        let controllers = [fileManagerVC, settingsVC]
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = controllers.map {
            UINavigationController(rootViewController: $0)
        }
        tabBarController.selectedIndex = 0
        tabBarController.tabBar.tintColor = .systemBlue
        
        window?.rootViewController = tabBarController
                
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}

