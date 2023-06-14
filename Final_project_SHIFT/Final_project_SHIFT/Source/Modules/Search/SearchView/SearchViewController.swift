//
//  SearchViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//


import UIKit

final class SearchViewController: UIViewController {
    
    private var candles: Candles?
    
    let networkManager = NetworkService()
    
    private var searchResults = [SearchCellModel]()
    
    private let customView = SearchView()
    
    override func loadView() {
        super.loadView()
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customView.setupControllers(with: self.tabBarController!, with: self.navigationController!)
        customView.collectionView.delegate = self
        customView.collectionView.dataSource = self
        customView.searchBar.delegate = self
        print(customView.searchBar)
    }
    
    private func setUIInteractionEnabled(_ enabled: Bool) {
        customView.searchBar.isUserInteractionEnabled = enabled
        customView.collectionView.isUserInteractionEnabled = enabled
        tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }
    
    private func createAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: Resources.Strings.SearchScreen.alertSubmitTitle, style: .default, handler: nil)
        alertController.addAction(submitAction)
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Очищаем массив прошлого списка
        self.searchResults.removeAll()
        customView.collectionView.reloadData()
        //Убираем пробелы из запроса
        let trimmedText = customView.searchBar.text?.trimmingCharacters(in: .whitespaces)
        customView.searchBar.text = trimmedText
        
        // Скрыть клавиатуру
        searchBar.resignFirstResponder()
        //Запускаем индикатор
        customView.activityIndicator.startAnimating()
        // Отключаем пользовательское взаимодействие
        setUIInteractionEnabled(false)
        
        networkManager.fetchSymbolLookup(symbol: searchBar.text ?? "") { [weak self] result in
            //Отключаем индикатор
            self?.customView.activityIndicator.stopAnimating()
            // Разрешаем пользовательское взаимодействие
            self?.setUIInteractionEnabled(true)
            
            // Обработка полученных данных
            switch result {
            case .success(let fetchedStocks):
                let stocks = fetchedStocks.filter { $0.type == Resources.Strings.SearchScreen.stockType && !$0.symbol.contains(".") }
                for (index, stock) in stocks.enumerated()  {
                    self?.searchResults.append(SearchCellModel(fullName: stock.description, symbol: stock.symbol, type: stock.type, index: index))
                    
                }
                self?.customView.collectionView.reloadData()
            case .failure(let error):
                print("Error: \(error)")
                self?.createAlertController(title: Resources.Strings.SearchScreen.alertErrorTitles.0, message: Resources.Strings.SearchScreen.alertErrorTitles.1)
            }
        }
    }
}

//MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Вернуть количество элементов в коллекции
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = customView.collectionView.dequeueReusableCell(withReuseIdentifier: Resources.Strings.SearchScreen.watchlistCellIdentifier, for: indexPath) as! SearchViewCell
        let searchData = searchResults[indexPath.item]
        cell.setModel(with: searchData)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let symbol = searchResults[indexPath.row].symbol
        let companyName = searchResults[indexPath.row].fullName
        
        customView.createBlurEffect(isOn: true)
        //Запускаем индикатор
        customView.activityIndicator.startAnimating()
        // Отключаем пользовательское взаимодействие
        setUIInteractionEnabled(false)
        
        networkManager.fetchStockProfile(symbol: symbol) { [weak self] result in
            switch result {
            case .success(let stockProfile):
                self?.networkManager.fetchStockCandles(symbol: symbol, timeFrame: .weekend) { [weak self] result in
                    switch result {
                    case .success(let fetchedCandles):
                        self?.candles = fetchedCandles
                        
                        // Отключаем индикатор
                        self?.customView.activityIndicator.stopAnimating()
                        // Отключаем блюр
                        self?.customView.createBlurEffect(isOn: false)
                        // Разрешаем пользовательское взаимодействие
                        self?.setUIInteractionEnabled(true)
                        
                        let destinationController = StockDetailViewController(stockDetailModel: StockDetailModel(symbol: symbol, companyName: companyName, stockProfile: stockProfile, currentRange: .weekend, candles: fetchedCandles))
                        destinationController.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(destinationController, animated: true)
                        
                    case .failure(let error):
                        print("Error fetching candles: \(error)")
                        self?.createAlertController(title: "Error", message: "Failed to get company candles data")
                    }
                }
                
            case .failure(let error):
                print("Error: \(error)")
                self?.createAlertController(title: "Error", message: "Failed to get company profile data")
            }
        }
        
    }
}
