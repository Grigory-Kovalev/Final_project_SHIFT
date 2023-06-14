//
//  WatchlistModuleBuilder.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import UIKit

class WatchlistModuleBuilder {
    static func build() -> WatchlistViewController {
        let interactor = WatchlistInteractor()
        let router = WatchlistRouter()
        let presenter = WatchlistPresenter(interactor: interactor, router: router)
        let viewController = WatchlistViewController()
        viewController.delegate = presenter
        viewController.presenter = presenter
        presenter.view = viewController
        interactor.presentor = presenter
        router.presentor = presenter
        return viewController
    }
}
