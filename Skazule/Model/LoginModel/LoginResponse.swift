//
//  LoginResponse.swift
//  Skazule
//
//  Created by ChawTech Solutions on 25/11/22.
//

import Foundation

struct LoginResponse {

    var errorMessage: String?
    var data: LoginResponseData?
}

struct LoginResponseData
{
    var companyId, employerId, industryId, token: String?
  
}
