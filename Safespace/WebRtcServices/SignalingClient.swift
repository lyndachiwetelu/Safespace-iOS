//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription, with sdpMetadata: SdpMetadata)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate, connectionId: String)
}

final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    weak var delegate: SignalClientDelegate?
    
    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
    }
    
    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    func send(sdp rtcSdp: RTCSessionDescription) {
        let message = Message.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            
            self.webSocket.send(data: dataMessage)
        }
        catch {
            Logger.doLog("Warning: Could not encode sdp: \(error)")
        }
    }
    
    func sendData(_ data: Data) {
        self.webSocket.sendString(data: String(decoding: data, as: UTF8.self))
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate, dest dstId: String, conn: String, type:String) {
        let iCandidate = IceCandidate(from: rtcIceCandidate)
        let icewrapper = IceCandidateWrapper(candidate: iCandidate, type: type, connectionId: conn)
        let message = Message.candidateWrapper(icewrapper, dstId)
        
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            Logger.doLog("Warning: Could not encode candidate: \(error)")
        }
    }
}


extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            Logger.doLog("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {

    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveStringData data: String) {
        Logger.doLog("Receiving String Data")
        
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data.data(using: .utf8) ?? Data())
        }
        catch {
            Logger.doLog("Warning: Could not decode incoming message: \(error), \(data)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            // do nothing
            let t = true
        case .candidateWrapper(let wrapper, let dest):
            self.delegate?.signalClient(self, didReceiveCandidate: wrapper.candidate.rtcIceCandidate, connectionId: wrapper.connectionId)
        case .sdpNew(let offerResponse):
            let sd = RTCSessionDescription(type: offerResponse.payload.sdp.type == "offer" ? .offer : .answer, sdp: offerResponse.payload.sdp.sdp)
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sd, with: SdpMetadata(connectionId: offerResponse.payload.connectionId, audioOnly: offerResponse.payload.metadata?.audioOnly ?? true, src: offerResponse.src, type: offerResponse.payload.type))
        }
       
    }
}
