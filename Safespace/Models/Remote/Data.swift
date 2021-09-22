//
//  Data.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 22.09.21.
//

import Foundation

struct LoginDataResponse: Decodable {
    let loginUser: LoginUserResponse
}

struct LoginResponse: Decodable {
    let data: LoginDataResponse
}

struct LoginUserResponse: Decodable {
    let user: UserData
    let token: String
}

struct UserData: Decodable {
    let id: Int
    let name: String
    let userType: String
}

struct TherapistDataResponse: Decodable {
    let getTherapists: [TherapistResponse]
}

struct TherapistListResponse: Decodable {
    let data: TherapistDataResponse
}

struct TherapistResponse: Decodable {
    let id: Int
    let name: String
    let userType: String
    let therapistSetting: TherapistSetting
}

struct TherapistSetting: Decodable {
    let ageFrom: Int
    let ageTo: Int
    let qualifications: String
    let timePerSession: String
    let religiousTherapy: String
    let couplesTherapy: Bool
    let summary: String
    let imageUrl: String
    let pricePerSession: Int
}
