//
//  TimeTrackingDetailVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 12/05/23.
//

import UIKit
import APJTextPickerView

class TimeTrackingDetailVC: UIViewController, APJTextPickerViewDelegate {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var fromDateTextField: APJTextPickerView!
    @IBOutlet weak var toDateTextField: APJTextPickerView!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var emptyView: UIImageView!
    var employeeTimeTrackingListArr = [EmployeeTimeTrackingListStruct]()
    
    var employeeName = ""
    var employeeId = ""
    var customEditTimeTrackingView : CustomEditTimeTrackingView!
    //Update shift data variables
    var idString            = ""
    var shiftName           = ""
    var shiftType           = ""
    var shiftCheckIn        = ""
    var shiftCheckOut       = ""
    var inDate              = ""
    var outDate             = ""
    var checkInTime         = ""
    var checkOutTime        = ""
    
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    // For pagination  1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    
    var fromDateStr = ""
    var toDateStr = ""
    
    let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.customNavigationBar.titleLabel.text = "\(employeeName.capitalized)"
        //        self.customNavigationBar.titleLabel.text = "Employee Time Tracking"
        tbleView.register(UINib(nibName: "EmployeeTimeTrackingCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeTimeTrackingCell")
        
        //Apjextextpicker
        self.fromDateTextField.pickerDelegate = self
        self.fromDateTextField.datePicker?.datePickerMode = .date
        self.fromDateTextField.dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.toDateTextField.pickerDelegate = self
        self.toDateTextField.datePicker?.datePickerMode = .date
        self.toDateTextField.dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
        self.getEmployeeTimeTrackingListApi()
    }
    func textPickerView(_ textPickerView: APJTextPickerView, didSelectDate date: Date?) {
        guard let date = date else { return }
        print("Date Selected: \(date)")
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        
        switch textPickerView.tag
        {
        case 101:
            self.fromDateStr = dateStr
        case 102:
            self.toDateStr = dateStr
        default:
            print("")
        }
        
        if (self.fromDateStr != "") && (self.toDateStr != "")
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let firstDate = formatter.date(from: self.fromDateStr)
            let secondDate = formatter.date(from: self.toDateStr)
            
            //            if firstDate?.compare(secondDate!) == .orderedSame {
            //                print("Both dates are same")
            //            }
            //            if firstDate?.compare(secondDate!) == .orderedAscending {
            //                print("First Date is greater then second date")
            //            }
            //            if (firstDate?.compare(secondDate!) == .orderedDescending) || (firstDate?.compare(secondDate!) == .orderedSame) {
            if (firstDate?.compare(secondDate!) == .orderedDescending){
                showMessageAlert(message: "To Date should be greater than From Date")
            }
            else
            {
                self.getEmployeeTimeTrackingListApi(fromDate: self.fromDateStr, toDate: self.toDateStr)
            }
        }
    }
    
    func getEmployeeTimeTrackingListApi(searchText: String? = nil, searchFields: String? = nil, fromDate: String? = nil, toDate: String? = nil)
    {
        
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_TIME_TRACKING_LIST_API
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            //            let param:[String:Any] = [ "page": self.currentPageIndex,"limit": "10","employee_id": self.employeeId]
            
            var param = [String:Any]()
            
            if (fromDate != nil) && (toDate != nil)
            {
                param = [ "page": self.currentPageIndex,"limit": "100","employee_id": self.employeeId,"from_date":fromDate!, "to_date":toDate!]
            }
            else
            {
                param = [ "page": self.currentPageIndex,"limit": "100","employee_id": self.employeeId]
            }
            
            
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
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
                        let date =  json["data"][i]["date"].stringValue
                        
                        let overTime =  json["data"][i]["over_time"].stringValue
                        let shiftHour =  json["data"][i]["shift_hour"].stringValue
                        let workingHour =  json["data"][i]["working_hour"].stringValue
                        
                        
                        var over_time =  ""
                        var shift_hour = ""
                        var working_hour = ""
                        if let result = self.formatter.string(from: TimeInterval((Float(overTime) ?? 0) * 60)) {
                            print(result)
                            over_time = result
                        }
                        if let result = self.formatter.string(from: TimeInterval((Float(shiftHour) ?? 0) * 60)) {
                            print(result)
                            shift_hour = result
                        }
                        if let result = self.formatter.string(from: TimeInterval((Float(workingHour) ?? 0) * 60)) {
                            print(result)
                            working_hour = result
                        }
                        
                        //                        let over_time =  calculateTime(Float(overTime) ?? 0)
                        //                        let shift_hour = calculateTime(Float(shiftHour) ?? 0)
                        //                        let working_hour = calculateTime(Float(workingHour) ?? 0)
                        
                        let localCheckInShiftTimeStr  = gmtToLocal(dateStr: shift_check_in) ?? "- "
                        let localCheckOutShiftTimeStr = gmtToLocal(dateStr: shift_check_out) ?? " -"
                        
                        let convertedLocalCheckInDateStr  = gmtToLocalDate(dateStr: check_in) ?? "- "
                        let convertedLocalCheckOutDateStr = gmtToLocalDate(dateStr: check_out) ?? " -"
                        let convertedLocalCheckInStr  = gmtToLocalTime(dateStr: check_in) ?? "- "
                        let convertedLocalCheckOutStr = gmtToLocalTime(dateStr: check_out) ?? " -"
                        
                        self.employeeTimeTrackingListArr.append(EmployeeTimeTrackingListStruct.init(id: id, employee_id: employee_id, name: name, shift_type: shift_type, shift_name: shift_name, shift_check_in: localCheckInShiftTimeStr, shift_check_out: localCheckOutShiftTimeStr, check_in: convertedLocalCheckInStr, check_out: convertedLocalCheckOutStr,checkInDate:convertedLocalCheckInDateStr,checkOutDate:convertedLocalCheckOutDateStr, shift_hour: shift_hour, working_hour: working_hour, over_time: over_time, date: date))
                    }
                }
                else
                {
                    self.employeeTimeTrackingListArr.removeAll()
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
    
    func showCustomEditTimeTrackingView (){
        self.customEditTimeTrackingView = CustomEditTimeTrackingView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.customEditTimeTrackingView.headerTitleLbl.text = "Update Time Tracker"
        
        self.customEditTimeTrackingView.shifttNameTextField.text = self.shiftName
        self.customEditTimeTrackingView.shifttTypeTextField.text = self.shiftType
        self.customEditTimeTrackingView.shifttCheckInTextField.text = self.shiftCheckIn
        self.customEditTimeTrackingView.shifttCheckOutTextField.text = self.shiftCheckOut
        self.customEditTimeTrackingView.inDateTextField.text = self.inDate
        self.customEditTimeTrackingView.outDateTextField.text = self.outDate
        self.customEditTimeTrackingView.checkInTimeTextField.text = self.checkInTime
        self.customEditTimeTrackingView.checkOutTimeTextField.text = self.checkOutTime
        
        self.customEditTimeTrackingView.shifttNameTextField.isEnabled = false
        self.customEditTimeTrackingView.shifttTypeTextField.isEnabled = false
        self.customEditTimeTrackingView.shifttCheckInTextField.isEnabled = false
        self.customEditTimeTrackingView.shifttCheckOutTextField.isEnabled = false
        self.customEditTimeTrackingView.updateButton.addTarget(self, action: #selector(self.updateButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customEditTimeTrackingView)
    }
    @objc func updateButtonPressed(sender: UIButton) {
        
        if (self.customEditTimeTrackingView.inDateTextField.text == "") || (self.customEditTimeTrackingView.inDateTextField.text?.filter { !$0.isWhitespace } == "-")
        {
            showMessageAlert(message: "Please enter shift check Out time")
        }
        else if (self.customEditTimeTrackingView.checkInTimeTextField.text == "") || (self.customEditTimeTrackingView.checkInTimeTextField.text?.filter { !$0.isWhitespace } == "-")
        {
            showMessageAlert(message: "Please enter shift check In time")
        }
        else if (self.customEditTimeTrackingView.outDateTextField.text == "") || (self.customEditTimeTrackingView.outDateTextField.text?.filter { !$0.isWhitespace } == "-")
        {
            showMessageAlert(message: "Please enter shift check Out time")
        }
        else if (self.customEditTimeTrackingView.checkOutTimeTextField.text == "") || (self.customEditTimeTrackingView.checkOutTimeTextField.text?.filter { !$0.isWhitespace } == "-")
        {
            showMessageAlert(message: "Please enter shift check In time")
        }
        else if (self.inDate != "") && (self.checkInTime != "") && (self.outDate != "") && (self.checkOutTime != "")
        {
            self.shiftName = self.customEditTimeTrackingView.shifttNameTextField.text ?? ""
            self.shiftType = self.customEditTimeTrackingView.shifttTypeTextField.text ?? ""
            self.shiftCheckIn = self.customEditTimeTrackingView.shifttCheckInTextField.text ?? ""
            self.shiftCheckOut = self.customEditTimeTrackingView.shifttCheckOutTextField.text ?? ""
            self.inDate = self.customEditTimeTrackingView.inDateTextField.text ?? ""
            self.outDate = self.customEditTimeTrackingView.outDateTextField.text ?? ""
            self.checkInTime = self.customEditTimeTrackingView.checkInTimeTextField.text ?? ""
            self.checkOutTime = self.customEditTimeTrackingView.checkOutTimeTextField.text ?? ""
            
            let checkInDateTimeStr = "\(self.inDate) \(self.checkInTime)"
            let checkOutDateTimeStr = "\(self.outDate) \(self.checkOutTime)"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd h:mm a"
            let firstDate = formatter.date(from: checkInDateTimeStr)
            let secondDate = formatter.date(from: checkOutDateTimeStr)
            
            if (firstDate?.compare(secondDate!) == .orderedDescending)
            {
                showMessageAlert(message: "Check Out Date should be greater than Check In Date")
            }
            else
            {
                self.updateEmployeeShiftTimeTrackingApi()
            }
        }
    }
    
    func updateEmployeeShiftTimeTrackingApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_TIME_TRACKING_API
        if self.idString == ""
        {
            return
        }
        guard UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID) != nil
        else {return}
        let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
        
        let checkInDateTimeStr = "\(self.inDate) \(self.checkInTime)"
        let checkInDateStr = localToGMTDateWithDate(dateStr: checkInDateTimeStr) ?? ""
        let checkInTimeStr = localToGMTWithTime(dateStr: checkInDateTimeStr) ?? ""
        let checkOutDateTimeStr = "\(self.outDate) \(self.checkOutTime)"
        let checkOutDateStr = localToGMTDateWithDate(dateStr: checkOutDateTimeStr) ?? ""
        let checkOutTimeStr = localToGMTWithTime(dateStr: checkOutDateTimeStr) ?? ""
        
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["id":self.idString,"user_id": userId,"check_in":checkInTimeStr,"check_out":checkOutTimeStr,"check_in_date":checkInDateStr,"check_out_date":checkOutDateStr]
            
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    //                    self.currentPageIndex = 0
                    //                    self.getEmployeeTimeTrackingListApi()
                    //                    self.customEditTimeTrackingView.removeFromSuperview()
                    self.customEditTimeTrackingView.removeFromSuperview()
                    let Alert = UIAlertController(title: "Message", message: json["message"].stringValue, preferredStyle: UIAlertController.Style.alert)
                    Alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action: UIAlertAction!) in
                        self.currentPageIndex = 0
                        self.getEmployeeTimeTrackingListApi()
                    }))
                    if let presenter = Alert.popoverPresentationController {
                        presenter.sourceView = self.view
                        presenter.sourceRect = self.view.bounds
                    }
                    DispatchQueue.main.async {
                        self.present(Alert, animated: true, completion: nil)
                    }
                    
                    
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
    @objc func editBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.employeeTimeTrackingListArr[index]
        self.idString = info.id
        if idString != ""
        {
            //Update shift data
            self.shiftName           = info.shift_name
            self.shiftType           = info.shift_type
            self.shiftCheckIn        = info.shift_check_in
            self.shiftCheckOut       = info.shift_check_out
            self.checkInTime         = info.check_in
            self.checkOutTime        = info.check_out
            self.inDate              = info.checkInDate
            self.outDate             = info.checkOutDate
            self.showCustomEditTimeTrackingView()
        }
    }
    
}
extension TimeTrackingDetailVC : UITableViewDataSource, UITableViewDelegate
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
        cell.shiftHoursBackView.isHidden = false
        cell.paidHoursBackView.isHidden  = false
        cell.otHoursBackView.isHidden    = false
        cell.editBtn.isHidden            = false
        
        let info = self.employeeTimeTrackingListArr[indexPath.row]
//        cell.employeeNameLbl.text           = "\(info.date)"
        cell.employeeNameLbl.text           = "\(info.date) (\(info.shift_type))"
        cell.employeeShiftTimeLbl.text      = "\(info.shift_check_in)-\(info.shift_check_out)"
        cell.employeeInTimeLbl.text         = "\(info.check_in)"
        cell.employeeOutTimeLbl.text        = "\(info.check_out)"
        cell.shiftHoursLbl.text             = "\(info.shift_hour)"
        cell.piadHoursLbl.text              = "\(info.working_hour)"
        cell.otHoursLbl.text                = "\(info.over_time)"
        
        cell.editBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(editBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 267
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.employeeTimeTrackingListArr.count - 1) {
            if (self.employeeTimeTrackingListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                //self.getEmployeeTimeTrackingListApi()
            }
        }
    }
    
}
