//
//  WatchlistViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

protocol IWatchlistViewController: AnyObject {
    var tapButtonHandler: ((String) -> Void)? { get set }
    
    func setStockDetailModel(with model: StockDetailModel)
    func setCellLabelPrice(indexPath: IndexPath, ticker: String, price: Double)
    func setDataSource(data: [PersistentStorageServiceModel])
}

extension WatchlistViewController: IWatchlistViewController {
    var tapButtonHandler: ((String) -> Void)? {
        get {
            
        }
        set {
            
        }
    }
    
    
    
    
    func setDataSource(data: [PersistentStorageServiceModel]) {
        self.dataSource = data
    }
    
    func setStockDetailModel(with model: StockDetailModel) {
        DispatchQueue.main.async {
            self.stockDetailModel = model
             //Отключаем индикатор
            self.customView.activityIndicator.stopAnimating()
            // Отключаем блюр
            self.customView.createBlurEffect(isOn: false)
            // Разрешаем пользовательское взаимодействие
            self.setUIInteractionEnabled(true)
        }
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
    
    var dataSource = [PersistentStorageServiceModel]()
    var stockDetailModel: StockDetailModel?
        
    let persistentStorageService = PersistentStorageService()
        
    var presenter: IWatchlistPresenter?
    
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()

        customView.collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.viewDidDisappear()

    }
    
    private func setUIInteractionEnabled(_ enabled: Bool) {
        customView.collectionView.isUserInteractionEnabled = enabled
        self.tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }
    
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
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Resources.Strings.Watchlist.watchlistCellIdentifier, for: indexPath) as! WatchlistViewCell
        let searchData = self.dataSource[indexPath.item]
        cell.setModel(with: WatchlistModel(ticker: searchData.ticker, name: searchData.name, logo: searchData.logo, price: searchData.price, currency: searchData.currency))
        return cell
    }
}


//MARK: - UICollectionViewDelegate
extension WatchlistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let symbol = (self.dataSource[indexPath.row].ticker)
        tapButtonHandler?(symbol)
        //let companyName = (self.dataSource[indexPath.row].name)
        
        customView.createBlurEffect(isOn: true)
        //Запускаем индикатор
        customView.activityIndicator.startAnimating()
        // Отключаем пользовательское взаимодействие
        setUIInteractionEnabled(false)
        
        let destinationController = StockDetailViewController(stockDetailModel: self.stockDetailModel ?? StockDetailModel(symbol: "", companyName: "", stockProfile: StockProfileModel(country: "", currency: "", estimateCurrency: "", exchange: "", finnhubIndustry: "", ipo: "", logo: "", marketCapitalization: 0, name: "", phone: "", shareOutstanding: 0, ticker: "", weburl: ""), currentRange: .weekend, candles: Candles(c: [Double](), h: [Double](), l: [Double](), o: [Double](), s: "", t: [Int](), v: [Int]())))
        destinationController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(destinationController, animated: true)
        
        //didTapCellButton()
        
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


