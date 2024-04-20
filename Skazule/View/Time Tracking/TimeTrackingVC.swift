//
//  TimeTrackingVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit
import APJTextPickerView

class TimeTrackingVC: UIViewController, APJTextPickerViewDelegate {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBarForDrawer!
    //    @IBOutlet weak var customNavigationBar: CustomNavigationBarForDrawer!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var emptyView: UIImageView!
    @IBOutlet weak var filterDateTxtField: APJTextPickerView!
    var employeeTimeTrackingListArr = [EmployeeTimeTrackingListStruct]()
    
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    // For pagination  1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    // For Notification
    var notificationDetailArr = [NotificationDetailStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.customNavigationBar.titleLabel.text = "Time Tracking"
        //self.getNotificationDetailApi()
        self.customNavigationBar.rightBtn.isHidden = true
        self.customNavigationBar.rightBtn.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
        tbleView.register(UINib(nibName: "EmployeeTimeTrackingCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeTimeTrackingCell")
        //Apjextextpicker
        //self.filterDateTxtField.datePicker?.minimumDate = Date()
        
        //Apjextextpicker
        filterDateTxtField.pickerDelegate = self
        self.filterDateTxtField.datePicker?.datePickerMode = .date
        self.filterDateTxtField.dateFormatter.dateFormat = "yyyy-MM-dd"
        self.filterDateTxtField.text = currentDate()
    }
    @objc func didTapNotificationButton (_ sender:UIButton) {
        print("Notification Button is selected")
        let vc = NotificationVC ()
        vc.notificationDetail = self.notificationDetailArr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getNotificationDetailApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_NOTIFICATION_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else { return }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "user_id": userId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { [self] (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let totalCount = json["total_record_count"].stringValue
                    notificationCount = totalCount
                    if notificationCount != "0"
                    {
                        self.customNavigationBar.notificationCountLbl.isHidden = false
                        self.customNavigationBar.notificationCountLbl.text = notificationCount
                    }
                    else
                    {
                        self.customNavigationBar.notificationCountLbl.isHidden = true
                    }
                    self.notificationDetailArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id              = json["data"][i]["id"].stringValue
                        let company_id      = json["data"][i]["company_id"].stringValue
                        let user_id         = json["data"][i]["user_id"].stringValue
                        let type            = json["data"][i]["type"].stringValue
                        let title           = json["data"][i]["title"].stringValue
                        let message         = json["data"][i]["message"].stringValue
                        let from_id         = json["data"][i]["from_id"].stringValue
                        let redirect_url    = json["data"][i]["redirect_url"].stringValue
                        let status          = json["data"][i]["status"].stringValue
                        let created_at      = json["data"][i]["created_at"].stringValue
                        let updated_at      = json["data"][i]["updated_at"].stringValue
                        let sender_name     = json["data"][i]["sender_name"].stringValue
                        let sender_profile_pic = json["data"][i]["sender_profile_pic"].stringValue
                        
                        self.notificationDetailArr.append(NotificationDetailStruct.init(id: id, company_id: company_id, user_id: user_id, type: type, title: title, message: message, from_id: from_id, redirect_url: redirect_url, status: status, created_at: created_at, updated_at: updated_at,sender_name: sender_name,sender_profile_pic: sender_profile_pic))
                    }
                    print(self.notificationDetailArr)
                    
                }
                else {
                    
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
    override func viewWillAppear(_ animated: Bool) {
        //        self.tabBarController?.tabBar.isHidden = false
        
        // For pagination 2
        currentPageIndex = 0
        self.getAllEmployeeTimeTrackingListApi(dateStr:self.filterDateTxtField.text ?? currentDate())
    }
    func currentDate() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: date)
        return currentDate
    }
    
    func getAllEmployeeTimeTrackingListApi(searchText: String? = nil, searchFields: String? = nil, dateStr:String)
    {
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullUrl = BASE_URL + PROJECT_URL.GET_ALL_EMPLOYEE_TIME_TRACKING_LIST_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "page": self.currentPageIndex,"limit": "100","company_id": companyId, "search":"\(searchStr)","date_filter":dateStr]
            ////print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                ////print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    //                    self.employeeTimeTrackingListArr.removeAll()
                    
                    //For pagination 3
                    self.totalPageIndexCount = json["total_record_count"].intValue
                    if self.currentPageIndex == 0 {
                        self.employeeTimeTrackingListArr.removeAll()
                    }
                    
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let employee_id =  json["data"][i]["employee_id"].stringValue
                        let name =  json["data"][i]["name"].stringValue
                        let shift_type =  json["data"][i]["shift_type"].stringValue
                        let shift_name =  json["data"][i]["shift_name"].stringValue
                        let shift_check_in =  json["data"][i]["shift_check_in"].stringValue
                        let shift_check_out =  json["data"][i]["shift_check_out"].stringValue
                        let check_in =  json["data"][i]["check_in"].stringValue
                        let check_out =  json["data"][i]["check_out"].stringValue
                        
                        let overTime =  json["data"][i]["over_time"].stringValue
                        let shiftHour =  json["data"][i]["shift_hour"].stringValue
                        let workingHour =  json["data"][i]["working_hour"].stringValue
                        
                        let over_time =  calculateTime(Float(overTime) ?? 0)
                        let shift_hour = calculateTime(Float(shiftHour) ?? 0)
                        let working_hour = calculateTime(Float(workingHour) ?? 0)
                        
                        
                        
                        let localCheckInShiftTimeStr  = gmtToLocal(dateStr: shift_check_in) ?? "- "
                        let localCheckOutShiftTimeStr = gmtToLocal(dateStr: shift_check_out) ?? " -"
                        //                        let convertedLocalCheckInStr  = gmtToLocalWithDateInAMPM(dateStr: check_in) ?? "- "
                        //                        let convertedLocalCheckOutStr = gmtToLocalWithDateInAMPM(dateStr: check_out) ?? " -"
                        let convertedLocalCheckInStr  = gmtToLocalTime(dateStr: check_in) ?? "- "
                        let convertedLocalCheckOutStr = gmtToLocalTime(dateStr: check_out) ?? " -"
                        
                        self.employeeTimeTrackingListArr.append(EmployeeTimeTrackingListStruct.init(id: id, employee_id: employee_id, name: name, shift_type: shift_type, shift_name: shift_name, shift_check_in: localCheckInShiftTimeStr, shift_check_out: localCheckOutShiftTimeStr, check_in: convertedLocalCheckInStr, check_out: convertedLocalCheckOutStr, shift_hour: shift_hour, working_hour: working_hour, over_time: over_time, date: ""))
                    }
                }
                else
                {
                    self.employeeTimeTrackingListArr.removeAll()
                    var errorMsg = ""
                    let errorDict = json["error"].dictionaryValue
                    // enumerate all of the keys and values
                    for (key, value) in errorDict {
                        ////print("\(key) -> \(value)")
                        for i in 0..<value.count
                        {
                            errorMsg = " \(json["error"][key][i].stringValue)"
                        }
                        ////print(errorMsg)
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
                    if self.employeeTimeTrackingListArr.count == 0
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
            self.getAllEmployeeTimeTrackingListApi(dateStr:self.filterDateTxtField.text ?? currentDate())
        }
    }
    
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        self.currentSearchFieldsText = nil
        self.currentSearchText = sender.text
        self.getAllEmployeeTimeTrackingListApi(searchText: sender.text!, dateStr:self.filterDateTxtField.text ?? currentDate())
    }
    func textPickerView(_ textPickerView: APJTextPickerView, didSelectDate date: Date?) {
        guard let date = date else { return }
        print("Date Selected: \(date)")
        self.getAllEmployeeTimeTrackingListApi(dateStr: "\(date)")
    }
}
extension TimeTrackingVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeTimeTrackingListArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTimeTrackingCell") as! EmployeeTimeTrackingCell
        cell.selectionStyle = .none
        let info = self.employeeTimeTrackingListArr[indexPath.row]
        cell.employeeNameLbl.text           = "\(info.name)(\(info.shift_type))"
        cell.employeeShiftTimeLbl.text      = "\(info.shift_check_in) - \(info.shift_check_out)"
        cell.employeeInTimeLbl.text         = "\(info.check_in)"
        cell.employeeOutTimeLbl.text        = "\(info.check_out)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = TimeTrackingDetailVC()
        vc.employeeId = self.employeeTimeTrackingListArr[indexPath.row].employee_id
        vc.employeeName = self.employeeTimeTrackingListArr[indexPath.row].name
        //        vc.employeeBenefitsDetail   = self.benefitsListArr[indexPath.row]
        //        if  self.benefitsListArr[indexPath.row].benefits?.count != 0
        //        {
        //            vc.benefitsArr       = self.benefitsListArr[indexPath.row].benefits!
        //        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 172 //267
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.employeeTimeTrackingListArr.count - 1) {
            if (self.employeeTimeTrackingListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getAllEmployeeTimeTrackingListApi(dateStr:self.filterDateTxtField.text ?? currentDate())
            }
        }
    }
}
extension TimeTrackingVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentSearchText = textField.text
        self.currentSearchFieldsText = nil
        self.getAllEmployeeTimeTrackingListApi(searchText: textField.text!,dateStr:self.filterDateTxtField.text ?? currentDate())
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
