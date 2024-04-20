//
//  CreateCompanyEmployeeSetupNewVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 18/09/23.
//

import UIKit

class CreateCompanyEmployeeSetupNewVC: UIViewController {
    //1
    @IBOutlet weak var employee1BackView: UIView!
    @IBOutlet weak var employeeFullNameTxtField1: UITextField!
    @IBOutlet weak var employeeEmailTxtField1: UITextField!
    @IBOutlet weak var employeeMobileNumberTxtField1: UITextField!
    @IBOutlet weak var countryPickerBtn1: UIButton!
    //2
    @IBOutlet weak var employee2BackView: UIView!
    @IBOutlet weak var employeeFullNameTxtField2: UITextField!
    @IBOutlet weak var employeeEmailTxtField2: UITextField!
    @IBOutlet weak var employeeMobileNumberTxtField2: UITextField!
    @IBOutlet weak var countryPickerBtn2: UIButton!
    //3
    @IBOutlet weak var employee3BackView: UIView!
    @IBOutlet weak var employeeFullNameTxtField3: UITextField!
    @IBOutlet weak var employeeEmailTxtField3: UITextField!
    @IBOutlet weak var employeeMobileNumberTxtField3: UITextField!
    @IBOutlet weak var countryPickerBtn3: UIButton!
    //4
    @IBOutlet weak var employee4BackView: UIView!
    @IBOutlet weak var employeeFullNameTxtField4: UITextField!
    @IBOutlet weak var employeeEmailTxtField4: UITextField!
    @IBOutlet weak var employeeMobileNumberTxtField4: UITextField!
    @IBOutlet weak var countryPickerBtn4: UIButton!
    //5
    @IBOutlet weak var employee5BackView: UIView!
    @IBOutlet weak var employeeFullNameTxtField5: UITextField!
    @IBOutlet weak var employeeEmailTxtField5: UITextField!
    @IBOutlet weak var employeeMobileNumberTxtField5: UITextField!
    @IBOutlet weak var countryPickerBtn5: UIButton!
    
    @IBOutlet weak var addMoreBtnBackView: UIView!
    var employeeTemplateCount = 3
    var employeeSetUpRequestArr = [EmployeeSetUpStruct]()
    
    var isClickedCCodeIndexStr = ""
    var countryCode1 = ""
    var countryCode2 = ""
    var countryCode3 = ""
    var countryCode4 = ""
    var countryCode5 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.employee4BackView.isHidden = true
        self.employee5BackView.isHidden = true
        self.addMoreBtnBackView.isHidden = false
        self.countryPickerBtn1.setTitle(defaultCountryCode, for: .normal)
        self.countryPickerBtn2.setTitle(defaultCountryCode, for: .normal)
        self.countryPickerBtn3.setTitle(defaultCountryCode, for: .normal)
        self.countryPickerBtn4.setTitle(defaultCountryCode, for: .normal)
        self.countryPickerBtn5.setTitle(defaultCountryCode, for: .normal)
        
        self.countryCode1 = defaultCCode
        self.countryCode2 = defaultCCode
        self.countryCode3 = defaultCCode
        self.countryCode4 = defaultCCode
        self.countryCode5 = defaultCCode
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.COUNTRY_CODE), object: nil)
        
        //1
        self.employeeFullNameTxtField1.text = ""
        self.employeeEmailTxtField1.text = ""
        self.employeeMobileNumberTxtField1.text = ""
        //2
        self.employeeFullNameTxtField2.text = ""
        self.employeeEmailTxtField2.text = ""
        self.employeeMobileNumberTxtField2.text = ""
        //3
        self.employeeFullNameTxtField3.text = ""
        self.employeeEmailTxtField3.text = ""
        self.employeeMobileNumberTxtField3.text = ""
        //4
        self.employeeFullNameTxtField4.text = ""
        self.employeeEmailTxtField4.text = ""
        self.employeeMobileNumberTxtField4.text = ""
        //5
        self.employeeFullNameTxtField5.text = ""
        self.employeeEmailTxtField5.text = ""
        self.employeeMobileNumberTxtField5.text = ""
    }
    
    // MARK: - Notification selector
    @objc func openNotification(_ notification: Notification)
    {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            
            if let countryCode = dict["countryCode"] as? String {
                // do something with your image
                let cCode = dict["extensionCode"] as? String
                
                if self.isClickedCCodeIndexStr == "1"
                {
                    self.countryPickerBtn1.setTitle("\(countryCode)", for: .normal)
                    self.countryCode1 = cCode ?? defaultCCode
                }
                else if self.isClickedCCodeIndexStr == "2"
                {
                    self.countryPickerBtn2.setTitle("\(countryCode)", for: .normal)
                    self.countryCode2 = cCode ?? defaultCCode
                }
                else if  self.isClickedCCodeIndexStr == "3"
                {
                    self.countryPickerBtn3.setTitle("\(countryCode)", for: .normal)
                    self.countryCode3 = cCode ?? defaultCCode
                }
                else if self.isClickedCCodeIndexStr == "4"
                {
                    self.countryPickerBtn4.setTitle("\(countryCode)", for: .normal)
                    self.countryCode4 = cCode ?? defaultCCode
                }
                else if self.isClickedCCodeIndexStr == "5"
                {
                    self.countryPickerBtn5.setTitle("\(countryCode)", for: .normal)
                    self.countryCode5 = cCode ?? defaultCCode
                }
            }
        }
    }
    @IBAction func onTapCountryCode(_ sender: UIButton) {
        
        let tag = sender.tag
        
        switch tag {
        case 101:
            self.isClickedCCodeIndexStr = "1"
        case 102:
            self.isClickedCCodeIndexStr = "2"
        case 103:
            self.isClickedCCodeIndexStr = "3"
        case 104:
            self.isClickedCCodeIndexStr = "4"
        case 105:
            self.isClickedCCodeIndexStr = "5"
        default:
            self.isClickedCCodeIndexStr = "0"
        }
        let vc = CountryPickerVC()
        present(vc, animated: true)
    }
    // MARK: - Add More Empployee button tapped
    @IBAction func onTapAddMoreEmployeeButton(_ sender: Any) {
        
        if self.employeeTemplateCount == 3
        {
            self.employee4BackView.isHidden = false
            self.employeeTemplateCount = 4
        }
        else if self.employeeTemplateCount == 4
        {
            self.employee5BackView.isHidden = false
            self.employeeTemplateCount = 5
            self.addMoreBtnBackView.isHidden = true
        }
    }
    // MARK: - Skip button tapped
    @IBAction func onTapSkipButton(_ sender: Any) {
        let vc = CreateCompanyScedulerSetupVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: - Next button tapped
    @IBAction func onTapNextButton(_ sender: Any) {
        
        self.employeeSetUpRequestArr.removeAll()
        //1
        let EmployeeName1   = self.employeeFullNameTxtField1.text ?? ""
        let EmployeeEmail1  = self.employeeEmailTxtField1.text ?? ""
        let EmployeeMobile1 = self.employeeMobileNumberTxtField1.text ?? ""
        
        if (self.employeeFullNameTxtField1.text != "") || (self.employeeEmailTxtField1.text != "") || (self.employeeMobileNumberTxtField1.text != "")
        {
            self.employeeSetUpRequestArr.append(EmployeeSetUpStruct.init(name: EmployeeName1, email: EmployeeEmail1, c_code: self.countryCode1, mobile: EmployeeMobile1, cellNumber: "0"))
        }
        //2
        let EmployeeName2   = self.employeeFullNameTxtField2.text ?? ""
        let EmployeeEmail2  = self.employeeEmailTxtField2.text ?? ""
        let EmployeeMobile2 = self.employeeMobileNumberTxtField2.text ?? ""
        
        if (self.employeeFullNameTxtField2.text != "") || (self.employeeEmailTxtField2.text != "") || (self.employeeMobileNumberTxtField2.text != "")
        {
            self.employeeSetUpRequestArr.append(EmployeeSetUpStruct.init(name: EmployeeName2, email: EmployeeEmail2, c_code: self.countryCode2, mobile: EmployeeMobile2, cellNumber: "1"))
        }
        
        //3
        let EmployeeName3   = self.employeeFullNameTxtField3.text ?? ""
        let EmployeeEmail3  = self.employeeEmailTxtField3.text ?? ""
        let EmployeeMobile3 = self.employeeMobileNumberTxtField3.text ?? ""
        
        if (self.employeeFullNameTxtField3.text != "") || (self.employeeEmailTxtField3.text != "") || (self.employeeMobileNumberTxtField3.text != "")
        {
            self.employeeSetUpRequestArr.append(EmployeeSetUpStruct.init(name: EmployeeName3, email: EmployeeEmail3, c_code: self.countryCode3, mobile: EmployeeMobile3, cellNumber: "2"))
        }
        //4
        let EmployeeName4   = self.employeeFullNameTxtField4.text ?? ""
        let EmployeeEmail4  = self.employeeEmailTxtField4.text ?? ""
        let EmployeeMobile4 = self.employeeMobileNumberTxtField4.text ?? ""
        
        if (self.employeeFullNameTxtField4.text != "") || (self.employeeEmailTxtField4.text != "") || (self.employeeMobileNumberTxtField4.text != "")
        {
            self.employeeSetUpRequestArr.append(EmployeeSetUpStruct.init(name: EmployeeName4, email: EmployeeEmail4, c_code: self.countryCode4, mobile: EmployeeMobile4, cellNumber: "3"))
        }
        //5
        let EmployeeName5   = self.employeeFullNameTxtField5.text ?? ""
        let EmployeeEmail5  = self.employeeEmailTxtField5.text ?? ""
        let EmployeeMobile5 = self.employeeMobileNumberTxtField5.text ?? ""
        
        if (self.employeeFullNameTxtField5.text != "") || (self.employeeEmailTxtField5.text != "") || (self.employeeMobileNumberTxtField5.text != "")
        {
            self.employeeSetUpRequestArr.append(EmployeeSetUpStruct.init(name: EmployeeName5, email: EmployeeEmail5, c_code: self.countryCode5, mobile: EmployeeMobile5, cellNumber: "4"))
        }
        print(self.employeeSetUpRequestArr.count)
        print(self.employeeSetUpRequestArr)
        
        DispatchQueue.main.async {
            self.importEmployeeApi()
        }
    }
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func importEmployeeApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.EMPLOYEE_SETUP_API
        if Reachability.isConnectedToNetwork() {
            guard let employerId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            // showProgressOnView(appDelegateInstance.window!)
            var subParam = [String:Any]()
            var employeeArray = [Any]()
            print("\(employeeSetUpRequestArr.count)")
            for item in employeeSetUpRequestArr {
                if ((item.name == "") || (item.email == "") || (item.mobile == ""))
                {
                }
                else
                {
                    let name = item.name
                    let email = item.email
                    let c_code = item.c_code
                    let mobile = item.mobile
                    subParam["name"] = name
                    subParam["email"] = email
                    subParam["c_code"] = c_code
                    subParam["mobile"] = mobile
                    employeeArray.append(subParam)
                }
            }
            print(employeeArray)
            
            //           let param:[String:Any] = ["user_id": "213", "company_id":"111", "employee":[["name": "name","email": "email@yopmail.com","c_code": "+91","mobile": "1234567890"]]]
            
                print(employeeArray)
            var employeeStr = ""
            employeeStr = json(from: employeeArray)!
            
            let param:[String:Any] = ["user_id": employerId, "company_id":companyId, "employee":employeeStr]
            print(param)
            
            var imageUrl:URL?
            ServerClass.sharedInstance.sendMultipartRequestToServer(urlString: fullUrl, fileName: "", param, imageUrl: imageUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let Alert = UIAlertController(title: "Message", message: json["message"].stringValue, preferredStyle: UIAlertController.Style.alert)
                    Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        let vc = CreateCompanyScedulerSetupVC()
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
                    //self.jobPositionsArr.removeAll()
                    //                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")

                    //                    }

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
                    //                    if (json["error"]["employee"].count != 0)
                    //                    {
                    //                        let errorMsg = json["error"]["employee"][0].stringValue
                    //                         UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    //
                    //                    }
                    //                    else
                    //                    {
                    //                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    //                    }

                }
                DispatchQueue.main.async {
                    // self.tbleView.reloadData()
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
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    func convertDictionaryToJsonData(infoDict:NSDictionary)-> Data
    {
        var jsonData: Data? = nil
        do
        {
            jsonData = try JSONSerialization.data(withJSONObject: infoDict as Any, options: .prettyPrinted)
        }
        catch
        {
        }
        return jsonData!
    }
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        return ""
    }
}
