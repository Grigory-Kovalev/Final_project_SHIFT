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
        return Double(stockDetailModel.candles.o.first ?? 0) < Double(stockDetailModel.candles.c.last ?? 0)
    }
    
    var priceDifference: (sign: String, price: String){
        let difference = Double(stockDetailModel.candles.c.last ?? 0) - Double(stockDetailModel.candles.o.first ?? 0)
        let price = String(format: "%.2f", abs(difference))
        let sign = "\(difference > 0 ? "+" : "-")"
        return (sign, price)
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
    
    var getCurrencySymbol: String {
        
        stockDetailModel.stockProfile.currency.getCurrencySymbol()
    }
    
    init(selectedResolution: Int, data: [CandleChartModel], stock: StockDetailModel) {
        self._candles = State(initialValue: data)
        self._selectedResolution = State(initialValue: selectedResolution)
        self.stockDetailModel = stock
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack(alignment: .leading) {
                    Text(stockDetailModel.stockProfile.name)
                        .font(.headline)
                        .fontWeight(.black)
                    
                    HStack {
                        Text("\(getCurrencySymbol)\(latestPrice.formatted())")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(Resources.Colors.green))
                        
                        Spacer()
                        
                        HStack {
                            Text("\(priceDifference.sign)\(getCurrencySymbol)\(priceDifference.price)")
                                .foregroundColor(Color(Resources.Colors.gray))
                            Text("(\(percentageDifference)%)")
                                .foregroundColor(isPriceRise ? Color(Resources.Colors.green) : Color.red)
                        }
                        .font(.title3)
                    }
                }
                .padding(.horizontal, 16)
                
                Picker("Resolution", selection: $selectedResolution) {
                    Text("\(TimeFrameResolution.fifteenMinutes.rawValue)M").tag(2)
                    Text("\(TimeFrameResolution.thirtyMinutes.rawValue)M").tag(3)
                    Text("\(TimeFrameResolution.hour.rawValue)M").tag(4)
                    Text(TimeFrameResolution.day.rawValue).tag(5)
                    Text(TimeFrameResolution.weekend.rawValue).tag(6)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
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
                
                ScrollView(showsIndicators: false) {
                    VStack {
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
                        .padding(.top, 20)
                        
                        CompanyProfileView(stockProfileModel: stockDetailModel.stockProfile)
                            .padding(.horizontal, -16)
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
        }
    }
}
