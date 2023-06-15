//
//  StockDetailPresenter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation
import SwiftUI

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
    
    func getCandles(candles: Candles) -> [CandleChartModel] {
        var candleArray = [ CandleChartModel]()
        
        let firstCandleColor: Color = .green
        let firstCandle = CandleChartModel(close: candles.c[0], high: candles.h[0], low: candles.l[0], open: candles.o[0], timestamp: candles.t[0], volume: candles.v[0], color: firstCandleColor)
        candleArray.append(firstCandle)
        
        for index in 1..<candles.c.count {
            let previousCandle = candleArray[index-1]
            let currentCandleColor: Color = candles.c[index] > previousCandle.close ? .green : .red
            
            let candle = CandleChartModel(close: candles.c[index], high: candles.h[index], low: candles.l[index], open: candles.o[index], timestamp: candles.t[index], volume: candles.v[index], color: currentCandleColor)
            candleArray.append(candle)
        }
        return candleArray
    }
    
    func getStockDetailViewModel() -> (selectedResolution: Int, data: [CandleChartModel], stock: StockDetailModel) {
        let selectedResolution = stockDetailModel.currentRange.getTag()
        let data = getCandles(candles: stockDetailModel.candles)
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

