//
//  WebSocketService.swift
//  Final_project_SHIFT
//
//  Created by Григорий Ковалев on 15.06.2023.
//

import Foundation

class WebSocketService {
    static let shared = WebSocketService()
    private init() {}
    
    private var dataArray = [LastStocksDataModelDTO]()
    private var data: LastStocksDataModelDTO?
    
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
    func receiveData(completion: @escaping (LastStocksDataModelDTO?) -> Void) {
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
                        let srvData = try? JSONDecoder().decode(LastStocksDataModelDTO.self, from: data ?? Data())
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
