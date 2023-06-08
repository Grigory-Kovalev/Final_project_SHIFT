//
//  DetailSwiftUI.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import SwiftUI
import Charts

//MARK: - DetailView


struct DetailSwiftUI: View {
    
    @State private var data: [Candle]
    
    @State private var selectedResolution: Int
    
    init(selectedResolution: Int, data: [Candle], stock: StockDetailModel) {
        self._data = State(initialValue: data)
        self._selectedResolution = State(initialValue: selectedResolution)
        self.stock = stock
    }
    
    let networkManager = NetworkService()
    
    @State var stock: StockDetailModel
    
    var latestPrice: Double {
        stock.candles.c.last ?? 0
    }
    
    var isGreen: Bool {
        return Double(stock.candles.o.first ?? 0) > Double(stock.candles.c.last ?? 0)
    }
    
    var priceDifference: String {
        let difference = Double(stock.candles.c.last ?? 0) - Double(stock.candles.o.first ?? 0)
        return String(format: "%.2f", difference)
    }
    
    var percentageDifference: String {
        let percentage = ((Double(stock.candles.c.last ?? 0) / Double(stock.candles.o.first ?? 0) - 1) * 100)
        return String(format: "%.2f", percentage)
    }
    
    var maxPrice: String {
        return stock.candles.h.max()?.formatted() ?? ""
    }
    
    var minPrice: String {
        return stock.candles.l.min()?.formatted() ?? ""
    }

    var minDate: String {
        data.map { $0.date }.first ?? ""
    }
    var maxDate: String {
        data.map { $0.date }.last ?? ""
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Название: \(stock.companyName)")
                            .bold()
                            .font(.headline)

                        Text("Тикер: \(stock.symbol)")
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
                    Text(TimeFrameResolution.minute.rawValue).tag(0)
                    Text(TimeFrameResolution.fiveMinutes.rawValue).tag(1)
                    Text(TimeFrameResolution.fifteenMinutes.rawValue).tag(2)
                    Text(TimeFrameResolution.thirtyMinutes.rawValue).tag(3)
                    Text(TimeFrameResolution.hour.rawValue).tag(4)
                    Text(TimeFrameResolution.day.rawValue).tag(5)
                    Text(TimeFrameResolution.weekend.rawValue).tag(6)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedResolution) { newValue in
                    networkManager.fetchStockCandles(symbol: stock.symbol, timeFrame: TimeFrameResolution.getTimeframeFromTag(tag: selectedResolution)) { result in
                        switch result {
                        case .success(let fetchedCandles):
                            // Обработка полученных данных о свечах
                            stock.candles = fetchedCandles
                            data = Candles.getCandles(candles: fetchedCandles)
                        case .failure(let error):
                            // Обработка ошибки запроса свечей
                            print("Error fetching candles: \(error)")
                        }
                    }
                }

                ScrollView {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                        CandleChart(candles: $data)
                            .padding()
                            .clipped()
                    }
                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.5)
                    .padding(.top, 50)

                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text(minDate)
                            Spacer()
                            Text(maxDate)
                        }
                        .foregroundColor(.pink)
                        .padding(.horizontal)
                        
                        Text("Максимальная цена за \(stock.currentRange.rawValue): $\(maxPrice)")
                        Text("Минимальная цена за \(stock.currentRange.rawValue): $\(minPrice)")
                        
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

//MARK: - CandleChart

struct CandleChart: View {
    
    @Binding var candles: [Candle]
    
    var minY: Double {
        let minClose = candles.map { $0.close }.min() ?? 0
        print("minClose \(minClose)")
        let minYOffset = minClose * 0.005
        print("minYOffset \(minYOffset)")
        let result = minClose - minYOffset
        print("result \(result)")
        print("--------------------------------------")
        return result
        //candles.map { $0.close }.min() ?? 0
    }
    
    var maxY: Double {
        let maxClose = candles.map { $0.close }.max() ?? 0
        print("maxClose \(maxClose)")
        let maxYOffset = maxClose * 0.005
        print("maxYOffset \(maxYOffset)")
        let result = maxClose + maxYOffset
        print("result \(result)")
        print("----------------------------------------------------------------------------")
        return result
        //candles.map { $0.close }.max() ?? 0
    }
    
    var minX: Int {
//        let minTimestamp = candles.map { $0.timestampValue }.min() ?? 0
//        let minYOffset = minTimestamp * 0.005
//        let result = minTimestamp - minYOffset
//        return result
//        let a = candles.map { $0.timestamp }.max() ?? 0
//        print(a)
//        print(Date(timeIntervalSince1970: TimeInterval(a)))
         candles.map { $0.timestamp }.min() ?? 0
    }

    var maxX: Int {
//        let maxTimestamp = candles.map { $0.timestampValue }.max() ?? 0
//        let maxYOffset = maxTimestamp * 0.000000005
//        let result = maxTimestamp + maxYOffset
//        return result
        candles.map { $0.timestamp }.max() ?? 0
    }

    
    var body: some View {
        VStack {
            Chart {
                ForEach(candles) { item in
                    RectangleMark(x: .value("", item.timestamp), yStart: .value("Low price", item.low), yEnd: .value("High price", item.high), width: 2)
                        .opacity(0.4)
                        .foregroundStyle(.gray)
                    RectangleMark(x: .value("", item.timestamp), yStart: .value("Open price", item.open), yEnd: .value("Close price", item.close), width: 4)
                        .foregroundStyle(item.color)
                }
            }
            .frame(height: 400)
            .chartYScale(domain: minY...maxY)
            .chartXScale(domain: minX...maxX)
            .chartXAxis(.hidden)
//            .chartXAxis {
//                AxisMarks(values: candles.map { $0.date }) { date in
//                    AxisValueLabel(format: .dateTime.day())
//                }
//            }
        }
    }
}


//MARK: - Model

struct Candle: Identifiable {
    var id = UUID()
    let close, high, low, open: Double
    let timestamp, volume: Int
    let color: Color
    
    var date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        //return Date(timeIntervalSince1970: TimeInterval(timestamp))
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
    
//    var timestampValue: Double {
//        let referenceDate = Date(timeIntervalSinceReferenceDate: 0) // Начальная дата для вычисления временных интервалов
//        let candleDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
//        return candleDate.timeIntervalSince(referenceDate)
//    }
}


struct StockDetailModel {
    let symbol: String
    let companyName: String
    
    let currentRange: TimeFrameResolution
    var candles: Candles
}
