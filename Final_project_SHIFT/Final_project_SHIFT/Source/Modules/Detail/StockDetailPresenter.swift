//
//  StockDetailPresenter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation

protocol StockDetailPresenterProtocol {
    func isFavoriteTicker() -> Bool?
    func getTicker() -> String
    func getStockDetailViewModel() -> (selectedResolution: Int, data: [CandleChartModel], stock: StockDetailModel)
    func deleteStock()
    func saveStock()
    func backButtonTapped()
}

final class StockDetailPresenter {
    
    // MARK: - Properties
    weak var viewController: StockDetailVCProtocol?
    let stockDetailModel: StockDetailModel
    private let storageManager: PersistentStorageService
    
    // MARK: - Init
    init(view: StockDetailVCProtocol, persistentStorageManager: PersistentStorageService, stockDetailModel: StockDetailModel) {
        self.viewController = view
        self.storageManager = persistentStorageManager
        self.stockDetailModel = stockDetailModel
    }
}

extension StockDetailPresenter: StockDetailPresenterProtocol {
        func backButtonTapped() {
            viewController?.popViewController()
    }
    
    
    func saveStock() {
        storageManager.saveStockToCoreData(ticker: stockDetailModel.symbol, name: stockDetailModel.companyName, logo: stockDetailModel.stockProfile.logo, currency: stockDetailModel.stockProfile.currency, price: stockDetailModel.candles.c.last ?? 0, isFavorite: true)
    }
    
    func deleteStock() {
        storageManager.deleteStockBy(ticker: stockDetailModel.symbol)
    }
    
    func getStockDetailViewModel() -> (selectedResolution: Int, data: [CandleChartModel], stock: StockDetailModel) {
        let selectedResolution = stockDetailModel.currentRange.getTag()
        let data = Candles.getCandles(candles: stockDetailModel.candles)
        let stock = stockDetailModel
        return (selectedResolution, data, stock)
    }
    
    func getTicker() -> String {
        return stockDetailModel.symbol
    }
    
    func isFavoriteTicker() -> Bool? {
        return storageManager.isStockFavorite(ticker: self.stockDetailModel.symbol)
    }
}

