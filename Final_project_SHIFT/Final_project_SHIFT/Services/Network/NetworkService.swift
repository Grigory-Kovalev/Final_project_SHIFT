//
//  NetworkService.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 05.06.2023.
//

import Foundation

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

extension Decodable {
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self? {
        do {
            let newdata = try decoder.decode(Self.self, from: data)
            return newdata
        } catch {
            print("decodable model error", error.localizedDescription)
            return nil
        }
    }
    static func decodeArray(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> [Self]{
        do {
            let newdata = try decoder.decode([Self].self, from: data)
            return newdata
        } catch {
            print("decodable model error", error.localizedDescription)
            return []
        }
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
    static let shared = WSManager() // Создаем синглтон
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

    
    // Функция получения данных с использованием эскейпинга, чтобы передать данные наружу
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
