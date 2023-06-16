//
//  Candles.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 16.06.2023.
//

import SwiftUI

struct Candles {
    let c, h, l, o: [Double]
    let s: String
    let t, v: [Int]

    init(from dto: CandlesDTO) {
        c = dto.c
        h = dto.h
        l = dto.l
        o = dto.o
        s = dto.s
        t = dto.t
        v = dto.v
    }
    static func getCandles(candles: Candles) -> [CandleChartModel] {
        var candleArray = [ CandleChartModel]()
        
        let firstCandleColor: Color = .green
        let firstCandle = CandleChartModel(close: candles.c[0], high: candles.h[0], low: candles.l[0], open: candles.o[0], timestamp: candles.t[0], volume: candles.v[0], color: firstCandleColor)
        candleArray.append(firstCandle)
        
        for index in 1..<candles.c.count {
            let previousCandle = candleArray[index-1]
            let currentCandleColor: Color = candles.c[index] > previousCandle.close ? .green : .red
            
            let candle = CandleChartModel(close: candles.c[index], high: candles.h[index], low: candles.l[index], open: candles.o[index], timestamp: candles.t[index], volume: candles.v[index], color: currentCandleColor)
            candleArray.append(candle)
        }
        return candleArray
    }
}
