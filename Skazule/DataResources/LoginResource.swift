//
//  LoginResource.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

struct LoginResource
{
    func loginUser(loginRequest: LoginRequest, completion : @escaping (_ result: LoginResponse?) -> Void)
    {
        let fullUrl = BASE_URL + PROJECT_URL.LOGIN_API
        let httpUtility = ServerClass()
        
        let param:[String:Any] = [ "email": loginRequest.email!,"password":loginRequest.password!,"device_token":loginRequest.device_token ?? "","device_id":loginRequest.device_id ?? "","device_type":loginRequest.device_type!]
        //        httpUtility.postRequestWithUrlParameters(requestBody: param, path: fullUrl, resultType: LoginResponse.self) { result in
        //            _ = completion(result)
        //        }
    }
}









//struct LoginResource
//{
//    func loginUser(loginRequest: LoginRequest, completion : @escaping (_ result: LoginResponse1?) -> Void)
//    {
//        let fullUrl = BASE_URL + PROJECT_URL.LOGIN_API
//        let loginUrl = URL(string: fullUrl)!
//        let httpUtility = ServerClass() //HttpUtility()
//        do {
//            let param:[String:String?] = [ "email": loginRequest.email,"password":loginRequest.password,"device_token":loginRequest.device_token,"device_id":loginRequest.device_id,"device_type":loginRequest.device_type ]
//
////            let loginPostBody = try JSONEncoder().encode(loginRequest)
//  //         httpUtility.postApiData(requestUrl: loginUrl, requestBody: loginPostBody, resultType: LoginResponse1.self) { (loginApiResponse) in
////
////                _ = completion(loginApiResponse)
////            }
//        }
//        catch let error {
//            debugPrint(error)
//        }
//    }
//}
