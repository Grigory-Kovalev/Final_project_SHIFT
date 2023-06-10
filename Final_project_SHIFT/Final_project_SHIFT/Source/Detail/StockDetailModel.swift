//
//  StockDetailModel.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 08.06.2023.
//

import Foundation

struct StockDetailModel {
    let symbol: String
    let stockProfile: StockProfileModel
    let currentRange: TimeFrameResolution
    var candles: Candles
}

extension StockDetailModel {
    init() {
        self.symbol = ""
        self.stockProfile = StockProfileModel(country: "", currency: "", estimateCurrency: "", exchange: "", finnhubIndustry: "", ipo: "", logo: "", marketCapitalization: 0, name: "", phone: "", shareOutstanding: 0, ticker: "", weburl: "")
        self.currentRange = .weekend
        self.candles = Candles(c: [Double](), h: [Double](), l: [Double](), o: [Double](), s: "", t: [Int](), v: [Int]())
    }
}
