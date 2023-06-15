//
//  WatchlistPresenter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 14.06.2023.
//

import UIKit

protocol WatchlistPresenterProtocol {
    var numberOfStocks: Int { get }
    
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    
    func didSelectStock(at index: Int)
    func getStock(at index: Int) -> WatchlistModel
}

final class WatchlistPresenter {
    
    // MARK: - Properties
    weak var viewController: WatchlistViewControllerProtocol?
    private let networkManager: NetworkService
    private let persistentStorageService: PersistentStorageService
    private var dataSource: [PersistentStorageServiceModel] = []
    
    // MARK: - Init
    init(view: WatchlistViewControllerProtocol, networkManager: NetworkService, persistentStorageService: PersistentStorageService) {
        self.viewController = view
        self.networkManager = networkManager
        self.persistentStorageService = persistentStorageService
    }

    // MARK: - Private methods
    private func getData() {
        WSManager.shared.receiveData { [weak self] data in
            guard let self = self, let response = data else {
                return
            }
            for stock in response.data {
                let ticker = stock.s
                let price = stock.p
                
                if let index = self.dataSource.firstIndex(where: { $0.ticker == ticker }) {
                    self.dataSource[index].price = price
                    
                    let indexPath = IndexPath(item: index, section: 0)
                    DispatchQueue.main.async {
                        if let cell = self.viewController?.getCollectionView().cellForItem(at: indexPath) as? WatchlistViewCell {
                            cell.updatePriceLabel(by: price)
                        }
                    }
                }
            }
        }
    }
    
    private func sortStocksAlphabetically() {
        dataSource.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

// MARK: - WatchlistPresenterProtocol
extension WatchlistPresenter: WatchlistPresenterProtocol {
    var numberOfStocks: Int {
        return dataSource.count
    }
    
    func viewDidLoad() {
        getData()
    }
    
    func viewDidAppear() {
        WSManager.shared.connectToWebSocket()
        dataSource = persistentStorageService.loadStocksFromCoreData() ?? []
        sortStocksAlphabetically()
        WSManager.shared.subscribeTo(symbols: dataSource.map({ $0.ticker }))
        viewController?.reloadCollectionView()
    }
    
    func viewDidDisappear() {
        WSManager.shared.unSubscribeFrom(symbols: dataSource.map({ $0.ticker }))
    }
    
    func didSelectStock(at index: Int) {
        let stock = getStock(at: index)
        
        let symbol = stock.ticker
        let companyName = stock.name
        
        viewController?.createBlurEffect(isOn: true)
        viewController?.showActivityIndicator()
        viewController?.setUIInteractionEnabled(false)
        
        networkManager.fetchStockProfile(symbol: symbol) { [weak self] result in
            switch result {
            case .success(let stockProfile):
                self?.networkManager.fetchStockCandles(symbol: symbol, timeFrame: .weekend) { [weak self] result in
                    switch result {
                    case .success(let fetchedCandles):
                        
                        let destinationController = StockDetailViewController(stockDetailModel: StockDetailModel(symbol: symbol, companyName: companyName, stockProfile: stockProfile, currentRange: .weekend, candles: fetchedCandles))
                        DispatchQueue.main.async {
                            destinationController.hidesBottomBarWhenPushed = true
                            self?.viewController?.navigationController?.pushViewController(destinationController, animated: true)
                        }
                        
                    case .failure(_):
                        self?.viewController?.hideActivityIndicator()
                        self?.viewController?.showError(message: "Failed to get company candles data")
                    }
                }
                
            case .failure(_):
                self?.viewController?.hideActivityIndicator()
                self?.viewController?.showError(message: "Failed to get company profile data")
            }
        }
    }
    
    func getStock(at index: Int) -> WatchlistModel {
        let stock = dataSource[index]
        return WatchlistModel(ticker: stock.ticker, name: stock.name, logo: stock.logo, price: stock.price, currency: stock.currency)
    }
}
