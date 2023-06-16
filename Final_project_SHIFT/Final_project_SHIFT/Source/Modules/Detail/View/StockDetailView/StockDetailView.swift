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
    @State private var showAlert = false
    let latestPrice: Double
        
//    var latestPrice: Double {
//        stockDetailModel.candles.c.last ?? 0
//    }
    
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
    
    init(selectedResolution: Int, data: [CandleChartModel], stock: StockDetailModel, latestPrice: Double) {
        self._candles = State(initialValue: data)
        self._selectedResolution = State(initialValue: selectedResolution)
        self.stockDetailModel = stock
        self.latestPrice = latestPrice
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
                    Text("\(TimeFrameResolution.thirtyMinutes.rawValue)M").tag(3)
                    Text("1H").tag(4)
                    Text(TimeFrameResolution.day.rawValue).tag(5)
                    Text(TimeFrameResolution.weekend.rawValue).tag(6)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedResolution) { newValue in
                    let stockDetailViewModel = StockDetailViewModel(stockDetailModel: $stockDetailModel, candles: $candles, isLoading: $isLoading, showAlert: $showAlert)
                    stockDetailViewModel.fetchStockCandles(selectedResolution: newValue)
                }
                
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(Resources.Strings.StockDetailScreen.alertErrorTitle), message: Text(Resources.Strings.StockDetailScreen.alertErrorMessage), dismissButton: .default(Text("OK")))
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
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
        }
    }
}
