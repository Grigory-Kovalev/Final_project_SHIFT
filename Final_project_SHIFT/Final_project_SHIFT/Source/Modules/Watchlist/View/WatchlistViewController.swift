//
//  WatchlistViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

protocol IWatchlistViewController: AnyObject {
    func setStockDetailModel(with model: StockDetailModel)
    func setCellLabelPrice(indexPath: IndexPath, ticker: String, price: Double)
    func didTapCellButton()
}

extension WatchlistViewController: IWatchlistViewController {
    func didTapCellButton() {
        presenter?.handleCellButtonTap(ticker: <#T##String#>)
    }
    
    
    func setStockDetailModel(with model: StockDetailModel) {
        
    }
    
    func setCellLabelPrice(indexPath: IndexPath, ticker: String, price: Double) {
        //res
        DispatchQueue.main.async {
            if let cell = self.customView.collectionView.cellForItem(at: indexPath) as? WatchlistViewCell {
                // Обновляем только нужный лейбл в ячейке
                cell.updatePriceLabel(by: price)
            }
        }
    }
}

final class WatchlistViewController: UIViewController {
    // MARK: Properties
    private let customView = WatchlistView()
    
    
    //let networkManager = NetworkService()
    
    let persistentStorageService = PersistentStorageService()
    
    //var dataSource = [PersistentStorageServiceModel]()
    
    var presenter: IWatchlistPresenter?
    
//    init(presenter: IWatchlistPresenter) {
//        self.presenter = presenter
//        super.init()
//    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: Lifecycle
    override func loadView() {
        self.view = self.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        customView.setupControllers(with: self.tabBarController!, with: self.navigationController!)
        customView.collectionView.dataSource = self
        customView.collectionView.delegate = self
        
        //getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
//        // подключаемся
//        WSManager.shared.connectToWebSocket()
//        // Получите данные из Core Data и сохраните их в dataSource
//        dataSource = persistentStorageService.loadStocksFromCoreData()!
//        sortStocksAlphabetically() //presentor
//        //подписываемся на получение данных
//        WSManager.shared.subscribeTo(symbols: dataSource.map({ $0.ticker }))
        customView.collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.viewDidDisappear()
//        WSManager.shared.unSubscribeFrom(symbols: dataSource.map({ $0.ticker }))
        //WSManager.shared.disconnectWebSocket()
    }
    
    private func setUIInteractionEnabled(_ enabled: Bool) {
        customView.collectionView.isUserInteractionEnabled = enabled
        self.tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }
    
//    private func getData() {
//        WSManager.shared.receiveData { [weak self] data in
//            guard let self = self, let response = data else { return }
//            for stock in response.data {
//                let ticker = stock.s
//                let price = stock.p
//
//                // Находим соответствующую модель данных в dataSource по тикеру акции
//                if let index = self.dataSource.firstIndex(where: { $0.ticker == ticker }) {
//                    // Обновляем цену акции в модели данных
//                    self.dataSource[index].price = price
//
//                    // Обновляем соответствующую ячейку в коллекции
//                    let indexPath = IndexPath(item: index, section: 0)
//                    DispatchQueue.main.async {
//                        if let cell = self.customView.collectionView.cellForItem(at: indexPath) as? WatchlistViewCell {
//                        // Обновляем только нужный лейбл в ячейке
//                            //cell.priceLabel.text = "\(price)"
//                        cell.updatePriceLabel(by: price)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
//    private func sortStocksAlphabetically() {
//        dataSource.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
//    }
    
    private func createAlertController(title: String, message: String) {
       let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
       
       let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
       alertController.addAction(okAction)
       present(alertController, animated: true, completion: nil)
   }
}

//MARK: - UICollectionViewDataSource
extension WatchlistViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Вернуть количество элементов в коллекции
        return presenter?.getDataSource().count ?? 0
        //return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Resources.Strings.Watchlist.watchlistCellIdentifier, for: indexPath) as! WatchlistViewCell
        let searchData = presenter?.getDataSource()[indexPath.item]
        cell.setModel(with: WatchlistModel(ticker: searchData!.ticker, name: searchData!.name, logo: searchData!.logo, price: searchData!.price, currency: searchData!.currency))
        return cell
    }
}


//MARK: - UICollectionViewDelegate
extension WatchlistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let symbol = (presenter?.getDataSource()[indexPath.row].ticker)!
        let companyName = (presenter?.getDataSource()[indexPath.row].name)
        
        customView.createBlurEffect(isOn: true)
        //Запускаем индикатор
        customView.activityIndicator.startAnimating()
        // Отключаем пользовательское взаимодействие
        setUIInteractionEnabled(false)
        
        didTapCellButton()
        
//        networkManager.fetchStockProfile(symbol: symbol ?? "AAPL") { [weak self] result in
//            switch result {
//            case .success(let stockProfile):
//                self?.networkManager.fetchStockCandles(symbol: symbol ?? "AAPL", timeFrame: .weekend) { [weak self] result in
//                    switch result {
//                    case .success(let fetchedCandles):
//                        // Отключаем индикатор
//                        self?.customView.activityIndicator.stopAnimating()
//                        // Отключаем блюр
//                        self?.customView.createBlurEffect(isOn: false)
//                        // Разрешаем пользовательское взаимодействие
//                        self?.setUIInteractionEnabled(true)
//
//                        let destinationController = StockDetailViewController(stockDetailModel: StockDetailModel(symbol: symbol!, companyName: companyName, stockProfile: stockProfile, currentRange: .weekend, candles: fetchedCandles))
//                        destinationController.hidesBottomBarWhenPushed = true
//                        self?.navigationController?.pushViewController(destinationController, animated: true)
//
//                    case .failure(let error):
//                        print("Error fetching candles: \(error)")
//                        self?.createAlertController(title: "Error", message: "Failed to get company candles data")
//                    }
//                }
//
//            case .failure(let error):
//                print("Error: \(error)")
//                self?.createAlertController(title: "Error", message: "Failed to get company profile data")
//            }
//        }
        
    }
}


