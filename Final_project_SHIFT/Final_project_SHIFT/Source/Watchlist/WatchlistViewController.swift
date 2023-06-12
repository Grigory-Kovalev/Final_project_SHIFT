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
    
    private let reuseIdentifier = "CellIdentifier"
    
    private var blurEffectView: UIVisualEffectView?
    
    private lazy var exchangeStatusView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0

        let label = UILabel()
        let now = Date() // Получаем текущую дату и время
        var calendar = Calendar.current
        let newYorkTimeZone = TimeZone(identifier: "America/New_York")
        calendar.timeZone = newYorkTimeZone!

        let openHour = 9
        let openMinute = 30
        let closeHour = 16

        let weekday = calendar.component(.weekday, from: now)
        if weekday >= 2 && weekday <= 6, // Проверяем, что это понедельник-пятница
            let openTime = calendar.date(bySettingHour: openHour, minute: openMinute, second: 0, of: now),
            let closeTime = calendar.date(bySettingHour: closeHour, minute: 0, second: 0, of: now),
            calendar.isDate(now, inSameDayAs: openTime) || calendar.isDate(now, inSameDayAs: closeTime),
            now >= openTime && now <= closeTime {
            // Биржа открыта с понедельника по пятницу
            label.text = "Stock exchange is open"
            label.textColor = Resources.Colors.gray

            let sunImage = UIImageView(image: UIImage(systemName: "sun.max"))
            sunImage.tintColor = .yellow

            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(sunImage)
        } else {
            // Биржа закрыта или не рабочий день
            label.text = "Stock exchange is closed"
            label.textColor = Resources.Colors.gray

            let moonImage = UIImageView(image: UIImage(systemName: "moon.zzz"))
            moonImage.tintColor = .blue

            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(moonImage)
        }

        return stackView
    }()

    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(WatchlistViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layer.cornerRadius = 15
        return collectionView
    }()
    
    private lazy var favoriteStocksLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorite stocks"
        label.font = UIFont.systemFont(ofSize: 22, weight: .black)
        return label
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
        // Получите данные из Core Data и сохраните их в dataSource
        dataSource = persistentStorageService.loadStocksFromCoreData()!
        sortStocksAlphabetically()
        WSManager.shared.subscribeTo(symbols: dataSource.map({ $0.ticker })) //подписываемся на получение данных
        
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
        getData()
    }
    
    //    override func loadView() {
    //
    //    }
    
    private func setupUI() {
        self.view.addSubview(exchangeStatusView)
        exchangeStatusView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(favoriteStocksLabel)
        favoriteStocksLabel.snp.makeConstraints { make in
            make.top.equalTo(exchangeStatusView.snp.bottom).inset(-16)
            make.leading.equalToSuperview().inset(16)
        }
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(favoriteStocksLabel.snp.bottom).inset(-8)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        self.view.addSubview(activityIndicator)
    }
    
    private func getData() {
        WSManager.shared.receiveData { [weak self] data in
            guard let self = self, let response = data else { return }
            for stock in response.data {
                let ticker = stock.s
                let price = stock.p

                // Находим соответствующую модель данных в dataSource по тикеру акции
                if let index = self.dataSource.firstIndex(where: { $0.ticker == ticker }) {
                    // Обновляем цену акции в модели данных
                    self.dataSource[index].price = price

                    // Обновляем соответствующую ячейку в коллекции
                    let indexPath = IndexPath(item: index, section: 0)
                    DispatchQueue.main.async {
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? WatchlistViewCell {
                        // Обновляем только нужный лейбл в ячейке
                            //cell.priceLabel.text = "\(price)"
                        cell.updateValue(price: price)
                        }
                    }
                }
            }
        }
    }



    private func setUIInteractionEnabled(_ enabled: Bool) {
        collectionView.isUserInteractionEnabled = enabled
        tabBarController?.tabBar.isUserInteractionEnabled = enabled
    }
    
    private func sortStocksAlphabetically() {
        dataSource.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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
