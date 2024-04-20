//
//  AssignBonusVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 27/01/23.
//

import UIKit

class AssignBonusVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var bonusAmountField: UITextField!
    @IBOutlet weak var bonusDesTxtField: UITextView!
    
    var employeeListArr = [EmployeeStruct]()
    var employeeNameIdArr = [String]()
    
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.titleLabel.text = "Assign Bonus"
        tblView.register(UINib(nibName: "CreateCompanyScheduledPositionsTableCell", bundle: Bundle.main), forCellReuseIdentifier: "CreateCompanyScheduledPositionsTableCell")
        self.bonusDesTxtField.placeholder = "Enter Description"
        self.getEmployeeListApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
    }
    
    func getEmployeeListApi(searchText: String? = nil, searchFields: String? = nil, pageIndex: String? = "")
    {
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_LIST_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            //let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId]
            
            var param:[String:Any] = [:]
            if (searchStr != "")
            {
                param = ["page": 0,"company_id": companyId, "search":"\(searchStr)"]
                self.currentPageIndex = 0
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
                    if (self.currentPageIndex == 0) {
                        self.employeeListArr.removeAll()
                    }
                    //self.employeeListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let profile_pic =  json["data"][i]["profile_pic"].stringValue
                        let id =  json["data"][i]["employee_id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let name =  json["data"][i]["name"].stringValue
                        let role =  json["data"][i]["role"].stringValue
                        self.employeeListArr.append(EmployeeStruct.init(profile_pic: profile_pic, status: status, id: id, name: name, role: role, checkBoxSelected: false))
                    }
                }
                else {
                    self.employeeListArr.removeAll()
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
                    if self.employeeListArr.count == 0
                    {
                        self.tblView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    else
                    {
                        self.tblView.isHidden = false
                        self.emptyView.isHidden = true
                    }
                    self.tblView.reloadData()
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
    func assignBonusApi(desc:String, bonusAmount:String )
    {
        let fullUrl = BASE_URL + PROJECT_URL.ASSIGN_BONUS_API
        
        if Reachability.isConnectedToNetwork() {
            
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            var employeeNameIdStr = ""
            employeeNameIdStr = self.employeeNameIdArr.joined(separator: ",")
            print(employeeNameIdStr)
            
            let param:[String:Any] = ["user_id": userId, "company_id":companyId, "employee_id": employeeNameIdStr,"bonus_amount":bonusAmount,"description": desc]
            
            //employee_id:"13,14,15"
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
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
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        self.currentSearchFieldsText = nil
        self.currentSearchText = sender.text
        self.getEmployeeListApi(searchText: sender.text!)
    }
    
    // MARK: - Next button tapped
    @IBAction func onTapAssignButton(_ sender: Any) {
        for i in 0..<self.employeeListArr.count
        {
            let checkStatus = self.employeeListArr[i].checkBoxSelected
            let checkStatusId = self.employeeListArr[i].id
            if checkStatus
            {
                employeeNameIdArr.append(checkStatusId)
            }
        }
        print(employeeNameIdArr)//
        
        if self.employeeNameIdArr.count == 0
        {
            showMessageAlert(message: "Please select Employee")
        }
        else if(self.bonusAmountField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter bonus amount")
        }
        else if (self.bonusDesTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter bonus description")
        }
        else
        {
            self.assignBonusApi(desc: self.bonusDesTxtField.text!, bonusAmount: bonusAmountField.text!)
        }
    }
    
    @objc func employeeCheckBoxBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        var info = self.employeeListArr
        
        sender.isSelected = !sender.isSelected
        info[index].checkBoxSelected = sender.isSelected
        self.employeeListArr = info
        self.tblView.reloadData()
    }
}
extension AssignBonusVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCompanyScheduledPositionsTableCell") as! CreateCompanyScheduledPositionsTableCell
        cell.selectionStyle = .none
        cell.cellBackView.backgroundColor = .clear
        let info = self.employeeListArr[indexPath.row]
        cell.jobPositionNameLbl.text = info.name
        
        if info.checkBoxSelected == true
        {
            cell.jobPositionCheckBox.isSelected = true
        }
        else
        {
            cell.jobPositionCheckBox.isSelected = false
        }
        
        cell.jobPositionCheckBox.tag = indexPath.row
        cell.jobPositionCheckBox.addTarget(self, action: #selector(employeeCheckBoxBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.employeeListArr.count - 1) {
            if (self.employeeListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getEmployeeListApi()
            }
        }
    }
}
extension AssignBonusVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentSearchText = textField.text
        self.currentSearchFieldsText = nil
        self.getEmployeeListApi(searchText: textField.text!)
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
