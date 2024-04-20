//
//  LoginViewModel.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

protocol LoginViewModelDelegate1 {
    func didReceiveLoginResponse1(loginResponse: LoginResponse1?)
}

struct LoginViewModel1
{
    var delegate : LoginViewModelDelegate1?

    func loginUser(loginRequest: LoginRequest)
    {
        let validationResult = LoginValidation().Validate(loginRequest: loginRequest)

        if(validationResult.success)
        {
            //use loginResource to call login API
            let loginResource = LoginResource()
            loginResource.loginUser(loginRequest: loginRequest) { (loginApiResponse) in

//                if(loginApiResponse?.errorMessage == nil && loginApiResponse?.data != nil)
//                {
//                    UserDefaultUtility().saveUserId(userId: loginApiResponse!.data!.userID)
//                }
//
//                //return the response we get from loginResource
//                DispatchQueue.main.async {
//                    self.delegate?.didReceiveLoginResponse1(loginResponse: loginApiResponse)
//                }

            }
        }
        self.delegate?.didReceiveLoginResponse1(loginResponse: LoginResponse1(errorMessage: validationResult.error, data: nil))
    }
}
