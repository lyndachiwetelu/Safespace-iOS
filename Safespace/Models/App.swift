//
//  App.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 19.09.21.
//

import Foundation
import UIKit

struct AppPrimaryColor {
    static var color: UIColor = UIColor(named: "App Teal")!
}

struct AppConstant {
    static let apiToken = "apiToken"
    static let segueToMainTab = "GoToMainView"
    static let segueToTherapistProfile = "goToTherapistProfile"
}


enum MediaName : String, CaseIterable {
    case video = "Video"
    case voice = "Voice"
    case text = "Text"
}

enum MediaKey: String, CaseIterable {
    case video = "video"
    case voice = "voice"
    case text = "text"
}
