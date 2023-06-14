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
    
    private func timeIntervalCondition(timeframe: TimeFrameResolution) -> (Int, Int) {
        
        let secondsInMinute = 60
        let secondsInHour = secondsInMinute * 60
        let secondsInDay = secondsInHour * 24
        let candlesCount = 50
        
        let intervalDifference: Int
        
        switch timeframe {
        case .minute:
            intervalDifference = 0
        case .fiveMinutes:
            intervalDifference = -(secondsInMinute * 5 * candlesCount)
        case .fifteenMinutes:
            intervalDifference = -(secondsInMinute * 15 * candlesCount)
        case .thirtyMinutes:
            intervalDifference = -(secondsInMinute * 30 * candlesCount)
        case .hour:
            intervalDifference = -(secondsInHour  * candlesCount)
        case .day:
            intervalDifference = -(secondsInDay * candlesCount)
        case .weekend:
            intervalDifference = -(secondsInDay * 7 * candlesCount)
        }
        
        // Получаем текущую дату и время
        var calendar = Calendar.current
        let newYorkTimeZone = TimeZone(identifier: "America/New_York")
        calendar.timeZone = newYorkTimeZone!
        let currentDate = Date()
        
        // Получаем компоненты текущей даты и времени
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: currentDate)
        let weekday = components.weekday ?? 1
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        // Проверяем, является ли текущий день недели рабочим днем (понедельник - пятница) и время находится в пределах рабочих часов (9:30 - 16:00)
            let isTradingHours = (weekday >= 2 && weekday <= 6) && (hour > 9 || (hour == 9 && minute >= 30)) && (hour < 16)
        var startTime = Date()
        
//        guard timeframe != .weekend else {
//            let startTime = calendar.date(byAdding: .second, value: intervalDifference, to: currentDate)!
//            return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
//        }
        
        if isTradingHours {
            startTime = calendar.date(byAdding: .second, value: intervalDifference, to: currentDate)!
        } else {
            
            if weekday >= 3 && weekday <= 6 {
                let lastTradingDay = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                let lastTradingHours = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: lastTradingDay)!
                startTime = calendar.date(byAdding: .second, value: intervalDifference, to: lastTradingHours)!
            } else if weekday == 2 {
                let lastTradingDay = calendar.date(byAdding: .day, value: 0, to: currentDate)!
                let lastTradingHours = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: lastTradingDay)!
                startTime = calendar.date(byAdding: .second, value: intervalDifference, to: lastTradingHours)!
            } else if weekday == 7 {
                let lastTradingDay = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                let lastTradingHours = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: lastTradingDay)!
                startTime = calendar.date(byAdding: .second, value: intervalDifference, to: lastTradingHours)!
            } else if weekday == 1 {
                let lastTradingDay = calendar.date(byAdding: .day, value: -2, to: currentDate)!
                let lastTradingHours = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: lastTradingDay)!
                startTime = calendar.date(byAdding: .second, value: intervalDifference, to: lastTradingHours)!
            }
        }
//        print(startTime.timeIntervalSince1970)
//        print(currentDate.timeIntervalSince1970)
//        print("-----------------------------")
        return (Int(startTime.timeIntervalSince1970), Int(currentDate.timeIntervalSince1970))
    }
    
    func getTimeInterval(timeframe: TimeFrameResolution) -> (from: Int, to: Int) {
        
        switch timeframe {
        case .minute:
            // Возвращаем интервал для минуты
            return timeIntervalCondition(timeframe: self)
            
        case .fiveMinutes:
            // Возвращаем интервал для пяти минут
            return timeIntervalCondition(timeframe: self)
            
        case .fifteenMinutes:
            return timeIntervalCondition(timeframe: self)
            // Возвращаем интервал для пятнадцати минут
            
        case .thirtyMinutes:
            // Возвращаем интервал для тридцати минут
            return timeIntervalCondition(timeframe: self)
            
        case .hour:
            // Возвращаем интервал для часа
            return timeIntervalCondition(timeframe: self)

        case .day:
            // Возвращаем интервал для дня
            return timeIntervalCondition(timeframe: self)
            
        case .weekend:
            // Возвращаем интервал для недели
            return timeIntervalCondition(timeframe: self)
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

// MARK: - LastPriceModel
struct LastStocksDataModel: Codable {
    let data: [LastStockDataModel]
    let type: String
}

// MARK: - Datum
struct LastStockDataModel: Codable {
    let p: Double
    let s: String
    let t: Int
    let v: Double
}

class WSManager {
    static let shared = WSManager()
    private init() {}
    
    private var dataArray = [LastStocksDataModel]()
    private var data: LastStocksDataModel?
    
    let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c8s4fv2ad3idbo5bhsbg")!)
    
    // Функция вызова подключения
    func connectToWebSocket() {
        if webSocketTask.state == .suspended || webSocketTask.state == .completed {
            webSocketTask.resume()
            receiveData { _ in }
            print("Success connect")
        } else {
            print("Already connected or in progress")
        }
    }
    
    // Функция вызова отключения
    func disconnectWebSocket() {
        if webSocketTask.state == .running || webSocketTask.state == .suspended {
            webSocketTask.cancel(with: .goingAway, reason: nil)
            print("Success disconnect")
        } else {
            print("No active connection to disconnect")
        }
    }
    
    // Функция подписки на что-либо  {"type": "subscribe", "symbol": "BINANCE:BTCUSDT"}
    func subscribeTo(symbols: [String]) {
        if !symbols.isEmpty {
            for symbol in symbols {
                let message = URLSessionWebSocketTask.Message.string("{\"type\": \"subscribe\", \"symbol\": \"\(symbol)\"}")
                webSocketTask.send(message) { error in
                    if let error = error {
                        print("WebSocket couldn’t send message because: \(error)")
                    }
                }
            }
        }
    }

    // Функция отписки от чего-либо
    func unSubscribeFrom(symbols: [String]) {
        if !symbols.isEmpty {
            for symbol in symbols {
                let message = URLSessionWebSocketTask.Message.string("{\"type\": \"unsubscribe\", \"symbol\": \"\(symbol)\"}")
                webSocketTask.send(message) { error in
                    if let error = error {
                        print("WebSocket couldn’t send message because: \(error)")
                    }
                }
            }
        }
    }

    
    // Функция получения данных
    func receiveData(completion: @escaping (LastStocksDataModel?) -> Void) {
        webSocketTask.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    if text == "{\"type\":\"ping\"}" {
                        // Отправка сообщения "pong" в ответ на "ping"
                        let pongMessage = URLSessionWebSocketTask.Message.string("{\"type\":\"pong\"}")
                        self?.webSocketTask.send(pongMessage) { error in
                            if let error = error {
                                print("WebSocket couldn’t send message because: \(error)")
                            }
                        }
                    } else {
                        let data: Data? = text.data(using: .utf8)
                        let srvData = try? JSONDecoder().decode(LastStocksDataModel.self, from: data ?? Data())
                        if let srvData = srvData {
                            self?.data = srvData
                            self?.dataArray.append(srvData)
                        }
                    }
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    debugPrint("Unknown message")
                }
                
                self?.receiveData(completion: completion) // Рекурсия
            }
        }
        completion(self.data) // Отправляем в комплишн
    }

}
