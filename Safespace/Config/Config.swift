//
//  Config.swift
//  WebRTC-Demo
//
//  Created by Stasel on 30/01/2019.
//  Copyright © 2019 Stasel. All rights reserved.
//

import Foundation

// Set this to the machine's address which runs the signaling server. Do not use 'localhost' or '127.0.0.1'


//fileprivate let url = "ws://192.168.2.33:8000/chat/peerjs?key=peerjs&id=5017-1630661802027_session-60-chat&token=ihzrkai0j4"

//fileprivate let url = "wss://safespace-backend.lyndachiwetelu.com:443/chat/peerjs?key=peerjs&id=9-1630661802027_session-60-chat&token=ihzrkai0j4"

//fileprivate let defaultSignalingServerUrl = URL(string: url)!

// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

let defaultStunIceServers = ["stun:stun.l.google.com:19302"]
let defaultTurnIceServers = ["turn:0.peerjs.com:3478"]

//const DEFAULT_CONFIG = {
//  iceServers: [
//    { urls: "stun:stun.l.google.com:19302" },
//    { urls: "turn:0.peerjs.com:3478", username: "peerjs", credential: "peerjsp" }
//  ],
//  sdpSemantics: "unified-plan"
//};

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    let turn: [String]
    
    init(id: String) {
        let url = "wss://\(AppConstant.peerSignalingUrl)/chat/peerjs?key=peerjs&id=\(id)&token=ihzrkai0j4"
        signalingServerUrl = URL(string: url)!
        webRTCIceServers = defaultIceServers
        turn = defaultTurnIceServers
    }
    
//    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers, turn: defaultTurnIceServers)
}
