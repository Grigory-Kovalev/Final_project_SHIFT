//
//  WatchlistInteractor.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import Foundation

protocol IWatchlistInteractor {
    func loadDataFromPersistentStorage()
    func connectToWebSocket()
    func subscribeToWebSocket(symbols: [String])
    func receiveDataFromWebSocket()
    func loadStockDetailModel(ticker: String)
    func unsubscribeFromWebSocket(symbols: [String])
}

class WatchlistInteractor {
    weak var presentor: IWatchlistPresenter?
    let persistentStorageService = PersistentStorageService()
    let networkManager = NetworkService()

}

extension WatchlistInteractor: IWatchlistInteractor {

    func loadDataFromPersistentStorage() {
        var stocks = persistentStorageService.loadStocksFromCoreData()
        //Sort stocks alphabetically
        stocks?.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        self.presentor?.didLoadDataFromPersistentStorage(stocks: stocks)
    }
    
    func connectToWebSocket() {
        WSManager.shared.connectToWebSocket()
        self.presentor?.didConnectToWebSocket()
    }
    
    func subscribeToWebSocket(symbols: [String]) {
        WSManager.shared.subscribeTo(symbols: symbols)
        self.presentor?.didSubscribeToWebSocket()
    }
    
    func receiveDataFromWebSocket() {
        WSManager.shared.receiveData { [weak self] data in
            self?.presentor?.didReceiveDataFromWebSocket(data: data)
        }
    }
    
    func loadStockDetailModel(ticker: String) {
        networkManager.fetchStockProfile(symbol: ticker) { [weak self] result in
            switch result {
            case .success(let stockProfile):
                self?.networkManager.fetchStockCandles(symbol: ticker, timeFrame: .weekend) { result in
                    switch result {
                    case .success(let fetchedCandles):
                        let model = StockDetailModel(symbol: ticker, companyName: stockProfile.name, stockProfile: stockProfile, currentRange: .weekend, candles: fetchedCandles)
                        self?.presentor?.didLoadStockDetailModel(model: model)
                        
                    case .failure(let error):
                        print("Error fetching candles: \(error)")
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    func unsubscribeFromWebSocket(symbols: [String]) {
        WSManager.shared.unSubscribeFrom(symbols: symbols)
    }
}
