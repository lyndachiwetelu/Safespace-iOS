import Foundation

protocol WebSocketProvider: AnyObject {
    var delegate: WebSocketProviderDelegate? { get set }
    func connect()
    func disconnectSocket()
    func send(data: Data)
    func sendString(data: String)
}

protocol WebSocketProviderDelegate: AnyObject {
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveStringData data: String)
}
