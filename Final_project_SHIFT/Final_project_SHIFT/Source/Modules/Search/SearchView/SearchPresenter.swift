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
    private let persistentStorageService: PersistentStorageService
    private var searchResults: [SearchCellModel] = []
    
    init(view: SearchViewControllerProtocol, networkManager: NetworkService, persistentStorageService: PersistentStorageService) {
        self.viewController = view
        self.networkManager = networkManager
        self.persistentStorageService = persistentStorageService
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
                self?.viewController?.showError()
            }
        }
    }
    
    // Добавьте другие методы презентера в соответствии с вашими требованиями
}
