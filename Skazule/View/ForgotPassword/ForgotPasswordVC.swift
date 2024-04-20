//
//  ForgotPasswordVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 21/11/22.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var employerEmailIdTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Submit button tapped
    @IBAction func onTapSubmitButton(_ sender: Any) {
        
        //        let request = LoginRequest(userEmail: userName.text, userPassword: password.text)
        //        loginViewModel.loginUser(loginRequest: request)
        
        if(self.employerEmailIdTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter email")
        }
        else if !(ValidationManager.validateEmail(email: employerEmailIdTxtField.text!))
        {
            showMessageAlert(message: "Please enter valid email")
        }
        else
        {
            self.ForgotPasswordApiCall(email: self.employerEmailIdTxtField.text!)
        }
    }
    
    
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func ForgotPasswordApiCall(email:String)
    {
        
        let fullUrl = BASE_URL + PROJECT_URL.FORGOT_PASSWORD_API
        
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String?] = ["email": email]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    //                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    
                    
                    let Alert = UIAlertController(title: "Message", message: json["message"].stringValue, preferredStyle: UIAlertController.Style.alert)
                    Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        let vc = OtpVerifyVC()
                        vc.employerEmail = self.employerEmailIdTxtField.text!
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    if let presenter = Alert.popoverPresentationController {
                        presenter.sourceView = self.view
                        presenter.sourceRect = self.view.bounds
                    }
                    DispatchQueue.main.async {
                        self.present(Alert, animated: true, completion: nil)
                    }
                    
                    
                    
                    
                    
                    
                    
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
