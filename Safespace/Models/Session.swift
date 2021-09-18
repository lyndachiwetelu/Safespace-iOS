//
//  Session.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 13.09.21.
//

import Foundation

struct Session {
    let from: String
    let to: String
    let day: String
    var with: String?
}

struct SessionChatMessage {
    let text: String
    let userId: String
}

struct SessionMessage: Codable {
    var message = "Hello there how are you doing?"
    var userId = "9"
    var key = "arandomkey1987"
    var time = "12:34"
    var day = "06/09/2021"
    
    var msgDict: [String: Any] {
        ["message": message, "time":time, "day":day, "key":key, "userId": userId];
    }
    
}


