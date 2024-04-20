//
//  Login.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

struct LoginResponse1 : Decodable {

    let errorMessage: String?
    let data: LoginResponseData1?
}

struct LoginResponseData1 : Decodable
{
    let userName: String
    let userID: Int
    let email: String

    enum CodingKeys: String, CodingKey {
        case userName
        case userID = "userId"
        case email
    }
}
