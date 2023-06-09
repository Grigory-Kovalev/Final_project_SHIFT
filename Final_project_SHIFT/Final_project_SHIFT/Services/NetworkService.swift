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

struct StockProfile: Codable {
    let country: String
    let currency: String
    let estimateCurrency: String
    let exchange: String
    let finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Double
    let name: String
    let phone: String
    let shareOutstanding: Double
    let ticker: String
    let weburl: String
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
        case .minute: return 0
        case .fiveMinutes: return 1
        case .fifteenMinutes: return 2
        case .thirtyMinutes: return 3
        case .hour: return 4
        case .day: return 5
        case .weekend: return 6
        }
    }
    
    static func getTimeframeFromTag(tag: Int) -> TimeFrameResolution {
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
    }
    
    func getTimeInterval(timeframe: TimeFrameResolution) -> (from: Int, to: Int) {
        // Получаем текущую дату и время
        let calendar = Calendar.current
        let currentDate = Date()

        let minute = 60
        let hour = minute * 60
        let day = hour * 24
        let candlesCount = 50
        
        switch timeframe {
        case .minute:
            // Возвращаем интервал для минуты
            let startTime = calendar.date(byAdding: .second, value: -(minute * candlesCount), to: currentDate)!
            return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .fiveMinutes:
            // Возвращаем интервал для пяти минут
            let startTime = calendar.date(byAdding: .second, value: -(minute * 5 * candlesCount), to: currentDate)!
            return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .fifteenMinutes:
            // Возвращаем интервал для пятнадцати минут
            let startTime = calendar.date(byAdding: .second, value: -(minute * 15 * candlesCount), to: currentDate)!
            return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .thirtyMinutes:
            // Возвращаем интервал для тридцати минут
            let startTime = calendar.date(byAdding: .second, value: -(minute * 30 * candlesCount), to: currentDate)!
            return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .hour:
            // Возвращаем интервал для часа
            let startTime = calendar.date(byAdding: .second, value: -(hour  * candlesCount), to: currentDate)!
            return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .day:
            // Возвращаем интервал для дня
            let startTime = calendar.date(byAdding: .second, value: -(day * candlesCount), to: currentDate)!
            return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
            
        case .weekend:
            // Возвращаем интервал для недели
            let startTime = calendar.date(byAdding: .second, value: -(day * 7 * candlesCount), to: currentDate)!
            return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
        }
    }
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
    
    func fetchStockProfile(symbol: String, completion: @escaping (Result<StockProfileModel, Error>) -> Void) {
        let urlString = "https://finnhub.io/api/v1/stock/profile2?symbol=\(symbol)&token=c8s4fv2ad3idbo5bhsbg"
        
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
                let stockProfile = try decoder.decode(StockProfileModel.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(stockProfile))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
