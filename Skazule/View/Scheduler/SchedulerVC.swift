//
//  SchedulerVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit
import DropDown
import CoreMedia

class SchedulerVC: UIViewController {
    
    @IBOutlet weak var customNavigationBarForDrawer: CustomNavigationBarForDrawer!
    @IBOutlet weak var calenderTxtField: UITextField!
    @IBOutlet weak var filterTxtField: UITextField!
    @IBOutlet weak var currentDateLbl: UILabel!
    @IBOutlet weak var weekCollectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var openShiftBackView: UIView!
    @IBOutlet weak var openShiftHeaderView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var hiddenSections = Set<Int>()
    var selectedEmplyeeSchedulelistCount = 0
    
    var currentWeekArr = [CurrentWeekStruct]()
    var dayNameArr = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
    var selectedDateByCalenderPicker = Date()
    
    var isSelected          = 0
    
    var openScheduleDataArr = [OpenScheduleDataStruct]()
    var employeeScheduleDataArr = [EmployeeScheduleDataStruct]()
    var employeeScheduleShiftsArr = [OpenScheduleDataStruct]()
    //Drop Down
    let singleSelectionDropDown = DropDown()
    let filterArr = ["Current Date", "Current Week"]
    
    let datePicker = UIDatePicker()
    var isSelectedDateArr = [Bool]()
    var isSelectedDate = false
    
    var selectedDate = ""
    
    func setupDropDown(arr:[String],showOn:UITextField)
    {
        singleSelectionDropDown.anchorView = showOn
        singleSelectionDropDown.bottomOffset = CGPoint(x: 0, y: showOn.bounds.height+10)
        singleSelectionDropDown.dataSource = arr
        singleSelectionDropDown.show()
        singleSelectionDropDown.selectionAction = { [unowned self] (index, item) in
            print(self)
            //let selectedIndex : Int? = index
            showOn.text = item
        }
    }
    
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
    //        self.getSchedulerDataApi(dateStr: self.selectedDate)
    //        refreshControl.endRefreshing()
    //    }
    
    // For Notification
    var notificationDetailArr = [NotificationDetailStruct]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply the font attributes to the segmented control's text
        self.segmentControl.setTitleTextAttributes(segmentFontAttributes, for: .normal)

        
        // Do any additional setup after loading the view.
        self.customNavigationBarForDrawer.titleLabel.text = "Scheduler"
       // self.getNotificationDetailApi()
        
        customNavigationBarForDrawer.rightBtn.isHidden = true
        customNavigationBarForDrawer.rightBtn.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
        self.tblView.register(UINib(nibName: "SchedulerShiftTableCell", bundle: Bundle.main), forCellReuseIdentifier: "SchedulerShiftTableCell")
        self.weekCollectionView.register(UINib(nibName: "SchedulerWeekCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SchedulerWeekCollectionCell")
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.SCHEDULE_CREATED_STATUS), object: nil)
        
        // View Will Appear code
        self.currentWeekArr.removeAll()
        let weekArr = Date().daysOfWeek(using: .iso8601).map(\.ddMMyyyy)
        self.isSelectedDateArr.removeAll()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: date)
        let currentDateArr = currentDate.split(separator: "-")
        for i in 0..<weekArr.count
        {
            let weekStr = weekArr[i]
            let dateArr = weekStr.split(separator: ".")
            self.currentWeekArr.append(CurrentWeekStruct.init(date: String(dateArr[0]), month: String(dateArr[1]), year: String(dateArr[2]), day: dayNameArr[i]))
            if dateArr[0] == currentDateArr[2]
            {
                self.isSelectedDateArr.append(true)
            }
            else
            {
                self.isSelectedDateArr.append(false)
            }
        }
        
        print(currentWeekArr)
        self.weekCollectionView.reloadData()
        showDatePicker()
        self.currentDateLbl.text = self.currentDate()
        self.calenderTxtField.text = currentDateShowInCalender(dateStr: currentDate)
        print(currentDate)
        self.selectedDate = currentDate
        self.getSchedulerDataApi(dateStr: currentDate)
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
                        customNavigationBarForDrawer.notificationCountLbl.isHidden = false
                        customNavigationBarForDrawer.notificationCountLbl.text = notificationCount
                    }
                    else
                    {
                        customNavigationBarForDrawer.notificationCountLbl.isHidden = true
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
    //MARK:- Notification selector
    @objc func openNotification(_ notification: Notification)
    {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            
            if let slectedDateStringBack = dict["date"] as? String {
                // do something with your image
                self.currentWeekArr.removeAll()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let commingDate = formatter.date(from: slectedDateStringBack) ?? Date()
                let weekArr = commingDate.daysOfWeek(using: .iso8601).map(\.ddMMyyyy)
                self.isSelectedDateArr.removeAll()
                let commingDateStr = formatter.string(from: commingDate)
                let commingDateStrArr = commingDateStr.split(separator: "-")
                for i in 0..<weekArr.count
                {
                    let weekStr = weekArr[i]
                    let dateArr = weekStr.split(separator: ".")
                    self.currentWeekArr.append(CurrentWeekStruct.init(date: String(dateArr[0]), month: String(dateArr[1]), year: String(dateArr[2]), day: dayNameArr[i]))
                    if dateArr[0] == commingDateStrArr[2]
                    {
                        self.isSelectedDateArr.append(true)
                    }
                    else
                    {
                        self.isSelectedDateArr.append(false)
                    }
                }
                print(currentWeekArr)
                self.weekCollectionView.reloadData()
                //                showDatePicker()
                self.currentDateLbl.text = self.selectedDate(selectDate: commingDate)
                self.calenderTxtField.text = currentDateShowInCalender(dateStr: slectedDateStringBack)
                self.selectedDate = slectedDateStringBack
                self.getSchedulerDataApi(dateStr: slectedDateStringBack)
            }
        }
    }
    func currentDate() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        let currentDate = formatter.string(from: date)
        return currentDate
    }
    func selectedDate(selectDate:Date) -> String
    {
        let date = selectDate
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        let currentDate = formatter.string(from: date)
        return currentDate
    }
    func selectedDateByCurrentWeek(dateStr:String) -> String {
        let formatter = DateFormatter()
        //formatter.dateFormat = "dd/MM/yyyy"
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateStr)
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dayName = formatter.string(from: date!)
        return dayName
    }
    func currentDateShowInCalender(dateStr:String) -> String {
        let formatter = DateFormatter()
        //formatter.dateFormat = "dd/MM/yyyy"
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateStr)
        formatter.dateFormat = "MMM d, yyyy"
        let dayName = formatter.string(from: date!)
        return dayName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //        // add the UIRefreshControl object to the UITableView object. // PtR 3
        //        self.tblView.addSubview(self.refreshControl)
        //
        //        self.currentWeekArr.removeAll()
        //        let weekArr = Date().daysOfWeek(using: .iso8601).map(\.ddMMyyyy)
        //        self.isSelectedDateArr.removeAll()
        //        let date = Date()
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "yyyy-MM-dd"
        //        let currentDate = formatter.string(from: date)
        //        let currentDateArr = currentDate.split(separator: "-")
        //        for i in 0..<weekArr.count
        //        {
        //            let weekStr = weekArr[i]
        //            let dateArr = weekStr.split(separator: ".")
        //            self.currentWeekArr.append(CurrentWeekStruct.init(date: String(dateArr[0]), month: String(dateArr[1]), year: String(dateArr[2]), day: dayNameArr[i]))
        //            if dateArr[0] == currentDateArr[2]
        //            {
        //                self.isSelectedDateArr.append(true)
        //            }
        //            else
        //            {
        //                self.isSelectedDateArr.append(false)
        //            }
        //        }
        //
        //        print(currentWeekArr)
        //        self.weekCollectionView.reloadData()
        //        showDatePicker()
        //        self.currentDateLbl.text = self.currentDate()
        //        self.calenderTxtField.text = currentDateShowInCalender(dateStr: currentDate)
        //        print(currentDate)
        //        self.selectedDate = currentDate
        //        self.getSchedulerDataApi(dateStr: currentDate)
    }
    
    @IBAction func segmentSelected(_ sender: UISegmentedControl)
    {
        if (sender.selectedSegmentIndex == 0)
        {
            //            self.view.bringSubviewToFront(self.resultScrollView)
            self.isSelected                = 0
            self.openShiftHeaderView.isHidden = false
        }
        else if (sender.selectedSegmentIndex == 1)
        {
            self.isSelected                  = 1
            self.openShiftHeaderView.isHidden = true
        }
        self.tblView.reloadData()
    }
    @objc func addEmployeeBtnClicked(_ sender:UIButton)
    {
        //        let index = sender.tag
        //
        //        if (self.employeeScheduleDataArr[index].employeeScheduleArr?.count ?? 0 > 0)
        //        {
        //            DispatchQueue.main.async
        //            {
        //                self.tblView.reloadData()
        //            }
        //        }
        //        else
        //        {
        //            DispatchQueue.main.async
        //            {
        //                self.tblView.reloadData()
        //            }
        //        }
        
        ///////// simple logic for collase and expand
        //        let section = sender.tag
        //        func indexPathsForSection() -> [IndexPath] {
        //            var indexPaths = [IndexPath]()
        //            //self.employeeScheduleDataArr[section].employeeScheduleArr?.count ?? 0
        //            for row in 0..<self.employeeScheduleDataArr[section].employeeScheduleArr!.count {
        //                indexPaths.append(IndexPath(row: row,
        //                                            section: section))
        //            }
        //
        //            return indexPaths
        //        }
        //        if self.hiddenSections.contains(section) {
        //            self.hiddenSections.remove(section)
        //            self.tblView.insertRows(at: indexPathsForSection(),
        //                                      with: .fade)
        //        } else {
        //            self.hiddenSections.insert(section)
        //            self.tblView.deleteRows(at: indexPathsForSection(),
        //                                      with: .fade)
        //        }
        
        
        
        
        
        
    }
    
    @IBAction func onTapCalenderBtn(_ sender: Any) {
        //        self.calenderTxtField.datePicker?.datePickerMode = .date
        //        //self.calenderTxtField.dateFormatter.dateFormat = "h:mm a"
    }
    @IBAction func onTapFilterBtn(_ sender: Any) {
        self.setupDropDown(arr: self.filterArr, showOn: self.filterTxtField)
    }
    
    @IBAction func onTapAddOpenShiftBtn(_ sender: Any) {
        
        let vc = AddEditSchedulerShiftViewController()
        vc.isOpenFrom = "Add Open Shift"
        vc.isOpenFromShift = "Open Shift"
        vc.byDefaultDate   = "\(selectedDate)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showDatePicker() {
        self.calenderTxtField.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        //datePicker.minimumDate = Date()
        datePicker.locale = .current
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline //.compact
        } else {
            // Fallback on earlier versions
        }
        
        datePicker.addTarget(self, action: #selector(handleDateSelection), for: .valueChanged)
    }
    @objc func handleDateSelection()
    {
        let dateFormetter = DateFormatter()
        dateFormetter.dateStyle = .medium
        dateFormetter.timeStyle = .none
        self.calenderTxtField.text = dateFormetter.string(from: datePicker.date)
        dateFormetter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormetter.string(from: datePicker.date)
        print(selectedDate)
        self.selectedDateByCalenderPicker = datePicker.date
        print(self.selectedDateByCalenderPicker)
        self.changeCurrentWeek(selectedDateStr: selectedDate)
        self.selectedDate = selectedDate
        self.getSchedulerDataApi(dateStr: selectedDate)
    }
    func changeCurrentWeek(selectedDateStr:String)
    {
        let weekArr = self.selectedDateByCalenderPicker.daysOfWeek(using: .iso8601).map(\.ddMMyyyy)
        self.currentWeekArr.removeAll()
        let selectedDateArr = selectedDateStr.split(separator: "-")
        self.isSelectedDateArr.removeAll()
        for i in 0..<weekArr.count
        {
            let weekStr = weekArr[i]
            let dateArr = weekStr.split(separator: ".")
            self.currentWeekArr.append(CurrentWeekStruct.init(date: String(dateArr[0]), month: String(dateArr[1]), year: String(dateArr[2]), day: dayNameArr[i]))
            if dateArr[0] == selectedDateArr[2]
            {
                self.isSelectedDateArr.append(true)
            }
            else
            {
                self.isSelectedDateArr.append(false)
            }
        }
        print(self.isSelectedDateArr)
        
        
        print(currentWeekArr)
        self.weekCollectionView.reloadData()
        
        self.currentDateLbl.text = selectedDate(selectDate: self.selectedDateByCalenderPicker)
    }
    
    //    func getSchedulerDataApi(date:String)
    //    {
    //        let fullUrl = BASE_URL + PROJECT_URL.GET_SCHEDULER_DATA_API
    //        if Reachability.isConnectedToNetwork() {
    //            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
    //            else {
    //                return
    //            }
    //            showProgressOnView(appDelegateInstance.window!)
    //            //            let param:[String:Any] = ["company_id": companyId, "filter": "", "date_filter":"", "page": "0","limit": "100"]
    //            let param:[String:Any] = ["company_id": companyId, "date_filter":date]
    //            print(param)
    //
    //            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
    //                print(json)
    //                hideAllProgressOnView(appDelegateInstance.window!)
    //                let success = json["status"].stringValue
    //                if success  == "1"
    //                {
    //                    self.openScheduleDataArr.removeAll()
    //                    for i in 0..<json["data"]["open_schedules"].count
    //                    {
    //                        let check_out =  json["data"]["open_schedules"][i]["check_out"].stringValue
    //                        let check_in =  json["data"]["open_schedules"][i]["check_in"].stringValue
    //                        let nubmer_of_opening =  json["data"]["open_schedules"][i]["nubmer_of_opening"].stringValue
    //                        let break_duration =  json["data"]["open_schedules"][i]["break_duration"].stringValue
    //                        let position =  json["data"]["open_schedules"][i]["position"].stringValue
    //                        let note =  json["data"]["open_schedules"][i]["note"].stringValue
    //                        let shift_name =  json["data"]["open_schedules"][i]["shift_name"].stringValue
    //                        let schedule_id =  json["data"]["open_schedules"][i]["schedule_id"].stringValue
    //                        let nubmer_of_assigned_opening =  json["data"]["open_schedules"][i]["nubmer_of_assigned_opening"].stringValue
    //                        let date =  json["data"]["open_schedules"][i]["date"].stringValue
    //
    //                        let rest_opening =  json["data"]["open_schedules"][i]["rest_opening"].stringValue
    //                        let color_code =  json["data"]["open_schedules"][i]["color_code"].stringValue
    //
    //
    //
    //                        self.openScheduleDataArr.append(OpenScheduleDataStruct.init(check_out: check_out, check_in: check_in, nubmer_of_opening: nubmer_of_opening, break_duration: break_duration, position: position, note: note, rest_opening: rest_opening, shift_name: shift_name, schedule_id: schedule_id, nubmer_of_assigned_opening: nubmer_of_assigned_opening, date: date, color_code: color_code, id: "",employee_id:""))
    //                    }
    //                    self.employeeScheduleDataArr.removeAll()
    //                    for i in 0..<json["data"]["employee_schedules"].count
    //                    {
    //
    //                        let name =  json["data"]["employee_schedules"][i]["name"].stringValue
    //                        let email =  json["data"]["employee_schedules"][i]["email"].stringValue
    //                        let c_code =  json["data"]["employee_schedules"][i]["c_code"].stringValue
    //                        let mobile =  json["data"]["employee_schedules"][i]["mobile"].stringValue
    //                        let profile_pic =  json["data"]["employee_schedules"][i]["profile_pic"].stringValue
    //                        let employee_id =  json["data"]["employee_schedules"][i]["employee_id"].stringValue
    //
    //
    //                        self.employeeScheduleShiftsArr.removeAll()
    //                        for j in 0..<json["data"]["employee_schedules"][i]["schedules"].count
    //                        {
    //                            let check_out =  json["data"]["employee_schedules"][i]["schedules"][j]["check_out"].stringValue
    //                            let check_in =  json["data"]["employee_schedules"][i]["schedules"][j]["check_in"].stringValue
    //                            let nubmer_of_opening =  json["data"]["employee_schedules"][i]["schedules"][j]["nubmer_of_opening"].stringValue
    //                            let break_duration =  json["data"]["employee_schedules"][i]["schedules"][j]["break_duration"].stringValue
    //                            let position =  json["data"]["employee_schedules"][i]["schedules"][j]["position"].stringValue
    //                            let note =  json["data"]["employee_schedules"][i]["schedules"][j]["note"].stringValue
    //                            let shift_name =  json["data"]["employee_schedules"][i]["schedules"][j]["shift_name"].stringValue
    //                            let schedule_id =  json["data"]["employee_schedules"][i]["schedules"][j]["schedule_id"].stringValue
    //                            let nubmer_of_assigned_opening =  json["data"]["employee_schedules"][i]["schedules"][j]["nubmer_of_assigned_opening"].stringValue
    //                            let date =  json["data"]["employee_schedules"][i]["schedules"][j]["date"].stringValue
    //
    //                            let rest_opening =  json["data"]["employee_schedules"][i]["schedules"][j]["rest_opening"].stringValue
    //                            let color_code =  json["data"]["employee_schedules"][i]["schedules"][j]["color_code"].stringValue
    //                            let id =  json["data"]["employee_schedules"][i]["schedules"][j]["id"].stringValue
    //                            let employee_id =  json["data"]["employee_schedules"][i]["schedules"][j]["employee_id"].stringValue
    //
    //                            self.employeeScheduleShiftsArr.append(OpenScheduleDataStruct.init(check_out: check_out, check_in: check_in, nubmer_of_opening: nubmer_of_opening, break_duration: break_duration, position: position, note: note, rest_opening: rest_opening, shift_name: shift_name, schedule_id: schedule_id, nubmer_of_assigned_opening: nubmer_of_assigned_opening, date: date, color_code: color_code, id: id,employee_id:employee_id))
    //                        }
    //                        self.employeeScheduleDataArr.append(EmployeeScheduleDataStruct.init(name: name, email: email, c_code: c_code, mobile: mobile, employee_id: employee_id, profile_pic: profile_pic, employeeScheduleArr: self.employeeScheduleShiftsArr))
    //                    }
    //
    //                }
    //                else {
    //
    //                    self.openScheduleDataArr.removeAll()
    //                    self.employeeScheduleDataArr.removeAll()
    //                    self.employeeScheduleShiftsArr.removeAll()
    //
    //                    var errorMsg = ""
    //                    let errorDict = json["error"].dictionaryValue
    //                    // enumerate all of the keys and values
    //                    for (key, value) in errorDict {
    //                        print("\(key) -> \(value)")
    //                        for i in 0..<value.count
    //                        {
    //                            errorMsg = " \(json["error"][key][i].stringValue)"
    //                        }
    //                        print(errorMsg)
    //                    }
    //                    if errorMsg == ""
    //                    {
    //                        //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
    //                    }
    //                    else
    //                    {
    //                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
    //                    }
    //                }
    //                DispatchQueue.main.async {
    //                    //                    if self.employeeListArr.count == 0
    //                    //                    {
    //                    //                        self.tbleView.isHidden = true
    //                    //                        self.emptyView.isHidden = false
    //                    //                    }
    //                    //                    else
    //                    //                    {
    //                    //                        self.tbleView.isHidden = false
    //                    //                        self.emptyView.isHidden = true
    //                    //                    }
    //                    self.tblView.reloadData()
    //                }
    //
    //            }, errorBlock: { (NSError) in
    //                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
    //                hideAllProgressOnView(appDelegateInstance.window!)
    //            })
    //
    //        }else{
    //            hideAllProgressOnView(appDelegateInstance.window!)
    //            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
    //        }
    //    }
    
    func getSchedulerDataApi(dateStr:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_SCHEDULER_DATA_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            //            let param:[String:Any] = ["company_id": companyId, "filter": "", "date_filter":"", "page": "0","limit": "100"]
            let param:[String:Any] = ["company_id": companyId, "date_filter":dateStr]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.openScheduleDataArr.removeAll()
                    for i in 0..<json["data"]["open_schedules"].count
                    {
                        let check_out =  json["data"]["open_schedules"][i]["check_out"].stringValue
                        let check_in =  json["data"]["open_schedules"][i]["check_in"].stringValue
                        let nubmer_of_opening =  json["data"]["open_schedules"][i]["nubmer_of_opening"].stringValue
                        let break_duration =  json["data"]["open_schedules"][i]["break_duration"].stringValue
                        let position =  json["data"]["open_schedules"][i]["position"].stringValue
                        let note =  json["data"]["open_schedules"][i]["note"].stringValue
                        let shift_name =  json["data"]["open_schedules"][i]["shift_name"].stringValue
                        let schedule_id =  json["data"]["open_schedules"][i]["schedule_id"].stringValue
                        let nubmer_of_assigned_opening =  json["data"]["open_schedules"][i]["nubmer_of_assigned_opening"].stringValue
                        let date =  json["data"]["open_schedules"][i]["date"].stringValue
                        
                        let rest_opening =  json["data"]["open_schedules"][i]["rest_opening"].stringValue
                        let color_code =  json["data"]["open_schedules"][i]["color_code"].stringValue
                        
                        //For change date gmt to local
                        let dateString = date + " " + check_in
                        let convertedLocalDateStr = gmtToLocalDate(dateStr: dateString)
                        
                        if dateStr == convertedLocalDateStr
                        {
                            self.openScheduleDataArr.append(OpenScheduleDataStruct.init(check_out: check_out, check_in: check_in, nubmer_of_opening: nubmer_of_opening, break_duration: break_duration, position: position, note: note, rest_opening: rest_opening, shift_name: shift_name, schedule_id: schedule_id, nubmer_of_assigned_opening: nubmer_of_assigned_opening, date: date, color_code: color_code, id: "",employee_id:"",status: "0"))
                        }
                    }
                    self.employeeScheduleDataArr.removeAll()
                    for i in 0..<json["data"]["employee_schedules"].count
                    {
                        let name =  json["data"]["employee_schedules"][i]["name"].stringValue
                        let email =  json["data"]["employee_schedules"][i]["email"].stringValue
                        let c_code =  json["data"]["employee_schedules"][i]["c_code"].stringValue
                        let mobile =  json["data"]["employee_schedules"][i]["mobile"].stringValue
                        let profile_pic =  json["data"]["employee_schedules"][i]["profile_pic"].stringValue
                        let employee_id =  json["data"]["employee_schedules"][i]["employee_id"].stringValue
                        
                        self.employeeScheduleShiftsArr.removeAll()
                        for j in 0..<json["data"]["employee_schedules"][i]["schedules"].count
                        {
                            let check_out =  json["data"]["employee_schedules"][i]["schedules"][j]["check_out"].stringValue
                            let check_in =  json["data"]["employee_schedules"][i]["schedules"][j]["check_in"].stringValue
                            let nubmer_of_opening =  json["data"]["employee_schedules"][i]["schedules"][j]["nubmer_of_opening"].stringValue
                            let break_duration =  json["data"]["employee_schedules"][i]["schedules"][j]["break_duration"].stringValue
                            let position =  json["data"]["employee_schedules"][i]["schedules"][j]["position"].stringValue
                            let note =  json["data"]["employee_schedules"][i]["schedules"][j]["note"].stringValue
                            let shift_name =  json["data"]["employee_schedules"][i]["schedules"][j]["shift_name"].stringValue
                            let schedule_id =  json["data"]["employee_schedules"][i]["schedules"][j]["schedule_id"].stringValue
                            let nubmer_of_assigned_opening =  json["data"]["employee_schedules"][i]["schedules"][j]["nubmer_of_assigned_opening"].stringValue
                            let date =  json["data"]["employee_schedules"][i]["schedules"][j]["date"].stringValue
                            
                            let rest_opening =  json["data"]["employee_schedules"][i]["schedules"][j]["rest_opening"].stringValue
                            let color_code =  json["data"]["employee_schedules"][i]["schedules"][j]["color_code"].stringValue
                            let id =  json["data"]["employee_schedules"][i]["schedules"][j]["id"].stringValue
                            let employee_id =  json["data"]["employee_schedules"][i]["schedules"][j]["employee_id"].stringValue
                            let status =  json["data"]["employee_schedules"][i]["schedules"][j]["status"].stringValue
                            
                            
                            //For change date gmt to local
                            let dateString = date + " " + check_in
                            let convertedLocalDateStr = gmtToLocalDate(dateStr: dateString)
                            let convertedLocalCheckInStr = gmtToLocal(dateStr: check_in)
                            //print(convertedLocalDateStr)
                            // print(convertedLocalCheckInStr)
                            if dateStr == convertedLocalDateStr
                            {
                                self.employeeScheduleShiftsArr.append(OpenScheduleDataStruct.init(check_out: check_out, check_in: check_in, nubmer_of_opening: nubmer_of_opening, break_duration: break_duration, position: position, note: note, rest_opening: rest_opening, shift_name: shift_name, schedule_id: schedule_id, nubmer_of_assigned_opening: nubmer_of_assigned_opening, date: date, color_code: color_code, id: id,employee_id:employee_id,status: status))
                            }
                        }
                        if self.employeeScheduleShiftsArr.count > 0
                        {
                            self.employeeScheduleDataArr.append(EmployeeScheduleDataStruct.init(name: name, email: email, c_code: c_code, mobile: mobile, employee_id: employee_id, profile_pic: profile_pic, employeeScheduleArr: self.employeeScheduleShiftsArr, expanded: false))
                        }
                    }
                    print(self.employeeScheduleDataArr.count)
                    print(self.employeeScheduleDataArr)
                }
                else {
                    
                    self.openScheduleDataArr.removeAll()
                    self.employeeScheduleDataArr.removeAll()
                    self.employeeScheduleShiftsArr.removeAll()
                    
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
                    //                    if self.employeeListArr.count == 0
                    //                    {
                    //                        self.tbleView.isHidden = true
                    //                        self.emptyView.isHidden = false
                    //                    }
                    //                    else
                    //                    {
                    //                        self.tbleView.isHidden = false
                    //                        self.emptyView.isHidden = true
                    //                    }
                    //                    // Dismiss the refresh control.
                    //                    self.tblView.refreshControl?.endRefreshing()  // PtR 4
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
    @objc func editBtnClicked(sender:UIButton)
    {
        let vc = AddEditSchedulerShiftViewController()
        if self.isSelected == 0
        {
            let row = sender.tag
            vc.isOpenFrom = "Update Open Shift"
            vc.isOpenFromShift = "Open Shift"
            vc.updateDetail   = self.openScheduleDataArr[row]
            vc.scheduleId = self.openScheduleDataArr[row].schedule_id
        }
        else
        {
            let row = sender.tag % 1000
            let section = sender.tag / 1000
            vc.isOpenFrom = "Update Employee Shift"
            vc.isOpenFromShift = "Employee Shift"
            vc.updateDetail   = self.employeeScheduleDataArr[section].employeeScheduleArr![row]
            vc.scheduleId = self.employeeScheduleDataArr[section].employeeScheduleArr![row].schedule_id
            //  vc.employeeName  = self.employeeScheduleDataArr[section].name
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func deleteBtnClicked(sender:UIButton)
    {
        if self.isSelected == 0
        {
            let row = sender.tag
            let scheduleId = self.openScheduleDataArr[row].schedule_id
            self.deleteApiCall(scheduleID: scheduleId, employeeID: "0")
        }
        else
        {
            let row = sender.tag % 1000
            let section = sender.tag / 1000
            let employeeId   = self.employeeScheduleDataArr[section].employeeScheduleArr![row].employee_id
            let scheduleId = self.employeeScheduleDataArr[section].employeeScheduleArr![row].schedule_id
            self.deleteApiCall(scheduleID: scheduleId, employeeID: employeeId)
        }
    }
    @objc func cellBtnClicked(sender:UIButton)
    {
        let tag = sender.tag
        let cell = (sender.superview?.superview?.superview as? SchedulerWeekCollectionCell) // track your cell here
        print(self.isSelectedDateArr)
        for i in 0..<self.isSelectedDateArr.count
        {
            if self.isSelectedDateArr[i] == true
            {
                self.isSelectedDateArr[i] = false
            }
        }
        print(self.isSelectedDateArr)
        self.isSelectedDate = self.isSelectedDateArr[tag]
        self.isSelectedDate = !self.isSelectedDate
        if self.isSelectedDateArr[tag] == true
        {
            cell?.cellView.backgroundColor = .white
        }
        else
        {
            cell?.cellView.backgroundColor = .systemGray6
        }
        self.isSelectedDateArr[tag] = self.isSelectedDate
        print(self.isSelectedDateArr)
        self.weekCollectionView.reloadData()
        
        let dateStr = "\(self.currentWeekArr[tag].year)-\(self.currentWeekArr[tag].month)-\(self.currentWeekArr[tag].date)"
        print(dateStr)
        self.currentDateLbl.text = selectedDateByCurrentWeek(dateStr: dateStr)
        self.calenderTxtField.text = currentDateShowInCalender(dateStr: dateStr)
        self.selectedDate = dateStr
        self.getSchedulerDataApi(dateStr: dateStr)
    }
    
    func deleteApiCall(scheduleID:String, employeeID:String)
    {
        let Alert = UIAlertController(title: "Alert", message: "Are you sure, You want to delete this Schedule!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteScheduleApi(scheduleId: scheduleID, employeeId: employeeID)
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
    
    func deleteScheduleApi(scheduleId:String, employeeId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_SCHEDULE_API
        
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String?] = [ "user_id": userId, "schedule_id":scheduleId,"employee_id":employeeId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getSchedulerDataApi(dateStr: self.selectedDate)
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
                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
                DispatchQueue.main.async {
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
}
extension SchedulerVC: UICollectionViewDelegateFlowLayout
{
    @objc(collectionView:layout:sizeForItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let screenSize              = collectionView.frame.size //UIScreen.main.bounds
        let screenWidth             = screenSize.width
        let cellSquareSize: CGFloat = (screenWidth / 7.0) - 5
        return CGSize.init(width: cellSquareSize, height: 85)
    }
    
    @objc(collectionView:layout:insetForSectionAtIndex:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(5), right: 0)
    }
    
    @objc(collectionView:layout:minimumLineSpacingForSectionAtIndex:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 5
    }
    
    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 5
    }
}
extension SchedulerVC:UICollectionViewDataSource,UICollectionViewDelegate
{
    //..........................Start collectionView code...............
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.currentWeekArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SchedulerWeekCollectionCell", for: indexPath) as! SchedulerWeekCollectionCell
        let info = self.currentWeekArr[indexPath.row]
        cell.dateLbl.text = info.date
        cell.dayLbl.text = info.day
        if self.isSelectedDateArr[indexPath.item] == true
        {
            cell.cellView.backgroundColor = .white
        }
        else
        {
            cell.cellView.backgroundColor = .systemGray6
        }
        cell.cellBtn.tag = indexPath.item
        cell.cellBtn.addTarget(self, action: #selector(cellBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //let cell = collectionView.cellForItem(at: indexPath) as! SchedulerWeekCollectionCell
        let dateStr = "\(self.currentWeekArr[indexPath.row].year)-\(self.currentWeekArr[indexPath.row].month)-\(self.currentWeekArr[indexPath.row].date)"
        print(dateStr)
        self.currentDateLbl.text = selectedDateByCurrentWeek(dateStr: dateStr)
        self.selectedDate = dateStr
        self.getSchedulerDataApi(dateStr: dateStr)
    }
}

extension SchedulerVC : UITableViewDataSource, UITableViewDelegate//,HeaderViewDelegate
{
    @objc func sectionBtnClicked(_ sender:UIButton)
    {
        let section = sender.tag
        self.employeeScheduleDataArr[section].expanded = !self.employeeScheduleDataArr[section].expanded
        
        tblView.beginUpdates()
        for i in 0..<(self.employeeScheduleDataArr[section].employeeScheduleArr?.count ?? 0)
        {
            tblView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tblView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        //view.backgroundColor = .init(red: 140.0/255.0, green: 224.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if self.isSelected == 1
        {
            let customView = HeaderView()
            let info = self.employeeScheduleDataArr[section]
            customView.titlelabel.text = "\(info.name)"
            let imageUrl = IMAGE_BASE_URL + info.profile_pic
            //            customView.employeeProfileImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "profilePlaceHolder"))
            customView.employeeProfileImgView.sd_setImage(with: URL(string:imageUrl))
            customView.rightBtn.tag = section
            customView.rightBtn.setImage(UIImage.init(named: "checklist"), for: .normal)
            //            customView.rightBtn.addTarget(self, action: #selector(addEmployeeBtnClicked), for: .touchUpInside)
            customView.rightBtn.addTarget(self, action: #selector(sectionBtnClicked), for: .touchUpInside)
            customView.titlelabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            return customView
        }
        else
        {
            let view = UIView()
            view.frame = CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 0)
            return view
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (self.isSelected == 1)
        {
            return 50
        }
        else
        {
            return .leastNonzeroMagnitude
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (self.isSelected == 0)
        {
            return 1
        }
        else
        {
            return self.employeeScheduleDataArr.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.isSelected == 0)
        {
            return self.openScheduleDataArr.count
        }
        else
        {
            return self.employeeScheduleDataArr[section].employeeScheduleArr?.count ?? 0
            //            // 1
            //            if self.hiddenSections.contains(section) {
            //                return 0
            //            }
            //
            //            // 2
            //            return self.employeeScheduleDataArr[section].employeeScheduleArr?.count ?? 0 //selectedEmplyeeSchedulelistCount//
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchedulerShiftTableCell") as! SchedulerShiftTableCell
        cell.selectionStyle = .none
        cell.deleteBtn.isHidden = false
        if (self.isSelected == 0)
        {
            let info = self.openScheduleDataArr[indexPath.row]
            let checkInTimeStr = gmtToLocal(dateStr: info.check_in)
            let checkOutTimeStr = gmtToLocal(dateStr: info.check_out)
            cell.scheduleTimeLbl.text = "\(checkInTimeStr ?? "")-\(checkOutTimeStr ?? "")"
            cell.positionNameLbl.text = info.position
            cell.editBtn.tag = indexPath.row
            cell.deleteBtn.tag = indexPath.row
            let colorCode = info.color_code
            let colorCodeStr = colorCode.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            let colorCodeArr = colorCodeStr.components(separatedBy: ",")
            let r = Double(colorCodeArr[0]) ?? 0.0
            let g = Double(colorCodeArr[1]) ?? 0.0
            let b = Double(colorCodeArr[2]) ?? 0.0
            let backColor = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            cell.cellBackView.backgroundColor = backColor
            cell.assignImgView.isHidden = true
            //cell.countLbl.isHidden = false
            
            if info.rest_opening != "0"
            {
                cell.countLbl.isHidden = false
                cell.countLbl.text = info.rest_opening
            }
            else
            {
                cell.countLbl.isHidden = true
            }
        }
        else
        {
            let info =  self.employeeScheduleDataArr[indexPath.section].employeeScheduleArr?[indexPath.row]
            
            let checkInTimeStr = gmtToLocal(dateStr: info?.check_in  ?? "")
            let checkOutTimeStr = gmtToLocal(dateStr: info?.check_out  ?? "")
            if checkInTimeStr != nil && checkOutTimeStr != nil{
                cell.scheduleTimeLbl.text = "\(checkInTimeStr!)-\(checkOutTimeStr!)"
            }
            cell.positionNameLbl.text = info?.position
            let colorCode = info?.color_code
            if colorCode != nil
            {
                let colorCodeStr = colorCode!.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                let colorCodeArr = colorCodeStr.components(separatedBy: ",")
                let r = Double(colorCodeArr[0]) ?? 0.0
                let g = Double(colorCodeArr[1]) ?? 0.0
                let b = Double(colorCodeArr[2]) ?? 0.0
                let backColor = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
                cell.cellBackView.backgroundColor = backColor
            }
            cell.editBtn.tag = (indexPath.section * 1000) + indexPath.row
            cell.deleteBtn.tag = (indexPath.section * 1000) + indexPath.row
            
            
            if info?.status == "0"
            {
                cell.assignImgView.isHidden = true
            }
            else
            {
                cell.assignImgView.isHidden = false
            }
            cell.countLbl.isHidden = true
            
            print(info?.status)
            
        }
        cell.editBtn.addTarget(self, action: #selector(editBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = SchedulerDetailVC()
        if self.isSelected == 0
        {
            let row = indexPath.row
            vc.isCommingFrom = "Open Shift"
            vc.openShiftDetail   = self.openScheduleDataArr[row]
            vc.scheduleId = self.openScheduleDataArr[row].schedule_id
        }
        else
        {
            let row = indexPath.row//sender.tag % 1000
            let section             = indexPath.section//sender.tag / 1000
            //            let row = sender.tag % 1000
            //            let section = sender.tag / 1000
            vc.isCommingFrom        = "Employee Shift"
            //            vc.openShiftDetail      = self.openScheduleDataArr[row]
            vc.employeeDetail       = self.employeeScheduleDataArr[section]
            vc.scheduleId = self.employeeScheduleDataArr[section].employeeScheduleArr![row].schedule_id
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //return UITableView.automaticDimension
        if self.isSelected == 1
        {
            
            if self.employeeScheduleDataArr[indexPath.section].expanded
            {
                return UITableView.automaticDimension
            }
            else
            {
                return 0
            }
        }
        else
        {
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
