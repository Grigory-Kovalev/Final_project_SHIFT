//
//  NetworkService.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import Foundation
import SwiftUI

struct SearchNetworkResult: Codable {
    let count: Int
    let result: [Stock]
}

struct Stock: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}

struct Candles: Codable {
    let c, h, l, o: [Double]
    let s: String
    let t, v: [Int]
    
    static func getCandles(candles: Candles) -> [Candle] {
        var candleArray = [ Candle]()
        
        let firstCandleColor: Color = .green
        let firstCandle = Candle(close: candles.c[0], high: candles.h[0], low: candles.l[0], open: candles.o[0], timestamp: candles.t[0], volume: candles.v[0], color: firstCandleColor)
        candleArray.append(firstCandle)
        
        for index in 1..<candles.c.count {
            let previousCandle = candleArray[index-1]
            let currentCandleColor: Color = candles.c[index] > previousCandle.close ? .green : .red
            
            let candle = Candle(close: candles.c[index], high: candles.h[index], low: candles.l[index], open: candles.o[index], timestamp: candles.t[index], volume: candles.v[index], color: currentCandleColor)
            candleArray.append(candle)
        }
        return candleArray
    }
}

enum TimeFrameResolution: String {
    case minute = "1"
    case fiveMinutes = "5"
    case fifteenMinutes = "15"
    case thirtyMinutes = "30"
    case hour = "60"
    case day = "D"
    case weekend = "W"
    
    func getTag() -> Int {
        switch self {
        case .minute: return 0 //Binding.constant(0)
        case .fiveMinutes: return 1 //Binding.constant(1)
        case .fifteenMinutes: return 2 //Binding.constant(2)
        case .thirtyMinutes: return 3 //Binding.constant(3)
        case .hour: return 4 //Binding.constant(4)
        case .day: return 5 //Binding.constant(5)
        case .weekend: return 6 //Binding.constant(6)
        }
    }
    
    static func getTimeframeFromTag(tag: Int) -> TimeFrameResolution {
        //var result: TimeFrameResolution = .day
        switch tag {
        case 0:  return  .minute
        case 1:  return .fiveMinutes
        case 2:  return .fifteenMinutes
        case 3:  return .thirtyMinutes
        case 4:  return .hour
        case 5:  return .day
        case 6:  return .weekend
        default: return .minute
        }
        //return result
    }
    
    func getTimeInterval(timeframe: TimeFrameResolution) -> (from: Int, to: Int) {
        let calendar = Calendar.current
        // Получаем текущую дату и время
        let currentDate = Date()

        let minute = 60
        let hour = minute * 60
        let day = hour * 24
        let candlesCount = 50
        
        switch timeframe {
        case .minute:
            // Возвращаем интервал для минуты (в данном случае 1 минута)
            let oneMinutesAgoDate = calendar.date(byAdding: .second, value: -(minute * 15 * candlesCount), to: currentDate)!
            return (Int(oneMinutesAgoDate.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .fiveMinutes:
            // Возвращаем интервал для пяти минут
            let fiveMinutesAgoDate = calendar.date(byAdding: .second, value: -(minute * 5 * candlesCount), to: currentDate)!
            return (Int(fiveMinutesAgoDate.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .fifteenMinutes:
            // Возвращаем интервал для пятнадцати минут
            let fifteenMinutesAgoDate = calendar.date(byAdding: .second, value: -(minute * 15 * candlesCount), to: currentDate)!
            return (Int(fifteenMinutesAgoDate.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .thirtyMinutes:
            // Возвращаем интервал для тридцати минут
            let thirtyMinutesAgoDate = calendar.date(byAdding: .second, value: -(minute * 30 * candlesCount), to: currentDate)!
            return (Int(thirtyMinutesAgoDate.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .hour:
            // Возвращаем интервал для часа
            let oneHourAgoDate = calendar.date(byAdding: .second, value: -(hour * 2 * candlesCount), to: currentDate)!
            return (Int(oneHourAgoDate.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .day:
            // Возвращаем интервал для дня (в данном случае 1 день)
            let oneYearAgoDate = calendar.date(byAdding: .second, value: -(day * candlesCount), to: currentDate)!
            return (Int(oneYearAgoDate.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .weekend:
            // Возвращаем интервал для недели (в данном случае 7 дней)
            let oneWeekAgoDate = calendar.date(byAdding: .second, value: -(day * 7 * candlesCount), to: currentDate)!
            return (Int(oneWeekAgoDate.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
        }
    }
    
//    func getTimeInterval(timeframe: TimeFrameResolution) -> (from: Int, to: Int) {
//        switch timeframe {
//        case .minute: return getTimeInterval(timeframe: .minute)
//        case .fiveMinutes: return getTimeInterval(timeframe: .fiveMinutes)
//        case .fifteenMinutes: return getTimeInterval(timeframe: .fifteenMinutes)
//        case .thirtyMinutes: return getTimeInterval(timeframe: .thirtyMinutes)
//        case .hour: return getTimeInterval(timeframe: .hour)
//        case .day: return getTimeInterval(timeframe: .day)
//        case .weekend: return getTimeInterval(timeframe: .weekend)
//        }
//    }
}

final class NetworkService {
    func fetchSymbolLookup(symbol: String, completion: @escaping (Result<[Stock], Error>) -> Void) {
        
        let urlString = "https://finnhub.io/api/v1/search?q=\(symbol)&token=c8s4fv2ad3idbo5bhsbg"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(SearchNetworkResult.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result.result))
                }
                
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchStockCandles(symbol: String, timeFrame: TimeFrameResolution, completion: @escaping (Result<Candles, Error>) -> Void) {
        
        let firstTime = timeFrame.getTimeInterval(timeframe: timeFrame).from
        let secondTime = timeFrame.getTimeInterval(timeframe: timeFrame).to
        
        let urlString = "https://finnhub.io/api/v1/stock/candle?symbol=\(symbol)&resolution=\(timeFrame.rawValue)&from=\(Int(firstTime))&to=\(Int(secondTime))&token=c8s4fv2ad3idbo5bhsbg"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let candles = try decoder.decode(Candles.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(candles))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
