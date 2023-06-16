//
//  SearchPresenter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation

protocol SearchPresenterProtocol {
    func searchButtonClicked(with searchText: String)
    func searchResultsRemoveAll()
    func searchResultsCount() -> Int
    func searchResultsItem(by index: Int) -> SearchCellModel
    func didSelectStock(at index: Int)
}

final class SearchPresenter {
    
    // MARK: - Properties
    weak var viewController: SearchViewControllerProtocol?
    private let networkManager: NetworkService
    private var searchResults: [SearchCellModel] = []
    
    // MARK: - Init
    init(view: SearchViewControllerProtocol, networkManager: NetworkService) {
        self.viewController = view
        self.networkManager = networkManager
    }
}

// MARK: - SearchPresenterProtocol
extension SearchPresenter: SearchPresenterProtocol {
    func searchResultsItem(by index: Int) -> SearchCellModel {
        return self.searchResults[index]
    }
    
    func searchResultsCount() -> Int {
        return self.searchResults.count
    }
    
    func searchResultsRemoveAll() {
        self.searchResults.removeAll()
    }
    
    func searchButtonClicked(with searchText: String) {

        networkManager.fetchSymbolLookup(symbol: searchText) { [weak self] result in
            
            // Обработка полученных данных
            switch result {
            case .success(let fetchedStocks):
                let stocks = fetchedStocks.filter { $0.type == Resources.Strings.SearchScreen.stockType && !$0.symbol.contains(".") }
                
                //Очищаем массив прошлого списка
                self?.searchResultsRemoveAll()
                for (index, stock) in stocks.enumerated()  {
                    self?.searchResults.append(SearchCellModel(fullName: stock.description, symbol: stock.symbol, type: stock.type, index: index))
                }
                if !(self?.searchResults.isEmpty ?? true) {
                    DispatchQueue.main.async {
                        self?.viewController?.getCollectionView().reloadData()
                        self?.viewController?.hideActivityIndicator()
                        self?.viewController?.setUIInteractionEnabled(true)
                        self?.viewController?.createBlurEffect(isOn: false)
                    }
                } else {
                    self?.viewController?.showError(title: Resources.Strings.SearchScreen.alertZeroStock.0, message: Resources.Strings.SearchScreen.alertZeroStock.1)
                    self?.viewController?.getCollectionView().reloadData()
                    self?.viewController?.hideActivityIndicator()
                    self?.viewController?.setUIInteractionEnabled(true)
                    self?.viewController?.createBlurEffect(isOn: false)
                }
            case .failure(let error):
                print("Error: \(error)")
                self?.viewController?.setUIInteractionEnabled(true)
                self?.viewController?.hideActivityIndicator()
                self?.viewController?.createBlurEffect(isOn: false)
                self?.viewController?.showError(title: Resources.Strings.SearchScreen.alertErrorTitles.0, message: Resources.Strings.SearchScreen.alertErrorTitles.1)
            }
        }
    }
    
    func didSelectStock(at index: Int) {
        let ticker = self.searchResultsItem(by: index).symbol
        
        networkManager.fetchStockProfile(symbol: ticker) { [weak self] result in
            switch result {
            case .success(let stockProfile):
                self?.networkManager.fetchStockCandles(symbol: ticker, timeFrame: .weekend) { [weak self] result in
                    switch result {
                    case .success(let fetchedCandles):
                        
                        let destinationController = StockDetailAssembly().createModule(with: StockDetailModel(symbol: ticker, companyName: stockProfile.name, stockProfile: stockProfile, currentRange: .weekend, candles: fetchedCandles))
                                                
                        DispatchQueue.main.async {
                            destinationController.hidesBottomBarWhenPushed = true
                            self?.viewController?.navigationController?.pushViewController(destinationController, animated: true)
                        }
                        
                    case .failure(_):
                        self?.viewController?.hideActivityIndicator()
                        self?.viewController?.createBlurEffect(isOn: false)
                        self?.viewController?.showError(title: Resources.Strings.SearchScreen.alertErrorCandlesTitles.0, message: Resources.Strings.SearchScreen.alertErrorCandlesTitles.1)
                    }
                }
                
            case .failure(_):
                self?.viewController?.hideActivityIndicator()
                self?.viewController?.createBlurEffect(isOn: false)
                self?.viewController?.showError(title: Resources.Strings.SearchScreen.alertErrorProfileTitles.0, message: Resources.Strings.SearchScreen.alertErrorProfileTitles.1)
            }
        }
    }
}

