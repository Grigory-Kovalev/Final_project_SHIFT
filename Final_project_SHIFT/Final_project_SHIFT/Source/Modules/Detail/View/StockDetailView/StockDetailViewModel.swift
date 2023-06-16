//
//  StockDetailViewModel.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 16.06.2023.
//

import SwiftUI

struct StockDetailViewModel {
    @Binding var stockDetailModel: StockDetailModel
    @Binding var candles: [CandleChartModel]
    @Binding var isLoading: Bool
    @Binding var showAlert: Bool
    
    private let networkManager = NetworkService()
    func fetchStockCandles(selectedResolution: Int) {
        isLoading = true
        
        networkManager.fetchStockCandles(symbol: stockDetailModel.symbol, timeFrame: TimeFrameResolution.getTimeframeFromTag(tag: selectedResolution)) {result in
            switch result {
            case .success(let fetchedCandles):
                self.stockDetailModel.candles = fetchedCandles
                DispatchQueue.main.async {
                    self.$candles.wrappedValue = Candles.getCandles(candles: fetchedCandles)
                }
            case .failure(let error):
                self.showAlert = true
                print("Error fetching candles: \(error)")
            }
            
            self.isLoading = false
        }
    }
}



