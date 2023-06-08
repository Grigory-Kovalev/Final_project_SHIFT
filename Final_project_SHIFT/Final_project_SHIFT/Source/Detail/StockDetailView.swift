//
//  DetailSwiftUI.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SwiftUI
import Charts

//MARK: - DetailView

struct StockDetailView: View {
    @State var stockDetailModel: StockDetailModel
    @State private var candles: [CandleChartModel]
    //Состояние для отслеживания загрузки данных
    @State private var isLoading: Bool = false
    //Tag выбранного таймфрейма
    @State private var selectedResolution: Int
    
    let networkManager = NetworkService()
    
    var latestPrice: Double {
        stockDetailModel.candles.c.last ?? 0
    }
    
    var isPriceRise: Bool {
        return Double(stockDetailModel.candles.o.first ?? 0) > Double(stockDetailModel.candles.c.last ?? 0)
    }
    
    var priceDifference: String {
        let difference = Double(stockDetailModel.candles.c.last ?? 0) - Double(stockDetailModel.candles.o.first ?? 0)
        return String(format: "%.2f", difference)
    }
    
    var percentageDifference: String {
        let percentage = ((Double(stockDetailModel.candles.c.last ?? 0) / Double(stockDetailModel.candles.o.first ?? 0) - 1) * 100)
        return String(format: "%.2f", percentage)
    }
    
    var maxPrice: String {
        return stockDetailModel.candles.h.max()?.formatted() ?? ""
    }
    
    var minPrice: String {
        return stockDetailModel.candles.l.min()?.formatted() ?? ""
    }
    
    init(selectedResolution: Int, data: [CandleChartModel], stock: StockDetailModel) {
        self._candles = State(initialValue: data)
        self._selectedResolution = State(initialValue: selectedResolution)
        self.stockDetailModel = stock
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Название: \(stockDetailModel.companyName)")
                            .bold()
                            .font(.headline)
                        
                        Text("Тикер: \(stockDetailModel.symbol)")
                    }
                    .padding(.leading, 16)
                    Spacer()
                    VStack(alignment: .center, spacing: 15) {
                        Text("Текущая цена: $\(latestPrice.formatted())")
                    }
                    .padding(.trailing)
                }
                
                Divider()
                
                Spacer()
                
                Picker("Resolution", selection: $selectedResolution) {
                    Text("\(TimeFrameResolution.fifteenMinutes.rawValue)M").tag(2)
                    Text("\(TimeFrameResolution.thirtyMinutes.rawValue)M").tag(3)
                    Text("\(TimeFrameResolution.hour.rawValue)M").tag(4)
                    Text(TimeFrameResolution.day.rawValue).tag(5)
                    Text(TimeFrameResolution.weekend.rawValue).tag(6)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedResolution) { newValue in
                    isLoading = true
                    
                    networkManager.fetchStockCandles(symbol: stockDetailModel.symbol, timeFrame: TimeFrameResolution.getTimeframeFromTag(tag: selectedResolution)) { result in
                        switch result {
                        case .success(let fetchedCandles):
                            stockDetailModel.candles = fetchedCandles
                            candles = Candles.getCandles(candles: fetchedCandles)
                        case .failure(let error):
                            print("Error fetching candles: \(error)")
                        }
                        isLoading = false
                    }
                }
                
                ScrollView {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                        
                        CandlesChartView(candles: $candles)
                            .padding()
                            .clipped()
                            .blur(radius: isLoading ? 10 : 0)
                        
                        if isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.5)
                    .padding(.top, 50)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Максимальная цена за \(stockDetailModel.currentRange.rawValue): $\(maxPrice)")
                        Text("Минимальная цена за \(stockDetailModel.currentRange.rawValue): $\(minPrice)")
                        
                        Text("Разница в цене за указанный период: $\(priceDifference) или \(percentageDifference)%")
                    }
                    .padding(.top, 40)
                }
                .frame(width: geo.size.width)
                
                Spacer()
            }
        }
    }
}
