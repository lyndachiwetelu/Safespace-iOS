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
    static let baseGqlUrl = "https://safespace-graphql.lyndachiwetelu.com/graphql"
    static let apiToken = "apiToken"
    static let userId = "userId"
    
    //MARK: - SEGUES
    static let segueToMainTab = "GoToMainView"
    static let segueToTherapistProfile = "goToTherapistProfile"
    static let segueToSignUpScreen = "ToSignUpScreen"
    static let segueToBookSession = "GoToBookSession"
    static let segueToPayForSession = "GoToPayForSession"
    static let segueToPaymentSuccess = "GoToPaymentSuccess"
    static let segueToSession = "EnterSession"
    
    static let creditCard = "CREDIT CARD"
    static let payPal = "PAYPAL"
    
    static let ailments =  [
        [
            "name": "Depression",
            "key": "depression"
        ],
        [
            "name": "Anxiety",
            "key": "anxiety"
        ],
        [
            "name": "Bipolar Disorder",
            "key": "bipolar"
        ],
        [
            "name": "Eating Disorders",
            "key": "eating-disorder"
        ],
        [
            "name": "PTSD",
            "key": "ptsd"
        ],
        [
            "name": "Addictions",
            "key": "addiction"
        ],
        [
            "name": "Personality Disorder",
            "key": "personality-disorder"
        ],
]


static let religions = [
    "None",
    "Christian",
    "Muslim",
    "Hindu",
    "Buddhist"
]
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


enum SessionType : String, CaseIterable {
    case active = "active"
    case upcoming = "upcoming"
    case past = "past"
}
