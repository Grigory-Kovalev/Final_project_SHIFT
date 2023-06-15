//
//  SearchModuleAssembly.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import UIKit

protocol SearchAssemblyProtocol {
    func createModule() -> UIViewController
}

class SearchAssembly: SearchAssemblyProtocol {
    let networkManager = NetworkService()
    
    func createModule() -> UIViewController {
        let view = SearchViewController()
        let presenter = SearchPresenter(view: view, networkManager: networkManager)
        
        // Установка зависимостей
        view.presenter = presenter
        presenter.viewController = view
        
        return view
    }
}
