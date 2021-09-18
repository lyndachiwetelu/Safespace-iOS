//
//  WebRTC.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 03.09.21.
//

import Foundation
import SocketIO
import Starscream

struct SMessage : SocketData {
   let roomId: String
    let userId: String
    let username: String

   func socketRepresentation() -> SocketData {
    return ["roomId":roomId, "userId":userId, "username":username]
   }
    
}


struct Sdp: Codable {
    let type : String
    let sdp: String
}


struct SdpMetadata {
    let connectionId: String
    let audioOnly: Bool
    let src: String
    let type: String
}

struct Metadata: Codable {
    var audioOnly: Bool?
}

struct Payload: Codable {
    var connectionId: String
    var type = "media"
    var sdp: Sdp
    var metadata: Metadata?
    var serialization: String?
}

struct OfferMessage : Codable  {
    let type: String
    let payload: Payload
//    let src: String
    let dst: String?
}

struct OfferResponse : Codable  {
    let type: String
    let payload: Payload
    let src: String
    let dst: String
}
