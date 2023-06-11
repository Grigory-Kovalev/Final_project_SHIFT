//
//  WatchlistViewController.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

final class WatchlistViewController: UIViewController {
    
    private var dataArray = [LastPriceModel]()
    
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
        
        WSManager.shared.connectToWebSocket() // подключаемся
        WSManager.shared.subscribeBtcUsd() //подписываемся на получение данных
        self.getData() //получаем данные
        
    }
    
    //    override func loadView() {
    //
    //    }
    private func getData() {
        //получаем данные
        WSManager.shared.receiveData() { [weak self] (data) in
            guard let self = self else { return }
            guard let data = data else { return }
            //self.dataArray = data // кладем данные в переменную и дальше можно делать с ними то что требуется
            print(data)
        }
    }
}
