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
    
    private let reuseIdentifier = "CellIdentifier"
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Поиск"
        searchBar.showsCancelButton = false
        searchBar.text = "MSFT"
        return searchBar
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
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
    
    private lazy var cancelButton: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        toolbar.items = [flexibleSpace, cancelButton]
        searchBar.inputAccessoryView = toolbar
        return toolbar
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
        self.view.addSubview(activityIndicator)
        self.searchBar.inputAccessoryView = cancelButton
    }
    
    private func setUIInteractionEnabled(_ enabled: Bool) {
        searchBar.isUserInteractionEnabled = enabled
        collectionView.isUserInteractionEnabled = enabled
        tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }
    
    
    @objc private func cancelButtonTapped() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Убираем пробелы из запроса
        let trimmedText = self.searchBar.text?.trimmingCharacters(in: .whitespaces)
        self.searchBar.text = trimmedText
        
        // Скрыть клавиатуру
        searchBar.resignFirstResponder()
        //Запускаем индикатор
        activityIndicator.startAnimating()
        // Отключаем пользовательское взаимодействие
        setUIInteractionEnabled(false)
        //Очищаем массив прошлого списка
        self.searchResults.removeAll()
        
        networkManager.fetchSymbolLookup(symbol: searchBar.text ?? "") { result in
            //Отключаем индикатор
            self.activityIndicator.stopAnimating()
            // Разрешаем пользовательское взаимодействие
            self.setUIInteractionEnabled(true)
            
            // Обработка полученных данных
            switch result {
            case .success(let stocks):
                for stock in stocks {
                    self.searchResults.append(SearchCellModel(fullName: stock.description, symbol: stock.symbol, type: stock.type))
                    self.collectionView.reloadData()
                }
            case .failure(let error):
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
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! SearchViewCell
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
        
        networkManager.fetchStockCandles(symbol: symbol, timeFrame: .weekend) { [weak self] result in
            switch result {
            case .success(let fetchedCandles):
                self?.candles = fetchedCandles
                
                self?.networkManager.fetchStockProfile(symbol: symbol) { [weak self] result in
                    switch result {
                        case .success(let stockProfile):
                            
                        let destinationController = StockDetailViewController(stockDetailModel: StockDetailModel(symbol: symbol, companyName: companyName, stockProfile: stockProfile, currentRange: .weekend, candles: fetchedCandles))
                        destinationController.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(destinationController, animated: true)
                        
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                }
                
                
            case .failure(let error):
                print("Error fetching candles: \(error)")
            }
        }
    }
}
//StockDetailModel(symbol: symbol, companyName: companyName, currentRange: .weekend, candles: fetchedCandles)
