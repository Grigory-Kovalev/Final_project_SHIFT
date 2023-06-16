//
//  NetworkServiceModel.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation
import SwiftUI

struct SearchNetworkResultDTO: Codable {
    let count: Int
    let result: [StockDTO]
}

struct StockDTO: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}

struct CandlesDTO: Codable {
    let c, h, l, o: [Double]
    let s: String
    let t, v: [Int]
}


struct StockProfileModelDTO: Codable {
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
        let newYorkTimeZone = TimeZone(identifier: Resources.Strings.exchangeTimeZone)
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
