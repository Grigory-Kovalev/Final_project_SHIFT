//
//  WatchlistAssembly.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import UIKit

protocol WatchlistModuleAssemblyProtocol {
    func createModule() -> UIViewController
}

class WatchlistModuleAssembly: WatchlistModuleAssemblyProtocol {
    let networkManager = NetworkService()
    let persistentStorageManager = PersistentStorageService()
    
    func createModule() -> UIViewController {
        let view = WatchlistViewController()
        let presenter = WatchlistPresenter(view: view, networkManager: networkManager, persistentStorageService: persistentStorageManager)
        
        // Установка зависимостей
        view.presenter = presenter
        presenter.viewController = view
        
        return view
    }
}
