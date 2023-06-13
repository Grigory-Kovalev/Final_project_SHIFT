//
//  CandlesChartView.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 08.06.2023.
//

import Charts
import SwiftUI

//MARK: - CandleChart

struct CandlesChartView: View {
    
    @Binding var candles: [CandleChartModel]
    
    var minY: Double {
        let minClose = candles.map { $0.close }.min() ?? 0
        let minYOffset = minClose * 0.005
        let result = minClose - minYOffset
        return result
    }
    
    var maxY: Double {
        let maxClose = candles.map { $0.close }.max() ?? 0
        let maxYOffset = maxClose * 0.005
        let result = maxClose + maxYOffset
        return result
    }
    
    var minX: Double {
        Double(candles.map { $0.timestamp }.min() ?? 0)
    }
    
    var maxX: Double {
        Double(candles.map { $0.timestamp }.max() ?? 0)
    }
    
    var xAxis: [Double] {
        let minValue = minX
        let maxValue = maxX
        let numberOfValues = 5
        
        let step = (maxValue - minValue) / Double(numberOfValues - 1)
        
        let values = (0..<numberOfValues).map { index in
            minValue + Double(index) * step
        }
        return values
    }
    
    var minDate: String {
        candles.map { $0.date }.first ?? ""
    }
    var maxDate: String {
        candles.map { $0.date }.last ?? ""
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(candles) { item in
                    RectangleMark(x: .value("Time", item.timestamp), yStart: .value("Low price", item.low), yEnd: .value("High price", item.high), width: 1)
                        .opacity(0.4)
                        .foregroundStyle(.gray)
                    RectangleMark(x: .value("Time", item.timestamp), yStart: .value("Open price", item.open), yEnd: .value("Close price", item.close), width: 4)
                        .foregroundStyle(item.color)
                }
            }
            .chartXAxis {
                AxisMarks(values: xAxis) { AxisGridLine() }
            }
            .frame(height: 400)
            .chartYScale(domain: minY...maxY)
            .chartXScale(domain: minX...maxX)
            
            .chartXAxisLabel(minDate, position: .automatic)
            .chartXAxisLabel(maxDate, position: .bottom, alignment: .trailing)
        }
    }
}
