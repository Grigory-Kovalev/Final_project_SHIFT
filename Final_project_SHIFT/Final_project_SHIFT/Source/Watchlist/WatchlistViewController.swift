//
//  WatchlistViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

final class WatchlistViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        //tabBar
        tabBarItem = UITabBarItem(title: Resources.Strings.TabBar.home, image: Resources.Images.TabBar.home, selectedImage: nil)
        tabBarController?.tabBar.unselectedItemTintColor = .systemGray
        tabBarController?.tabBar.tintColor = .label
        
        
        //Nav
        navigationItem.title = "Watchlist"
        let attributes: [NSAttributedString.Key: Any] = [
            //.font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: Resources.Colors.green
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes

    }
    
//    override func loadView() {
//        
//    }
}
