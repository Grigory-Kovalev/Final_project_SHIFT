//
//  WatchlistInteractor.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import Foundation

protocol WatchlistInteractorProtocol {
    func loadData(completion: @escaping ([PersistentStorageServiceModel]?) -> Void)
    func subscribeToWebSocket(symbols: [String])
    func unsubscribeFromWebSocket(symbols: [String])
}

class WatchlistInteractor: WatchlistInteractorProtocol {
    let persistentStorageService: PersistentStorageService
    
    init(persistentStorageService: PersistentStorageService) {
        self.persistentStorageService = persistentStorageService
    }
    
    func loadData(completion: @escaping ([PersistentStorageServiceModel]?) -> Void) {
        let data = persistentStorageService.loadStocksFromCoreData()
        completion(data)
    }
    
    func subscribeToWebSocket(symbols: [String]) {
        WSManager.shared.subscribeTo(symbols: symbols)
    }
    
    func unsubscribeFromWebSocket(symbols: [String]) {
        WSManager.shared.unSubscribeFrom(symbols: symbols)
    }
}
