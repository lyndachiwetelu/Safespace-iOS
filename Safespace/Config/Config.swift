import Foundation

// Google's public stun servers.
fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

let defaultStunIceServers = ["stun:stun.l.google.com:19302"]
let defaultTurnIceServers = ["turn:0.peerjs.com:3478"]

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
}
