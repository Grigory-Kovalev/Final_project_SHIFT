//
//  WatchlistPresenter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import Foundation

protocol IWatchlistPresenter: AnyObject {
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    
    func didLoadDataFromPersistentStorage(stocks: [PersistentStorageServiceModel]?)
    func didConnectToWebSocket()
    func didSubscribeToWebSocket()
    func didReceiveDataFromWebSocket(data: LastStocksDataModel?)
    func didLoadStockDetailModel(model: StockDetailModel)
    func didUnsubscribeFromWebSocket()
    func getDataSource() -> [PersistentStorageServiceModel]
    
    func handleCellButtonTap(ticker: String)
}


class WatchlistPresenter {
        
    weak var view: IWatchlistViewController?
    var interactor: IWatchlistInteractor
    var router: IWatchlistRouter
    
    var dataSource = [PersistentStorageServiceModel]()
    var selectedTicker = ""
    private var stockDetailModel: StockDetailModel?
    
    init(interactor: IWatchlistInteractor, router: IWatchlistRouter) {
        self.interactor = interactor
        self.router = router
    }
    
}

extension WatchlistPresenter: IWatchlistPresenter {
    func handleCellButtonTap(ticker: String) {
        <#code#>
    }
    

    
    func getDataSource() -> [PersistentStorageServiceModel] {
        return dataSource
    }
    
    
    func didLoadStockDetailModel(model: StockDetailModel) {
        self.stockDetailModel = model
    }
    
    func didSubscribeToWebSocket() {
        let tickers = dataSource.map({ $0.ticker })
        interactor.subscribeToWebSocket(symbols: tickers)
    }
    
    func didReceiveDataFromWebSocket(data: LastStocksDataModel?) {
        guard let response = data else { return }
        for stock in response.data {
            let ticker = stock.s
            let price = stock.p
            
            // Находим соответствующую модель данных в dataSource по тикеру акции
            if let index = self.dataSource.firstIndex(where: { $0.ticker == ticker }) {
                // Обновляем цену акции в модели данных
                self.dataSource[index].price = price
                
                // Обновляем соответствующую ячейку в коллекции
                let indexPath = IndexPath(item: index, section: 0)
                self.view?.setCellLabelPrice(indexPath: indexPath, ticker: ticker, price: price)
            }
        }
    }
    
    func didUnsubscribeFromWebSocket() {
        let tickers = dataSource.map({ $0.ticker })
        interactor.unsubscribeFromWebSocket(symbols: tickers)
    }
    
    func didConnectToWebSocket() {
    }
    
    func didLoadDataFromPersistentStorage(stocks: [PersistentStorageServiceModel]?) {
        guard let stocks else { return }
        self.dataSource = stocks
        //self.view?.setStocks(with: stocks)
        
        
        
    }
    
    func viewDidLoad() {
        interactor.receiveDataFromWebSocket()
    }
    
    func viewDidAppear() {
        interactor.connectToWebSocket()
        interactor.loadDataFromPersistentStorage()
        self.didSubscribeToWebSocket()

    }
    
    func viewDidDisappear() {
        self.didUnsubscribeFromWebSocket()
    }
}































//    func viewDidLoad(ui: IWatchlistView) {
//        self.ui = ui
        
//        let model = self.interactor.load()
//        self.ui?.set(text: model.firstName + " " + model.secondName)
//
//        self.ui?.tapButtonHandler = {
//            self.router.nextModule()
//        }
//    }
    
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
    
//    private func sortStocksAlphabetically() {
//        dataSource.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
//    }
    
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
    
//    func didSelectItem(at indexPath: IndexPath) {
//        let symbol = dataSource[indexPath.row].ticker
//        let companyName = dataSource[indexPath.row].name
//
//        // Здесь можно выполнить действия для обработки выбора элемента в коллекции
//        // Например, передать информацию о выбранной акции через делегат или замыкание
//    }
