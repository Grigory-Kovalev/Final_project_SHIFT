//
//  WatchlistEntity.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 13.06.2023.
//

import Foundation

// Протокол модели
protocol WatchlistModelProtocol {
    var ticker: String { get }
    var name: String { get }
    var logo: String { get }
    var price: Double { get set }
    var currency: String { get }
}


struct WatchlistModel {
    let ticker: String
    let name: String
    let logo: String
    var price: Double
    let currency: String
}
