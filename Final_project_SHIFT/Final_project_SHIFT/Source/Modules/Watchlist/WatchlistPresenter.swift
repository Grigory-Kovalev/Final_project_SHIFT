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

}



class WatchlistPresenter {
        
    weak var view: IWatchlistViewController?
    var interactor: IWatchlistInteractor
    var router: IWatchlistRouter
    
    var dataSource = [PersistentStorageServiceModel]()
    private var stockDetailModel: StockDetailModel?
    
    init(interactor: IWatchlistInteractor, router: IWatchlistRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func configureView() {
//            view?.tapCellButtonHandler = { [weak self] text in
//                self?.handleButtonTap(ticker: text)
//            }
        }
    
    func handleButtonTap(ticker: String) {
        // Обработка нажатия кнопки с переданным текстом
        
    }
}

extension WatchlistPresenter: IWatchlistPresenter {
    
    func didLoadStockDetailModel(model: StockDetailModel) {
        var ticker = ""
//        self.view?.tapButtonHandler { [weak self] ticker in
//            self.ticker = ticker
//        }
        
        self.interactor.loadStockDetailModel(ticker: <#T##String#>)
        self.stockDetailModel = model
        self.view?.setStockDetailModel(with: model)
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
    
    func didLoadDataFromPersistentStorage(stocks: [PersistentStorageServiceModel]?) {
        guard let stocks else { return }
        self.dataSource = stocks
        self.view?.setDataSource(data: stocks)
        
        
        
    }
    
    func didSubscribeToWebSocket() {
        let tickers = dataSource.map({ $0.ticker })
        interactor.subscribeToWebSocket(symbols: tickers)
    }
    
    
    func didUnsubscribeFromWebSocket() {
        let tickers = dataSource.map({ $0.ticker })
        interactor.unsubscribeFromWebSocket(symbols: tickers)
    }
    
    func didConnectToWebSocket() {
        self.interactor.connectToWebSocket()
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
