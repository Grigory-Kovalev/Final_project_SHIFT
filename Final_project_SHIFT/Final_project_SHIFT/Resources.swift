//
//  Resources.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import UIKit

enum Resources {
    enum Colors {
        static let green = UIColor(red: 63/255, green: 191/255, blue: 160/255, alpha: 1.0)
        static let gray = UIColor(red: 142/255, green: 142/255, blue: 142/255, alpha: 1.0)
        static let dullDark = UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0)
        
        static let priceGreen = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
        static let priceRed = UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    enum Strings {
        enum TabBar {
            static var home = "Home"
            static var search = "Search"
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
}
