//
//  WatchlistViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

struct WatchlistModel {
    let ticker: String
    let name: String
    let logo: String
    var price: Double
    let currency: String
}

final class WatchlistViewController: UIViewController {
    
    let networkManager = NetworkService()
    let persistentStorageService = PersistentStorageService()
    
    var dataSource = [PersistentStorageServiceModel]()

    
    //private var dataArray = [LastStocksDataModel]()
    
    private let reuseIdentifier = "CellIdentifier"
    
    private var blurEffectView: UIVisualEffectView?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.12)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(WatchlistViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layer.cornerRadius = 15
        return collectionView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WSManager.shared.unSubscribeFrom(symbols: dataSource.map({ $0.ticker }))
        //WSManager.shared.disconnectWebSocket()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        WSManager.shared.connectToWebSocket() // подключаемся
        WSManager.shared.subscribeTo(symbols: dataSource.map({ $0.ticker })) //подписываемся на получение данных
        
        // Получите данные из Core Data и сохраните их в dataSource
        dataSource = persistentStorageService.loadStocksFromCoreData()!
        print(dataSource)
        self.collectionView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        //tabBar
        tabBarController?.tabBar.unselectedItemTintColor = .systemGray
        tabBarController?.tabBar.tintColor = .label
        
        
        //Nav
        navigationItem.title = "Watchlist"
        let attributes: [NSAttributedString.Key: Any] = [
            //.font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: Resources.Colors.green
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        setupUI()
    }
    
    //    override func loadView() {
    //
    //    }
    
    private func setupUI() {
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        self.view.addSubview(activityIndicator)
    }
    
    private func getData() {
        WSManager.shared.receiveData { [weak self] data in
            guard let self = self, let response = data else { return }

            var responseTickers = [String]()
            for stock in response.data {
                responseTickers.append(stock.s)
            }

            // Находим соответствующую модель данных в dataSource
            if let index = self.dataSource.firstIndex(where: { responseTickers.contains($0.ticker) }) {
                print(index)
                // Обновляем цену акции в модели данных
                if response.data[index].p != 0 {
                    let price = response.data[index].p
                    print(price)
                    self.dataSource[index].price = price
                }

                // Обновляем соответствующую ячейку в коллекции
                let indexPath = IndexPath(item: index, section: 0)
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }



    
    private func setUIInteractionEnabled(_ enabled: Bool) {
        collectionView.isUserInteractionEnabled = enabled
        tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }
    
    private func createBlurEffect(isOn: Bool) {
        if isOn {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView?.frame = collectionView.bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.addSubview(blurEffectView!)
        } else {
            blurEffectView?.removeFromSuperview()
            blurEffectView = nil
        }
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
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! WatchlistViewCell
        let searchData = dataSource[indexPath.item]
        cell.setModel(with: WatchlistModel(ticker: searchData.ticker, name: searchData.name, logo: searchData.logo, price: searchData.price, currency: searchData.currency))
        return cell
    }
}


//MARK: - UICollectionViewDelegate
extension WatchlistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let symbol = dataSource[indexPath.row].ticker
        let companyName = dataSource[indexPath.row].name
        
        createBlurEffect(isOn: true)
        //Запускаем индикатор
        activityIndicator.startAnimating()
        // Отключаем пользовательское взаимодействие
        setUIInteractionEnabled(false)
        
        networkManager.fetchStockProfile(symbol: symbol) { [weak self] result in
            switch result {
            case .success(let stockProfile):
                self?.networkManager.fetchStockCandles(symbol: symbol, timeFrame: .weekend) { [weak self] result in
                    switch result {
                    case .success(let fetchedCandles):                        
                        // Отключаем индикатор
                        self?.activityIndicator.stopAnimating()
                        // Отключаем блюр
                        self?.createBlurEffect(isOn: false)
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
