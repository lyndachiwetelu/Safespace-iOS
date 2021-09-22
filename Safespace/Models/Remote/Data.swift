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
