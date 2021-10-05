import Foundation

enum Message {
    case sdp(SessionDescription)
    case candidate(IceCandidate)
    case candidateWrapper(IceCandidateWrapper, String)
    case sdpNew(OfferResponse)
}

extension Message: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case String(describing: SessionDescription.self):
            self = .sdp(try container.decode(SessionDescription.self, forKey: .payload))
//        case String(describing: IceCandidate.self):
//            self = .candidate(try container.decode(IceCandidate.self, forKey: .payload))
        case String("CANDIDATE"):
            self = .candidateWrapper(try container.decode(IceCandidateWrapper.self, forKey: .payload), try container.decode(String.self, forKey: .src))
        case String("OFFER"), String("ANSWER"):
            let payload = try container.decode(Payload.self, forKey: .payload)
            let src = try container.decode(String.self, forKey: .src)
            let dst = try container.decode(String.self, forKey: .dst)
            self = .sdpNew(OfferResponse(type: type, payload: payload, src: src, dst: dst))
        default:
            throw DecodeError.unknownType
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
//        case .sdp(let sessionDescription):
//            try container.encode(sessionDescription, forKey: .payload)
//            try container.encode(String(describing: SessionDescription.self), forKey: .type)
//            try container.encode(String("5017-1630661802027_session-60-chat"), forKey: .dst)
//        case .candidate(let iceCandidate):
//            try container.encode(iceCandidate, forKey: .payload)
////            try container.encode(String(describing: IceCandidate.self), forKey: .type)
//            try container.encode(String("CANDIDATE"), forKey: .type)
//
//            try container.encode(String("5017-1630661802027_session-60-chat"), forKey: .dst)
        case .sdp(_):
            true == true
        case .candidate(_):
            true == true
        case .candidateWrapper(let iceCandidateWrapper, let destination):
            try container.encode(iceCandidateWrapper, forKey: .payload)
            try container.encode(String("CANDIDATE"), forKey: .type)
            try container.encode(destination, forKey: .dst)
        case .sdpNew(_):
            true == true
//            try container.encode(sdpOffer.payload, forKey: .payload)
//            try container.encode("OFFER", forKey: .type)
//            try container.encode(id, forKey: .dst)
        }
    }
    
    enum DecodeError: Error {
        case unknownType
    }
    
    enum CodingKeys: String, CodingKey {
        case type, payload, dst, src
    }
    
    
}
