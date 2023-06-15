//
//  Resources.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

enum Resources {
    enum Colors {
        
        enum TabBar {
            static let selectedItemColor = UIColor.label
            static let unselectedItemColor = UIColor.gray
        }
        
        enum Watchlist {
            static let sunImageColor = UIColor.yellow
            static let moonImageColor = UIColor.blue
            static let cellBackground = UIColor.systemGray.withAlphaComponent(0.3)
        }
        static let labelColor = UIColor.label
        static let activityIndicatorColor = UIColor.gray
        static let backgroundColor = UIColor.systemBackground
        
        static let green = UIColor(red: 63/255, green: 191/255, blue: 160/255, alpha: 1.0)
        static let gray = UIColor(red: 142/255, green: 142/255, blue: 142/255, alpha: 1.0)
        static let dullDark = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0)
        
        static let priceGreen = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
        static let priceRed = UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    enum Fonts {
        static let thickFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        static let nameLabelFont = UIFont.systemFont(ofSize: 12)
        static let tickerLabelFont = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let priceLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    
    enum Strings {
        static let exchangeTimeZone = "America/New_York"
        enum TabBar {
            static var home = "Home"
            static var search = "Search"
        }
        
        enum WatchlistScreen {
            static let exchangeStatusViewOpenText = "Stock exchange is open"
            static let exchangeStatusViewOpenImage = "sun.max"
            static let exchangeStatusViewCloseText = "Stock exchange is closed"
            static let exchangeStatusViewCloseImage = "moon.zzz"
            static let titleLabel = "Watchlist"
            static let watchlistCellIdentifier = "CellIdentifier"
            static let favoriteStocksLabelText = "Favorite stocks"
        }
        
        enum SearchScreen {
            static let watchlistCellIdentifier = "CellIdentifier"
            static let searchBarPlaceholder = "Enter stock ticker"
            static let cancelButtonTitle = "Cancel"
            static let navigationTitle = "Search"
            static let alertSubmitTitle = "OK"
            static let stockType = "Common Stock"
            static let alertErrorTitles = ("Error", "Failed to get data for the specified ticker")
            static let alertErrorCandlesTitles = ("Error", "Failed to get company candles data")
            static let alertErrorProfileTitles = ("Error", "Failed to get company profile data")
        }
    }
    
    enum Images {
        enum TabBar {
            static var home = UIImage(systemName: "latch.2.case.fill")
            static var search = UIImage(systemName: "sparkle.magnifyingglass")
        }
        static let lightModeImage = UIImage(named: "lightModeBackButton")?.withRenderingMode(.alwaysOriginal)
        static let darkModeImage = UIImage(named: "darkModeBackButton")?.withRenderingMode(.alwaysOriginal)
    }
    
    enum Condition {
        static var exchangeStatus: Bool {
            let now = Date()
            var calendar = Calendar.current
            let newYorkTimeZone = TimeZone(identifier: Resources.Strings.exchangeTimeZone)
            calendar.timeZone = newYorkTimeZone!

            let openHour = 9
            let openMinute = 30
            let closeHour = 16

            let weekday = calendar.component(.weekday, from: now)

            let isWorkDay = weekday >= 2 && weekday <= 6
            let openTime = calendar.date(bySettingHour: openHour, minute: openMinute, second: 0, of: now)
            let closeTime = calendar.date(bySettingHour: closeHour, minute: 0, second: 0, of: now)

            if isWorkDay, let openTime = openTime, let closeTime = closeTime,
                calendar.isDate(now, inSameDayAs: openTime) || calendar.isDate(now, inSameDayAs: closeTime),
                now >= openTime && now <= closeTime {
                return true
            } else {
                return false
            }
        }
    }

}
