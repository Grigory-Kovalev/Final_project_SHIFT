//
//  CandleChartModel.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 08.06.2023.
//

import SwiftUI

//MARK: - Model

struct CandleChartModel: Identifiable {
    var id = UUID()
    let close, high, low, open: Double
    let timestamp, volume: Int
    let color: Color
    
    var date: String {
        let timeInterval = TimeInterval(timestamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}
