import Foundation
import Starscream

class StarscreamWebSocket: WebSocketProvider {

    var delegate: WebSocketProviderDelegate?
    private let socket: WebSocket
    
    init(url: URL) {
        Logger.doLog("Signal Client is using starscream")
        self.socket = WebSocket(request: URLRequest(url: url))
        self.socket.delegate = self
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func disconnectSocket() {
        self.socket.disconnect()
    }
    
    func send(data: Data) {
        self.socket.write(data: data)
    }
    
    func sendString(data: String) {
        // todo
    }
}

extension StarscreamWebSocket: Starscream.WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
    }
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.delegate?.webSocketDidDisconnect(self)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        self.delegate?.webSocket(self, didReceiveData: data)
    }
    
    
}
