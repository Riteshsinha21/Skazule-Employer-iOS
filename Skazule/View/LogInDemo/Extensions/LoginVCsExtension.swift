//
//  LoginVCExtension.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation
import UIKit

extension LoginViewController : LoginViewModelDelegate1
{
    func didReceiveLoginResponse1(loginResponse: LoginResponse1?){

        if(loginResponse?.errorMessage == nil && loginResponse?.data != nil)
        {
            self.performSegue(withIdentifier: "navigateToEmployeeView", sender: nil)
        }
        else if (loginResponse?.errorMessage != nil)
        {
            let alert = UIAlertController(title: Constants.ErrorAlertTitle, message: loginResponse?.errorMessage, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: Constants.OkAlertTitle, style: .default, handler: nil))

            self.present(alert, animated: true)
        }
    }
}

