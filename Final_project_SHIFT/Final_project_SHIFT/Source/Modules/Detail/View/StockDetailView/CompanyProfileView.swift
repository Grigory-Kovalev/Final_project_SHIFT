//
//  CompanyProfileView.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 09.06.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct CompanyProfileView: View {
    
    let stockProfileModel: StockProfileModel
    
    private enum Metrics {
        static let VStackSpacing: CGFloat = 16
        static let imageLenght: CGFloat = 28
        static let imageCornerRadius: CGFloat = 10
        static let verticalPadding: CGFloat = 30
    }
    
    private var getCurrencySymbol: String {
        stockProfileModel.currency.getCurrencySymbol()
    }
    
    private var dateIPO: Date {
        let dateString = stockProfileModel.ipo
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            return Date()
        }
    }
    
    private var amount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = getCurrencySymbol
        guard let formattedString = formatter.string(from: NSNumber(value: stockProfileModel.marketCapitalization)) else {  return "" }
        return formattedString
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: Metrics.VStackSpacing) {
                Text(Resources.Strings.StockDetailScreen.CompanyProfile.about)
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
                        .frame(width: Metrics.imageLenght, height: Metrics.imageLenght)
                        .clipShape(RoundedRectangle(cornerRadius: Metrics.imageCornerRadius))
                    
                    Text(stockProfileModel.name)
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.gray))
                }
                
                HStack {
                    Image(Resources.Images.CompanyProfile.location)
                    
                    Text("Location: \(stockProfileModel.country)")
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.gray))
                }
                
                HStack {
                    Image(Resources.Images.CompanyProfile.ipo)
                    
                    Text("IPO: \(dateIPO.formatted(date: .long, time: .omitted))")
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.gray))
                }
            }
            .padding(.top, Metrics.verticalPadding)
            
            VStack(alignment: .leading, spacing: Metrics.VStackSpacing) {
                Text(Resources.Strings.StockDetailScreen.CompanyProfile.type)
                    .font(.headline)
                    .fontWeight(.black)
                
                Text(stockProfileModel.finnhubIndustry)
                    .font(.title3)
                    .foregroundColor(Color(Resources.Colors.gray))
                
                HStack(alignment: .top) {
                    Image(Resources.Images.CompanyProfile.exchange)
                    
                    Text("Exchange: \(stockProfileModel.exchange)")
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.gray))
                }
            }
            .padding(.vertical, Metrics.verticalPadding)
            
            VStack(alignment: .leading, spacing: Metrics.VStackSpacing) {
                Text(Resources.Strings.StockDetailScreen.CompanyProfile.marketStats)
                    .font(.headline)
                    .fontWeight(.black)
                
                HStack(alignment: .top) {
                    Image(Resources.Images.CompanyProfile.marketCapitalization)
                    
                    Text("Market capitalization: " + amount)
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.gray))
                }
                
                HStack(alignment: .top) {
                    Image(Resources.Images.CompanyProfile.shareOutstanding)
                    
                    Text("Share outstanding: " + String(format: "%.2f", stockProfileModel.shareOutstanding))
                        .font(.title3)
                        .foregroundColor(Color(Resources.Colors.gray))
                }
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompanyProfileView(stockProfileModel: StockProfileModel(country: "US", currency: "USD", estimateCurrency: "USD", exchange: "NASDAQ NMS - GLOBAL MARKET", finnhubIndustry: "Technology", ipo: "1980-12-12", logo: "https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AAPL.svg", marketCapitalization: 2840131.8639257923, name: "Apple Inc", phone: "14089961010.0", shareOutstanding: 15728.7, ticker: "AAPL", weburl: "https://www.apple.com/"))
//    }
//}
