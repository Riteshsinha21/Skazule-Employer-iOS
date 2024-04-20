//
//  SchedulerDetailVC.swift
//  Skazule
//
//  Created by Chawtech on 14/04/23.
//

import UIKit

class SchedulerDetailVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profileImgBackView: UIView!
    @IBOutlet weak var noOfOpeningBackView: UIStackView!
    @IBOutlet weak var noOfAssignedOpeningBackView: UIStackView!
    @IBOutlet weak var noOfRsetOpeningBackView: UIStackView!
    @IBOutlet weak var positionBackView: UIStackView!
    @IBOutlet weak var tagsBackView: UIStackView!
    
    var isCommingFrom = ""
    var scheduleId = ""
    var openShiftDate  = ""
    var employeeDetail = EmployeeScheduleDataStruct()
    var openShiftDetail = OpenScheduleDataStruct()
    var companyTagsArr = [CompanyTagsStruct]()
    var tagsArr =  [String]()
    var selectedTagIdsArr = [String]()
    
    var assignEmployeeListArr = [AssignEmployeeListStruct]()
    
    @IBOutlet weak var shiftTypeLbl: UILabel!
    @IBOutlet weak var assignBtnBackView: UIView!
    @IBOutlet weak var assignBtn: UIButton!
    
    @IBOutlet weak var employeeProfileImgView: UIImageView!
    @IBOutlet weak var employeeNameLbl: UILabel!
    @IBOutlet weak var employeeEmailLbl: UILabel!
    @IBOutlet weak var employeePhoneNumberLbl: UILabel!
    @IBOutlet weak var noOfOpeningsLbl: UILabel!
    @IBOutlet weak var noOfAssignedOpeningsLbl: UILabel!
    @IBOutlet weak var noOfRestOpeningsLbl: UILabel!
    @IBOutlet weak var shiftDateLbl: UILabel!
    @IBOutlet weak var shiftStartTimeLbl: UILabel!
    @IBOutlet weak var shiftEndTimeLbl: UILabel!
    @IBOutlet weak var shiftBreakDurationLbl: UILabel!
    @IBOutlet weak var employeePositionLbl: UILabel!
    @IBOutlet weak var employeeTagLbl: UILabel!
    @IBOutlet weak var shiftNotesLbl: UILabel!
    
    //Custom View
    var customEmployeeListView : CustomAppliedShiftEmployeeListView!
    
    
    //    // MARK: - Pull-to-Refresh   // PtR 1
    //    lazy var refreshControl: UIRefreshControl = {
    //        let refreshControl = UIRefreshControl()
    //        refreshControl.addTarget(self, action:
    //                                    #selector(self.handleRefresh(_:)),
    //                                 for: .valueChanged)
    //        refreshControl.tintColor = .black
    //        return refreshControl
    //    }()
    //    // PtR 2
    //    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    //        //currentPageIndex = 1
    //        //self.getTimeLineListApi()
    //        //refreshControl.endRefreshing()
    //        self.getScheduleDetailApi(scheduleId: self.scheduleId)
    //        refreshControl.endRefreshing()
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.customNavigationBar.titleLabel.text = "Schedule Detail"
        self.getScheduleDetailApi(scheduleId: self.scheduleId)
        self.setUIData()
        
        //        // Register to receive notification in your class
        //        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil)
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.EMPLOYEE_SHIFT_STATUS), object: nil)
        
    }
    @objc func openNotification(_ notification: Notification)
    {
        //        print(notification.userInfo ?? "")
        //
        //        if let dict = notification.userInfo as NSDictionary? {
        //            if let employeeId = dict["employeeId"] as? String {
        //                //self.selectedEmployeeId = employeeId
        //                self.assignSchedulerToEmployeeApi(scheduleId: self.scheduleId, employeeId: employeeId, dateStr: self.openShiftDate)
        //            }
        //        }
        self.getScheduleDetailApi(scheduleId: self.scheduleId)
        
    }
    func setUIData()
    {
        self.shiftTypeLbl.text = "\(isCommingFrom) Schedule"
        let info = openShiftDetail
        self.openShiftDate = info.date
        let dateString = info.date + " " + info.check_in
        let convertedLocalDateStr = gmtToLocalDate(dateStr: dateString)
        let convertedLocalCheckInStr = gmtToLocal(dateStr: info.check_in)
        let convertedLocalCheckOutStr = gmtToLocal(dateStr: info.check_out)
        
        let currentDateStr  = Date().toString(dateFormat: "yyyy-MM-dd")
        let currentTimeStr  = Date().toString(dateFormat: "h:mm a")
        
        if isCommingFrom ==  "Open Shift"
        {
            if (currentDateStr > convertedLocalDateStr ?? "\(currentDateStr)")
            {
                self.assignBtnBackView.isHidden = true
            }
            else if (currentDateStr == convertedLocalDateStr ?? "\(currentDateStr)") && (isTimeCompareFromCurrentTime(currentTimeStr: currentTimeStr, timeIn: convertedLocalCheckInStr ?? "\(currentTimeStr)") == false)
            {
                self.assignBtnBackView.isHidden = true
            }
            else
            {
                self.assignBtnBackView.isHidden = false
            }
            //self.assignBtnBackView.isHidden = false
            self.profileImgBackView.isHidden = true
            self.noOfOpeningBackView.isHidden = false
            self.positionBackView.isHidden = false
            self.tagsBackView.isHidden = false
            self.noOfAssignedOpeningBackView.isHidden = false
            self.noOfRsetOpeningBackView.isHidden = false
            
            //            self.noOfOpeningsLbl.text           = "\(info.nubmer_of_opening)"
            //            self.noOfAssignedOpeningsLbl.text   = "\(info.nubmer_of_assigned_opening)"
            //            self.noOfRestOpeningsLbl.text       = "\(info.rest_opening)"
            self.shiftDateLbl.text              = "\(convertedLocalDateStr ?? "")"
            self.shiftStartTimeLbl.text         = "\(convertedLocalCheckInStr ?? "")"
            self.shiftEndTimeLbl.text           = "\(convertedLocalCheckOutStr ?? "")"
            self.shiftBreakDurationLbl.text     = "\(info.break_duration)"
            self.shiftNotesLbl.text             = "\(info.note)"
            self.employeePositionLbl.text       = "\(info.position)"
            self.employeeTagLbl.text            = "-"
            self.shiftNotesLbl.text             = "\(info.note)"
        }
        else  if isCommingFrom ==  "Employee Shift"
        {
            self.profileImgBackView.isHidden = false
            self.assignBtnBackView.isHidden = true
            self.noOfOpeningBackView.isHidden = true
            self.positionBackView.isHidden = true
            self.tagsBackView.isHidden = true
            self.noOfAssignedOpeningBackView.isHidden = true
            self.noOfRsetOpeningBackView.isHidden = true
            
            let employeeInfo = employeeDetail
            
            let imageUrl = IMAGE_BASE_URL + employeeInfo.profile_pic
            self.employeeProfileImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "profilePlaceHolder"))
            self.employeeNameLbl.text           = "\(employeeInfo.name)"
            self.employeeEmailLbl.text          = "\(employeeInfo.email)"
            self.employeePhoneNumberLbl.text    = "\(employeeInfo.mobile)"
        }
    }
    
    func getScheduleDetailApi(scheduleId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_SCHEDULER_EDIT_DETAIL_API
        if Reachability.isConnectedToNetwork() {
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "schedule_id": scheduleId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { [self] (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let date =  json["data"]["date"].stringValue
                    let check_in =  json["data"]["check_in"].stringValue
                    let check_out =  json["data"]["check_out"].stringValue
                    let break_duration =  json["data"]["break_duration"].stringValue
                    let note =  json["data"]["note"].stringValue
                    
                    let noOfOpening =  json["data"]["nubmer_of_opening"].stringValue
                    let noOfAssignedOpening =  json["data"]["nubmer_of_assigned_opening"].stringValue
                    
                    if isCommingFrom ==  "Employee Shift"
                    {
                        let dateString = date + " " + check_in
                        let convertedLocalDateStr = gmtToLocalDate(dateStr: dateString)
                        let convertedLocalCheckInStr = gmtToLocal(dateStr: check_in)
                        let convertedLocalCheckOutStr = gmtToLocal(dateStr: check_out)
                        self.shiftDateLbl.text              = "\(convertedLocalDateStr ?? "")"
                        self.shiftStartTimeLbl.text         = "\(convertedLocalCheckInStr ?? "")"
                        self.shiftEndTimeLbl.text           = "\(convertedLocalCheckOutStr ?? "")"
                        self.shiftBreakDurationLbl.text     = "\(break_duration)"
                        self.shiftNotesLbl.text             = "\(note)"
                        
                    }
                    else if isCommingFrom ==  "Open Shift"
                    {
                        let tags =  json["data"]["tags"].arrayValue
                        for item in tags
                        {
                            tagsArr.append(item.rawValue as! String)
                        }
                        if tagsArr.count != 0
                        {
                            self.getCompanyTagsApi()
                        }
                        self.assignEmployeeListArr.removeAll()
                        for i in 0..<json["data"]["request_from"].count
                        {
                            let status =  json["data"]["request_from"][i]["schedule_status"].stringValue
                            let name =  json["data"]["request_from"][i]["name"].stringValue
                            let email =  json["data"]["request_from"][i]["email"].stringValue
                            let profile_pic =  json["data"]["request_from"][i]["profile_pic"].stringValue
                            let mobile =  json["data"]["request_from"][i]["mobile"].stringValue
                            let c_code =  json["data"]["request_from"][i]["c_code"].stringValue
                            let employee_id =  json["data"]["request_from"][i]["employee_id"].stringValue
                            
                            self.assignEmployeeListArr.append(AssignEmployeeListStruct.init(schedule_status: status, name: name, email: email, profile_pic: profile_pic, mobile: mobile, c_code: c_code, employee_id: employee_id,checkBoxSelected: false))
                        }
                        
                        print(self.assignEmployeeListArr)
                        
                        self.noOfOpeningsLbl.text           = "\(noOfOpening)"
                        self.noOfAssignedOpeningsLbl.text   = "\(noOfAssignedOpening)"
                        let restOpening = (Int(noOfOpening) ?? 0) - (Int(noOfAssignedOpening) ?? 0)
                        self.noOfRestOpeningsLbl.text       = "\(restOpening)"
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
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    func getCompanyTagsApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_COMPANY_TAGS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "company_id": companyId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.companyTagsArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let tag =  json["data"][i]["tag"].stringValue
                        
                        self.companyTagsArr.append(CompanyTagsStruct.init(id: id, tag: tag))
                    }
                    DispatchQueue.main.async {
                        var tagsStrArr = [String]()
                        for i in 0..<self.tagsArr.count
                        {
                            if let tagID = self.companyTagsArr.first(where: {$0.id == self.tagsArr[i]}) {
                                self.selectedTagIdsArr.append(tagID.id)
                                tagsStrArr.append(tagID.tag)
                            }
                        }
                        self.selectedTagIdsArr = self.selectedTagIdsArr.uniqued()
                        tagsStrArr = tagsStrArr.uniqued()
                        let selectedTagsStr = tagsStrArr.joined(separator: ",")
                        self.employeeTagLbl.text = selectedTagsStr
                    }
                    
                }
                else {
                    self.companyTagsArr.removeAll()
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
    
    func assignSchedulerToEmployeeApi(scheduleId:String, employeeId:String, dateStr:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.ASSIGN_SCHEDULE_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String?] = [ "user_id": userId, "company_id":companyId, "schedule_id":scheduleId,"employee_id":employeeId, "date": dateStr]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { [self] (json) in
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
    
    @IBAction func onTapAssignEmployeeBtn(_ sender: Any) {
        if self.assignEmployeeListArr.count > 0
        {
            self.customEmployeeListView = CustomAppliedShiftEmployeeListView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            self.customEmployeeListView.employeeListArr = self.assignEmployeeListArr
            self.customEmployeeListView.scheduleID = self.scheduleId
            self.view.addSubview(self.customEmployeeListView)
        }
        else
        {
            showMessageAlert(message: "Not applied by any employee")
        }
        
        //showMessageAlert(message: "Work in progress")
    }
    
}
