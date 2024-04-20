//
//  EmployeeResponseModel.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

struct EmployeeResponse : Decodable
{
    let errorMessage: String?
    let data: [Employee]?
}

struct Employee: Decodable {
    let name, email, id: String
    let joining: String

    enum CodingKeys: String, CodingKey {
        case name, email, id, joining
    }
}
