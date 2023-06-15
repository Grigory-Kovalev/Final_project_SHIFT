//
//  StockDetailAssembly.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import UIKit

protocol StockDetailAssemblyProtocol {
    func createModule(with model: StockDetailModel) -> UIViewController
}

class StockDetailAssembly: StockDetailAssemblyProtocol {
    let storageManager = PersistentStorageService()
    
    func createModule(with model: StockDetailModel) -> UIViewController {
        let view = StockDetailViewController(stockDetailModel: model)
        let presenter = StockDetailPresenter(view: view, persistentStorageManager: storageManager)
        
        // Установка зависимостей
        view.presenter = presenter
        presenter.viewController = view
        
        return view
    }
}


