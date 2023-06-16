//
//  NetworkServiceModel.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation
import SwiftUI

struct SearchNetworkResultDTO: Codable {
    let count: Int
    let result: [StockDTO]
}

struct StockDTO: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}

struct CandlesDTO: Codable {
    let c, h, l, o: [Double]
    let s: String
    let t, v: [Int]
}


struct StockProfileModelDTO: Codable {
    let country: String
    let currency: String
    let estimateCurrency: String
    let exchange: String
    let finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Double
    let name: String
    let phone: String
    let shareOutstanding: Double
    let ticker: String
    let weburl: String
}
