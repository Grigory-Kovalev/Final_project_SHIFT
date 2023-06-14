//
//  SearchViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//


import UIKit

protocol SearchViewControllerProtocol: AnyObject {
    func hideActivityIndicator()
    func setUIInteractionEnabled(_ enabled: Bool)
    func getCollectionView() -> UICollectionView
    func showError()
}

final class SearchViewController: UIViewController, SearchViewControllerProtocol {
    func showError() {
        self.createAlertController(title: Resources.Strings.SearchScreen.alertErrorTitles.0, message: Resources.Strings.SearchScreen.alertErrorTitles.1)
    }
    
    func getCollectionView() -> UICollectionView {
        return self.customView.collectionView
    }
    
    
    func hideActivityIndicator() {
        customView.activityIndicator.stopAnimating()
    }
    
    private var candles: Candles?
    
    let networkManager = NetworkService()
    
    
    private let customView = SearchView()
    var presenter: SearchPresenterProtocol?
    
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
    }
    
    func setUIInteractionEnabled(_ enabled: Bool) {
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
        self.presenter?.searchResultsRemoveAll()
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
        let ticker = searchBar.text ?? ""
        presenter?.searchButtonClicked(with: ticker)
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Метод вызывается, когда пользователь нажимает на кнопку "Отмена" в поисковой строке
        // Здесь вы можете выполнить действия по очистке поисковых результатов или закрытию поисковой строки
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Метод вызывается, когда текст в поисковой строке изменяется
        // Здесь вы можете реагировать на изменения и выполнять дополнительные действия, например, фильтрацию результатов поиска в реальном времени
    }
}

//MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Вернуть количество элементов в коллекции
        return self.presenter?.searchResultsCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = customView.collectionView.dequeueReusableCell(withReuseIdentifier: Resources.Strings.SearchScreen.watchlistCellIdentifier, for: indexPath) as! SearchViewCell
        let searchData = self.presenter?.searchResultsItem(by: indexPath.item)
        cell.setModel(with: searchData!)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let symbol = self.presenter?.searchResultsItem(by: indexPath.row).symbol
        let companyName = self.presenter?.searchResultsItem(by: indexPath.row).fullName
        
        guard let symbol else { return }
        guard let companyName else { return }
        
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
