//
//  WatchlistRouter.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import UIKit

// MARK: - Router
protocol IWatchlistRouter: AnyObject {
    //func showStockDetail(with model: StockDetailModel)
}

// Пример имплементации WatchlistRouter
class WatchlistRouter {
    weak var view: IWatchlistViewController?
    //weak var viewController: UIViewController?
    
//    func showStockDetail(with model: StockDetailModel) {
//        let stockDetailViewController = StockDetailViewController(stockDetailModel: model)
//        viewController?.navigationController?.pushViewController(stockDetailViewController, animated: true)
//    }
}

extension WatchlistRouter: IWatchlistRouter {
    
}
//protocol IVIPERRouter: AnyObject
//{
//    func nextModule()
//}
//
//final class VIPERRouter {}
//
//extension VIPERRouter: IVIPERRouter
//{
//    func nextModule() {
//        // routing
//    }
//}
