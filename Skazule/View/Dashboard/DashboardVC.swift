//
//  DashboardVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit

class DashboardVC: UIViewController {
    
    @IBOutlet weak var todayScheduleViewAllBtn: UIButton!
    @IBOutlet weak var todayOpenShiftViewAll: UIButton!
    @IBOutlet weak var todayScheduleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var todayOpenShiftHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var todayScheduledBackView: CardView!
    
    @IBOutlet weak var openShiftViewAllWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customNavigationBarForDrawer: CustomNavigationBarForDrawer!
    @IBOutlet weak var customNavHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dashboardCollectionView: UICollectionView!
    @IBOutlet weak var dashboardScheduledCollectionView: UICollectionView!
    @IBOutlet weak var todayScheduleDateLbl: UILabel!
    @IBOutlet weak var dashboardOpenShiftCollectionView: UICollectionView!
    @IBOutlet weak var todayOpenShiftTitleLbl: UILabel!
    @IBOutlet weak var todayOpenShiftDateLbl: UILabel!
    
    let dashboardTopCellBackgroundColorsArr = [#colorLiteral(red: 0.8039215686, green: 0.8156862745, blue: 0.9647058824, alpha: 1), #colorLiteral(red: 0.862745098, green: 0.9333333333, blue: 0.937254902, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.8509803922, blue: 0.8352941176, alpha: 1), #colorLiteral(red: 0.8823529412, green: 0.968627451, blue: 0.862745098, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.9215686275, blue: 0.8509803922, alpha: 1), #colorLiteral(red: 0.9803921569, green: 0.9254901961, blue: 0.5607843137, alpha: 1)]
    let dashboardTopCellIconsArr = [#imageLiteral(resourceName: "scheduled"), #imageLiteral(resourceName: "currently_clocked_in"), #imageLiteral(resourceName: "currently_on_break"), #imageLiteral(resourceName: "unfilled_open_shifts"), #imageLiteral(resourceName: "employees_with_timeoff"), #imageLiteral(resourceName: "pending_shifts_request")]
    let dashboardTopCellTitleArr = ["Scheduled :", "Currently Clocked In :", "Currently On Break :", "Unfilled Open Shift :", "Employees With Time Off :", "Pending Shift Requests :"]
    var dashboardTopCellTitleValueArr = [String]()
    
    let dashboardTopCellTitleColorArr = [#colorLiteral(red: 0.3725490196, green: 0.3882352941, blue: 0.6196078431, alpha: 1), #colorLiteral(red: 0.3529411765, green: 0.5529411765, blue: 0.5607843137, alpha: 1), #colorLiteral(red: 0.5137254902, green: 0.231372549, blue: 0.2, alpha: 1), #colorLiteral(red: 0.5254901961, green: 0.7215686275, blue: 0.4823529412, alpha: 1), #colorLiteral(red: 0.7843137255, green: 0.5764705882, blue: 0.3568627451, alpha: 1), #colorLiteral(red: 0.4666666667, green: 0.4274509804, blue: 0.1568627451, alpha: 1)]
    let dashboardTopCelldetailArr = ["Today's Scheduled", "Time Tracker", "Time Tracker", "Details", "Time Off Request", "Pending Shift Requests"]
    
    var dashBoardDataArr        = [DashBoardDataStruct]()
    var todayOpenShiftDataArr   = [TodayOpenShiftDataStruct]()
    var todayOpenShiftDetailArr = [OpenScheduleDataStruct]()
    
    let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    
    // For Notification
    var notificationDetailArr = [NotificationDetailStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.main.bounds.height <= 667 { // iPhone SE screen height is 667 points.
            self.openShiftViewAllWidthConstraint.constant = 100
        } else {
        }
        
        self.customNavigationBarForDrawer.titleLabel.text = "Dashboard"
        //self.setDrowerHeight()
        customNavigationBarForDrawer.rightBtn.isHidden = true
        customNavigationBarForDrawer.rightBtn.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
        
        dashboardCollectionView.register(UINib(nibName: "DashboardTopCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "DashboardTopCollectionCell")
        
        dashboardScheduledCollectionView.register(UINib(nibName: "DashboardTodayScheduledCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "DashboardTodayScheduledCollectionCell")
        
        dashboardOpenShiftCollectionView.register(UINib(nibName: "DashboardTodayScheduledCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "DashboardTodayScheduledCollectionCell")
        
        //        self.getDashboardDetailApi()
        self.todayOpenShiftDateLbl.text = self.currentDate()
        //self.getNotificationDetailApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getProfileDetailApi()
        //self.getNotificationDetailApi()
        self.getDashboardDetailApi()
    }
    func currentDate() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        //        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let currentDate = formatter.string(from: date)
        return currentDate
    }
    /*
     func underlineLabel(text: String, label: UILabel) {
     let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
     let attributedText = NSAttributedString(string: text, attributes: underlineAttribute)
     label.attributedText = attributedText
     }
     */
    /*
     func createUnderlinedText(text: String) -> NSAttributedString {
     let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
     let underlinedText = NSAttributedString(string: text, attributes: underlineAttribute)
     return underlinedText
     }
     */
    @objc func didTapNotificationButton (_ sender:UIButton) {
        print("Notification Button is selected")
        let vc = NotificationVC ()
        vc.notificationDetail = self.notificationDetailArr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getDashboardDetailApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_DASHBOARD_DATA_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "company_id": companyId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { [self] (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let scheduled_hour      =  json["data"]["scheduled_hour"].stringValue
                    let unfilled_opening    =  json["data"]["unfilled_opening"].stringValue
                    let totalOnBreak        =  json["data"]["totalOnBreak"].stringValue
                    let totalCheckedIn      =  json["data"]["totalCheckedIn"].stringValue
                    let unfilled_shift      =  json["data"]["unfilled_shift"].stringValue
                    let pendingShiftRequest =  json["data"]["pendingShiftRequest"].stringValue
                    let employeeOnLeave     =  json["data"]["employeeOnLeave"].stringValue
                    
                    //        "scheduled_hour" : 12614, //1
                    //        "totalCheckedIn" : 3, //2
                    //        "totalOnBreak" : 3, //3
                    //        "unfilled_opening" : 17, //4
                    //        "employeeOnLeave" : 0 //5
                    //        "pendingShiftRequest" : 8, //6
                    var scheduledHour = ""
                    if let result = self.formatter.string(from: TimeInterval((Float(scheduled_hour) ?? 0) * 60)) {
                        print(result)
                        let stringWithSpace = result.replacingOccurrences(of: "min", with: " min")
                        scheduledHour = stringWithSpace
                    }
                    
                    self.dashboardTopCellTitleValueArr.removeAll()
                    self.dashboardTopCellTitleValueArr.append(scheduledHour)
                    self.dashboardTopCellTitleValueArr.append(totalCheckedIn)
                    self.dashboardTopCellTitleValueArr.append(totalOnBreak)
                    self.dashboardTopCellTitleValueArr.append(unfilled_shift)
                    self.dashboardTopCellTitleValueArr.append(employeeOnLeave)
                    self.dashboardTopCellTitleValueArr.append(pendingShiftRequest)
                    
                    self.todayOpenShiftDataArr.removeAll()
                    self.todayOpenShiftDetailArr.removeAll()
                    
                    for i in 0..<json["data"]["todaysOpenShift"].count
                    {
                        let schedule_id         = json["data"]["todaysOpenShift"][i]["schedule_id"].stringValue
                        let check_out           = json["data"]["todaysOpenShift"][i]["check_out"].stringValue
                        let position            = json["data"]["todaysOpenShift"][i]["position"].stringValue
                        let date                = json["data"]["todaysOpenShift"][i]["date"].stringValue
                        let note                = json["data"]["todaysOpenShift"][i]["note"].stringValue
                        let break_duration      = json["data"]["todaysOpenShift"][i]["break_duration"].stringValue
                        let nubmer_of_assigned_opening = json["data"]["todaysOpenShift"][i]["nubmer_of_assigned_opening"].stringValue
                        let nubmer_of_opening   = json["data"]["todaysOpenShift"][i]["nubmer_of_opening"].stringValue
                        let color_code          = json["data"]["todaysOpenShift"][i]["color_code"].stringValue
                        let shift_name          = json["data"]["todaysOpenShift"][i]["shift_name"].stringValue
                        let rest_opening        = json["data"]["todaysOpenShift"][i]["rest_opening"].stringValue
                        let check_in            = json["data"]["todaysOpenShift"][i]["check_in"].stringValue
                        
                        
                        self.todayOpenShiftDetailArr.append(OpenScheduleDataStruct.init(check_out: check_out, check_in: check_in, nubmer_of_opening: nubmer_of_opening, break_duration: break_duration, position: position, note: note, rest_opening: rest_opening, shift_name: shift_name, schedule_id: schedule_id, nubmer_of_assigned_opening: nubmer_of_assigned_opening, date: date, color_code: color_code, id: "", employee_id: "", status: ""))
                        
                        self.todayOpenShiftDataArr.append(TodayOpenShiftDataStruct .init(schedule_id: schedule_id, check_out: check_out, position: position, date: date, note: note, break_duration: break_duration, nubmer_of_assigned_opening: nubmer_of_assigned_opening, nubmer_of_opening: nubmer_of_opening, color_code: color_code, shift_name: shift_name, rest_opening: rest_opening, check_in: check_in))
                    }
                    // Set Today open shift Title Detail
                    self.todayOpenShiftTitleLbl.text = "Today's Open Shift (\(self.todayOpenShiftDataArr.count))"
                    if self.todayOpenShiftDataArr.count < 7
                    {
                        self.todayOpenShiftViewAll.isHidden = true
                    }
                    else
                    {
                        self.todayOpenShiftViewAll.isHidden = false
                    }
                    if self.todayOpenShiftDataArr.count == 0
                    {
                        self.todayOpenShiftHeightConstraint.constant = 111
                    }
                    else if self.todayOpenShiftDataArr.count <= 3
                    {
                        self.todayOpenShiftHeightConstraint.constant = 231
                    }
                    else
                    {
                        self.todayOpenShiftHeightConstraint.constant = 350
                    }
                    
                    // Set Today Scheduled Detail
                    self.todayScheduledBackView.isHidden = true
                    
                    self.dashBoardDataArr.append(DashBoardDataStruct.init(scheduled_hour: scheduled_hour, unfilled_opening: unfilled_opening, totalOnBreak: totalOnBreak, totalCheckedIn: totalCheckedIn, unfilled_shift: unfilled_shift, pendingShiftRequest: pendingShiftRequest, employeeOnLeave: employeeOnLeave, todaysOpenShift: todayOpenShiftDataArr))
                    
                }
                else {
                    //self.employeeBenefitsArr.removeAll()
                    //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    
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
                    self.dashboardCollectionView.reloadData()
                    self.dashboardOpenShiftCollectionView.reloadData()
                    
                    //                    if self.employeeBenefitsArr.count == 0
                    //                    {
                    //                        self.benefitsCardBackView.isHidden = true
                    //                    }
                    //                    else
                    //                    {
                    //                        self.benefitsCardBackView.isHidden = false
                    //                    }
                    //                    self.tblView.reloadData()
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
                    //                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    //                    }
                    //                    else
                    //                    {
                    //                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    //                    }
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
    
    func setDashboardDetail()
    {
        //        "scheduled_hour" : 12614, //1
        //        "totalCheckedIn" : 3, //2
        //        "totalOnBreak" : 3, //3
        //        "unfilled_opening" : 17, //4
        //        "employeeOnLeave" : 0 //5
        //        "pendingShiftRequest" : 8, //6
        
    }
    // MARK: - Today Scheduled ViweAll button tapped
    @IBAction func onTapTodayScheduledViweAllButton(_ sender: Any) {
    }
    
    // MARK: - Today Open Shift button tapped
    @IBAction func onTapTodayOpenShiftViweAllButton(_ sender: Any) {
        let vc = TodayScheduledOpenShiftListVC()
        vc.todayOpenShiftDetailArr = self.todayOpenShiftDetailArr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- set navigationDrower Height
    func setDrowerHeight() {
        if UIDevice.current.hasNotch {
            self.customNavHeightConstraint.constant = DroverHeight.haveNotch
        } else {
            self.customNavHeightConstraint.constant = DroverHeight.dontHaveNotch
        }
    }
    
    
    func getProfileDetailApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_PROFILE_DATA_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId]
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let profile_pic =  json["data"]["profile_pic"].stringValue
                    UserDefaults.standard.setValue(profile_pic, forKey: USER_DEFAULTS_KEYS.EMPLOYER_PROFILE_PIC)
                    let employerPhotoDataDict:[String: String] = ["employerPhoto": profile_pic]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYER_PROFILE_PIC), object: nil, userInfo: employerPhotoDataDict)
                    
                    let company_name = json["data"]["company_name"].stringValue
                    UserDefaults.standard.setValue(company_name, forKey: USER_DEFAULTS_KEYS.COMPANY_NAME)
                    let companyNameDataDict:[String: String] = ["companyName": company_name]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.COMPANY_NAME), object: nil, userInfo: companyNameDataDict)
                    
                    let employer_name = json["data"]["name"].stringValue
                    UserDefaults.standard.setValue(employer_name, forKey: USER_DEFAULTS_KEYS.EMPLOYER_NAME)
                    let employerNameDataDict:[String: String] = ["employerName": employer_name]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYER_NAME), object: nil, userInfo: employerNameDataDict)
                    
                    //                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
                }
                else {
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
    
    func downloadPdf()
    {
        //        let urlString = "http://swift-lang.org/guides/tutorial.pdf"
        //        let url = URL(string: urlString)
        //        let fileName = String((url!.lastPathComponent)) as NSString
        //        // Create destination URL
        //        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        //        let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
        //        //Create URL to the source file you want to download
        //        let fileURL = URL(string: urlString)
        //        let sessionConfig = URLSessionConfiguration.default
        //        let session = URLSession(configuration: sessionConfig)
        //        let request = URLRequest(url:fileURL!)
        //        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
        //            if let tempLocalUrl = tempLocalUrl, error == nil {
        //                // Success
        //                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
        //                    print("Successfully downloaded. Status code: \(statusCode)")
        //                }
        //                do {
        //                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
        //                    do {
        //                        //Show UIActivityViewController to save the downloaded file
        //                        let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        //                        for indexx in 0..<contents.count {
        //                            if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
        //                                let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
        //                                self.present(activityViewController, animated: true, completion: nil)
        //                            }
        //                        }
        //                    }
        //                    catch (let err) {
        //                        print("error: \(err)")
        //                    }
        //                } catch (let writeError) {
        //                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
        //                }
        //            } else {
        //                print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
        //            }
        //        }
        //        task.resume()
    }
    
    @objc func onClickViewBtn(_ sender:UIButton)
    {
        let info = self.todayOpenShiftDetailArr[sender.tag]
        let vc = SchedulerDetailVC()
        vc.isCommingFrom   = "Open Shift"
        vc.openShiftDetail = info
        vc.scheduleId      = info.schedule_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension DashboardVC
{
    @objc(collectionView:layout:sizeForItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let screenSize              = collectionView.frame.size //UIScreen.main.bounds
        let screenWidth             = screenSize.width
        let cellSquareSize: CGFloat = (screenWidth / 2.0) - 3
        
        if collectionView.tag == 101
        {
            return CGSize.init(width: cellSquareSize, height: 175)
        }
        else
        {
            //            let cellSquareSize: CGFloat = (screenWidth / 3.0) - 5
            let cellSquareSize: CGFloat = (UIScreen.main.bounds.width / 3.0) - 10
            return CGSize.init(width: cellSquareSize, height: 115)
        }
    }
    @objc(collectionView:layout:insetForSectionAtIndex:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 10, left: 0, bottom: CGFloat(0), right: 0)
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
extension DashboardVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    //..........................Start collectionView code...............
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView.tag == 101
        {
            return  6
        }
        else if collectionView.tag == 102
        {
            return  6
        }
        else if collectionView.tag == 103
        {
            return  self.todayOpenShiftDataArr.count
        }
        else
        {
            return  0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        //let cell = UICollectionViewCell()
        if collectionView.tag == 101
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardTopCollectionCell", for: indexPath) as! DashboardTopCollectionCell
            
            let colorInfo = dashboardTopCellBackgroundColorsArr[indexPath.item]
            let colorTitleInfo = dashboardTopCellTitleColorArr[indexPath.item]
            let  iconInfo = dashboardTopCellIconsArr[indexPath.item]
            if self.dashboardTopCellTitleValueArr.count > 0
            {
                /*
                 let  titleInfo = "\(dashboardTopCellTitleArr[indexPath.row])\n\(self.dashboardTopCellTitleValueArr[indexPath.row])"
                 if self.dashboardTopCellTitleValueArr[indexPath.row] == "0 min"
                 {
                 cell.cellTitleLbl.text = "\(dashboardTopCellTitleArr[indexPath.row])\n0 hour"
                 }
                 else
                 {
                 cell.cellTitleLbl.text = titleInfo
                 }
                 */
                if indexPath.row == 0
                {
                    let  titleInfo = "\(dashboardTopCellTitleArr[indexPath.row])\n\(self.dashboardTopCellTitleValueArr[indexPath.row]) Hrs"
                    cell.cellTitleLbl.text = titleInfo
                }
                else
                {
                    let  titleInfo = "\(dashboardTopCellTitleArr[indexPath.row])\n\(self.dashboardTopCellTitleValueArr[indexPath.row])"
                    cell.cellTitleLbl.text = titleInfo
                }
            }
            let  detailInfo = dashboardTopCelldetailArr[indexPath.item]
            cell.cellBackgroundView.backgroundColor   = colorInfo
            cell.cellImg.image                        = iconInfo
            cell.cellTitleLbl.textColor               = colorTitleInfo
            cell.cellDesLbl.text                      = detailInfo
            
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardTodayScheduledCollectionCell", for: indexPath) as! DashboardTodayScheduledCollectionCell
            if collectionView.tag == 103
            {
                let info = self.todayOpenShiftDataArr[indexPath.item]
                let checkInTimeStr  = gmtToLocal(dateStr: info.check_in)
                let checkOutTimeStr = gmtToLocal(dateStr: info.check_out)
                if (checkInTimeStr != nil) && (checkOutTimeStr != nil){
                    cell.scheduleTimeLbl.text = "\(checkInTimeStr!)-\(checkOutTimeStr!)"
                }
                cell.titleLbl.text  = info.position
                cell.viewBtn.tag = indexPath.item
                cell.viewBtn.addTarget(self, action: #selector(onClickViewBtn), for: .touchUpInside)
            }
            else
            {
                cell.scheduleTimeLbl.text = "STime - ETime"
                cell.titleLbl.text        = "Meeting with..."
            }
            return cell
        }
        
        
        //        {
        //            let info = moodDictArr[indexPath.item]
        //            cell.optionTitleLbl.text = info["opt"] as? String
        //            cell.optionButton.tag = indexPath.row
        //
        //            if info["radioBtnStatus"] as? Bool == true
        //            {
        //                //                let image = UIImage(named: "tick-1") as UIImage?
        //                //                cell.optionButton.setImage(image, for: .normal)
        //
        //                let isDeviceType = getDeviceType()
        //                if isDeviceType == "iPad"
        //                {
        //                    cell.optionButton.setBackgroundImage(UIImage(named: "tick-1"), for: .normal)
        //                    cell.optionButton.setImage(nil, for: .normal)
        //                }
        //                else
        //                {
        //                    cell.optionButton.setImage(UIImage(named: "tick-1"), for: .normal)
        //                }
        //
        //            }
        //            else
        //            {
        //                //                let image = UIImage(named: "tick_blank") as UIImage?
        //                //                cell.optionButton.setImage(image, for: .normal)
        //
        //                let isDeviceType = getDeviceType()
        //                if isDeviceType == "iPad"
        //                {
        //                    cell.optionButton.setBackgroundImage(UIImage(named: "tick_blank"), for: .normal)
        //                    cell.optionButton.setImage(nil, for: .normal)
        //                }
        //                else
        //                {
        //                    cell.optionButton.setImage(UIImage(named: "tick_blank"), for: .normal)
        //                }
        //
        //            }
        //            cell.optionButton.addTarget(self, action: #selector(self.optionButtonClickedMoods(sender:)), for: UIControl.Event.touchUpInside)
        //        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let rootController = (sideMenuViewController.rootViewController as! UINavigationController)
        var tabbarController = UITabBarController()
        tabbarController = rootController.viewControllers.last as! UITabBarController
        removeController(rootController: rootController)
        
        switch collectionView.tag
        {
        case 101:
            switch indexPath.row
            {
            case 0:
                tabbarController.selectedIndex = 1
                NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
                break
            case 1:
                //                let vc = TimeTrackingVC()
                //                self.navigationController?.pushViewController(vc, animated: true)
                tabbarController.selectedIndex = 3
                NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
                break
            case 2:
                //                let vc = TimeTrackingVC()
                //                self.navigationController?.pushViewController(vc, animated: true)
                tabbarController.selectedIndex = 3
                NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
                break
            case 3:
                tabbarController.selectedIndex = 1
                NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
                break
            case 4:
                let vc = TimeOffRequestVC()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case 5:
                tabbarController.selectedIndex = 1
                NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
                break
            default: break
            }
            break
        case 102:
            break
        case 103:
            let info = self.todayOpenShiftDetailArr[indexPath.item]
            let vc = SchedulerDetailVC()
            vc.isCommingFrom   = "Open Shift"
            vc.openShiftDetail = info
            vc.scheduleId      = info.schedule_id
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default: break
        }
    }
}

extension DashboardVC
{
    //    func multipartRequest<T:Decodable>(requestUrl: URL, imageData: Data, request: EditProfileRequest, resultType: T.Type, completionHandler:@escaping(_ result: T)-> Void){
    //
    //        var urlRequest = URLRequest(url: requestUrl)
    //        let lineBreak = "\r\n"
    //
    //        urlRequest.httpMethod = "post"
    //        let boundary = "---------------------------------\(UUID().uuidString)"
    //        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
    //
    //        let fname = "test.png"
    //        let mimetype = "image/png"
    //
    //        var requestData = Data()
    //
    //        requestData.append("--\(boundary)\r\n" .data(using: .utf8)!)
    //        requestData.append("content-disposition: form-data; name=\"user_id\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
    //        requestData.append(request.userID! .data(using: .utf8)!)
    //
    //        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
    //        requestData.append("content-disposition: form-data; name=\"name\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
    //        requestData.append("\(request.name! + lineBreak)" .data(using: .utf8)!)
    //
    //        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
    //        requestData.append("content-disposition: form-data; name=\"email\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
    //        requestData.append("\(request.email! + lineBreak)" .data(using: .utf8)!)
    //
    //        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
    //        requestData.append("content-disposition: form-data; name=\"phone\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
    //        requestData.append("\(request.phone! + lineBreak)" .data(using: .utf8)!)
    //
    //        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
    //        requestData.append("content-disposition: form-data; name=\"location\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
    //        requestData.append("\(request.location! + lineBreak)" .data(using: .utf8)!)
    //
    //        //        requestData.append("\(lineBreak)--\(boundary)\r\n" .data(using: .utf8)!)
    //        //        requestData.append("content-disposition: form-data; name=\"user_id\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
    //        //        requestData.append("\(request.userID! + lineBreak)" .data(using: .utf8)!)
    //
    //        requestData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    //        requestData.append("Content-Disposition:form-data; name=\"image\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
    //        requestData.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
    //        requestData.append(imageData)
    //        requestData.append("\r\n".data(using: String.Encoding.utf8)!)
    //
    //        requestData.append("--\(boundary)--\(lineBreak)" .data(using: .utf8)!)
    //
    //        urlRequest.addValue("\(requestData.count)", forHTTPHeaderField: "content-length")
    //        urlRequest.httpBody = requestData
    //
    //        URLSession.shared.dataTask(with: urlRequest) { (data, httpUrlResponse, error) in
    //            if(error == nil && data != nil && data?.count != 0)
    //            {
    //                let dataStr = String(decoding: requestData, as: UTF8.self) //to view the data you receive from the API
    //                print(dataStr)
    //                do {
    //                    let response = try JSONDecoder().decode(T.self, from: data!)
    //                    _=completionHandler(response)
    //                }
    //                catch let decodingError {
    //                    debugPrint(decodingError)
    //                }
    //            }
    //
    //        }.resume()
    //
    //    }
    
}
