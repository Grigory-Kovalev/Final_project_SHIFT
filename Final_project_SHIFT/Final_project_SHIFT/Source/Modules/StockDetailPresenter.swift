//
//  StockDetailPresenter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation

protocol StockDetailPresenterProtocol {
    func isFavoriteTicker(_ ticker: String) -> Bool?
}

final class StockDetailPresenter {
    
    // MARK: - Properties
    weak var viewController: StockDetailVCProtocol?
    private let storageManager: PersistentStorageService
    
    // MARK: - Init
    init(view: StockDetailVCProtocol, persistentStorageManager: PersistentStorageService) {
        self.viewController = view
        self.storageManager = persistentStorageManager
    }
}

extension StockDetailPresenter: StockDetailPresenterProtocol {
    func isFavoriteTicker(_ ticker: String) -> Bool? {
        return storageManager.isStockFavorite(ticker: self.viewController.)
    }
    
    
}

