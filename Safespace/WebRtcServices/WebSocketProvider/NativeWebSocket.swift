//
//  NativeSocketProvider.swift
//  WebRTC-Demo
//
//  Created by stasel on 15/07/2019.
//  Copyright © 2019 stasel. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class NativeWebSocket: NSObject, WebSocketProvider {
    
    weak var delegate: WebSocketProviderDelegate?
    private let url: URL
    private weak var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    init(url: URL) {
        Logger.doLog("Signal Client is using native")
        self.url = url
        super.init()
    }

    func  connect() {
        let socket = urlSession.webSocketTask(with: url)
        socket.resume()
        self.socket = socket
        self.readMessage()
    }

    func send(data: Data) {
        self.socket?.send(.data(data)) { _ in }
    }
    
    func sendString(data: String) {
        self.socket?.send(.string(data)) { _ in }
    }
    
    func disconnectSocket() {
        self.disconnect()
    }
    
    private func readMessage() {
        self.socket?.receive { [weak self] message in
            Logger.doLog("Socket receiving..............")
            guard let self = self else { return }
            
            switch message {
            case .success(.data(let data)):
                Logger.doLog("GOT DATA!!!!!!")
                self.delegate?.webSocket(self, didReceiveData: data)
                self.readMessage()
                
            case .success(.string(let str)):
                Logger.doLog("Warning: Expected to receive data format but received a string. Check the websocket server config. \(str)")
                self.delegate?.webSocket(self, didReceiveStringData: str)
                self.readMessage()

            case .failure:
                self.disconnect()
                
            default:
                self.disconnect()
            }
        }
    }
    
    private func disconnect() {
        self.socket?.cancel(with: .goingAway, reason: nil)
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
}

@available(iOS 13.0, *)
extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate  {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.disconnect()
    }
}
