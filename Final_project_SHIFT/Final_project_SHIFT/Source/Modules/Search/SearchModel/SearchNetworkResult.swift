//
//  SearchNetworkResult.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 16.06.2023.
//

import Foundation

struct SearchNetworkResult {
    let count: Int
    let result: [Stock]
    
    init(from dto: SearchNetworkResultDTO) {
        self.count = dto.count
        self.result = Stock.getStocks(from: dto)
    }
}

struct Stock {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String

    init(from dto: StockDTO) {
        description = dto.description
        displaySymbol = dto.displaySymbol
        symbol = dto.symbol
        type = dto.type
    }
    
    static func getStocks(from dto: SearchNetworkResultDTO) -> [Stock] {
         return dto.result.map { Stock(from: $0) }
    }
}
