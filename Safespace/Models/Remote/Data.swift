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
    let availabilityId: Int
    let day: String
    let time: Time
}

struct SessionRequest {
    let availabilityId : Int
    let requestedBy: Int
    let status = "confirmed"
    let from : String
    let to: String
}

struct CreateSessionResponse: Decodable {
    let data: SessionDataResponse
}

struct SessionDataResponse: Decodable {
    let createSession: SessionResponse
}

struct SessionResponse: Decodable {
    let status: String
    let id: Int
    let from: String
    let to: String
    let requestedBy: Int
    let availabilityId: Int
    let day: String
    let therapist: TherapistMini
}

struct TherapistMini: Decodable {
    let id: Int
    let name: String
}

struct TherapistMiniWithPhoto: Decodable {
    let id: Int
    let name: String
    let therapistSetting: TherapistPhoto
}

struct TherapistPhoto: Decodable {
    let imageUrl: String
}

struct GetSessionsResponse: Decodable {
    let data: UserSessionsDataResponse
}

struct UserSessionsDataResponse: Decodable {
    let getUserSessions: [UserSessionResponse]
}

struct UserSessionResponse: Decodable {
    let status: String
    let id: Int
    let from: String
    let to: String
    let requestedBy: Int
    let availabilityId: Int
    let day: String
    let therapistInfo: TherapistMiniWithPhoto
}

struct UserSession {
    let id: Int
    let from: String
    let to: String
    let day: String
    let with: String
    let imageUrl: String
    let therapistId: Int
    let userId: Int
}

struct SessionMessageResponse: Decodable {
    let id: Int
    let sessionId: Int
    let message: String
    let userId: Int
    let createdAt: String
}

struct CreateSessionMessageResponse: Decodable {
    let data: CreateSessionMessageData
}


struct CreateSessionMessageData: Decodable {
    let saveSessionMessage: SessionMessageResponse
}

struct GetSessionMessagesData: Decodable {
    let getSessionMessages: [SessionMessageResponse]
}

struct GetSessionMessagesResponse: Decodable {
    let data: GetSessionMessagesData
}

struct SessionMessageRequest {
    let message: String
    let userId: Int
}



