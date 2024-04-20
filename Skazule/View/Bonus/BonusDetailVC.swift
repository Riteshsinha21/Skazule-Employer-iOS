//
//  BonusDetailVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 27/01/23.
//

import UIKit

class BonusDetailVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var employeeNameLbl: UILabel!
    @IBOutlet weak var employeePhoneNumberLbl: UILabel!
    @IBOutlet weak var employeeEmailLbl: UILabel!
    @IBOutlet weak var tagTopBackView: UIView!
    @IBOutlet weak var bonusAmountLbl: UILabel!
    @IBOutlet weak var positionLbl: UILabel!
    @IBOutlet weak var desLbl: UILabel!
    
    //Custom View
    var customUpdateBonusPopUp : CustomUpdateBonusPopUp!
    
    var bonusDetail = BonusStruct()
    var bonusAmountString = ""
    var bonusDesString    = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        self.customNavigationBar.titleLabel.text = "Bonus Details"
        self.setEmployeeDetail()
        if bonusDetail.status == "1"
        {}
        else
        {
            self.setNavUI()
        }
    }
    func setNavUI()
    {
        self.customNavigationBar.customRightBarButton.isHidden = false
        self.customNavigationBar.customRightBarButton.setBackgroundImage(UIImage.init(named: "delete"), for: .normal)
        self.customNavigationBar.customRightBarButton.addTarget(self, action: #selector(onClickDeleteBonusBtn), for: .touchUpInside)
        self.customNavigationBar.customRightBarButton2.isHidden = false
        self.customNavigationBar.customRightBarButton2.setBackgroundImage(UIImage.init(named: "edit"), for: .normal)
        self.customNavigationBar.customRightBarButton2.addTarget(self, action: #selector(onClickEditBonusBtn), for: .touchUpInside)
    }
    @objc func onClickEditBonusBtn(_ sender:UIButton)
    {
        self.showCustomUpdateBonusPopUp()
    }
    @objc func onClickDeleteBonusBtn(_ sender:UIButton)
    {
        let bonusId = bonusDetail.id
        if bonusId != ""
        {
            self.deleteApiCall(idStr: bonusId)
        }
    }
    func setEmployeeDetail()
    {
        let info = bonusDetail
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        self.profilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        self.employeeNameLbl.text               = "\(info.employee_name)"
        self.employeePhoneNumberLbl.text      = "\(info.mobile)"
        self.employeeEmailLbl.text              = "\(info.email)"
        self.bonusAmountLbl.text                = "\(cuurrencyStr)\(info.bonus_amount)"
        self.positionLbl.text                    = "\(info.position)"
        self.desLbl.text                          = "\(info.desc)"
    }
    func deleteApiCall(idStr:String)
    {
        let Alert = UIAlertController(title: "Alert", message: "Are you sure, You want to delete this bonus!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteBonusApi(id: idStr)
        }))
//        Alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action: UIAlertAction!) in
//        }))
        Alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { (action: UIAlertAction!) in
            // Dismiss the alert controller when "Not Now" is tapped
            Alert.dismiss(animated: true, completion: nil)
        }))
        if let presenter = Alert.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        DispatchQueue.main.async {
            self.present(Alert, animated: true, completion: nil)
        }
    }
    
    func deleteBonusApi(id:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_EMPLOYER_BONUS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "user_id": userId, "bonus_id":id]
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
                }
                else
                {
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
                DispatchQueue.main.async {
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
    
    
    func showCustomUpdateBonusPopUp(){
        self.customUpdateBonusPopUp = CustomUpdateBonusPopUp(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        let info = bonusDetail
        self.customUpdateBonusPopUp.bonusAmountTextField.text = info.bonus_amount
        self.customUpdateBonusPopUp.bonusDesTextView.text = info.desc
        
        self.customUpdateBonusPopUp.updateButton.addTarget(self, action: #selector(self.updateBonusButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customUpdateBonusPopUp)
    }
    @objc func updateBonusButtonPressed(sender: UIButton) {
        
        if self.customUpdateBonusPopUp.bonusAmountTextField.text == ""
        {
            showMessageAlert(message: "Please enter bonus amount")
        }
        else if self.customUpdateBonusPopUp.bonusDesTextView.text == ""
        {
            showMessageAlert(message: "Please enter bonus description")
        }
        else
        {
            self.customUpdateBonusPopUp.removeFromSuperview()
            let bonusAmountStr = self.customUpdateBonusPopUp.bonusAmountTextField.text!
            let bonusDesStr = self.customUpdateBonusPopUp.bonusDesTextView.text!
            self.bonusAmountString = bonusAmountStr
            self.bonusDesString = bonusDesStr
            let bonusIdStr = bonusDetail.id
            self.updateBonusApi(bonusId: bonusIdStr,bonusAmount:bonusAmountStr,bonusDes:bonusDesStr)
        }
        
    }
    func updateBonusApi(bonusId:String, bonusAmount:String,bonusDes:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_EMPLOYER_BONUS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["bonus_amount":bonusAmount,"description":bonusDes,"user_id": userId,"bonus_id":bonusId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    self.bonusAmountLbl.text = "\(self.bonusAmountString)"
                    self.desLbl.text = "\(self.bonusDesString)"
                    
                }
                else {
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
                
                DispatchQueue.main.async {
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
