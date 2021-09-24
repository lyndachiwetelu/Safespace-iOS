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
    let media: [Media]
    let ailments: [Ailment]
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

struct Media: Decodable {
    let mediaKey: String
    let name: String
}

struct Ailment: Decodable {
    let ailmentKey: String
    let name: String
}

struct SignupRequest: Decodable {
    let name: String
    let email: String
    let password: String
    let settings: Questionnaire
}

struct Questionnaire : Decodable {
    let age: Int
    let hasHadTherapy: Bool
    let ailments: [String]
    let media: [String]
    let religiousTherapy: String
    let couplesTherapy: Bool
}

struct SignupResponse: Decodable {
    let data: SignupData
}

struct SignupData: Decodable {
    let signupUser: SignupUserResponse
}

struct SignupUserResponse: Decodable {
    let user: UserData
    let token: String
}

struct AvailabilityListResponse: Decodable {
    let data: AvailabilityResponse
}

struct AvailabilityResponse: Decodable {
    let getAvailabilitiesForUserByDay: [Availability]
}

struct Availability: Decodable {
    let id: Int
    let userId: Int
    let day: String
    let times: [Time]
}

struct Time: Decodable, Equatable {
    let start: String
    let end: String
}

struct DayTime {
    let day: String
    let time: Time
}

