//
//  NetworkService.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import Foundation

final class NetworkService {
    private let token = "c8s4fv2ad3idbo5bhsbg"
    
    func fetchSymbolLookup(symbol: String, completion: @escaping (Result<[Stock], Error>) -> Void) {
        
        let urlString = "https://finnhub.io/api/v1/search?q=\(symbol)&token=\(self.token)"
        
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
                let resultDTO = try decoder.decode(SearchNetworkResultDTO.self, from: data)
                let result = SearchNetworkResult(from: resultDTO).result
                DispatchQueue.main.async {
                    completion(.success(result))
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
        
        let urlString = "https://finnhub.io/api/v1/stock/candle?symbol=\(symbol)&resolution=\(timeFrame.rawValue)&from=\(Int(firstTime))&to=\(Int(secondTime))&token=\(self.token)"
        
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
                let candlesDTO = try decoder.decode(CandlesDTO.self, from: data)
                let candles = Candles(from: candlesDTO)
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
        let urlString = "https://finnhub.io/api/v1/stock/profile2?symbol=\(symbol)&token=\(self.token)"
        
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
                let stockProfileDTO = try decoder.decode(StockProfileModelDTO.self, from: data)
                let result = StockProfileModel(from: stockProfileDTO)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

