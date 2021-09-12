//
//  Connection.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 11.09.21.
//

import Foundation
import WebRTC

class Connection {
    var connectionId: String
    var dataChannel: RTCDataChannel?
    var localDataChannel: RTCDataChannel?
    var peerConnection: RTCPeerConnection?
    
    init(connectionId: String, dataChannel: RTCDataChannel?, peerConnection: RTCPeerConnection?) {
        self.connectionId = connectionId
        self.dataChannel = dataChannel
        self.peerConnection = peerConnection
    }
    
    func setLocal(dc: RTCDataChannel) {
        localDataChannel = dc
    }
}
