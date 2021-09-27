//
//  SessionDetailViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit
import WebRTC
import SocketIO

class SessionDetailViewController: HasSpinnerViewController, UsesUserDefaults {
    
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var textView: UITextView!
    @IBOutlet var tableView: UITableView!
    
    var videoIcon: UIImageView?
    var audioIcon: UIImageView?
    
    var readOnlySession: Bool = false
    var userId = ""
    private var timer: Timer?
    
    private var uniqSessionId = ""
    private var chatRoomId = ""
    
    var sessionMessageManager = SessionMessageManager()
    
    //MARK: - Session Data
    var userSession: UserSession? {
        didSet {
            let timestamp = Int(Date().timeIntervalSince1970)
            uniqSessionId = "\(userSession!.userId)-\(timestamp)_session-\(userSession!.id)-chat"
            chatRoomId = "session-\(userSession!.id)-chat"
            userId = String(userSession!.userId)
        }
    }
    
    //MARK: - WebRTC Connection
    private var signalClient: SignalingClient?
    private var webRTCClient: WebRTCClient?
    private var socket: SocketIOClient?
    private var manager: SocketManager?
    private var videoViewController: VideoViewController?
    private var dest: String = ""
    private var connId: String? = "1234567890" {
        didSet {
            DispatchQueue.main.async {
                self.videoViewController = VideoViewController(webRTCClient: self.webRTCClient!, self.socket!, connectionId: self.connId!)
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
    
    var messages = [SessionChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionMessageManager.delegate = self
        sessionMessageManager.fetchDelegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SessionMessageCell", bundle: nil), forCellReuseIdentifier: "SessionMessageCell")
        addGestureRecognizer()
        navigationItem.rightBarButtonItem = getRightBarView()
        navigationItem.titleView = getTitleView()
        textView.delegate = self
        configureTextView()
        
        if readOnlySession == false {
            startSession()
        } else {
            disableSession()
        }
        sessionMessageManager.getSessionMessages(sessionId: userSession!.id)
    }
    
    func removeManagerEngine() {
        self.manager?.engine = nil
    }
    
    func disconnectSocketManager() {
        manager?.handleQueue.async {
            self.socket?.disconnect()
            self.removeManagerEngine()
        }
        self.manager?.disconnect()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            Logger.doLog("Removing Timer and Connections")
            disconnectSocketManager()
            self.signalClient?.disconnect()
            self.signalClient?.removeWebSocket()
            self.signalClient = nil
            self.webRTCClient = nil
            
            self.videoViewController = nil
            timer?.invalidate()
            
        }
    }
    
    func startSession() {
        manager = SocketManager(socketURL: URL( string: AppConstant.socketIOUrl )!, config: [.log(true), .compress, .reconnects(false)])
        config = Config(id: uniqSessionId)
        webRTCClient = WebRTCClient(iceServers: self.config!.webRTCIceServers, turnServers: self.config!.turn)
        signalClient = self.buildSignalingClient()
        self.webRTCClient!.delegate = self
        self.signalClient!.delegate = self
        self.signalClient!.connect()
        doHeartbeat(signalClient: signalClient!)
        
        self.socket = self.manager!.defaultSocket
        manager!.handleQueue.async {
            self.addHandlers()
            self.socket?.connect()
        }
        doSpinner(text: "Waiting for user to join session...")
    }
    
    func disableSession() {
        textView.isEditable = false
        videoIcon?.alpha = 0.5
        videoIcon?.isUserInteractionEnabled = false
        
        audioIcon?.alpha = 0.5
        audioIcon?.isUserInteractionEnabled = false
    }

    
    //MARK: - SocketIO Handlers
    func connectToPeer() {
        manager?.handleQueue.async {
            Logger.doLog("sending socket message...")
            self.socket?.emit("join-room", SMessage(roomId: self.chatRoomId, userId: self.uniqSessionId, username: "lynda"), completion: {
                Logger.doLog("socket emission done")
            })
            self.manager?.handleQueue.async {
                self.manager?.engine?.disconnect(reason: "Just want you to stop bih")
            }
           
        }
    }
    
    func addHandlers() {
        socket?.on("user-connected") {[weak self] data, ack in
            self!.removeSpinner()
            Logger.doLog("RECEIVED USER CONNECTED....\(data)")
            self!.dest = data[0] as! String
            self?.makeOffer(dst: self!.dest, connectionId: "1234567890")
            
            return
        }
        
        socket?.on("connect") {[weak self] data, ack in
            Logger.doLog("Socket Connected")
            self?.connectToPeer()
            return
        }
        
        socket?.on("disconnect") {[weak self] data, ack in
            Logger.doLog("Socket is disconnected")
            return
        }
        
        socket?.onAny {
            if $0.event == "user-connected" {
                // do something
            }

            Logger.doLog("Got event: \($0.event), with items: \($0.items!) \($0)")

        }
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
    
    
    func configureTextView() {
        textView.layer.cornerRadius = 15
        textView.keyboardDistanceFromTextField = 30
    }
    
    func addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textView.endEditing(true)
    }
    
    
    func getRightBarView() -> UIBarButtonItem {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = 30
        
        let videoTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.videoIconTapped))
        
        let audioTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.audioIconTapped))
        
        videoIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        videoIcon!.image = UIImage(systemName: "camera.fill")
        videoIcon!.isUserInteractionEnabled = true
        videoIcon!.addGestureRecognizer(videoTapRecognizer)
        
        audioIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        audioIcon!.image = UIImage(systemName: "phone.fill")
        audioIcon!.isUserInteractionEnabled = true
        audioIcon!.addGestureRecognizer(audioTapRecognizer)
        
        
        view.frame =  CGRect(x: 0, y: 0, width: 150, height: 50)
        view.addArrangedSubview(videoIcon!)
        view.addArrangedSubview(audioIcon!)
        
        return UIBarButtonItem(customView: view)
    }
    
    func getTitleView() -> UIStackView {
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 10
        
        let avatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        avatar.load(url: URL(string: userSession!.imageUrl)!)
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 23
        avatar.clipsToBounds = true
        
        let label = UILabel()
        label.text = userSession!.with
        label.textColor = .white
        
        view.addArrangedSubview(avatar)
        view.addArrangedSubview(label)
        
        
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 42),
            avatar.heightAnchor.constraint(equalToConstant: 42),
            view.widthAnchor.constraint(equalToConstant: 250)
        ])
        
        return view
    }
    
    @objc func videoIconTapped(gesture : UITapGestureRecognizer) {
        switchToVideo()
    }
    
    @objc func audioIconTapped(gesture : UITapGestureRecognizer) {
        switchToAudio()
    }
    
    func scrollTableView() {
        if messages.count > 6 {
            let lastIndex = NSIndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: lastIndex as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        } else {
            let firstIndex = NSIndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: firstIndex as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let message = textView.text
        textView.text = ""
        textViewHeightConstraint.constant = 35
        
        if message!.trimmingCharacters(in: .whitespaces).isEmpty {
            return
        }
        
        let messageRequest = SessionMessageRequest(message: message!, userId: Int(userId)!)
        
        sessionMessageManager.createSessionMessage(sessionId: userSession!.id, message: messageRequest)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeOfMessage = dateFormatter.string(from: Date())
        
        let dict = SessionMessage(message: message!, userId: userId, key: String(Int.random(in: 0..<100000)), time: timeOfMessage, day: userSession!.day).msgDict
        
        do {
            let dataToSend = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            self.webRTCClient?.sendData(dataToSend, connectionId: connId!)
            messages.append(SessionChatMessage(text: message!, userId: userId))
            self.tableView.reloadData()
            self.scrollTableView()
            
        } catch {
            Logger.doLog("ERROR:")
            Logger.doLog(String(describing: error))
        }
        
    }
    
    func switchToVideo() {
        self.present(videoViewController!, animated: true, completion: nil)
    }
    
    func switchToAudio() {
        performSegue(withIdentifier: "MakeAudioCall", sender: self)
    }
    
    //MARK: - WebRTC Offer Answer Handler Section
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
    
    func doHeartbeat(signalClient: SignalingClient) {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {  timer in
            do {
                let heartbeat = try JSONEncoder().encode(HeartBeat())
                self.signalClient?.sendData(heartbeat)
            } catch {
                Logger.doLog("Encoding? error sending heartbeat")
            }
        }
    }
    
    override func removeSpinner() {
        DispatchQueue.main.async {
            super.removeSpinner()
        }
    }
    
}


extension SessionDetailViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}


extension SessionDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionMessageCell", for: indexPath) as! SessionMessageCell
        
        cell.chatTextView.text = messages[indexPath.row].text
        cell.chatBox.backgroundColor = userId ==  messages[indexPath.row].userId ? AppPrimaryColor.color : .white
        cell.chatTextView.textColor = userId ==  messages[indexPath.row].userId ?  .white : AppPrimaryColor.color
        cell.chatBox.layer.borderWidth = 1
        cell.chatBox.layer.borderColor = AppPrimaryColor.color.cgColor
        
        if (userId != messages[indexPath.row].userId) {
            cell.leadingConstraint.isActive = false
            cell.trailingConstraint.isActive = true
        } else {
            cell.leadingConstraint.isActive = true
            cell.trailingConstraint.isActive = false
        }
        
        return cell
    }
    
}


//MARK: - Text View Delegate
extension SessionDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.sizeToFit()
        textViewHeightConstraint.constant = textView.contentSize.height
    }
    
}

//MARK: - SignalClientDelegate Section
extension SessionDetailViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        Logger.doLog("Signaling client connected")
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        Logger.doLog("Signal Client did disconnect")
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
            removeSpinner()
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

//MARK: - WebRTCClientDelegate
extension SessionDetailViewController: WebRTCClientDelegate {
    
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
            do {
                let decodedMessage = try JSONDecoder().decode(SessionMessage.self, from: data)
                self.messages.append(SessionChatMessage(text: decodedMessage.message, userId: decodedMessage.userId))
                self.tableView.reloadData()
                self.scrollTableView()
                
            } catch {
                Logger.doLog("Error Decoding received message")
                
            }
           
        }
    }
    
}

//MARK: - SessionMessageManager Delegate
extension SessionDetailViewController: SessionMessageManagerDelegate {
    func didCreateSessionMessage(_ smManager: SessionMessageManager, message: SessionMessageResponse) {
    }
    
    func didFailWithError(error: Error) {
        Logger.doLog("SessionMessage error:")
        Logger.doLog(error)
    }
    
    
}


//MARK: - SessionMessagerManagerFetchDelegate
extension SessionDetailViewController: SessionMessageManagerFetchDelegate {
    func didFetchMessages(_ smManager: SessionMessageManager, messages: [SessionMessageResponse]?) {
        Logger.doLog("Session Messages Fetched Successfully!")
        for message in messages! {
            let chat = SessionChatMessage(text: message.message, userId: String(message.userId))
            self.messages.append(chat)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}






