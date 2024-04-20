//
//  TimeOffRequestVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit
import DropDown

class TimeOffRequestVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var icanApproveBtn: UIButton!
    @IBOutlet weak var allRequestBtn: UIButton!
    @IBOutlet weak var icanApproveDDBackView: UIView!
    @IBOutlet weak var icanApproveTypeDDTextField: UITextField!
    @IBOutlet weak var icanApproveTypeDDBtn: UIButton!
    @IBAction func onTapICanApproveDDBtn(_ sender: Any) {
        self.setupDropDown(arr: self.leaveTypeDDArr, showOn: self.icanApproveTypeDDTextField)
    }
    @IBOutlet weak var requestDDBackView: UIStackView!
    @IBOutlet weak var requestTypeDDTextField: UITextField!
    @IBOutlet weak var requestTypeDDBtn: UIButton!
    @IBAction func onTapRequestDDBtn(_ sender: Any) {
        self.setupDropDown(arr: self.leaveTypeDDArr, showOn: self.requestTypeDDTextField)
    }
    @IBOutlet weak var requestStatusDDTextField: UITextField!
    @IBOutlet weak var requestStatusDDBtn: UIButton!
    @IBAction func onTaprequestStatusDDBtn(_ sender: Any) {
        self.setupDropDown(arr: self.filterStatusDDArr, showOn: self.requestStatusDDTextField)
    }
    let singleSelectionDropDown = DropDown()
    var filterStatusDDArr = ["Select Status","Pending","Approved","Denied/Rejected"]
    var filterStatusIdDDArr = ["","0","1","3"]
    
    var leaveTypeDDArr = [String]()
    var leaveTypeArr = [LeaveTypeStruct]()
    
    var selectedFilterStatusId = ""
    var selectedICanApproveLeaveTypeStatusId = ""
    var selectedRequestLeaveTypeStatusId = ""
    
    var employeeLeaveListArr = [EmployeeLeaveListStruct]()
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    
    var isSeletedTopTab = 0
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    func setupDropDown(arr:[String],showOn:UITextField)
    {
        singleSelectionDropDown.anchorView = showOn
        singleSelectionDropDown.bottomOffset = CGPoint(x: 0, y: showOn.bounds.height+10)
        singleSelectionDropDown.dataSource = arr
        singleSelectionDropDown.show()
        singleSelectionDropDown.selectionAction = { [unowned self] (index, item) in
            print(self)
            let selectedIndex : Int? = index
            showOn.text = item
            
            if (showOn == self.icanApproveTypeDDTextField)
            {
                let info = self.leaveTypeArr[selectedIndex!]
                self.selectedICanApproveLeaveTypeStatusId = info.id
                
                self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_PENDING_LEAVE_REQUST_API)
            }
            if (showOn == self.requestTypeDDTextField)
            {
                let info = self.leaveTypeArr[selectedIndex!]
                self.selectedRequestLeaveTypeStatusId = info.id
                
                self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_ALL_LEAVE_REQUST_API)
                
            }
            if (showOn == self.requestStatusDDTextField)
            {
                let info = self.filterStatusIdDDArr[selectedIndex!]
                self.selectedFilterStatusId = info
                
                self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_ALL_LEAVE_REQUST_API)
            }
            
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.titleLabel.text = "Time Off Request"
        //self.customNavigationBar.leftBarButtonItem.isHidden = true
        tbleView.register(UINib(nibName: "EmployeeListTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeListTableCell")
        self.requestDDBackView.isHidden = true
        self.icanApproveDDBackView.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if UIScreen.main.bounds.height <= 667 { // iPhone SE screen height is 667 points.
            //self.icanApproveBtn.setTitle("Requests I Can /n Approve ", for: .normal)
            // Configure the title label for multi-line text
            self.icanApproveBtn.titleLabel?.numberOfLines = 0
            self.icanApproveBtn.titleLabel?.lineBreakMode = .byWordWrapping
        }
        
        // For pagination 2
        currentPageIndex = 0
        
        if isSeletedTopTab == 0
        {
            self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_PENDING_LEAVE_REQUST_API)
        }
        else
        {
            self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_ALL_LEAVE_REQUST_API)
        }
        self.getLeaveTypeDDApi()
        
        self.requestStatusDDTextField.text = self.filterStatusDDArr[0]
        self.selectedFilterStatusId        = ""
    }
    @IBAction func searchBtnClicked(_ sender: Any)
    {
        if searchTxtField.text != ""
        {
            if isSeletedTopTab == 0
            {
                self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_PENDING_LEAVE_REQUST_API)
            }
            else
            {
                self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_ALL_LEAVE_REQUST_API)
            }
        }
    }
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        self.currentSearchFieldsText = nil
        self.currentSearchText = sender.text
        if isSeletedTopTab == 0
        {
            self.getEmployeeLeaveListApi(searchText: sender.text!, endPointUrl: PROJECT_URL.GET_PENDING_LEAVE_REQUST_API)
        }
        else
        {
            self.getEmployeeLeaveListApi(searchText: sender.text!, endPointUrl: PROJECT_URL.GET_ALL_LEAVE_REQUST_API)
        }
    }
    @IBAction func onTapICanApproveBtn(_ sender: Any) {
        self.setDropDownTextAccordingToCondition()
        
        self.requestDDBackView.isHidden = true
        self.icanApproveDDBackView.isHidden = false
        currentPageIndex = 0
        self.searchTxtField.text = ""
        self.isSeletedTopTab = 0
        self.icanApproveBtn.backgroundColor = UIColor(r: 10, g: 75, b: 144, a: 1)
        self.icanApproveBtn.setTitleColor(UIColor.white, for: .normal)
        self.allRequestBtn.backgroundColor = .clear
        self.allRequestBtn.setTitleColor(UIColor(r: 10, g: 75, b: 144, a: 1), for: .normal)
        
        self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_PENDING_LEAVE_REQUST_API)
    }
    @IBAction func onTapAllRequestBtn(_ sender: Any) {
        self.setDropDownTextAccordingToCondition()
        self.requestDDBackView.isHidden = false
        self.icanApproveDDBackView.isHidden = true
        currentPageIndex = 0
        self.searchTxtField.text = ""
        self.isSeletedTopTab = 1
        self.icanApproveBtn.backgroundColor = .clear
        self.icanApproveBtn.setTitleColor(UIColor(r: 10, g: 75, b: 144, a: 1), for: .normal)
        self.allRequestBtn.backgroundColor = UIColor(r: 10, g: 75, b: 144, a: 1)
        self.allRequestBtn.setTitleColor(UIColor.white, for: .normal)
        self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_ALL_LEAVE_REQUST_API)
    }
    func setDropDownTextAccordingToCondition()
    {
        self.icanApproveTypeDDTextField.text = self.leaveTypeDDArr[0]
        self.requestTypeDDTextField.text     = self.leaveTypeDDArr[0]
        self.selectedICanApproveLeaveTypeStatusId = ""
        self.selectedRequestLeaveTypeStatusId = ""
        self.requestStatusDDTextField.text = self.filterStatusDDArr[0]
        self.selectedFilterStatusId        = ""
    }
    func getEmployeeLeaveListApi(searchText: String? = nil, searchFields: String? = nil,endPointUrl:String)
    {
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullUrl = BASE_URL + endPointUrl
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            
            var param:[String:Any] = [:]
            if (searchStr != "")
            {
                param = ["page": 0,"company_id": companyId, "search":"\(searchStr)"]
                self.currentPageIndex = 0
            }
            else if (selectedICanApproveLeaveTypeStatusId != "")
            {
                param = ["page": 0,"company_id": companyId, "request_type_filter":"\(selectedICanApproveLeaveTypeStatusId)"]
                self.currentPageIndex = 0
            }
            else if (selectedRequestLeaveTypeStatusId != "")
            {
                param = ["page": 0,"company_id": companyId, "request_type_filter":"\(selectedRequestLeaveTypeStatusId)"]
                self.currentPageIndex = 0
            }
            else if (selectedFilterStatusId != "")
            {
                param = ["page": 0,"company_id": companyId, "status_filter":"\(selectedFilterStatusId)"]
                self.currentPageIndex = 0
            }
            else
            {
                param = ["page": "\(self.currentPageIndex)","limit": "10","company_id": companyId, "search":"\(searchStr)"]
            }
            
            print(fullUrl)
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.totalPageIndexCount = json["total_record_count"].intValue
                    if (self.currentPageIndex == 0) {
                        self.employeeLeaveListArr.removeAll()
                    }
                    //self.employeeLeaveListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let c_code =  json["data"][i]["c_code"].stringValue
                        let start_date =  json["data"][i]["start_date"].stringValue
                        let description =  json["data"][i]["description"].stringValue
                        let email =  json["data"][i]["email"].stringValue
                        let profile_pic =  json["data"][i]["profile_pic"].stringValue
                        let id =  json["data"][i]["id"].stringValue
                        let created_at =  json["data"][i]["created_at"].stringValue
                        let employee_id =  json["data"][i]["employee_id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let role =  json["data"][i]["role"].stringValue
                        let leave_type =  json["data"][i]["leave_type"].stringValue
                        let end_date =  json["data"][i]["end_date"].stringValue
                        let employee_name =  json["data"][i]["employee_name"].stringValue
                        let mobile =  json["data"][i]["mobile"].stringValue
                        
                        let updated_by =  json["data"][i]["updated_by"].stringValue
                        let updated_at =  json["data"][i]["updated_at"].stringValue
                        let modefier_role =  json["data"][i]["modefier_role"].stringValue
                        
                        self.employeeLeaveListArr.append(EmployeeLeaveListStruct.init(mobile: mobile, employee_name: employee_name, end_date: end_date, leave_type: leave_type, role: role, status: status, employee_id: employee_id, email: email, id: id, created_at: created_at, profile_pic: profile_pic, description: description, start_date: start_date, c_code: c_code,updated_by:updated_by,updated_at:updated_at,modefier_role:modefier_role))
                    }
                }
                else {
                    self.employeeLeaveListArr.removeAll()
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
                        //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
                DispatchQueue.main.async {
                    if self.employeeLeaveListArr.count == 0
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
    
    func getLeaveTypeDDApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.LEAVE_TYPE_DD_API
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.leaveTypeArr.removeAll()
                    self.leaveTypeDDArr.removeAll()
                    
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let name =  json["data"][i]["name"].stringValue
                        
                        self.leaveTypeArr.append(LeaveTypeStruct.init(id: id, role: name))
                        self.leaveTypeDDArr.append(name)
                    }
                    self.leaveTypeArr.insert(LeaveTypeStruct.init(id: "", role: "Select Type"), at: 0)
                    self.leaveTypeDDArr.insert("Select Type", at: 0)
                    
                    self.icanApproveTypeDDTextField.text = self.leaveTypeDDArr[0]
                    self.requestTypeDDTextField.text     = self.leaveTypeDDArr[0]
                    self.selectedICanApproveLeaveTypeStatusId = ""
                    self.selectedRequestLeaveTypeStatusId = ""
                    self.requestStatusDDTextField.text = self.filterStatusDDArr[0]
                    self.selectedFilterStatusId        = ""
                    
                }
                else {
                    self.leaveTypeArr.removeAll()
                    self.leaveTypeDDArr.removeAll()
                    
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
                    //self.tbleView.reloadData()
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
extension TimeOffRequestVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeLeaveListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeListTableCell") as! EmployeeListTableCell
        cell.selectionStyle = .none
        cell.editDeleteBackView.isHidden = true
        cell.shiftNameTextField.isHidden = true
        cell.tagTextField.isHidden = true
        cell.statusBackView.isHidden = false
        
        let info = self.employeeLeaveListArr[indexPath.row]
        cell.nameTextField.text = info.employee_name
        cell.roleTextField.text = "Request Type : \(info.leave_type)"
        //        cell.mobileTextField.text = "Request On : \(info.created_at)"
        let onRequestDateTime = gmtToLocalWithDate(dateStr: info.created_at)
        cell.mobileTextField.text = "Request On : \(onRequestDateTime ?? "--")"
        
        if info.status == "0"
        {
            cell.statusLbl.text = "Pending"
            cell.statusLbl.textColor = .orange
        }
        else if info.status == "1"
        {
            cell.statusLbl.text = "Approved"
            cell.statusLbl.textColor = .systemGreen
        }
        else if info.status == "3"
        {
            cell.statusLbl.text = "Rejeted"
            cell.statusLbl.textColor = .red
        }
        
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        cell.employeeProfilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = TimeOffRequestDetailVC()
        vc.employeeLeaveDetail = self.employeeLeaveListArr[indexPath.row]
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
        
        if isSeletedTopTab == 0
        {
            if indexPath.row == (self.employeeLeaveListArr.count - 1) {
                if (self.employeeLeaveListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                    currentPageIndex = currentPageIndex + 1
                    self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_PENDING_LEAVE_REQUST_API)
                }
            }
        }
        else
        {
            if indexPath.row == (self.employeeLeaveListArr.count - 1) {
                if (self.employeeLeaveListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                    currentPageIndex = currentPageIndex + 1
                    self.getEmployeeLeaveListApi(endPointUrl: PROJECT_URL.GET_ALL_LEAVE_REQUST_API)
                }
            }
        }
    }
}
extension TimeOffRequestVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentSearchText = textField.text
        self.currentSearchFieldsText = nil
        if isSeletedTopTab == 0
        {
            self.getEmployeeLeaveListApi(searchText: textField.text!, endPointUrl: PROJECT_URL.GET_PENDING_LEAVE_REQUST_API)
        }
        else
        {
            self.getEmployeeLeaveListApi(searchText: textField.text!, endPointUrl: PROJECT_URL.GET_ALL_LEAVE_REQUST_API)
        }
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
