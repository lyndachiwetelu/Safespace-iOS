//
//  WebRTCClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
    func webRTCClient(_ client: WebRTCClient, shouldNegotiate: Bool)
}

final class WebRTCClient: NSObject {
    
    // The `RTCPeerConnectionFactory` is in charge of creating new RTCPeerConnection instances.
    // A new RTCPeerConnection should be created every new call, but the factory is shared.
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?

    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstraints = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]    
    private var videoCapturer: RTCVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    
    // added
    private var connections = [Connection]()
    private var config: RTCConfiguration
    private var constraints: RTCMediaConstraints

    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    required init(iceServers: [String], turnServers: [String]) {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers), RTCIceServer(urlStrings: turnServers, username: "peerjs", credential: "peerjsp")]
        
        // Unified plan is more superior than planB
        config.sdpSemantics = .unifiedPlan
        
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually
        
        
        // Define media constraints. DtlsSrtpKeyAgreement is required to be true to be able to connect with web browsers.
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        
        self.config = config
        self.constraints = constraints
        super.init()
    }
    
    func createNewPeerConnection(connectionId: String) -> (RTCPeerConnection, RTCDataChannel)? {
        let dataChannelConfig = RTCDataChannelConfiguration()
        let pc = WebRTCClient.factory.peerConnection(with: self.config, constraints: constraints, delegate: self)
        self.createMediaSendersForConnection(peerConnection: pc!)
        self.configureAudioSession()
        
        if let dataChannel = pc?.dataChannel(forLabel: connectionId, configuration: dataChannelConfig) {
            dataChannel.delegate = self
            return (pc, dataChannel) as? (RTCPeerConnection, RTCDataChannel)
        }
    
       return nil
    }
    
    func addConnection(_ connection: Connection) {
        connections.append(connection)
    }
    
    func createNewConnection(peerConnection: RTCPeerConnection, connectionId: String, dataChannel: RTCDataChannel) -> Connection {
        let conn = Connection(connectionId: connectionId, dataChannel: dataChannel, peerConnection: peerConnection)
        return conn
    }
    
    func getConnection(connectionId: String) -> Connection? {
        return connections.first { $0.connectionId == connectionId }
    }
    
    
    func endTracks() {
        // @TODO
    }
    
    //MARK: - Signaling
    func offer(peerConnection: RTCPeerConnection, completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstraints,
                                             optionalConstraints: nil)
        peerConnection.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                print("error creating sdp for offer!")
                return
            }
            
            peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                print("error setting local description for offer! \(String(describing: error))")
                completion(sdp)
            })
        }
    }
    
    func answer(connectionId: String, completion: @escaping (_ sdp: RTCSessionDescription) -> Void)  {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstraints,
                                             optionalConstraints: nil)
        let conn = getConnection(connectionId: connectionId)
        conn!.peerConnection!.answer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                print("ERROR 1 \(String(describing: error))")
                return
            }
            
            conn!.peerConnection!.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func set(peerConnection: RTCPeerConnection, remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
        peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(connectionId: String, remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> ()) {
        let conn = getConnection(connectionId: connectionId)
        conn?.peerConnection?.add(remoteCandidate, completionHandler: completion)
        print(conn != nil ? "connection exists" : "connection does not exist")
        print("setting ice candidate for peerConnection \(String(describing: connectionId))")
    }
    
    // MARK: Media
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }

        guard
            let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }),
        
            // choose highest res
            let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }).last,
        
            // choose highest fps
            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
            return
        }

        capturer.startCapture(with: frontCamera,
                              format: format,
                              fps: Int(fps.maxFrameRate))
        
        self.localVideoTrack?.add(renderer)
    }
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        self.remoteVideoTrack?.add(renderer)
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSendersForConnection(peerConnection: RTCPeerConnection) {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        peerConnection.add(audioTrack, streamIds: [streamId])
        
        // Video
        let videoTrack = self.createVideoTrack()
        self.localVideoTrack = videoTrack
        peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        
        #if TARGET_OS_SIMULATOR
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    // MARK: Data Channels
    
    func sendData(_ data: Data, connectionId: String) {
        let buffer = RTCDataBuffer(data: data, isBinary: false)
        for conn in connections {
            conn.dataChannel?.sendData(buffer)
        }
    
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
        self.delegate?.webRTCClient(self, shouldNegotiate: true)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel ID:\(dataChannel.channelId) \(String(describing: dataChannel))")
        let connId = dataChannel.label
        let conn = getConnection(connectionId: connId)
        conn?.dataChannel = dataChannel
        print("data channel \(connId) should be added to peer connection \(String(describing: conn))")
    }
    
}
extension WebRTCClient {
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool, peerConnection: RTCPeerConnection) {
        print("setting track enabled, \(isEnabled)");
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach {
                $0.isEnabled = isEnabled
                print("in transceiver")
            }
    }
}

// MARK: - Video control
extension WebRTCClient {
    func hideVideo(connId: String) {
        let conn = getConnection(connectionId: connId)
        self.setVideoEnabled(false, connection: conn!)
    }
    
    func showVideo(connId: String) {
        let conn = getConnection(connectionId: connId)
        self.setVideoEnabled(true, connection: conn!)
    }
    
    private func setVideoEnabled(_ isEnabled: Bool, connection: Connection) {
        setTrackEnabled(RTCVideoTrack.self, isEnabled: isEnabled, peerConnection: connection.peerConnection!)
    }
}
// MARK:- Audio control
extension WebRTCClient {
    func muteAudio(connectionId: String) {
        let conn = getConnection(connectionId: connectionId)
        self.setAudioEnabled(false, peerConnection: conn!.peerConnection!)
    }
    
    func unmuteAudio(connectionId: String) {
        let conn = getConnection(connectionId: connectionId)
        self.setAudioEnabled(true, peerConnection: conn!.peerConnection!)
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // Force speaker
    func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool, peerConnection: RTCPeerConnection) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled, peerConnection: peerConnection)
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state: \(String(describing: dataChannel)) \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
    
}
