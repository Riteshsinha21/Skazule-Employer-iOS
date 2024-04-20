//
//  SignUpVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 21/11/22.
//

import UIKit

class SignUpVC: UIViewController {
    
    @IBOutlet weak var employerFullNameTxtField: UITextField!
    @IBOutlet weak var employerEmailIdTxtField: UITextField!
    @IBOutlet weak var employerMobileNoTxtField: UITextField!
    @IBOutlet weak var employerPasswordTxtField: UITextField!
    @IBOutlet weak var employerTermPrivacyConditionLbl: UILabel!
    @IBOutlet weak var employerTermPrivacyConditionBtn: UIButton!
    
    @IBOutlet weak var hideShowPasswordBtn: UIButton!
    @IBOutlet weak var countryPickerBtn: UIButton!
    
    var termConditionBtnStatus = false
    var extensionCCode = ""
    var flagWithCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        employerTermPrivacyConditionButton()
        
        self.countryPickerBtn.setTitle(defaultCountryCode, for: .normal)
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.COUNTRY_CODE), object: nil)
    }
    //    //MARK:- Notification selector
    //    @objc func openNotification(_ notification: Notification)
    //    {
    //        print(notification.userInfo ?? "")
    //        if let dict = notification.userInfo as NSDictionary? {
    //
    //            if let countryCode = dict["countryCode"] as? String {
    //                // do something with your image
    //                self.countryPickerBtn.setTitle("\(countryCode)", for: .normal)
    //            }
    //            if let extensionCode = dict["extensionCodeDataDict"] as? String {
    //                // do something with your image
    //                extensionCCode = "\(extensionCode)"
    //            }
    //
    //        }
    //    }
    //MARK:- Notification selector
    @objc func openNotification(_ notification: Notification)
    {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            
            if let countryCode = dict["countryCode"] as? String {
                // do something with your image
                self.countryPickerBtn.setTitle("\(countryCode)", for: .normal)
                
            }
            if let extensionCode = dict["extensionCode"] as? String {
                // do something with your image
                self.extensionCCode = "\(extensionCode)"
                
            }
        }
    }
    // MARK: - Register button tapped
    @IBAction func onTapRegisterButton(_ sender: Any) {
        
        //        let request = LoginRequest(userEmail: userName.text, userPassword: password.text)
        //        loginViewModel.loginUser(loginRequest: request)
        
        if(self.employerFullNameTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter full name")
        }
        else if(self.employerEmailIdTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter email")
        }
        else if !(ValidationManager.validateEmail(email: employerEmailIdTxtField.text!))
        {
            showMessageAlert(message: "Please enter valid email")
        }
        else if(self.employerMobileNoTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter mobile number")
        }
        else if !(ValidationManager.validatePhone(no: employerMobileNoTxtField.text!))
        {
            showMessageAlert(message: "Please enter valid mobile number")
        }
        else if( self.employerPasswordTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter password")
        }
        
        else if(self.employerPasswordTxtField.text!.count < 6)
        {
            showMessageAlert(message: "Entered password must be atleast 6 charaters")
        }
        else if termConditionBtnStatus == false
        {
            showMessageAlert(message: "Please Agree With Terms and Conditions ")
        }
        else
        {
            // var countryCode = (UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.C_CODE) ?? "+91") as String
            var countryCode = self.extensionCCode
            if countryCode == ""
            {
                countryCode = defaultCCode
            }
            print(countryCode)
            
            self.SignUpApiCall(name: employerFullNameTxtField.text!, email: employerEmailIdTxtField.text!, password: employerPasswordTxtField.text!, mobile: employerMobileNoTxtField.text!, c_code: countryCode)
        }
    }
    
    // MARK: - Remember Me button tapped
    @IBAction func onTapTermPrivacyConditionButton(_ sender: UIButton) {
        
        //        let request = LoginRequest(userEmail: userName.text, userPassword: password.text)
        //        loginViewModel.loginUser(loginRequest: request)
        
        sender.isSelected = !sender.isSelected
        self.termConditionBtnStatus = sender.isSelected
        
    }
    
    // MARK: - Log In button tapped
    @IBAction func onTapLogInButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
        //        let request = LoginRequest(userEmail: userName.text, userPassword: password.text)
        //        loginViewModel.loginUser(loginRequest: request)
    }
    
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        //       //Back to the root view controller
        //       self.navigationController?.popToRootViewController(animated: true)
        
    }
    // MARK: - Password Hide Show button tapped
    @IBAction func onTapHideShowPasswordBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.employerPasswordTxtField.isSecureTextEntry = !self.employerPasswordTxtField.isSecureTextEntry
    }
    
    
    func employerTermPrivacyConditionButton()
    {
        let attributedString = NSMutableAttributedString.init(string: "I HAVE READ AND AGREE TO THE TERMS OF USE  AND PRIVACY POLICY")
        
        // Add Underline Style Attribute.
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
                                        NSRange.init(location: 29, length: 13))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 10.0/255.0, green: 75.0/255.0, blue: 144.0/255.0, alpha: 1), range: NSRange(location: 29, length: 13))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
                                        NSRange.init(location: 47, length: 14))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 10.0/255.0, green: 75.0/255.0, blue: 144.0/255.0, alpha: 1), range: NSRange(location: 47, length: 14))
        self.employerTermPrivacyConditionLbl.attributedText = attributedString
        
        
        self.employerTermPrivacyConditionLbl.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        self.employerTermPrivacyConditionLbl.addGestureRecognizer(tapgesture)
    }
    
    //MARK:- tappedOnLabel
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.employerTermPrivacyConditionLbl.text else { return }
        let conditionsRange = (text as NSString).range(of: "TERMS OF USE")
        let privacyPolicyRange = (text as NSString).range(of: "PRIVACY POLICY")
        var imgUrlStr = ""
        if gesture.didTapAttributedTextInLabel(label: self.employerTermPrivacyConditionLbl, inRange: conditionsRange) {
            print("user tapped on TERMS OF USE text")
            
            imgUrlStr = "https://skazule.com/terms-service.html"
            self.callWebView(imageUrl: imgUrlStr, titleStr: "TERMS OF USE")
            
        } else if gesture.didTapAttributedTextInLabel(label: self.employerTermPrivacyConditionLbl, inRange: privacyPolicyRange){
            print("user tapped on PRIVACY POLICY text")
            
            imgUrlStr = "https://skazule.com/privacy-policy.html"
            self.callWebView(imageUrl: imgUrlStr, titleStr: "PRIVACY POLICY")
        }
    }
    
    func SignUpApiCall(name:String,email:String, password:String, mobile:String, c_code:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.SIGNUP_API
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:String?] = [ "email": email,"password":password,"name":name,"mobile":mobile,"c_code":c_code ]
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    
                    UserDefaults.standard.setValue(self.extensionCCode, forKey: USER_DEFAULTS_KEYS.C_CODE)
                    UserDefaults.standard.setValue(selectedCountry, forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE)
                    
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay", viewController: self)
                    
                    
                    
                    
                    //                    let companyId = json["data"]["company_id"].stringValue
                    //                    let employerId = json["data"]["employer_id"].stringValue
                    //                    let industryId = json["data"]["industry_id"].stringValue
                    //
                    //                    //save data in userdefault..
                    //                    UserDefaults.standard.setValue(json["token"].stringValue, forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN)
                    //                    UserDefaults.standard.setValue(true, forKey: USER_DEFAULTS_KEYS.IS_LOGIN)
                    //                    UserDefaults.standard.setValue(companyId, forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
                    //                    UserDefaults.standard.setValue(employerId, forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
                    //                    UserDefaults.standard.setValue(industryId, forKey: USER_DEFAULTS_KEYS.INDUSTRY_ID)
                    //
                    //                    if companyId == ""
                    //                    {
                    //                        let vc = CreateCompanyVC()
                    //                        self.navigationController?.pushViewController(vc, animated: true)
                    //                    }
                    //                    else
                    //                    {
                    //                        // Go to Tab Bar Screen
                    //                        initialiseAppWithController(loadTabBar())
                    //                    }
                    //
                    //                    //goToVerificationScreen(email: email, phone: completePhone, controller: controller, type: type)
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
                    
                    //                    var errorMsg = ""
                    //                    let arr = json["error"].dictionaryValue
                    //                    if arr.containsKey("position") {
                    //                        errorMsg = json["error"]["position"][0].stringValue
                    //                    }
                    //                    print(errorMsg)
                    //                    UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
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
    @IBAction func onTapCountryPicker(_ sender: Any) {
        let vc = CountryPickerVC()
        present(vc, animated: true)
    }
    private func callWebView(imageUrl:String,titleStr:String)
    {
        let webView = WebKitViewController()
        webView.urlStr = imageUrl
        webView.headerTitle = "\(titleStr)"
        webView.isCommingFrom = " "
        self.navigationController?.pushViewController(webView, animated: true)
    }
}
