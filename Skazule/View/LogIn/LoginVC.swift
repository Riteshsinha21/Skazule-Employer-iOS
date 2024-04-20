//
//  LoginVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 18/11/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class LoginVC: UIViewController, LoginViewModelDelegate {
    func didReceiveLoginResponse(loginResponse: LoginResponse?) {
        print(loginResponse?.errorMessage)
    }
    
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var createAccountBackViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailBackView: UIView!
    @IBOutlet weak var passwordBackView: UIView!
    @IBOutlet weak var emailTitleLbl: UILabel!
    @IBOutlet weak var passwordTitleLbl: UILabel!
    @IBOutlet weak var employerEmailIdTxtField: UITextField!
    @IBOutlet weak var employerPasswordTxtField: UITextField!
    @IBOutlet weak var employerRememberMeBtn: UIButton!
    @IBOutlet weak var hideShowPasswordBtn: UIButton!
    
    private var loginViewModel = LoginViewModel()
    private let fdbRef = Database.database().reference()
    
    
    //For remember me functionality //1
    private var rememberMeFlag = false
    
    
    ///For work chat with firebase
    private let loginUserViewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginViewModel.delegate = self
        
        //For remember me functionality //2
        rememberMeFlag = UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEYS.IS_REMEMBER_USER)
        if rememberMeFlag {
            let employerEmail     = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_EMAIL)
            let employerPassword  = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD)
            
            self.employerEmailIdTxtField.text = employerEmail!
            self.employerPasswordTxtField.text = employerPassword!
            self.employerRememberMeBtn.isSelected = true
            //self.employerRememberMeBtn.setImage(UIImage(named: "tick"), for: .normal)
        }
        else
        {
            //self.rememberMe.setImage(UIImage(named: "tick_blank"), for: .normal)
            self.employerRememberMeBtn.isSelected = false
        }
        
        // For Chat Module
        let serverKey = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.FCM_SERVER_KEY)
        print("key=AAAAcbuEb50:APA91bHe28sZTqDtrsKcMcdeQWcDkQVwu1Km19Qhv4NTI4RSLI6iNDw4_jUfg46coN0E_HGVziKDJ8hU10R6Fw7ltSpzqFm3TWx9bYR503oWhJXT2-Rfb-ipjKxOTvzuO-ruX5YR46ld")
        print("key=\(serverKey ?? "")")
        if serverKey == nil{
            self.getFcmServerKey()
        }
    }
    //    func request<T: Decodable>(url: URL, callback: @escaping (DataResponse<T, AFError>) -> Void) {
    //        AF.request(url).responseDecodable { (response: DataResponse<T, AFError>) in
    //            callback(response)
    //
    //        }
    //    }
    
    //    func request<T:Decodable>(_ requestBody:[String:Any], requestUrl:String, callback:@escaping (DataResponse<T, AFError>) -> Void) {
    //
    //        let headerField : HTTPHeaders = ["Content-Type":"application/json"]
    //
    //        AF.request(requestUrl, method: .post, parameters: requestBody, encoding: JSONEncoding.default, headers: headerField).responseDecodable { (response: DataResponse<T, AFError>) in
    //
    //            print(response.result)
    //
    ////            switch response.result {
    ////            case .success(let value):
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
    //        }
    //
    //
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
    
    
    // MARK: - Login button tapped
    @IBAction func onTapLoginButton(_ sender: Any) {
        
        //        let request = LoginRequest(email: self.employerEmailIdTxtField.text, password: self.employerPasswordTxtField.text, device_token: "123456", device_id: "12", device_type: "3")
        //            loginViewModel.loginUser(loginRequest: request)
        
        
        if rememberMeFlag == true
        {
            let emailText = self.employerEmailIdTxtField.text
            let passwordText = self.employerPasswordTxtField.text
            UserDefaults.standard.set(emailText, forKey: USER_DEFAULTS_KEYS.EMPLOYER_EMAIL)
            UserDefaults.standard.set(passwordText, forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD)
        }
        else
        {
            UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.EMPLOYER_EMAIL)
            UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD)
        }
        
        if(self.employerEmailIdTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter email")
        }
        else if !(ValidationManager.validateEmail(email: employerEmailIdTxtField.text!))
        {
            showMessageAlert(message: "Please enter valid email")
        }
        else if( self.employerPasswordTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter password")
        }
        
        else if(self.employerPasswordTxtField.text!.count < 6)
        {
            showMessageAlert(message: "Entered password must be atleast 6 charaters")
        }
        else
        {
            let fcmStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.FCM_KEY) as? String ?? "qwerty"
            loginApiCall(email: self.employerEmailIdTxtField.text!, password: self.employerPasswordTxtField.text!, deviceToken: fcmStr, deviceId: "12", deviceType: "3")
            print(self.employerEmailIdTxtField.text!)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if UIScreen.main.bounds.height <= 667 { // iPhone SE screen height is 667 points.
            self.topViewConstraint.constant = 0
            self.createAccountBackViewHeightConstraint.constant = 40
        } else {
        }
    }
    //    func testApi()
    //    {
    //        let fullUrl = "https://skazulebackend.chawtechsolutions.ch/api/employer-login"
    //        if Reachability.isConnectedToNetwork() {
    //
    //            showProgressOnView(appDelegateInstance.window!)
    //
    //            let param:[String:Any] = ["email": "angel@yopmail.com", "password":"123456", "device_token": "abc", "device_type": "3", "device_id": "xyz"]
    //            print(param)
    //
    //            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
    //                print(json)
    //                hideAllProgressOnView(appDelegateInstance.window!)
    //                let success = json["status"].stringValue
    //                if success  == "1"
    //                {
    //
    //                }
    //                else
    //                {
    //
    //                }
    //                DispatchQueue.main.async {
    //
    //                }
    //
    //            }, errorBlock: { (NSError) in
    //                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
    //                hideAllProgressOnView(appDelegateInstance.window!)
    //            })
    //
    //        }else{
    //            hideAllProgressOnView(appDelegateInstance.window!)
    //            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
    //        }
    //    }
    func loginApiCall(email:String, password:String, deviceToken:String, deviceId:String, deviceType:String)
    {
        
        let fullUrl = BASE_URL + PROJECT_URL.LOGIN_API
        
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String?] = [ "email": email,"password":password,"device_token":deviceToken,"device_id":deviceId,"device_type":deviceType ]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    //"profile_pic" : "public\/default_avatar.jpg",
                    
                    let companyId = json["data"]["company_id"].stringValue
                    let employerId = json["data"]["employer_id"].stringValue
                    let industryId = json["data"]["industry_id"].stringValue
                    let token = json["data"]["token"].stringValue
                    
                    //save data in userdefault..
                    UserDefaults.standard.setValue(token, forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN)
                    UserDefaults.standard.setValue(true, forKey: USER_DEFAULTS_KEYS.IS_LOGIN)
                    UserDefaults.standard.setValue(companyId, forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
                    UserDefaults.standard.setValue(employerId, forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
                    UserDefaults.standard.setValue(industryId, forKey: USER_DEFAULTS_KEYS.INDUSTRY_ID)
                    
                    let email = json["data"]["email"].stringValue
                    let c_code = json["data"]["c_code"].stringValue
                    let mobile = json["data"]["mobile"].stringValue
                    let company_name = json["data"]["company_name"].stringValue
                    let employer_name = json["data"]["employer_name"].stringValue
                    let profile_pic = json["data"]["profile_pic"].stringValue
                    
                    //save data in userdefault..
                    UserDefaults.standard.setValue(email, forKey: USER_DEFAULTS_KEYS.EMAIL)
                    UserDefaults.standard.setValue(c_code, forKey: USER_DEFAULTS_KEYS.C_CODE)
                    UserDefaults.standard.setValue(mobile, forKey: USER_DEFAULTS_KEYS.MOBILE_NO)
                    UserDefaults.standard.setValue(company_name, forKey: USER_DEFAULTS_KEYS.COMPANY_NAME)
                    UserDefaults.standard.setValue(employer_name, forKey: USER_DEFAULTS_KEYS.EMPLOYER_NAME)
                    UserDefaults.standard.setValue(profile_pic, forKey: USER_DEFAULTS_KEYS.EMPLOYER_PROFILE_PIC)
                    
                    let employerNameDataDict:[String: String] = ["employerName": employer_name]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYER_NAME), object: nil, userInfo: employerNameDataDict)
                    
                    let employerPhotoDataDict:[String: String] = ["employerPhoto": profile_pic]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYER_PROFILE_PIC), object: nil, userInfo: employerPhotoDataDict)
                    let companyNameDataDict:[String: String] = ["companyName": company_name]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.COMPANY_NAME), object: nil, userInfo: companyNameDataDict)
                    
                    let emailDataDict:[String: String] = ["email": email]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMAIL), object: nil, userInfo: emailDataDict)
                    
                    let cCodeDataDict:[String: String] = ["c_code": c_code]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.C_CODE), object: nil, userInfo: cCodeDataDict)
                    
                    let mobileDataDict:[String: String] = ["mobile": mobile]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.MOBILE_NO), object: nil, userInfo: mobileDataDict)
                    
                    let imageUrl =  IMAGE_BASE_URL + profile_pic
                    DispatchQueue.main.async{
                        if email != ""
                        {
                            //                            let timestamp = Int(Date().timeIntervalSince1970*1000)
                            //                            self.signUpIntoFirebase(email: email, userId: "ID", userName: employer_name, profile: imageUrl, timestamp: String(timestamp), role: "Employer")
                            self.getUserInfo(email: email, password: password, userName: employer_name, profilePic: imageUrl)
                            
                            
                            //   self.loginWithFirebase(email:email, userId:userId, userName: userName, profile:profile, timestamp:timestamp, role:role)
                            
                            
                            
                        }
                    }
                    
                    
                    if companyId == ""
                    {
                        let vc = CreateCompanyVC()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else
                    {
                        // Go to Tab Bar Screen
                        //initialiseAppWithController(loadTabBar())
                        self.goToDashBoardScreen()
                        
                    }
                    
                    //goToVerificationScreen(email: email, phone: completePhone, controller: controller, type: type)
                    
                    // self.loginWithFirebase( email: email,id : "id", name : company_name,ID : "ID",Role : "role")
                    
                    
                    
                    
                    
                }
                else
                {
                    var errorMsg = ""
                    let errorDict = json["error"].dictionaryValue
                    // enumerate all of the keys and values
                    for (key, value) in errorDict {
                        print("\(key) -> \(value)")
                        for i in 0..<value.count
                        {
                            errorMsg = " \(json["error"][key][i].stringValue)"
                        }
                        print(errorMsg)
                    }
                    if errorMsg == ""
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                    //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    private func getUserInfo(email: String, password: String, userName: String, profilePic: String) {
        
        var fcmKey = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.FCM_KEY)
        
        if fcmKey == nil
        {
            fcmKey = " "
        }
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        
        fdbRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                if let dataDict = snapshot.value as? [String:AnyObject]{
                    
                    for (key,_) in dataDict {
                        
                        let emailStr  = dataDict[key]!["email"] as? String
                        let userId    = dataDict[key]!["userId"] as? String
                        if emailStr != email
                        {
                            self.signUpIntoFirebase(email: email, userId: "ID", userName: userName, profile: profilePic, timestamp: String(timestamp), role: "Employer")
                        }
                        else
                        {
                            //userId
                            UserDefaults.standard.setValue(userId, forKey: "userId")
                            var chatDict: [String:AnyObject] = [:]
                            chatDict = [
                                "fcmKey" : fcmKey
                            ] as [String : AnyObject]
                            
                            if userId != ""
                            {
                                self.fdbRef.child("Users").child("\(userId!)").updateChildValues(chatDict)
                            }
                        }
                    }
                }
            }
            else
            {
                self.signUpIntoFirebase(email: email, userId: "ID", userName: userName, profile: profilePic, timestamp: String(timestamp), role: "Employer")
            }
        }
    }
    
    func goToDashBoardScreen()
    {
        (sideMenuViewController.rootViewController as! UINavigationController).pushViewController(loadTabBar(), animated: false)
    }
    
    // MARK: - Remember Me button tapped
    @IBAction func onTapRememberMeButton(_ sender: UIButton) {
        //        sender.isSelected = !sender.isSelected
        //        UserDefaults.standard.setValue(sender.isSelected, forKey: USER_DEFAULTS_KEYS.IS_AUTO_LOGIN)
        //3
        rememberMeFlag = !rememberMeFlag
        UserDefaults.standard.set(rememberMeFlag, forKey: USER_DEFAULTS_KEYS.IS_REMEMBER_USER)
        if rememberMeFlag == true
        {
            //self.employerRememberMeBtn.setImage(UIImage(named: "tick"), for: .normal)
            self.employerRememberMeBtn.isSelected = true
            
            let emailText = self.employerEmailIdTxtField.text
            let passwordText = self.employerPasswordTxtField.text
            
            UserDefaults.standard.set(emailText, forKey: USER_DEFAULTS_KEYS.EMPLOYER_EMAIL)
            UserDefaults.standard.set(passwordText, forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD)
        }
        else
        {
            //self.employerRememberMeBtn.setImage(UIImage(named: "tick_blank"), for: .normal)
            self.employerRememberMeBtn.isSelected = false
            
            UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.EMPLOYER_EMAIL)
            UserDefaults.standard.removeObject(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD)
        }
    }
    
    // MARK: - Forgot Password button tapped
    @IBAction func onTapForgotPasswordButton(_ sender: Any) {
        
        let vc = ForgotPasswordVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Create Account button tapped
    @IBAction func onTapCreateAccountButton(_ sender: Any) {
        
        let vc = SignUpVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Password Hide Show button tapped
    @IBAction func onTapHideShowPasswordBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.employerPasswordTxtField.isSecureTextEntry = !self.employerPasswordTxtField.isSecureTextEntry
    }
    
}
extension UIView {
    public func addViewBorder(borderColor:CGColor,borderWith:CGFloat,borderCornerRadius:CGFloat){
        self.layer.borderWidth = borderWith
        self.layer.borderColor = borderColor
        self.layer.cornerRadius = borderCornerRadius
        
    }
}


extension LoginVC{
    private func getFcmServerKey(){
        if Reachability.isConnectedToNetwork(){
            //                showProgressOnView(self.view)
            //                let param:[String:String] = [:]
            //                ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.GET_FCM_SERVER_KEY , successBlock: { (json) in
            //                    print(json)
            //                    hideProgressOnView(self.view)
            //
            //                    if json["message"].stringValue == "Success"{
            //                        let fcmServerKey = json["fcmServerKey"].stringValue
            //                        //UserDefaultManager.setFcmServerKey(fcmServerKey: fcmServerKey)
            //                        UserDefaults.standard.set(fcmServerKey, forKey: "FcmServerKey")
            //                    }
            //                }, errorBlock: { (NSError) in
            //                    UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
            //                    hideProgressOnView(self.view)
            //                })
            
        }else{
            hideProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
}


extension LoginVC
{
    //MARK:  firebase login
    private func signUpIntoFirebase(email:String, userId:String, userName:String, profile:String, timestamp : String, role : String) {
        
        let pass = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD) ?? ""
        
        loginUserViewModel.signUpWithFirebase(email: email, password: pass, userId : userId, userName : userName, profile:profile, timestamp:timestamp, role:role) { (success) in
            
            //guard let userId = Auth.auth().currentUser?.uid  else { return }
            //save Employer Firebase userId in userdefault..
            //UserDefaults.standard.setValue(userId, forKey: USER_DEFAULTS_KEYS.FIREBASE_EMPLOYER_USER_ID)
            
            self.loginWithFirebase(email:email, userId:userId, userName:userName, profile:profile, timestamp:timestamp, role:role)
        } onError: { (errorMessage) in
            DispatchQueue.main.async {
                hideProgressOnView(self.view)
                showMessageAlert(message: errorMessage)
            }
        }
    }
    
    private func loginWithFirebase(email:String, userId:String, userName:String, profile:String, timestamp : String, role : String){
        
        let pass = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD) ?? ""
        
        loginUserViewModel.loginWithFirebase(email: email, userId: userId, userName: userName, profile: profile, timestamp: timestamp, role: role) { (success) in
            //  if self.user != nil{
            //self.saveDataToUserDefaults(user: self.user!)
            
            DispatchQueue.main.async {
                hideProgressOnView(self.view)
                print("Logged in with firebase successfully")
            }
        } onError: { (errorMessage) in
            DispatchQueue.main.async {
                hideProgressOnView(self.view)
                showMessageAlert(message: errorMessage)
            }
        }
    }
}
