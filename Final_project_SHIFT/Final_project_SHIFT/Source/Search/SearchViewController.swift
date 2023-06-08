//
//  SearchViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

final class SearchViewController: UIViewController {
    
    private var candles: Candles?

    
    let network = NetworkService()
    
    private var searchResults = [SearchCellModel]()
    
    private let reuseIdentifier = "CellIdentifier"
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Поиск"
        searchBar.showsCancelButton = false
        searchBar.text = "MSFT"
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.12)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(SearchViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        //tabBar
        tabBarItem = UITabBarItem(title: Resources.Strings.TabBar.search, image: Resources.Images.TabBar.search, selectedImage: nil)
        tabBarController?.tabBar.unselectedItemTintColor = .systemGray
        tabBarController?.tabBar.tintColor = .label
        
        //Nav
        navigationItem.title = "Search"
        let attributes: [NSAttributedString.Key: Any] = [
            //.font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: Resources.Colors.green
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        //searchBar
        navigationItem.titleView = searchBar
        
        setupUI()
    }
    
    //    override func loadView() {
    //
    //    }
    
    private func setupUI() {
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Скрыть клавиатуру
        // Ваш код для выполнения поисковой логики
        
        self.searchResults.removeAll()
        
        network.fetchSymbolLookup(symbol: searchBar.text ?? "") { result in
            switch result {
            case .success(let stocks):
                // Обработка полученных данных
                for stock in stocks {
                    
                    self.searchResults.append(SearchCellModel(fullName: stock.description, symbol: stock.symbol, type: stock.type))
                    self.collectionView.reloadData()
                    //print(stock.type)
                }
            case .failure(let error):
                // Обработка ошибки
                print("Error: \(error)")
            }
        }
        
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
        return searchResults.count // Замените searchResults на ваш массив данных
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Создайте и настройте ячейку для данного индекса
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! SearchViewCell
        // Настройте ячейку с данными из источника данных
        let searchData = searchResults[indexPath.item] // Замените searchResults на ваш массив данных
        cell.setModel(with: searchData)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let symbol = searchResults[indexPath.row].symbol
        let companyName = searchResults[indexPath.row].fullName
        
        let calendar = Calendar.current
        // Получаем текущую дату и время
        let currentDate = Date()

        // Получаем дату, ровно год назад от текущего момента
        let oneYearAgoDate = calendar.date(byAdding: .year, value: -1, to: currentDate)!
        
        let secondTime = Int(currentDate.timeIntervalSince1970)
        let firstTime = Int(oneYearAgoDate.timeIntervalSince1970)
        
        network.fetchStockCandles(symbol: symbol, timeFrame: .weekend) { result in
            switch result {
            case .success(let fetchedCandles):
                self.candles = fetchedCandles
                // Обработка полученных данных о свечах
                let destinationController = DetailViewController(stockDetailModel: StockDetailModel(symbol: symbol, companyName: companyName, currentRange: .weekend, candles: fetchedCandles))
                        destinationController.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(destinationController, animated: true)
            case .failure(let error):
                // Обработка ошибки запроса свечей
                print("Error fetching candles: \(error)")
            }
        }
//        let destinationController = DetailViewController(stockDetailModel: StockDetailModel(symbol: symbol, companyName: companyName, currentRange: .day, candles: candles))
//        destinationController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(destinationController, animated: true)
    }
}
