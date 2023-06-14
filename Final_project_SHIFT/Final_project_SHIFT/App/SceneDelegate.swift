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
        
        let watchlistAssembly = WatchlistModuleAssembly()
        let watchlistModule = watchlistAssembly.createModule()

        watchlistModule.tabBarItem = UITabBarItem(title: Resources.Strings.TabBar.home, image: Resources.Images.TabBar.home, selectedImage: nil)
        let SearchVC = SearchViewController()
        SearchVC.tabBarItem = UITabBarItem(title: Resources.Strings.TabBar.search, image: Resources.Images.TabBar.search, selectedImage: nil)
        
        let WatchlistNavigationController = UINavigationController(rootViewController: watchlistModule)
        let SearchNavigationController = UINavigationController(rootViewController: SearchVC)
        
        tabBarController.setViewControllers([WatchlistNavigationController, SearchNavigationController], animated: false)
        
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

