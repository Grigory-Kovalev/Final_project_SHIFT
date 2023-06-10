//
//  CompanyProfileView.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 09.06.2023.
//

extension String {
    func getCurrencySymbol() -> String {
        let currencySymbols: [String: String] = [
            "USD": "$", // Доллар США
            "EUR": "€", // Евро
            "GBP": "£", // Фунт стерлингов
            "CNY": "¥"  // Йена
        ]
        let currencySymbol = currencySymbols[self] ?? ""
        return currencySymbol
    }
}

import SwiftUI
import SDWebImageSwiftUI

struct CompanyProfileView: View {
    
    let stockProfileModel: StockProfileModel
    
    var getCurrencySymbol: String {
        stockProfileModel.currency.getCurrencySymbol()
    }
    
    var dateIPO: Date {
        let dateString = stockProfileModel.ipo
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            return Date()
        }
    }
    
    var amount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = getCurrencySymbol
        guard let formattedString = formatter.string(from: NSNumber(value: stockProfileModel.marketCapitalization)) else { print("Ошибка форматирования"); return "" }
        return formattedString
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 16) {
                Text("About")
                    .font(.headline)
                    .fontWeight(.black)
                HStack {
                    WebImage(url: URL(string: stockProfileModel.logo), options: [], context: [.imageThumbnailPixelSize : CGSize.zero])
                        .placeholder {ZStack {
                            Color(Resources.Colors.gray)
                            ProgressView()
                        }}
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text(stockProfileModel.name)
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.dullDark))
                }
                
                HStack {
                    Image("location")
                    
                    Text("Location: \(stockProfileModel.country)")
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.dullDark))
                }
                
                HStack {
                    Image("ipo")
                    
                    Text("IPO: \(dateIPO.formatted(date: .long, time: .omitted))")
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.dullDark))
                }
            }
            .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Type")
                    .font(.headline)
                    .fontWeight(.black)
                
                Text(stockProfileModel.finnhubIndustry)
                    .font(.title3)
                    .foregroundColor(Color(Resources.Colors.gray))
                
                HStack(alignment: .top) {
                    Image("exchange")
                    
                    Text("Exchange: \(stockProfileModel.exchange)")
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.dullDark))
                }
            }
            .padding(.vertical, 30)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Market Stats")
                    .font(.headline)
                    .fontWeight(.black)
                
                HStack(alignment: .top) {
                    Image("marketCapitalization")
                    
                    Text("Market capitalization: " + amount)
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.dullDark))
                }
                
                HStack(alignment: .top) {
                    Image("shareOutstanding")
                    
                    Text("Share outstanding: " + String(format: "%.2f", stockProfileModel.shareOutstanding))
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.dullDark))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyProfileView(stockProfileModel: StockProfileModel(country: "US", currency: "USD", estimateCurrency: "USD", exchange: "NASDAQ NMS - GLOBAL MARKET", finnhubIndustry: "Technology", ipo: "1980-12-12", logo: "https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AAPL.svg", marketCapitalization: 2840131.8639257923, name: "Apple Inc", phone: "14089961010.0", shareOutstanding: 15728.7, ticker: "AAPL", weburl: "https://www.apple.com/"))
    }
}
