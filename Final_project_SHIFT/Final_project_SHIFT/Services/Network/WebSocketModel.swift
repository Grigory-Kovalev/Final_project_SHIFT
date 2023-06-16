//
//  WebSocketModel.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation

// MARK: - LastPriceModel
struct LastStocksDataModelDTO: Codable {
    let data: [LastStockDataModelDTO]
    let type: String
}

// MARK: - Datum
struct LastStockDataModelDTO: Codable {
    let p: Double
    let s: String
    let t: Int
    let v: Double
}

