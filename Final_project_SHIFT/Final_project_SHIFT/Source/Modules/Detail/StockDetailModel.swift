//
//  StockDetailModel.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 08.06.2023.
//

import Foundation

struct StockDetailModel {
    let symbol: String
    let companyName: String
    let stockProfile: StockProfileModel
    let currentRange: TimeFrameResolution
    var candles: Candles
}
