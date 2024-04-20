//
//  ServerClass.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//

import UIKit
import Alamofire
import SwiftyJSON

public struct ERNetworkManagerResponse {    /// The server's response to the URL request
    public let responseDict: NSDictionary?
    /// The error encountered while executing or validating the request.
    public let message: String?
    
    /// Status of the request.
    public let success: Bool?
    var _metrics: AnyObject?
    init(response: NSDictionary?, status: Bool?,error: String?) {
        
        self.message = error
        self.responseDict = response
        self.success = status
    }
}

struct HTTPBinResponse: Decodable { let url: String }

class ServerClass: NSObject {
    var arrRes = [[String:AnyObject]]()
    class var sharedInstance:ServerClass {
        struct Singleton {
            static let instance = ServerClass()
        }
        return Singleton.instance
    }
    
    //    private static var Manager: Alamofire.SessionManager = {
    //        // Create the server trust policies
    //        let serverTrustPolicies: [String: ServerTrustPolicy] = [
    //            TRUST_BASE_URL: .disableEvaluation
    //        ]
    //        // Create custom manager
    //        let configuration = URLSessionConfiguration.default
    //        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    //        let manager = Alamofire.SessionManager(
    //            configuration: URLSessionConfiguration.default,
    //            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
    //        )
    //        return manager
    //    }()
    private static var Manager: Session = {
        //change for live url
        let manager = ServerTrustManager(evaluators: ["api.skazule.com": DisabledTrustEvaluator()])
        
//        // Change "chawtechsolutions.ch" for Staging url
//        let manager = ServerTrustManager(evaluators: ["skazulebackend.chawtechsolutions.ch": DisabledTrustEvaluator()])
        
        let configuration = URLSessionConfiguration.af.default
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
    func getRequestWithUrlParameters2(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        }
        else {
            headerField = ["Content-Type":"application/json","X-API-KEY":XAPIKEY]
        }
        
        ServerClass.Manager.request(path, method: .get, encoding: JSONEncoding.default, headers: headerField).responseString { (response) in
            switch response.result {
            case .success(let value):
                let status = response.response?.statusCode
                if status == 401 {
                    
                    //    ErrorReporting.showMessage(title: "Error", msg: "Login Session expired Please login again!")
                }else {
                    successBlock(JSON(value))
                }
                
            case .failure(let error):
                errorBlock(error as NSError)
            }
        }
    }
    
    func getRequestWithUrlParameters(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : HTTPHeaders = [:]
        
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            
            let token = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String
            let authorization = "Bearer " + token
            
            headerField = ["Content-Type":"application/json", "Authorization": authorization]
        }
        ServerClass.Manager.request(path, method: .get, encoding: JSONEncoding.default, headers: headerField).responseJSON { (response) in
            switch response.result
            {
            case .success(let value):
                // if let value = response.result.value {
                // print(String(data: value as! Data, encoding: .utf8)!)
                let status = response.response?.statusCode
                print(status)
                if status == 401 {
                    
                    //       ErrorReporting.showMessage(title: "Error", msg: "Login Session expired Please login again!")
                }else {
                    successBlock(JSON(value ))
                }
                
            case .failure(let error):
                errorBlock(error as NSError)
            }
            //            {
            //            case .success:
            //                if let value = response.result.value {
            //                    successBlock(JSON(value ))
            //                }
            //            case .failure(let error):
            //                errorBlock(error as NSError)
            //
            //            //                print("\n\n===========Error===========")
            //            //
            //            //                print("Error Code: \(error._code)")
            //            //                print("Error Messsage: \(error.localizedDescription)")
            //            ////                if let data = response.data, let str = String(data: data, encoding: String.Encoding.utf8){
            //            ////                    print("Server Error: " + str)
            //            ////                }
            //            //                debugPrint(error as Any)
            //            //                print("\(String(describing: response.response?.statusCode))")
            //            //
            //            //                print("===========================\n\n")
            //            }
        }
    }
    
    //    func postApiData<T:Decodable>(requestUrl: URL, requestBody: Data, resultType: T.Type, completionHandler:@escaping(_ result: T)-> Void)
    //    {
    //        var urlRequest = URLRequest(url: requestUrl)
    //        urlRequest.httpMethod = "post"
    //        urlRequest.httpBody = requestBody
    //        urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
    //
    //        URLSession.shared.dataTask(with: urlRequest) { (data, httpUrlResponse, error) in
    //
    //            if(data != nil && data?.count != 0)
    //            {
    //                do {
    //
    //                    let response = try JSONDecoder().decode(T.self, from: data!)
    //                    _=completionHandler(response)
    //                }
    //                catch let decodingError {
    //                    debugPrint(decodingError)
    //                }
    //            }
    //        }.resume()
    //    }
    //
    //    func request1<T: Decodable>(requestUrl: URL, requestBody: Data, resultType: T.Type, completionHandler:@escaping(_ result: T)-> Void) {
    //
    //
    //        AF.request(requestUrl).responseDecodable { (response) in
    //        }
    //    }
    //
    //    func request<T: Decodable>(url: URL, callback: @escaping (DataResponse<T, AFError>) -> Void) {
    //        AF.request(url).responseDecodable { (response: DataResponse<T, AFError>) in
    //            callback(response)
    //        }
    //    }
    //
    //
    //
    //
    //
    //    func postRequestWithUrlParameters<T:Decodable>(_ requestBody:[String:Any], requestUrl:String, resultType: T.Type, successBlock:@escaping (_ resultType: T)->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
    //        var headerField : HTTPHeaders = [:]
    //        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
    //            //            headerField = ["Content-Type":"application/json", "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
    //        }
    //        else {
    //            //            headerField = ["Content-Type":"application/json","X-API-KEY":XAPIKEY]
    //            headerField = ["Content-Type":"application/json"]
    //        }
    //
    //
    //
    //
    //
    //
    //
    ////        AF.request(requestUrl, method: .post, parameters: requestBody, encoding: JSONEncoding.default, headers: headerField).responseDecodable(of: resultType.self) { response in.. }
    //
    //
    //
    //
    //        //{ (response:  ResponseType(.self)) in
    ////            switch response.result {
    ////            case .success(let profileModel):
    ////                switch profileModel.status {
    ////                case 200:
    ////                    print("success")
    ////                case 101:
    ////                    print("sessionExpire")
    ////                default:
    ////                    print("default")
    ////                }
    ////            case .failure(let error):
    ////                print("failure")
    ////            }
    ////        }
    ////
    //
    //
    ////        ServerClass.Manager.request(path, method: .post, parameters: sendJson, encoding: JSONEncoding.default, headers: headerField).responseJSON { (response) in
    ////            switch response.result
    ////            {
    ////            case .success(let value):
    ////                // if let value = response.result.value {
    ////                let status = response.response?.statusCode
    ////                print("\(status)")
    ////                if status == 401 {
    ////                    //    ErrorReporting.showMessage(title: "Error", msg: "Login Session expired Please login again!")
    ////                }else {
    ////                    successBlock(JSON(value ))
    ////                }
    ////            case .failure(let error):
    ////                print(error.localizedDescription)
    ////                errorBlock(error as NSError)
    ////            }
    ////            //            {
    ////            //            case .success:
    ////            //                if let value = response.result.value {
    ////            //                    //(response.response?.statusCode)
    ////            //                    successBlock(JSON(value ))
    ////            //                }
    ////            //            case .failure(let error):
    ////            //                print(error.localizedDescription)
    ////            //                errorBlock(error as NSError)
    ////            //            }
    ////        }
    //    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func postApiData<T:Decodable>(requestUrl: URL, requestBody: Data, resultType: T.Type, completionHandler:@escaping(_ result: T)-> Void)
    {}
    func postRequestWithUrlParameters(requestBody:[String:Any], path:String, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            let token = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String
            let authorization = "Bearer " + token
            headerField = ["Content-Type":"application/json", "Authorization": authorization]
        }
        else
        {
            headerField = ["Content-Type":"application/json"]
        }
        ServerClass.Manager.request(path, method: .post, parameters: requestBody, encoding: JSONEncoding.default, headers: headerField).responseJSON { (response) in
            switch response.result
            {
            case .success(let value):
                successBlock(JSON(value))
            case .failure(let error):
                print(error.localizedDescription)
                errorBlock(error as NSError)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - sendJson: <#sendJson description#>
    ///   - path: <#path description#>
    ///   - successBlock: <#successBlock description#>
    ///   - errorBlock: <#errorBlock description#>
    func postRequestWithUrlParameters(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : HTTPHeaders = [:]
        
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            
            let token = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String
            let authorization = "Bearer " + token
            
            headerField = ["Content-Type":"application/json", "Authorization": authorization]
        }
        else {
            headerField = ["Content-Type":"application/json"]
        }
        
        ServerClass.Manager.request(path, method: .post, parameters: sendJson, encoding: JSONEncoding.default, headers: headerField).responseJSON { (response) in
            
            switch response.result
            {
            case .success(let value):
                // if let value = response.result.value {
                let status = response.response?.statusCode
                print("\(status)")
                //                if status == 401 {
                //                    //    ErrorReporting.showMessage(title: "Error", msg: "Login Session expired Please login again!")
                //                }else {
                //                    successBlock(JSON(value ))
                //                }
                successBlock(JSON(value ))
            case .failure(let error):
                print(error.localizedDescription)
                errorBlock(error as NSError)
            }
            //            {
            //            case .success:
            //                if let value = response.result.value {
            //                    //(response.response?.statusCode)
            //                    successBlock(JSON(value ))
            //                }
            //            case .failure(let error):
            //                print(error.localizedDescription)
            //                errorBlock(error as NSError)
            //            }
        }
    }
    
    func postRequestWithUrlParameters2(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        }
        else {
            headerField = ["Content-Type":"application/json","X-API-KEY":XAPIKEY]
        }
        ServerClass.Manager.request(path, method: .post, parameters: sendJson, encoding: JSONEncoding.default, headers: headerField).responseString { (response) in
            switch response.result
            {
            case .success(let value):
                
                let status = response.response?.statusCode
                if status == 401 {
                    //   ErrorReporting.showMessage(title: "Error", msg: "Login Session expired Please login again!")
                }else {
                    successBlock(JSON(value ))
                }
            case .failure(let error):
                print(error.localizedDescription)
                errorBlock(error as NSError)
            }
            //            {
            //            case .success:
            //                if let value = response.result.value {
            //                    //(response.response?.statusCode)
            //                    successBlock(JSON(value ))
            //                }
            //            case .failure(let error):
            //                errorBlock(error as NSError)
            //            }
        }
    }
    
    func putRequestWithUrlParameters(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        }
        else {
            headerField = ["Content-Type":"application/json","X-API-KEY":XAPIKEY]
        }
        ServerClass.Manager.request(path, method: .put, parameters: sendJson, encoding: JSONEncoding.default, headers: headerField).responseJSON
        { (response) in
            if response.response?.statusCode == 200 {
            }
            switch response.result
            {
            case .success(let value):
                // if let value = response.result.value {
                print(String(data: value as! Data, encoding: .utf8)!)
                successBlock(JSON(value ))
            case .failure(let error):
                errorBlock(error as NSError)
            }
            //            {
            //            case .success:
            //                if let value = response.result.value {
            //                    successBlock(JSON(value ))
            //                }
            //            case .failure(let error):
            //                errorBlock(error as NSError)
            //            }
        }
    }
    
    func deleteRequestWithUrlParameters(_ sendJson:[String:Any], path:String, successBlock:@escaping (_ response: JSON )->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = ["Content-Type":"application/json", "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        }
        else {
            headerField = ["Content-Type":"application/json","X-API-KEY":XAPIKEY]
        }
        ServerClass.Manager.request(path, method: .delete, parameters: sendJson, encoding: JSONEncoding.default, headers: headerField).responseJSON { (response) in
            switch response.result
            {
            case .success(let value):
                // if let value = response.result.value {
                //print(String(data: value as! Data, encoding: .utf8)!)
                successBlock(JSON(value))
            case .failure(let error):
                errorBlock(error as NSError)
            }
            //            {
            //            case .success:
            //                if let value = response.result.value {
            //                    successBlock(JSON(value ))
            //                }
            //            case .failure(let error):
            //                errorBlock(error as NSError)
            //            }
        }
    }
    
    func sendMultipartRequestToServer(urlString:String,fileName:String, _ sendJson:[String:Any], imageUrl:URL?, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void )
    {
        
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            
            let token = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String
            let authorization = "Bearer " + token
            headerField = ["Authorization": authorization]
            print(headerField)
        }
        else {
        }
        //        AF.upload(
        //            multipartFormData: { multipartFormData in
        //                for (key, param) in sendJson {
        //                    if let array = param as? [String] {
        //                        for item in array {
        //                            if let data = item.data(using: .utf8) {
        //                                multipartFormData.append(data, withName: key)
        //                            }
        //                        }
        //                    } else {
        //                        if let data = "\(param)".data(using: .utf8) {
        //                            multipartFormData.append(data, withName: key)
        //                        }
        //                    }
        //                }
        //            },
        //            to: urlString, method: .post, headers: headerField)
        //        .response { resp in
        //            print(resp)
        //
        //
        //        }
        //
        
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key,value) in sendJson {
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                }
                else
                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                }
            }
            if let url = imageUrl
            {
                multipartFormData.append(url, withName: fileName)
            }
        },to: urlString, method: .post, headers : headerField)
        .responseJSON {  response in
            if response.response?.statusCode == 403 {
                //self.manageSession()
            }
            switch response.result {
                
            case .success(let value):
                // print(String(data: value as! Data, encoding: .utf8)!)
                successBlock(JSON(value ))
                
            case .failure( let error):
                errorBlock(error as NSError)
                print("ERROR RESPONSE: \(error)")
            }
        }
        
    }
    
    func sendMultipartRequestWithArrayParams(urlString:String,fileName:String, _ sendJson:[String:Any], imageUrl:URL?, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void )
    {
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            
            let token = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String
            let authorization = "Bearer " + token
            
            headerField = ["Authorization": authorization]
        }
        else {
        }
        AF.upload(multipartFormData: { multipartFormData in
            for (key,value) in sendJson {
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                }
                else
                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                }
            }
            if let url = imageUrl
            {
                multipartFormData.append(url, withName: fileName)
            }
        },to: urlString, method: .post, headers : headerField)
        .responseJSON {  response in
            if response.response?.statusCode == 403 {
                //self.manageSession()
            }
            switch response.result {
            case .success(let value):
                // print(String(data: value as! Data, encoding: .utf8)!)
                successBlock(JSON(value ))
                
            case .failure( let error):
                errorBlock(error as NSError)
                print("ERROR RESPONSE: \(error)")
            }
        }
    }    
    //    func sendMultipartRequestToServer(urlString:String,fileName:String, _ sendJson:[String:Any], imageUrl:URL?, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void )
    //    {
    //        var headerField : HTTPHeaders = [:]
    //        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
    //            headerField = [ "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
    //        }
    //        else {
    //            headerField = ["X-API-KEY":XAPIKEY]
    //        }
    //
    //        Alamofire.upload(multipartFormData: { multipartFormData in
    //            for (key,value) in sendJson {
    //                if (value is NSArray)
    //                {
    //                    if let jsonData = try? JSONSerialization.data(withJSONObject: value, options:.prettyPrinted) {
    //                        multipartFormData.append(jsonData, withName: key )
    //                    }
    //
    //                }
    //                else
    //                {
    //                    multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
    //                }
    //            }
    //            if let url = imageUrl
    //            {
    //                multipartFormData.append(url, withName: fileName)
    //            }
    //        }, to: urlString, method: .post, headers : headerField,
    //           encodingCompletion: { encodingResult in
    //
    //            switch encodingResult {
    //            case .success(let upload, _, _):
    //                print(upload.progress)
    //                upload.responseJSON {  response in
    //                    if response.response?.statusCode == 403 {
    //                        //self.manageSession()
    //                    }
    //                    if let value = response.result.value
    //                    {
    //                        successBlock(JSON(value ))
    //                    }
    //                }
    //            case .failure( let error):
    //                errorBlock(error as NSError)
    //            }
    //        })
    //    }
    
    
    
    func sendMultipartRequestWithMultileFiles(urlString:String,fileNames:[String], _ sendJson:[String:Any], imageUrl:[URL?], successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void )
    {
        //        var headerField : HTTPHeaders = [:]
        //        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
        //            headerField = [ "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        //        }
        //        else
        //        {
        //            headerField = ["X-API-KEY":XAPIKEY]
        //        }
        //        var headerField : HTTPHeaders = [:]
        //        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
        //            headerField = [ "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        //        }
        //        else
        //        {
        //            headerField = ["X-API-KEY":XAPIKEY]
        //        }
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            
            let token = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String
            let authorization = "Bearer " + token
            
            headerField = ["Authorization": authorization]
        }
        else {
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key,value) in sendJson {
                multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
            }
            var index = 0
            for filePath in imageUrl
            {
                if let url = filePath
                {
                    multipartFormData.append(url, withName: "\(fileNames[index])")
                }
                index += 1
            }
            
        }, to: urlString, method: .post, headers : headerField)
        .responseJSON {  response in
            if response.response?.statusCode == 403 {
            }
            switch response.result {
            case .success(let value):
                // print(String(data: value as! Data, encoding: .utf8)!)
                successBlock(JSON(value ))
                
            case .failure( let error):
                errorBlock(error as NSError)
                print("ERROR RESPONSE: \(error)")
            }
        }
        
        
        
        
        
        //to: urlString, method: .post, headers : headerField,
        //        encodingCompletion: { encodingResult in
        //
        //            switch encodingResult {
        //            case .success(let upload, _, _):
        //                print(upload.progress)
        //                upload.responseJSON {  response in
        //                    if response.response?.statusCode == 403 {
        //                        //self.manageSession()
        //                    }
        //
        //                    if let value = response.result.value
        //                    {
        //                        successBlock(JSON(value ))
        //                    }
        //                }
        //            case .failure( let error):
        //                errorBlock(error as NSError)
        //            }
        //        })
    }
    
    func sendMultipartRequestWithMultileFiles2(urlString:String,fileNames:[String], _ sendJson:[String:Any], imageUrl:[URL?], successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void )
    {
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            headerField = [ "X-API-KEY":XAPIKEY, "token":UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String]
        }
        else {
            headerField = ["X-API-KEY":XAPIKEY]
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key,value) in sendJson {
                multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
            }
            var index = 0
            for filePath in imageUrl
            {
                if let url = filePath
                {
                    multipartFormData.append(url, withName: "\(fileNames[index])[]")
                }
                index += 1
            }
            
        },to: urlString, method: .post, headers : headerField)
        .responseJSON {  response in
            if response.response?.statusCode == 403 {
                //self.manageSession()
            }
            switch response.result {
            case .success(let value):
                // print(String(data: value as! Data, encoding: .utf8)!)
                successBlock(JSON(value ))
                
            case .failure( let error):
                errorBlock(error as NSError)
                print("ERROR RESPONSE: \(error)")
            }
        }
        //        to: urlString, method: .post, headers : headerField,
        //        encodingCompletion: { encodingResult in
        //
        //            switch encodingResult {
        //            case .success(let upload, _, _):
        //                print(upload.progress)
        //                upload.responseJSON {  response in
        //                    if response.response?.statusCode == 403 {
        //                        //self.manageSession()
        //                    }
        //
        //                    if let value = response.result.value
        //                    {
        //                        successBlock(JSON(value ))
        //                    }
        //                }
        //            case .failure( let error):
        //                errorBlock(error as NSError)
        //            }
        //        })
    }
    
    func sendMultipartRequestToServerPP(apiUrlStr:String, imageKeyName:String, imageUrl:URL?, successBlock:@escaping (_ response: JSON)->Void , errorBlock: @escaping (_ error: NSError) -> Void ){
        var headerField : HTTPHeaders = [:]
        if UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) != nil  {
            
            let token = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN) as! String
            let authorization = "Bearer " + token
            
            headerField = ["Authorization": authorization]
        }
        else {
        }
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageUrl! , withName: imageKeyName)
        },to: apiUrlStr, method: .post, headers : headerField)
        .responseJSON {  response in
            if response.response?.statusCode == 403 {
                //self.manageSession()
            }
            switch response.result {
            case .success(let value):
                // print(String(data: value as! Data, encoding: .utf8)!)
                successBlock(JSON(value ))
                
            case .failure( let error):
                errorBlock(error as NSError)
                print("ERROR RESPONSE: \(error)")
            }
        }
        
        //        to:apiUrlStr, method: .post, headers : headerField,
        //        encodingCompletion: { encodingResult in
        //            switch encodingResult {
        //            case .success(let upload, _, _):
        //                upload.responseJSON { response in
        //                    if let value = response.result.value {
        //                        successBlock(JSON(value ))
        //                    }
        //                }
        //            case .failure(let error):
        //                errorBlock(error as NSError)
        //            }
        //        })
    }
    
    
}
