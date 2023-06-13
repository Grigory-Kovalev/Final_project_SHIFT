////
////  WatchlistPresenter.swift
////  Final_project_SHIFT
////
////  Created by Григорий Ковалев on 13.06.2023.
////
//
//import Foundation
//
//protocol WatchlistPresenterProtocol: AnyObject {
//    var router: WatchlistRouterProtocol? { get set }
//    func viewDidLoad()
//    func didSelectItem(at indexPath: IndexPath)
//}
//
//class WatchlistPresenter: WatchlistPresenterProtocol {
//    private weak var view: WatchlistViewProtocol?
//    private let networkManager: NetworkService
//    private let persistentStorageService: PersistentStorageService
//    
//    private var dataSource: [PersistentStorageServiceModel] = []
//    
//    var router: WatchlistRouterProtocol?
//    
//    init(view: WatchlistViewProtocol, networkManager: NetworkService, persistentStorageService: PersistentStorageService) {
//        self.view = view
//        self.networkManager = networkManager
//        self.persistentStorageService = persistentStorageService
//    }
//    
//    func viewDidLoad() {
//        view?.setupControllers()
//        
//        getData()
//    }
//    
//    private func getData() {
//        // Получите данные из Core Data и сохраните их в dataSource
//        dataSource = persistentStorageService.loadStocksFromCoreData() ?? []
//        sortStocksAlphabetically()
//        // Обновите коллекцию на экране
//        view?.reloadCollectionView()
//        
//        // Подпишитесь на получение данных через WebSocket
//        WSManager.shared.subscribeTo(symbols: dataSource.map({ $0.ticker }))
//        
//        // Подключитесь к WebSocket
//        WSManager.shared.connectToWebSocket()
//        
//        // Получите начальные данные и обновите ячейки в коллекции
//        updateCells()
//    }
//    
//    private func sortStocksAlphabetically() {
//        dataSource.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
//    }
//    
//    private func updateCells() {
//        WSManager.shared.receiveData { [weak self] data in
//            guard let self = self, let response = data else { return }
//            for stock in response.data {
//                let ticker = stock.s
//                let price = stock.p
//                
//                // Найдите соответствующую модель данных в dataSource по тикеру акции
//                if let index = self.dataSource.firstIndex(where: { $0.ticker == ticker }) {
//                    // Обновите цену акции в модели данных
//                    self.dataSource[index].price = price
//                    
//                    // Обновите соответствующую ячейку в коллекции
//                    self.view?.updatePriceLabel(at: IndexPath(item: index, section: 0), price: price)
//                }
//            }
//        }
//    }
//    
//    func didSelectItem(at indexPath: IndexPath) {
//        let symbol = dataSource[indexPath.row].ticker
//        let companyName = dataSource[indexPath.row].name
//        
//        // Здесь можно выполнить действия для обработки выбора элемента в коллекции
//        // Например, передать информацию о выбранной акции через делегат или замыкание
//    }
//}
//
//protocol WatchlistViewProtocol: AnyObject {
//    func setupControllers()
//    func reloadCollectionView()
//    func updatePriceLabel(at indexPath: IndexPath, price: Double)
//}
//
//// Пример реализации WatchlistViewController с использованием презентера
//class WatchlistViewController: UIViewController, WatchlistViewProtocol {
//    private let presenter: WatchlistPresenterProtocol
//    
//    // Инициализация контроллера с презентером
//    init(presenter: WatchlistPresenterProtocol) {
//        self.presenter = presenter
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // ... остальной код контроллера ...
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        presenter.viewDidLoad()
//    }
//    
//    // Реализация протокола WatchlistViewProtocol
//    
//    func setupControllers() {
//        // Установите контроллеры, такие как tabBarController и navigationController
//    }
//    
//    func reloadCollectionView() {
//        collectionView.reloadData()
//    }
//    
//    func updatePriceLabel(at indexPath: IndexPath, price: Double) {
//        if let cell = collectionView.cellForItem(at: indexPath) as? WatchlistViewCell {
//            cell.updatePriceLabel(by: price)
//        }
//    }
//}
