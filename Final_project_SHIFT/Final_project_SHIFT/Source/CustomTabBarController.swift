//
//  TabBarController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

class CustomTabBarController {
    func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = Resources.Colors.TabBar.backgroundColor
        
        let watchlistAssembly = WatchlistModuleAssembly()
        let watchlistModule = watchlistAssembly.createModule()
        watchlistModule.tabBarItem = UITabBarItem(title: Resources.Strings.TabBar.home, image: Resources.Images.TabBar.home, selectedImage: nil)
        
        let searchAssembly = SearchAssembly()
        let searchModule = searchAssembly.createModule()
        searchModule.tabBarItem = UITabBarItem(title: Resources.Strings.TabBar.search, image: Resources.Images.TabBar.search, selectedImage: nil)
        
        let watchlistNavigationController = UINavigationController(rootViewController: watchlistModule)
        let searchNavigationController = UINavigationController(rootViewController: searchModule)
        
        tabBarController.setViewControllers([watchlistNavigationController, searchNavigationController], animated: false)
        
        return tabBarController
    }
}

