//
//  CreateCompanyScedulerSetupVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit
import DropDown

struct SchedulerSetUpStruct
{
    var shift_name: String   = ""
    var check_in: String  = ""
    var check_out: String = ""
    var break_duration: String = ""
    var cellNumber: String = "0"
}

class CreateCompanyScedulerSetupVC: UIViewController {
    
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var dayDropDownTxtField: UITextField!
    @IBOutlet weak var tbleViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addMoreBtnBackView: UIView!
    
    
    var schedulerSetUpArr = [SchedulerSetUpStruct]()
    var schedulerSetUpRequestArr = [SchedulerSetUpStruct]()
    
    let datePicker = UIDatePicker()
    let singleSelectionDropDown = DropDown()
    var dayItemsArr = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var selectDayItemId = "0"
    
    func setupDropDown(arr:[String],showOn:UITextField)
    {
        singleSelectionDropDown.anchorView = showOn
        singleSelectionDropDown.bottomOffset = CGPoint(x: 0, y: showOn.bounds.height+10)
        singleSelectionDropDown.dataSource = arr
        singleSelectionDropDown.show()
        singleSelectionDropDown.selectionAction = { [unowned self] (index, item) in
            print(self)
            let selectedIndex : Int? = index
            if (showOn == self.dayDropDownTxtField)
            {
                //                let info = self.employeeRangeArr[selectedIndex!]
                //                self.selectEmplyeeRangeId = info.id
                self.selectDayItemId = String((selectedIndex ?? 0))
                self.dayDropDownTxtField.text = item
            }
        }
        singleSelectionDropDown.reloadAllComponents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tbleView.register(UINib(nibName: "CreateCompanySchedulerSetupCell", bundle: Bundle.main), forCellReuseIdentifier: "CreateCompanySchedulerSetupCell")
        
        //1
        for i in 0..<3
        {
            self.schedulerSetUpArr.append(SchedulerSetUpStruct.init(shift_name: "", check_in: "", check_out: "", break_duration: "", cellNumber: "\(i)"))
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
    func createDateTimePicker(showOn:UITextField){
        datePicker.datePickerMode = .time
        //ToolBar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDateTimePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDateTimePicker));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        showOn.inputAccessoryView = toolbar
        showOn.inputView = datePicker
    }
    @objc func doneDateTimePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        //        selectedTime = formatter.string(from: datePicker.timeZone)
        //        self.selectDateTxtField.text = formatter.string(from: datePicker.date) //selectedDate
        self.view.endEditing(true)
    }
    @objc func cancelDateTimePicker(){
        self.view.endEditing(true)
    }
    
    // MARK: - Day Drop Down button tapped
    @IBAction func onTapDayDropDownButton(_ sender: Any) {
        self.setupDropDown(arr: self.dayItemsArr, showOn: self.dayDropDownTxtField)
    }
    // MARK: - Add More Templates button tapped
    @IBAction func onTapAddMoreTemplatesButton(_ sender: Any) {
        if self.schedulerSetUpArr.count < 5
        {
            self.schedulerSetUpArr.append(SchedulerSetUpStruct.init(shift_name: "", check_in: "", check_out: "", break_duration: "", cellNumber: "\(self.schedulerSetUpArr.count)"))
            
            self.tbleView.reloadData()
        }
        
        if self.schedulerSetUpArr.count == 5
        {
            self.addMoreBtnBackView.isHidden = true
        }
        else
        {
            self.addMoreBtnBackView.isHidden = false
        }
    }
    // MARK: - Skip button tapped
    @IBAction func onTapSkipButton(_ sender: Any) {
        // goToDashBoardScreen()
        let vc = CompanyRegistrationCompleteVc()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Next button tapped
    @IBAction func onTapNextButton(_ sender: Any) {
        //goToDashBoardScreen()
        self.importSchedulerTemplateApi()
        
    }
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func goToDashBoardScreen()
    {
        (sideMenuViewController.rootViewController as! UINavigationController).pushViewController(loadTabBar(), animated: false)
    }
    
    
    
    func importSchedulerTemplateApi()
    {
        
        let fullUrl = BASE_URL + PROJECT_URL.SCHEDULER_SETUP_API
        if Reachability.isConnectedToNetwork() {
            guard let employerId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            // showProgressOnView(appDelegateInstance.window!)
            var subParam = [String:Any]()
            var schedulerArray = [Any]()
            for item in schedulerSetUpRequestArr {
                if ((item.shift_name == "") || (item.check_in == "") || (item.check_out == "") || (item.break_duration == ""))
                {
                    
                }
                else
                {
                    let shiftName = item.shift_name
                    let checkIn = item.check_in
                    let checkOut = item.check_out
                    let breakDuration = item.break_duration
                    subParam["shift_name"] = shiftName
                    //                    subParam["check_in"] = getFormattedTimeStr(timeStr: checkIn)
                    //                    subParam["check_out"] = getFormattedTimeStr(timeStr: checkOut)
                    let checkInStr  = getFormattedTimeStrSendInAPI(timeStr: checkIn)
                    let checkOutStr = getFormattedTimeStrSendInAPI(timeStr: checkOut)
                    subParam["check_in"] = localToGMT(dateStr: checkInStr)
                    subParam["check_out"] = localToGMT(dateStr: checkOutStr)
                    subParam["break_duration"] = breakDuration
                    schedulerArray.append(subParam)
                }
            }
            print(schedulerArray)
            
            
            
            //            let param:[String:Any] = ["user_id": "213", "company_id":"111", "employee":[["shift_name": "Morning","check_in": "11:00:00","check_out": "8:30:00","break_duration": "60"]]]
            
            //        var detail =  cell.schedulerSetUpDetail
            //        detail?.shift_name = shiftName
            //        detail?.check_in = getFormattedTimeStr(timeStr: checkIn)
            //        detail?.check_out = getFormattedTimeStr(timeStr: checkOut)
            //        let cellIndexNumber = Int(detail?.cellNumber ?? "0")
            
            
            
            var shiftStr = ""
            
            do
            {
                //Convert to Data
                let jsonData = try JSONSerialization.data(withJSONObject: schedulerArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                //Convert back to string. Usually only do this for debugging
                if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    print(JSONString)
                    shiftStr = JSONString
                }
                
            } catch {
                print("error.description")
            }
            
            
            let param:[String:Any] = ["user_id": employerId, "company_id":companyId,"week_start_day": self.selectDayItemId, "shift":shiftStr]
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
                        let vc = CompanyRegistrationCompleteVc()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    if let presenter = Alert.popoverPresentationController {
                        presenter.sourceView = self.view
                        presenter.sourceRect = self.view.bounds
                    }
                    DispatchQueue.main.async {
                        self.present(Alert, animated: true, completion: nil)
                    }
                    //self.goToDashBoardScreen()
                }
                else {
                    // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
                    //                    if (json["error"]["shift"].count != 0)
                    //                    {
                    //                        let errorMsg = json["error"]["shift"][0].stringValue
                    //                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
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
    
    
    
    
    
}
extension CreateCompanyScedulerSetupVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.schedulerSetUpArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCompanySchedulerSetupCell") as! CreateCompanySchedulerSetupCell
        cell.selectionStyle = .none
        cell.delegate = self
        
        if self.schedulerSetUpArr.count > 0
        {
            cell.schedulerSetUpDetail = self.schedulerSetUpArr[indexPath.row]
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


extension CreateCompanyScedulerSetupVC: CreateCompanySchedulerSetupCellDelegate{
    
    func onChangeSchedulerSetup(cell: CreateCompanySchedulerSetupCell, shiftName: String, checkIn: String, checkOut: String, breakDuration: String)
    {
        var detail =  cell.schedulerSetUpDetail
        detail?.shift_name = shiftName
        detail?.check_in = checkIn
        detail?.check_out = checkOut
        detail?.break_duration = breakDuration
        
        let cellIndexNumber = Int(detail?.cellNumber ?? "0")
        
        switch cellIndexNumber
        {
        case 0:
            if self.schedulerSetUpRequestArr.count == 0
            {
                self.schedulerSetUpRequestArr.insert(detail!, at: 0)
            }
            else
            {
                self.schedulerSetUpRequestArr[0] = detail!
            }
            break
        case 1:
            if self.schedulerSetUpRequestArr.count == 0
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 0)
            }
            
            if self.schedulerSetUpRequestArr.count == 1
            {
                detail?.shift_name = shiftName
                detail?.check_in = checkIn
                detail?.check_out = checkOut
                detail?.break_duration = breakDuration
                self.schedulerSetUpRequestArr.insert(detail!, at: 1)
            }
            else
            {
                detail?.shift_name = shiftName
                detail?.check_in = checkIn
                detail?.check_out = checkOut
                detail?.break_duration = breakDuration
                self.schedulerSetUpRequestArr[1] = detail!
            }
            break
        case 2:
            if self.schedulerSetUpRequestArr.count == 0
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 0)
            }
            if self.schedulerSetUpRequestArr.count == 1
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 1)
            }
            if self.schedulerSetUpRequestArr.count == 2
            {
                detail?.shift_name = shiftName
                detail?.check_in = checkIn
                detail?.check_out = checkOut
                detail?.break_duration = breakDuration
                self.schedulerSetUpRequestArr.insert(detail!, at: 2)
            }
            else
            {
                detail?.shift_name = shiftName
                detail?.check_in = checkIn
                detail?.check_out = checkOut
                detail?.break_duration = breakDuration
                self.schedulerSetUpRequestArr[2] = detail!
            }
            break
        case 3:
            if self.schedulerSetUpRequestArr.count == 0
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 0)
            }
            if self.schedulerSetUpRequestArr.count == 1
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 1)
            }
            if self.schedulerSetUpRequestArr.count == 2
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 2)
            }
            if self.schedulerSetUpRequestArr.count == 3
            {
                detail?.shift_name = shiftName
                detail?.check_in = checkIn
                detail?.check_out = checkOut
                detail?.break_duration = breakDuration
                self.schedulerSetUpRequestArr.insert(detail!, at: 3)
            }
            else
            {
                detail?.shift_name = shiftName
                detail?.check_in = checkIn
                detail?.check_out = checkOut
                detail?.break_duration = breakDuration
                self.schedulerSetUpRequestArr[3] = detail!
            }
            break
        case 4:
            if self.schedulerSetUpRequestArr.count == 0
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 0)
            }
            if self.schedulerSetUpRequestArr.count == 1
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 1)
            }
            if self.schedulerSetUpRequestArr.count == 2
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 2)
            }
            if self.schedulerSetUpRequestArr.count == 3
            {
                detail?.shift_name = ""
                detail?.check_in = ""
                detail?.check_out = ""
                detail?.break_duration = ""
                self.schedulerSetUpRequestArr.insert(detail!, at: 3)
            }
            if self.schedulerSetUpRequestArr.count == 4
            {
                detail?.shift_name = shiftName
                detail?.check_in = checkIn
                detail?.check_out = checkOut
                detail?.break_duration = breakDuration
                self.schedulerSetUpRequestArr.insert(detail!, at: 4)
            }
            else
            {
                detail?.shift_name = shiftName
                detail?.check_in = checkIn
                detail?.check_out = checkOut
                detail?.break_duration = breakDuration
                self.schedulerSetUpRequestArr[4] = detail!
            }
            break
        default: break
        }
    }
    
}

