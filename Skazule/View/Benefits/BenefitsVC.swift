//
//  BenefitsVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit

class BenefitsVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var emptyView: UIImageView!
    var benefitsListArr = [BenefitsListStruct]()
    var employeeBenefitsArr = [BenefitsStruct]()
    
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.customNavigationBar.titleLabel.text = "Benefits"
        tbleView.register(UINib(nibName: "EmployeeListTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeListTableCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
        self.getEmployeeBenefitsListApi()
    }
    func getEmployeeBenefitsListApi(searchText: String? = nil, searchFields: String? = nil)
    {
        
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_BENEFITS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            //            let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId, "search":"\(searchStr)"]
            
            var param:[String:Any] = [:]
            if searchStr != ""
            {
                param = ["page": 0,"limit": "1000","company_id": companyId, "search":"\(searchStr)"]
            }
            else
            {
                param = ["page": "\(self.currentPageIndex)","limit": "10","company_id": companyId, "search":"\(searchStr)"]
            }
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    // For pagination 3
                    self.totalPageIndexCount = json["total_record_count"].intValue
                    if self.currentPageIndex == 0 {
                        self.benefitsListArr.removeAll()
                    }
                    //self.benefitsListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        var benefits_name =  json["data"][i]["benefits_name"].stringValue //4
                        var mobile =  json["data"][i]["mobile"].stringValue // 3
                        var role =  json["data"][i]["role"].stringValue //2
                        let profile_pic =  json["data"][i]["profile_pic"].stringValue
                        let position =  json["data"][i]["position"].stringValue
                        var employee_name =  json["data"][i]["employee_name"].stringValue //1
                        let email =  json["data"][i]["email"].stringValue
                        let employee_id =  json["data"][i]["employee_id"].stringValue
                        let c_code =  json["data"][i]["c_code"].stringValue
                        
                        if employee_name == ""
                        {
                            employee_name = "--"
                        }
                        if role == ""
                        {
                            role = "--"
                        }
                        if mobile == ""
                        {
                            mobile = "--"
                        }
                        if benefits_name == ""
                        {
                            benefits_name = "--"
                        }
                        let jsonBenefits = json["data"][i]["benefits"]
                        self.employeeBenefitsArr.removeAll()
                        for j in 0..<jsonBenefits.count
                        {
                            let id          =  jsonBenefits[j]["id"].stringValue
                            let benefit     =  jsonBenefits[j]["benefit"].stringValue
                            let description =  jsonBenefits[j]["description"].stringValue
                            let premium_pay =  jsonBenefits[j]["premium_pay"].stringValue
                            let company_pay =  jsonBenefits[j]["company_pay"].stringValue
                            let employee_pay =  jsonBenefits[j]["employee_pay"].stringValue
                            let gross_pay   =  jsonBenefits[j]["gross_pay"].stringValue
                            self.employeeBenefitsArr.append(BenefitsStruct.init(id: id, benefit: benefit, description: description, premium_pay: premium_pay, company_pay: company_pay, employee_pay: employee_pay, gross_pay: gross_pay))
                        }
                        self.benefitsListArr.append(BenefitsListStruct.init(benefits_name: benefits_name, mobile: mobile, role: role, profile_pic: profile_pic, position: position, employee_name: employee_name, email: email, employee_id: employee_id, c_code: c_code, benefits: self.employeeBenefitsArr))
                    }
                }
                else
                {
                    self.benefitsListArr.removeAll()
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
                        // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
                DispatchQueue.main.async {
                    if self.benefitsListArr.count == 0
                    {
                        self.tbleView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    else
                    {
                        self.tbleView.isHidden = false
                        self.emptyView.isHidden = true
                    }
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
    @IBAction func searchBtnClicked(_ sender: Any)
    {
        if searchTxtField.text != ""
        {
            self.getEmployeeBenefitsListApi()
        }
    }
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        self.currentSearchFieldsText = nil
        self.currentSearchText = sender.text
        self.getEmployeeBenefitsListApi(searchText: sender.text!)
    }
}
extension BenefitsVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.benefitsListArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeListTableCell") as! EmployeeListTableCell
        cell.selectionStyle = .none
        cell.shiftNameTextField.isHidden = true
        let info = self.benefitsListArr[indexPath.row]
        cell.nameTextField.text = info.employee_name
        cell.roleTextField.text = info.role
        cell.mobileTextField.text = "Contact Number : \(info.mobile)"
        cell.tagTextField.text = "Benefits : \(info.benefits_name)"
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        cell.employeeProfilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = BenefitsDetailVC()
        vc.employeeBenefitsDetail   = self.benefitsListArr[indexPath.row]
        if  self.benefitsListArr[indexPath.row].benefits?.count != 0
        {
            vc.benefitsArr       = self.benefitsListArr[indexPath.row].benefits!
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.benefitsListArr.count - 1) {
            if (self.benefitsListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getEmployeeBenefitsListApi()
            }
        }
    }
}
extension BenefitsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentSearchText = textField.text
        self.currentSearchFieldsText = nil
        self.getEmployeeBenefitsListApi(searchText: textField.text!)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard range.location == 0 else {
            return true
        }
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
}
