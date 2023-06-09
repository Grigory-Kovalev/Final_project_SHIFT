//
//  StockProfileModel.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 09.06.2023.
//

import Foundation

struct StockProfileModel: Codable {
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
