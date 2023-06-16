//
//  FinhubExchangeManager.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation

class FinhubExchangeManager {
    static var exchangeName: String? {
        let supportedExchanges = ["NYSE", "NASDAQ", "LSE", "TSE", "HKEX"]

        for exchange in supportedExchanges {
            if isExchangeOpen(exchange) {
                return exchangeName(for: exchange)
            }
        }

        return nil
    }

    static func exchangeName(for exchange: String) -> String {
        switch exchange {
            //Нью-Йоркская фондовая биржа
        case "NYSE":
            return "NYSE"
            //Насда́к
        case "NASDAQ":
            return "NASDAQ"
            //Лондонская фондовая биржа
        case "LSE":
            return "LSE"
            //Токийская фондовая биржа
        case "TSE":
            return "TSE"
            //Гонконгская фондовая биржа
        case "HKEX":
            return "HKEX"
        default:
            return ""
        }
    }

    static func isExchangeOpen(_ exchange: String) -> Bool {
        let now = Date()
        var calendar = Calendar.current

        switch exchange {
        case "NYSE", "NASDAQ":
            let newYorkTimeZone = TimeZone(identifier: "America/New_York")
            calendar.timeZone = newYorkTimeZone!

            let preMarketOpenHour = 4
            let preMarketCloseHour = 9
            let marketOpenHour = 9
            let marketCloseHour = 16
            let postMarketOpenHour = 16
            let postMarketCloseHour = 20

            let weekday = calendar.component(.weekday, from: now)

            let isWorkDay = weekday >= 2 && weekday <= 6
            let preMarketOpenTime = calendar.date(bySettingHour: preMarketOpenHour, minute: 0, second: 0, of: now)
            let preMarketCloseTime = calendar.date(bySettingHour: preMarketCloseHour, minute: 30, second: 0, of: now)
            let marketOpenTime = calendar.date(bySettingHour: marketOpenHour, minute: 30, second: 0, of: now)
            let marketCloseTime = calendar.date(bySettingHour: marketCloseHour, minute: 0, second: 0, of: now)
            let postMarketOpenTime = calendar.date(bySettingHour: postMarketOpenHour, minute: 0, second: 0, of: now)
            let postMarketCloseTime = calendar.date(bySettingHour: postMarketCloseHour, minute: 0, second: 0, of: now)

            if isWorkDay, let preMarketOpenTime = preMarketOpenTime, let preMarketCloseTime = preMarketCloseTime,
                let marketOpenTime = marketOpenTime, let marketCloseTime = marketCloseTime,
                let postMarketOpenTime = postMarketOpenTime, let postMarketCloseTime = postMarketCloseTime,
                (calendar.isDate(now, inSameDayAs: preMarketOpenTime) || calendar.isDate(now, inSameDayAs: marketOpenTime) || calendar.isDate(now, inSameDayAs: postMarketOpenTime)),
                (now >= preMarketOpenTime && now <= preMarketCloseTime) || (now >= marketOpenTime && now <= marketCloseTime) || (now >= postMarketOpenTime && now <= postMarketCloseTime) {
                return true
            } else {
                return false
            }

        case "LSE":
            let londonTimeZone = TimeZone(identifier: "Europe/London")
            calendar.timeZone = londonTimeZone!

            let marketOpenHour = 8
            let marketCloseHour = 16
            let marketCloseMinute = 30

            let weekday = calendar.component(.weekday, from: now)

            let isWorkDay = weekday >= 2 && weekday <= 6
            let marketOpenTime = calendar.date(bySettingHour: marketOpenHour, minute: 0, second: 0, of: now)
            let marketCloseTime = calendar.date(bySettingHour: marketCloseHour, minute: marketCloseMinute, second: 0, of: now)

            if isWorkDay, let marketOpenTime = marketOpenTime, let marketCloseTime = marketCloseTime,
                calendar.isDate(now, inSameDayAs: marketOpenTime) || calendar.isDate(now, inSameDayAs: marketCloseTime),
                now >= marketOpenTime && now <= marketCloseTime {
                return true
            } else {
                return false
            }

        case "TSE":
            let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo")
            calendar.timeZone = tokyoTimeZone!

            let marketOpenHour = 9
            let marketCloseHour = 15

            let weekday = calendar.component(.weekday, from: now)

            let isWorkDay = weekday >= 2 && weekday <= 6
            let marketOpenTime = calendar.date(bySettingHour: marketOpenHour, minute: 0, second: 0, of: now)
            let marketCloseTime = calendar.date(bySettingHour: marketCloseHour, minute: 0, second: 0, of: now)

            if isWorkDay, let marketOpenTime = marketOpenTime, let marketCloseTime = marketCloseTime,
                calendar.isDate(now, inSameDayAs: marketOpenTime) || calendar.isDate(now, inSameDayAs: marketCloseTime),
                now >= marketOpenTime && now <= marketCloseTime {
                return true
            } else {
                return false
            }

        case "HKEX":
            let hongKongTimeZone = TimeZone(identifier: "Asia/Hong_Kong")
            calendar.timeZone = hongKongTimeZone!

            let marketOpenHour = 9
            let marketCloseHour = 16

            let weekday = calendar.component(.weekday, from: now)

            let isWorkDay = weekday >= 2 && weekday <= 6
            let marketOpenTime = calendar.date(bySettingHour: marketOpenHour, minute: 30, second: 0, of: now)
            let marketCloseTime = calendar.date(bySettingHour: marketCloseHour, minute: 0, second: 0, of: now)

            if isWorkDay, let marketOpenTime = marketOpenTime, let marketCloseTime = marketCloseTime,
                calendar.isDate(now, inSameDayAs: marketOpenTime) || calendar.isDate(now, inSameDayAs: marketCloseTime),
                now >= marketOpenTime && now <= marketCloseTime {
                return true
            } else {
                return false
            }

        default:
            return false
        }
    }
}

