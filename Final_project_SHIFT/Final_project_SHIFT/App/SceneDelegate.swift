//
//  SceneDelegate.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 30.05.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        
        let tabBarController = UITabBarController()
        
        tabBarController.tabBar.backgroundColor = .secondarySystemFill
        
        let WatchlistVC = WatchlistViewController()
        let SearchVC = SearchViewController()
        
        let WatchlistNavigationController = UINavigationController(rootViewController: WatchlistVC)
        let SearchNavigationController = UINavigationController(rootViewController: SearchVC)
        
        tabBarController.setViewControllers([WatchlistNavigationController, SearchNavigationController], animated: true)
        
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

