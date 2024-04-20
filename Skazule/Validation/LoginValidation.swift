//
//  LoginValidation.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

struct LoginValidation {

    func Validate(loginRequest: LoginRequest) -> ValidationResult
    {
        if(loginRequest.email!.isEmpty)
        {
            return ValidationResult(success: false, error: "User email is empty")
        }
        if !(ValidationManager.validateEmail(email: loginRequest.email!))
        {
            return ValidationResult(success: false, error: "Please enter valid email")
        }
        if(loginRequest.password!.isEmpty)
        {
            return ValidationResult(success: false, error: "User password is empty")
        }
        
        if(loginRequest.password!.count < 6)
        {
            return ValidationResult(success: false, error: "User password count is greatre than 6")
        }

        return ValidationResult(success: true, error: nil)
    }

}
