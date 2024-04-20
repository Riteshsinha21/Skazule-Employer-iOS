//
//  CreateCompanyThirdStepVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit
import DropDown

struct EmployeeRangeStruct
{
    var status: String = ""
    var emp_range_from: String = ""
    var emp_range_to: String = ""
    var id: String = ""
}

struct IndustriesStruct
{
    var status: String = ""
    var industry: String = ""
    var id: String = ""
}

class CreateCompanyThirdStepVC: UIViewController {
    
    @IBOutlet weak var employeeRangeDropDownTxtField: UITextField!
    @IBOutlet weak var industryDropDownTxtField: UITextField!
    
    var companyName = ""
    var companyAddress = ""
    
    var employeeRangeArr = [EmployeeRangeStruct]()
    var industriesArr = [IndustriesStruct]()
    var employeeRangeStringArr = [String]()
    var industriesStringArr = [String]()
    let singleSelectionDropDown = DropDown()
    var selectEmplyeeRangeId = ""
    var selectIndustryId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.getEmployeeRangeApi()
        self.getIndusrtiesApi()
    }
    
    func setupDropDown(arr:[String],showOn:UITextField)
    {
        singleSelectionDropDown.anchorView = showOn
        singleSelectionDropDown.bottomOffset = CGPoint(x: 0, y: showOn.bounds.height)
        singleSelectionDropDown.dataSource = arr
        singleSelectionDropDown.show()
        singleSelectionDropDown.selectionAction = { [unowned self] (index, item) in
            print(self)
            let selectedIndex : Int? = index
            if (showOn == self.employeeRangeDropDownTxtField)
            {
                let info = self.employeeRangeArr[selectedIndex!]
                self.selectEmplyeeRangeId = info.id
                self.employeeRangeDropDownTxtField.text = item
            }
            else if (showOn == self.industryDropDownTxtField)
            {
                let info = self.industriesArr[selectedIndex!]
                self.selectIndustryId = info.id
                self.industryDropDownTxtField.text = item
            }
        }
        singleSelectionDropDown.reloadAllComponents()
    }
    
    
    
    
    
    
    
    
    func getEmployeeRangeApi()
    {
        if Reachability.isConnectedToNetwork()
        {
            showProgressOnView(appDelegateInstance.window!)
            //            guard let schoolId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.SCHOOL_ID)
            //            else {
            //                return
            //            }
            let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_RANGE_API
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path:fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.employeeRangeArr.removeAll()
                    self.employeeRangeStringArr.removeAll()
                    
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let emp_range_from =  json["data"][i]["emp_range_from"].stringValue
                        let emp_range_to =  json["data"][i]["emp_range_to"].stringValue
                        
                        self.employeeRangeArr.append(EmployeeRangeStruct.init(status: status, emp_range_from: emp_range_from, emp_range_to: emp_range_to, id: id))
                        self.employeeRangeStringArr.append("\(emp_range_from) - \(emp_range_to)")
                    }
                }
                else {
                    self.employeeRangeArr.removeAll()
                    self.employeeRangeStringArr.removeAll()
                    
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
    func getIndusrtiesApi()
    {
        if Reachability.isConnectedToNetwork()
        {
            showProgressOnView(appDelegateInstance.window!)
            
            let fullUrl = BASE_URL + PROJECT_URL.GET_INDUSTRY_API
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path:fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.industriesArr.removeAll()
                    self.industriesStringArr.removeAll()
                    
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let industry =  json["data"][i]["industry"].stringValue
                        
                        self.industriesArr.append(IndustriesStruct.init(status: status, industry: industry, id: id))
                        self.industriesStringArr.append(industry)
                    }
                }
                else {
                    self.industriesArr.removeAll()
                    self.industriesStringArr.removeAll()
                    
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
    
    
    func CreateCompanyProfileApi(companyName:String, companyAddress:String, employeeRange:String, industry:String)
    {
        
        let fullUrl = BASE_URL + PROJECT_URL.CREATE_COMPANY_PROFILE_API
        
        if Reachability.isConnectedToNetwork() {
            
            guard let employerId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:String?] = [ "employer_id": employerId, "company_name":companyName,"company_address":companyAddress,"emp_range":employeeRange,"industry":industry]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let companyId = json["data"]["company_id"].stringValue
                    let industryId = json["data"]["industry_id"].stringValue
                    //save data in userdefault..
                    //                    UserDefaults.standard.setValue(json["token"].stringValue, forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN)
                    UserDefaults.standard.setValue(true, forKey: USER_DEFAULTS_KEYS.IS_LOGIN)
                    UserDefaults.standard.setValue(companyId, forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
                    UserDefaults.standard.setValue(industryId, forKey: USER_DEFAULTS_KEYS.INDUSTRY_ID)
                    
                    
                    
                    
                    let Alert = UIAlertController(title: "Message", message: json["message"].stringValue, preferredStyle: UIAlertController.Style.alert)
                    Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        //                        let vc = CreateCompanyScheduledPositionsVC()
                        //                        self.navigationController?.pushViewController(vc, animated: true)
                        let vc = CreateCompanyScheduledPositionsViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }))
                    if let presenter = Alert.popoverPresentationController {
                        presenter.sourceView = self.view
                        presenter.sourceRect = self.view.bounds
                    }
                    DispatchQueue.main.async {
                        self.present(Alert, animated: true, completion: nil)
                    }
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
                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                    
                    
                    //                    if (json["error"]["company_name"].count != 0) ||  (json["error"]["company_address"].count != 0)
                    //                    {
                    //                        var errorMsg = ""
                    //                        if json["error"]["company_name"].count != 0
                    //                        {
                    //                            let companyNameError = json["error"]["company_name"][0].stringValue
                    //                            errorMsg = "\(companyNameError)"
                    //                        }
                    //                        if json["error"]["company_address"].count != 0
                    //                        {
                    //                            let companyAddressError = json["error"]["company_address"][0].stringValue
                    //                            if errorMsg == ""
                    //                            {
                    //                                errorMsg = "\(companyAddressError)"
                    //                            }
                    //                            else
                    //                            {
                    //                            errorMsg = "\(errorMsg)\n\(companyAddressError)"
                    //                            }
                    //                        }
                    //
                    //                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay",viewController: self)
                    //                    }
                    //                    else
                    //                    {
                    //
                    //                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    //
                    //                    }
                    
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
    
    
    
    // MARK: - Next button tapped
    @IBAction func onTapNextButton(_ sender: Any) {
        
        //        let request = LoginRequest(userEmail: userName.text, userPassword: password.text)
        //        loginViewModel.loginUser(loginRequest: request)
        
        if ((self.employeeRangeDropDownTxtField.text!.isEmpty) || (self.employeeRangeDropDownTxtField.text! == "Select Employee Range"))
        {
            showMessageAlert(message: "Please select employee range")
        }
        else if ((self.industryDropDownTxtField.text!.isEmpty) || (self.industryDropDownTxtField.text! == "Select Industry"))
        {
            showMessageAlert(message: "Please select industry")
        }
        else
        {
            CreateCompanyProfileApi(companyName: self.companyName, companyAddress: self.companyAddress, employeeRange: self.selectEmplyeeRangeId, industry: self.selectIndustryId)
        }
    }
    
    
    // MARK: - Employee Range DropDown button tapped
    @IBAction func onTapEmployeeRangeDropDownButton(_ sender: Any) {
        self.setupDropDown(arr: self.employeeRangeStringArr, showOn: self.employeeRangeDropDownTxtField)
    }
    
    // MARK: - Industry DropDown button tapped
    @IBAction func onTapIndustryDropDownButton(_ sender: Any) {
        self.setupDropDown(arr: self.industriesStringArr, showOn: self.industryDropDownTxtField)
        
    }
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension Dictionary where Value: Equatable {
    func key(from value: Value) -> Key? {
        return self.first(where: { $0.value == value })?.key
    }
}
