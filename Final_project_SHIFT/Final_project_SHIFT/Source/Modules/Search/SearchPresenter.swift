//
//  SearchPresenter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation

// Протокол презентера
protocol SearchPresenterProtocol {
    func searchButtonClicked(with searchText: String)
    func searchResultsRemoveAll()
    func searchResultsCount() -> Int
    func searchResultsItem(by index: Int) -> SearchCellModel
    func didSelectStock(at index: Int)
}

// Презентер
class SearchPresenter: SearchPresenterProtocol {
    func searchResultsItem(by index: Int) -> SearchCellModel {
        return self.searchResults[index]
    }
    
    func searchResultsCount() -> Int {
        return self.searchResults.count
    }
    
    func searchResultsRemoveAll() {
        self.searchResults.removeAll()
    }
    
    
    weak var viewController: SearchViewControllerProtocol?
    private let networkManager: NetworkService
    private var searchResults: [SearchCellModel] = []
    
    init(view: SearchViewControllerProtocol, networkManager: NetworkService) {
        self.viewController = view
        self.networkManager = networkManager
    }
    
    func searchButtonClicked(with searchText: String) {
        networkManager.fetchSymbolLookup(symbol: searchText) { [weak self] result in
            //Отключаем индикатор
            self?.viewController?.hideActivityIndicator()
            // Разрешаем пользовательское взаимодействие
            self?.viewController?.setUIInteractionEnabled(true)
            
            // Обработка полученных данных
            switch result {
            case .success(let fetchedStocks):
                let stocks = fetchedStocks.filter { $0.type == Resources.Strings.SearchScreen.stockType && !$0.symbol.contains(".") }
                for (index, stock) in stocks.enumerated()  {
                    self?.searchResults.append(SearchCellModel(fullName: stock.description, symbol: stock.symbol, type: stock.type, index: index))
                    
                }
                self?.viewController?.getCollectionView().reloadData()
            case .failure(let error):
                print("Error: \(error)")
                self?.viewController?.showError(title: Resources.Strings.SearchScreen.alertErrorTitles.0, message: Resources.Strings.SearchScreen.alertErrorTitles.1)
            }
        }
    }
    
    func didSelectStock(at index: Int) {
        
        let ticker = self.searchResultsItem(by: index).symbol
        
        viewController?.createBlurEffect(isOn: true)
        viewController?.showActivityIndicator()
        viewController?.setUIInteractionEnabled(false)
        
        networkManager.fetchStockProfile(symbol: ticker) { [weak self] result in
            switch result {
            case .success(let stockProfile):
                self?.networkManager.fetchStockCandles(symbol: ticker, timeFrame: .weekend) { [weak self] result in
                    switch result {
                    case .success(let fetchedCandles):
                        self?.viewController?.hideActivityIndicator()
                        self?.viewController?.createBlurEffect(isOn: false)
                        self?.viewController?.setUIInteractionEnabled(true)
                        
                        let destinationController = StockDetailViewController(stockDetailModel: StockDetailModel(symbol: ticker, companyName: stockProfile.name, stockProfile: stockProfile, currentRange: .weekend, candles: fetchedCandles))
                        
                        DispatchQueue.main.async {
                            destinationController.hidesBottomBarWhenPushed = true
                            self?.viewController?.navigationController?.pushViewController(destinationController, animated: true)
                        }
                        
                    case .failure(_):
                        self?.viewController?.hideActivityIndicator()
                        self?.viewController?.showError(title: Resources.Strings.SearchScreen.alertErrorCandlesTitles.0, message: Resources.Strings.SearchScreen.alertErrorCandlesTitles.1)
                    }
                }
                
            case .failure(_):
                self?.viewController?.hideActivityIndicator()
                self?.viewController?.showError(title: Resources.Strings.SearchScreen.alertErrorProfileTitles.0, message: Resources.Strings.SearchScreen.alertErrorProfileTitles.1)
            }
        }
    }
}
