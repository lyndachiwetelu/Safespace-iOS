//
//  TherapistProfileViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 03.09.21.
//

import UIKit
import WebRTC
import SocketIO

class SessionViewController: UIViewController {
    
    private var signalClient: SignalingClient?
    private var webRTCClient: WebRTCClient?
    private var socket: SocketIOClient?
    private var manager = SocketManager(socketURL: URL( string:"http://192.168.2.33:8000" )!, config: [.log(true), .compress])
    //    private var manager = SocketManager(socketURL: URL( string:"https://safespace-backend.lyndachiwetelu.com" )!, config: [.log(true), .compress])
    private var connection: Connection?
    private lazy var videoViewController = VideoViewController(webRTCClient: self.webRTCClient!, self.socket!, connectionId: connId!)
    private var dest: String = ""
    private var connId: String? = "1234567890" {
        didSet {
            DispatchQueue.main.async {
                self.videoViewController = VideoViewController(webRTCClient: self.webRTCClient!, self.socket!, connectionId: self.connId!)
                // do this instead  self.videoViewController.connectionId = self.connId
            }
        }
    }
    
    private var callAccepted = false
    private var callRejected = false
    private var connectionType = "data"
    
    var config: Config?
    
    init(signalClient: SignalingClient, webRTCClient: WebRTCClient) {
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        super.init(nibName: nil, bundle: nil)
        
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.doLog("view did load")
        
        self.socket = self.manager.defaultSocket
        manager.handleQueue.async {
            self.addHandlers()
            self.socket?.connect()
        }
        
        config = Config.default
        webRTCClient = WebRTCClient(iceServers: self.config!.webRTCIceServers, turnServers: self.config!.turn)
        signalClient = self.buildSignalingClient()
        self.webRTCClient!.delegate = self
        self.signalClient!.delegate = self
        self.signalClient!.connect()
    }
    
    private func buildSignalingClient() -> SignalingClient {
        // iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
        let webSocketProvider: WebSocketProvider
        
        if #available(iOS 13.0, *) {
            webSocketProvider = NativeWebSocket(url: self.config!.signalingServerUrl)
        } else {
            webSocketProvider = StarscreamWebSocket(url: self.config!.signalingServerUrl)
        }
        
        return SignalingClient(webSocket: webSocketProvider)
    }
    
    @IBAction func sendDataPressed(_ sender: UIButton) {
        
        let dict = SessionMessage().msgDict
        
        do {
            let dataToSend = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            self.webRTCClient?.sendData(dataToSend, connectionId: connId!)
            
        } catch {
            Logger.doLog(String(describing: error))
        }
    }
    
    func switchToVideo() {
        self.present(videoViewController, animated: true, completion: nil)
    }
    
    @IBAction func videoCallPressed(_ sender: UIButton) {
        switchToVideo()
    }
    
    @IBAction func connectButtonPressed(_ sender: Any) {
        connectToPeer()
    }
    
    func connectToPeer() {
        Logger.doLog("sending socket message...")
        self.socket?.emit("join-room", SMessage(roomId: "session-60-chat", userId: "5017-1630661802027_session-60-chat", username: "lynda"), completion: {
            Logger.doLog("socket emission done")
        })
        
    }
    
    func doWebrtcAnswer(_ sdpMetadata: SdpMetadata, payloadType:String) {
        self.webRTCClient!.answer(connectionId: sdpMetadata.connectionId) { localSdp in
            Logger.doLog("LOCAL SDP for Received")
            
            let theSdp = Sdp( type: "answer", sdp:localSdp.sdp)
            let payload = Payload(connectionId: sdpMetadata.connectionId, type:payloadType, sdp: theSdp, serialization: "json")
            let offer = OfferMessage(type: "ANSWER", payload: payload, dst: sdpMetadata.src)
            
            do {
                let json =  try JSONEncoder().encode(offer)
                Logger.doLog("Sending Received remote sdp answer for \(sdpMetadata.connectionId)")
                self.signalClient!.sendData(json)
            } catch {
                Logger.doLog(String(describing: error))
            }
        }
            
    }
    
    func sendAnswer(_ sdpMetadata: SdpMetadata) {
        if sdpMetadata.type == "media" {
            if sdpMetadata.audioOnly == false {
                confirmAnswerVideoCall(sdpMetadata)
                return
            }
            if sdpMetadata.audioOnly == true {
                confirmAnswerAudioCall(sdpMetadata)
                return
            }
        }
        
        doWebrtcAnswer(sdpMetadata, payloadType: sdpMetadata.type)
    }
    
    func makeOffer(dst: String, connectionId: String, type: String = "data") {
        
        /// do connection stuff
        let connectionWithDataChannel = self.webRTCClient!.createNewPeerConnection(connectionId: connectionId)
        let peerConnection = connectionWithDataChannel?.0
        let dc = connectionWithDataChannel?.1
        let newConnection = Connection(connectionId: connectionId, dataChannel: dc, peerConnection: peerConnection)
        self.webRTCClient!.addConnection(newConnection)
        
        self.webRTCClient!.offer(peerConnection: newConnection.peerConnection!) { sdp in
            Logger.doLog("Making offer to remote sdp")
            let theSdp = Sdp( type: "offer", sdp: sdp.sdp)
            let metadata =  Metadata(audioOnly: true)
            let payload = Payload(connectionId: connectionId, type: type, sdp: theSdp, metadata: metadata, serialization: "json")
            let offer = OfferMessage(type: "OFFER", payload: payload, dst: dst)
            
            
            do {
                let json =  try JSONEncoder().encode(offer)
                self.signalClient!.sendData(json)
            } catch {
                Logger.doLog(String(describing: error))
            }
        }
    }
    
    func addHandlers() {
        socket?.on("user-connected") {[weak self] data, ack in
            Logger.doLog("RECEIVED USER CONNECTED....\(data)")
            self!.dest = data[0] as! String
            self?.makeOffer(dst: self!.dest, connectionId: "1234567890")
            
            return
        }
        
        socket?.onAny {
            if $0.event == "user-connected" {
               // do something
            }
            
            Logger.doLog("Got event: \($0.event), with items: \($0.items!) \($0)")
            
        }
    }
    
    func confirmAnswerVideoCall(_ sdpMeta: SdpMetadata) {
        let alert = UIAlertController(title: "Incoming Call", message: "Someeone is video calling you", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
            self.doWebrtcAnswer(sdpMeta, payloadType: "media")
            self.switchToVideo()
        }))
        
        alert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { _ in
            // Possibly emit socket event showing call was rejected!
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func confirmAnswerAudioCall(_ sdpMeta: SdpMetadata) {
        let alert = UIAlertController(title: "Incoming Voice Call", message: "Someeone is voice calling you", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
            self.doWebrtcAnswer(sdpMeta, payloadType: "media")
        }))
        
        alert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { _ in
            // Possibly emit socket event showing call was rejected!
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

extension SessionViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription, with sdpMetadata: SdpMetadata) {
        Logger.doLog("DEST IS SET for local candidate")
        dest = sdpMetadata.src

        if sdp.type == .answer {
            Logger.doLog("Received remote sdp answer!")
            let sdpPassive = sdp.sdp.replacingOccurrences(of: "", with: "")
            let sdpM = RTCSessionDescription(type: sdp.type, sdp: sdpPassive)
            
            let conn = webRTCClient!.getConnection(connectionId: sdpMetadata.connectionId)
            
            self.webRTCClient!.set(peerConnection: conn!.peerConnection!, remoteSdp: sdpM) { error in
                if error != nil {
                    Logger.doLog("Received remote sdp error 1 \(String(describing: error))")
                } else  {
                    Logger.doLog("Did set remote sdp from answer \(sdpMetadata)")
                }
            }
            return
        } else if sdp.type == .offer {
            connId = sdpMetadata.connectionId
            Logger.doLog("Received remote sdp offer!")
            Logger.doLog(String(describing: sdpMetadata))
            
            
            // create new connection
            let connectionWithDataChannel = webRTCClient!.createNewPeerConnection(connectionId: sdpMetadata.connectionId)
            let peerConnection = connectionWithDataChannel?.0
            let dc = connectionWithDataChannel?.1
            let newConnection = Connection(connectionId: sdpMetadata.connectionId, dataChannel:nil, peerConnection: peerConnection)
            newConnection.setLocal(dc: dc!)
            
            webRTCClient!.addConnection(newConnection)
            
            self.webRTCClient!.set(peerConnection: newConnection.peerConnection!, remoteSdp: sdp) { error in
                Logger.doLog("Received remote sdp error \(String(describing: error))")
                if error == nil {
                    self.sendAnswer(sdpMetadata)
                }
            }
            
            
        } else {
            Logger.doLog("Received remote sdp Other type \(String(describing: sdp.type))")
        }
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {

    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate, connectionId: String) {
        self.webRTCClient!.set(connectionId: connectionId, remoteCandidate: candidate) { error in
            Logger.doLog("Received remote candidate. Error: \(String(describing: error))")
        }
    }
}

extension SessionViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, shouldNegotiate: Bool) {
    }
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        Logger.doLog("discovered local candidate")
        self.signalClient!.send(candidate: candidate, dest: dest, conn: connId!, type: connectionType)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
    
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
