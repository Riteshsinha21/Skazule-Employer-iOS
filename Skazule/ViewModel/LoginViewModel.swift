//
//  LoginViewModel.swift
//  Skazule
//
//  Created by ChawTech Solutions on 25/11/22.
//

import Foundation
import UIKit

protocol LoginViewModelDelegate {
    func didReceiveLoginResponse(loginResponse: LoginResponse?)
}

struct LoginViewModel
{
    var delegate : LoginViewModelDelegate?

    func loginUser(loginRequest: LoginRequest)
    {
        let validationResult = LoginValidation().Validate(loginRequest: loginRequest)

        if(validationResult.success)
        {
//            loginApiCall(email: loginRequest.email!, password: loginRequest.password!, deviceToken: loginRequest.device_token!, deviceId: loginRequest.device_id!, deviceType: loginRequest.device_type! )


            //use loginResource to call login API
            let loginResource = LoginResource()
            loginResource.loginUser(loginRequest: loginRequest) { result in
                print(result)
            }
            
            
            
//            loginResource.loginUser(loginRequest: loginRequest) { (loginApiResponse) in
//
//                if(loginApiResponse?.errorMessage == nil && loginApiResponse?.data != nil)
//                {
//                    UserDefaultUtility().saveUserId(userId: loginApiResponse!.data!.userID)
//                }
//
//                //return the response we get from loginResource
//                DispatchQueue.main.async {
//                    self.delegate?.didReceiveLoginResponse(loginResponse: loginApiResponse)
//                }
//            }
        }
        self.delegate?.didReceiveLoginResponse(loginResponse: LoginResponse(errorMessage: validationResult.error, data: nil))
    }
}



//{
//    //use loginResource to call login API
//    let loginResource = LoginResource()
//    loginResource.loginUser(loginRequest: loginRequest) { (loginApiResponse) in
//
//        if(loginApiResponse?.errorMessage == nil && loginApiResponse?.data != nil)
//        {
//            UserDefaultUtility().saveUserId(userId: loginApiResponse!.data!.userID)
//        }
//
//        //return the response we get from loginResource
//        DispatchQueue.main.async {
//            self.delegate?.didReceiveLoginResponse1(loginResponse: loginApiResponse)
//        }
//
//    }
//}

//
//func loginApiCall(email:String, password:String, deviceToken:String, deviceId:String, deviceType:String)
//{
//    if Reachability.isConnectedToNetwork() {
//        showProgressOnView(appDelegateInstance.window!)
//        
//        let param:[String:String?] = [ "email": email,"password":password,"device_token":deviceToken,"device_id":deviceId,"device_type":deviceType ]
//        
//        ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.LOGIN_API, successBlock: { (json) in
//            print(json)
//            hideAllProgressOnView(appDelegateInstance.window!)
//            let success = json["success"].stringValue
//            if success  == "true"
//            {
////                //save data in userdefault..
////                UserDefaults.standard.setValue(json["token"].stringValue, forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN)
////                UserDefaults.standard.setValue(json["user_id"].stringValue, forKey: USER_DEFAULTS_KEYS.USER_ID)
//                
//                //goToVerificationScreen(email: email, phone: completePhone, controller: controller, type: type)
//            }
//            else {
//                UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
//            }
//        }, errorBlock: { (NSError) in
//            UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
//            hideAllProgressOnView(appDelegateInstance.window!)
//        })
//        
//    }else{
//        hideAllProgressOnView(appDelegateInstance.window!)
//        UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
//    }
//}
