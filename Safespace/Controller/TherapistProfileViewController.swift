//
//  TherapistProfileViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 03.09.21.
//

import UIKit
import WebRTC
import SocketIO

class TherapistProfileViewController: UIViewController {
    
    private var signalClient: SignalingClient?
    private var webRTCClient: WebRTCClient?
    private var socket: SocketIOClient?
    private var manager = SocketManager(socketURL: URL( string:"http://192.168.2.33:8000" )!, config: [.log(true), .compress])
    //    private var manager = SocketManager(socketURL: URL( string:"https://safespace-backend.lyndachiwetelu.com" )!, config: [.log(true), .compress])
    private var connectTo = [String]()
    private lazy var videoViewController = VideoViewController(webRTCClient: self.webRTCClient!)
    private var dest: String = ""
    private var callAccepted = false
    private var callRejected = false
    
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
        
        self.socket = self.manager.defaultSocket
        manager.handleQueue.async {
            self.addHandlers()
            self.socket?.connect()
        }
        
        config = Config.default
        webRTCClient = WebRTCClient(iceServers: self.config!.webRTCIceServers)
        signalClient = self.buildSignalingClient()
        self.title = "WebRTC Demo"
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
            self.webRTCClient?.sendData(dataToSend)
            
            
        } catch {
            print(error)
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
        print("sending socket message...")
        self.socket?.emit("join-room", SMessage(roomId: "session-60-chat", userId: "9-1630661802027_session-60-chat", username: "lynda"), completion: {
            print("socket emission done")
        })
        
    }
    
    func doWebrtcAnswer(_ sdpMetadata: SdpMetadata) {
        self.webRTCClient!.answer { (localSdp) in
            print("LOCAL SDP for Received")
            
            let theSdp = Sdp( type: "answer", sdp:localSdp.sdp)
            let payload = Payload(connectionId: sdpMetadata.connectionId, sdp: theSdp)
            let offer = OfferMessage(type: "ANSWER", payload: payload, dst: sdpMetadata.src)
            
            do {
                let json =  try JSONEncoder().encode(offer)
                print("Sending Received remote sdp answer \(sdpMetadata.connectionId)")
                self.signalClient!.sendData(json)
            } catch {
                print(error)
            }
            
        }
    }
    
    func sendAnswer(_ sdpMetadata: SdpMetadata) {
        if sdpMetadata.type == "media" && sdpMetadata.audioOnly == false {
            confirmAnswerCall(sdpMetadata)
            return
        }
        
        doWebrtcAnswer(sdpMetadata)
    }
    
    fileprivate func makeOffer() {
        self.webRTCClient!.offer { (sdp) in
            let theSdp = Sdp( type: "offer", sdp: sdp.sdp)
            let payload = Payload(connectionId: "1234567890", sdp: theSdp)
            let offer = OfferMessage(type: "OFFER", payload: payload, dst: "9-1630661802027_session-60-chat")
            
            do {
                let json =  try JSONEncoder().encode(offer)
                self.signalClient!.sendData(json)
            } catch {
                print(error)
            }
            
        }
    }
    
    func addHandlers() {
        socket?.on("user-connected") {[weak self] data, ack in
            self?.connectTo.append(data[0] as! String)
            print("RECEIVED USER CONNECTED....")
            self?.makeOffer()
            
            return
        }
        
        socket?.onAny {
            if $0.event == "user-connected" {
                print("I GOT THE USER!")
            }
            print("Got event: \($0.event), with items: \($0.items!) \($0)")
            
        }
    }
    
    func confirmAnswerCall(_ sdpMeta: SdpMetadata) {
        let alert = UIAlertController(title: "Incoming Call", message: "Someeone is video calling you", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
            self.doWebrtcAnswer(sdpMeta)
            self.switchToVideo()
        }))
        
        alert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { _ in
            // Possibly emit socket event showing call was rejected!
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

extension TherapistProfileViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
    
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription, with sdpMetadata: SdpMetadata) {
        dest = sdpMetadata.src
        print("Received remote sdp \(sdpMetadata.connectionId)")
        guard sdpMetadata.connectionId != "1234567890" else {
            print("Received remote sdp for same connection! Aborting without sending answer")
            return
        }
        
        if webRTCClient != nil {
            //replace
            webRTCClient = WebRTCClient(iceServers: self.config!.webRTCIceServers)
            webRTCClient!.delegate = self
        }
        
        self.webRTCClient!.set(remoteSdp: sdp) { (error) in
            print("Received remote sdp error \(String(describing: error))")
            self.sendAnswer(sdpMetadata)
        }
        
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient!.set(remoteCandidate: candidate) { error in
            print("Received remote candidate")
        }
    }
}

extension TherapistProfileViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.signalClient!.send(candidate: candidate, dest: dest)
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
