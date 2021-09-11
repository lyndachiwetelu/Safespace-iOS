//
//  Connection.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 11.09.21.
//

import Foundation
import WebRTC

struct Connection {
    let connectionId: String
    let dataChannel: RTCDataChannel
    let peerConnection: RTCPeerConnection
}
