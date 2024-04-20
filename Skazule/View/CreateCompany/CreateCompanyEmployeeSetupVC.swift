//
//  CreateCompanyEmployeeSetupVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit
import Alamofire

struct EmployeeSetUpStruct
{
    var name: String   = ""
    var email: String  = ""
    var c_code: String = defaultCCode
    var mobile: String = ""
    var cellNumber: String = "0"
}
class CreateCompanyEmployeeSetupVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tbleView: UITableView!
    var employeeTemplateCount = 3
    var employeeSetUpArr = [EmployeeSetUpStruct]()
    var employeeSetUpRequestArr = [EmployeeSetUpStruct]()
    
    //1
    var extensionCCode = ""
    
    @IBOutlet weak var tbleViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tbleView.register(UINib(nibName: "CreateCompanyEmployeeSetupCell", bundle: Bundle.main), forCellReuseIdentifier: "CreateCompanyEmployeeSetupCell")
        //1
        for i in 0..<3
        {
            self.employeeSetUpArr.append(EmployeeSetUpStruct.init(name: "", email: "", c_code: defaultCCode, mobile: "", cellNumber: "\(i)"))
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tbleView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tbleView.removeObserver(self, forKeyPath: "contentSize")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"
        {
            if let newValue = change?[.newKey]
            {
                let newsize = newValue as! CGSize
                self.tbleViewHeightConstraint.constant = newsize.height
            }
        }
    }
    
    // MARK: - Add More Empployee button tapped
    @IBAction func onTapAddMoreEmpployeeButton(_ sender: Any) {
        
        //        if self.employeeTemplateCount <= 5
        //        {
        //            self.employeeTemplateCount = (self.employeeTemplateCount + 1)
        //            self.employeeSetUpArr.append(EmployeeSetUpStruct.init(name: "", email: "", c_code: "", mobile: ""))
        //            self.tbleView.reloadData()
        //        }
        //2
        if self.employeeSetUpArr.count <= 5
        {
            self.employeeSetUpArr.append(EmployeeSetUpStruct.init(name: "", email: "", c_code: defaultCCode, mobile: "", cellNumber: "\(self.employeeSetUpArr.count)"))
            self.tbleView.reloadData()
        }
    }
    // MARK: - Skip button tapped
    @IBAction func onTapSkipButton(_ sender: Any) {
        let vc = CreateCompanyScedulerSetupVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Next button tapped
    @IBAction func onTapNextButton(_ sender: Any) {
        self.importEmployeeApi()
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
            
            //           let param:[String:Any] = ["user_id": "213", "company_id":"111", "employee":[["name": "name","email": "email@yopmail.com","c_code": defaultCCode,"mobile": "1234567890"]]]
            
            print(employeeArray)
            var employeeStr = ""
            employeeStr = json(from: employeeArray)!
            
            let param:[String:Any] = ["user_id": employerId, "company_id":companyId, "employee":employeeStr]
            //print(param)
            
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
                    self.tbleView.reloadData()
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
    
    @objc func onTapCountryPicker(sender:UIButton)
    {
        let index = sender.tag
        let vc = CountryPickerVC()
        present(vc, animated: true)
        
        //        var info = self.employeeBonusListArr
        //        var checkBoxStatus = info[index].checkBoxStatus
        //        checkBoxStatus = !checkBoxStatus
        //        info[index].checkBoxStatus = checkBoxStatus
        //        var bonusId = info[index].id
        //        if checkBoxStatus == true
        //        {
        //            bonusIdArr.append(bonusId)
        //        }
        //        else
        //        {
        //            if let index = bonusIdArr.firstIndex(of: bonusId) {
        //                bonusIdArr.remove(at: index)
        //            }
        //        }
        //        print(bonusIdArr)
        //        self.employeeBonusListArr = info
        //        self.tbleView.reloadData()
    }
    
}
extension CreateCompanyEmployeeSetupVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeSetUpArr.count //employeeTemplateCount //3 //self.employeeSetUpArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCompanyEmployeeSetupCell") as! CreateCompanyEmployeeSetupCell
        cell.selectionStyle = .none
        cell.delegate = self
        
        if self.employeeSetUpArr.count > 0
        {
            cell.employeeSetUpDetail = self.employeeSetUpArr[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 300
    }
}
extension CreateCompanyEmployeeSetupVC: CreateCompanyEmployeeSetupCellDelegate{
    
    func onChangeEmployeeSetup(cell: CreateCompanyEmployeeSetupCell, fullName: String, email: String, mobileNumber: String) {
        
        var detail =  cell.employeeSetUpDetail
        detail?.name = fullName
        detail?.email = email
        detail?.mobile = mobileNumber
        let cellIndexNumber = Int(detail?.cellNumber ?? "0")
        
        switch cellIndexNumber
        {
        case 0:
            if self.employeeSetUpRequestArr.count == 0
            {
                self.employeeSetUpRequestArr.insert(detail!, at: 0)
            }
            else
            {
                self.employeeSetUpRequestArr[0] = detail!
            }
            break
        case 1:
            if self.employeeSetUpRequestArr.count == 0
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 0)
            }
            
            if self.employeeSetUpRequestArr.count == 1
            {
                detail?.name = fullName
                detail?.email = email
                detail?.mobile = mobileNumber
                self.employeeSetUpRequestArr.insert(detail!, at: 1)
            }
            else
            {
                detail?.name = fullName
                detail?.email = email
                detail?.mobile = mobileNumber
                self.employeeSetUpRequestArr[1] = detail!
            }
            break
        case 2:
            if self.employeeSetUpRequestArr.count == 0
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 0)
            }
            if self.employeeSetUpRequestArr.count == 1
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 1)
            }
            if self.employeeSetUpRequestArr.count == 2
            {
                detail?.name = fullName
                detail?.email = email
                detail?.mobile = mobileNumber
                self.employeeSetUpRequestArr.insert(detail!, at: 2)
            }
            else
            {
                detail?.name = fullName
                detail?.email = email
                detail?.mobile = mobileNumber
                self.employeeSetUpRequestArr[2] = detail!
            }
            break
        case 3:
            if self.employeeSetUpRequestArr.count == 0
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 0)
            }
            if self.employeeSetUpRequestArr.count == 1
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 1)
            }
            if self.employeeSetUpRequestArr.count == 2
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 2)
            }
            if self.employeeSetUpRequestArr.count == 3
            {
                detail?.name = fullName
                detail?.email = email
                detail?.mobile = mobileNumber
                self.employeeSetUpRequestArr.insert(detail!, at: 3)
            }
            else
            {
                detail?.name = fullName
                detail?.email = email
                detail?.mobile = mobileNumber
                self.employeeSetUpRequestArr[3] = detail!
            }
            break
        case 4:
            if self.employeeSetUpRequestArr.count == 0
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 0)
            }
            if self.employeeSetUpRequestArr.count == 1
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 1)
            }
            if self.employeeSetUpRequestArr.count == 2
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 2)
            }
            if self.employeeSetUpRequestArr.count == 3
            {
                detail?.name = ""
                detail?.email = ""
                detail?.mobile = ""
                self.employeeSetUpRequestArr.insert(detail!, at: 3)
            }
            if self.employeeSetUpRequestArr.count == 4
            {
                detail?.name = fullName
                detail?.email = email
                detail?.mobile = mobileNumber
                self.employeeSetUpRequestArr.insert(detail!, at: 4)
            }
            else
            {
                detail?.name = fullName
                detail?.email = email
                detail?.mobile = mobileNumber
                self.employeeSetUpRequestArr[4] = detail!
            }
            break
        default: break
        }
    }
}
