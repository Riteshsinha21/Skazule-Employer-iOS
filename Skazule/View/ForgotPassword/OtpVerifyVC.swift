//
//  OtpVerifyVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 24/11/22.
//

import UIKit

class OtpVerifyVC: UIViewController {
    
    @IBOutlet weak var employerOtpTxtField: UITextField!
    @IBOutlet weak var employerPasswordTxtField: UITextField!
    @IBOutlet weak var employerConfirmPasswordTxtField: UITextField!
    
    @IBOutlet weak var hideShowPasswordBtn: UIButton!
    @IBOutlet weak var hideShowConfPasswordBtn: UIButton!

    var employerEmail = ""
    @IBOutlet weak var resendOTPBtn: UIButton!
    
    
    @IBOutlet weak var countLblBackView: UIView!
    @IBOutlet weak var resendOtpCountLbl: UILabel!
   @IBOutlet weak var countLbl: UILabel!
    
    var timer: Timer?
    var remainingTime = 60 // 60 seconds
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        // Create a string with an underline
//        let attributedString = NSMutableAttributedString(string: "Resend OTP")
//        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
//        self.resendOTPBtn.setAttributedTitle(attributedString, for: .normal)
        
        /*
        // Disable the button
         resendOTPBtn.isEnabled = false
        // Start the timer when the view loads
        startTimer()

         */
        
        
        self.countLblBackView.isHidden = true
        
        
    }
    
    // MARK: - Submit button tapped
    @IBAction func onTapVerifyButton(_ sender: Any) {
        
        if(self.employerOtpTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter otp")
        }
        else if(self.employerPasswordTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter password")
        }
        else if(self.employerPasswordTxtField.text!.count < 6)
        {
            showMessageAlert(message: "Entered password must be atleast 6 charaters")
        }
        else if(self.employerConfirmPasswordTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter confirm password")
        }
        else if (self.employerPasswordTxtField.text! != self.employerConfirmPasswordTxtField.text!)
        {
            showMessageAlert(message: "Password and confirm password should be same")
        }
        else
        {
            self.otpVarifyApiCall(otp: self.employerOtpTxtField.text!, password: self.employerPasswordTxtField.text!, confirm_password: self.employerConfirmPasswordTxtField.text!)
        }
    }
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    // MARK: - Password Hide Show button tapped
    @IBAction func onTapHideShowPasswordBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.tag == 101
        {
        self.employerPasswordTxtField.isSecureTextEntry = !self.employerPasswordTxtField.isSecureTextEntry
        }
        else
        {
            self.employerConfirmPasswordTxtField.isSecureTextEntry = !self.employerConfirmPasswordTxtField.isSecureTextEntry
        }
    }
    
    func otpVarifyApiCall(otp:String, password:String, confirm_password:String)
    {
        
        let fullUrl = BASE_URL + PROJECT_URL.VERIFY_OTP_API
        
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String?] = ["email": employerEmail, "otp": otp, "password": password, "confirm_password": confirm_password]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    
                    let Alert = UIAlertController(title: "Message", message: json["message"].stringValue, preferredStyle: UIAlertController.Style.alert)
                    Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        
                        //initialiseAppWithController(LoginVC())
                        (sideMenuViewController.rootViewController as! UINavigationController).pushViewController(LoginVC(), animated: false)
                        
                    }))
                    if let presenter = Alert.popoverPresentationController {
                        presenter.sourceView = self.view
                        presenter.sourceRect = self.view.bounds
                    }
                    DispatchQueue.main.async {
                        self.present(Alert, animated: true, completion: nil)
                    }
                    
                    
//                    let vc = OtpVerifyVC()
//                    self.navigationController?.pushViewController(vc, animated: true)

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
//                        let vc = OtpVerifyVC()
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                    else
//                    {
//                        // Go to Tab Bar Screen
//                        //initialiseAppWithController(loadTabBar())
//                        self.goToDashBoardScreen()
//
//                    }
//
//                    //goToVerificationScreen(email: email, phone: completePhone, controller: controller, type: type)
                }
                else {
                   // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
    
    
    @IBAction func onTapResendOTP(_ sender: UIButton) {

        // Disable the button
         resendOTPBtn.isEnabled = false
        self.countLblBackView.isHidden = false

         remainingTime = 60
         // Start the timer again
         startTimer()
    }
    func startTimer() {
        // Call Resend Otp API
        self.resendOtpApiCall()
        
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        
        @objc func updateTimer() {
            if remainingTime > 0 {
//                resendOTPBtn.setTitle("Resend OTP in \(remainingTime)s", for: .normal)
                self.countLbl.text = "\(remainingTime) sec"
                //resendOTPBtn.setTitle("\(remainingTime)s", for: .normal)
                remainingTime -= 1
            } else {
                // Re-enable the button after 60 seconds
                resendOTPBtn.isEnabled = true
                self.countLblBackView.isHidden = true
                resendOTPBtn.setTitle("Resend OTP", for: .normal)
                timer?.invalidate()
                timer = nil
            }
        }
    func resendOtpApiCall()
    {
        let fullUrl = BASE_URL + PROJECT_URL.FORGOT_PASSWORD_API
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String?] = ["email": employerEmail]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    
                }
                else {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
    
    
    
}
