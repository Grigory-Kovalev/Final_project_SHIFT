//
//  WatchlistRouter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import UIKit

// MARK: - Router
protocol WatchlistRouterProtocol: AnyObject {
    func showStockDetail(with model: StockDetailModel)
}

// Пример имплементации WatchlistRouter
class WatchlistRouter: WatchlistRouterProtocol {
    weak var viewController: UIViewController?
    
    func showStockDetail(with model: StockDetailModel) {
        let stockDetailViewController = StockDetailViewController(stockDetailModel: model)
        viewController?.navigationController?.pushViewController(stockDetailViewController, animated: true)
    }
}
