//
//  EmployeeShiftTemplatesVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 13/12/22.
//

import UIKit

class EmployeeShiftTemplatesVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var tblBackView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var companyShiftArr = [CompanyShiftStruct]()
    // For Update Tags
    var isOpenFrom = "Add"
    var shiftId = ""
    var shift = ""
    var checkIn = ""
    var checkOut = ""
    var breakDuration = ""
    
    //Custom View
    var customAddShiftTempView : CustomAddShiftTempView!
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customNavigationBar.titleLabel.text = "Shift Templates"
        self.customNavigationBar.customRightBarButton.isHidden = false
        self.customNavigationBar.customRightBarButton.setBackgroundImage(UIImage.init(named: "add_employee"), for: .normal)
        self.customNavigationBar.customRightBarButton.addTarget(self, action: #selector(onClickAddShiftTemplateBtn), for: .touchUpInside)
        tblView.register(UINib(nibName: "EmployeeShiftTempBenefitCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeShiftTempBenefitCell")
        self.getCompanyShiftApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
    }
    
    @objc func onClickAddShiftTemplateBtn(_ sender:UIButton)
    {
        self.isOpenFrom = "Add"
        self.showCustomAddShiftTempView()
    }
    func showCustomAddShiftTempView (){
        self.customAddShiftTempView = CustomAddShiftTempView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        if self.isOpenFrom == "Edit"
        {
            self.customAddShiftTempView.shifttNameTextField.text = self.shift
            //            self.customAddShiftTempView.checkInTextField.text = getFormattedTimeStr(timeStr: self.checkIn)
            //            self.customAddShiftTempView.checkOutTextField.text = getFormattedTimeStr(timeStr: self.checkOut)
            self.customAddShiftTempView.checkInTextField.text = gmtToLocal(dateStr: self.checkIn)
            self.customAddShiftTempView.checkOutTextField.text = gmtToLocal(dateStr: self.checkOut)
            self.customAddShiftTempView.breakDurationTextField.text = self.breakDuration
            //self.tag = self.customAddTagView.addTagTextField.text ?? ""
            self.customAddShiftTempView.headerTitleLbl.text = "Update Shift Template"
            self.customAddShiftTempView.addButton.setTitle("UPDATE", for: .normal)
        }
        else
        {
            //            self.shift = self.customAddShiftTempView.shifttNameTextField.text ?? ""
            //            self.checkIn = self.customAddShiftTempView.checkInTextField.text ?? ""
            //            self.checkOut = self.customAddShiftTempView.checkOutTextField.text ?? ""
            //            self.breakDuration = self.customAddShiftTempView.breakDurationTextField.text ?? ""
            
            self.customAddShiftTempView.shifttNameTextField.text = ""
            self.customAddShiftTempView.checkInTextField.text = ""
            self.customAddShiftTempView.checkOutTextField.text = ""
            self.customAddShiftTempView.breakDurationTextField.text = ""
            self.customAddShiftTempView.headerTitleLbl.text = "Add Shift Template"
            self.customAddShiftTempView.addButton.setTitle("ADD", for: .normal)
        }
        self.customAddShiftTempView.addButton.addTarget(self, action: #selector(self.addShiftTempButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customAddShiftTempView)
    }
    @objc func addShiftTempButtonPressed(sender: UIButton) {
        
        if self.customAddShiftTempView.shifttNameTextField.text == ""
        {
            showMessageAlert(message: "Please enter shift name")
        }
        else if self.customAddShiftTempView.checkInTextField.text == ""
        {
            showMessageAlert(message: "Please enter Check In time")
        }
        else if self.customAddShiftTempView.checkOutTextField.text == ""
        {
            showMessageAlert(message: "Please enter Check Out time")
        }
        else if self.customAddShiftTempView.breakDurationTextField.text == ""
        {
            showMessageAlert(message: "Please enter break duration")
        }
        else
        {
            self.customAddShiftTempView.removeFromSuperview()
            self.shift = self.customAddShiftTempView.shifttNameTextField.text!
            self.checkIn = self.customAddShiftTempView.checkInTextField.text!
            self.checkOut = self.customAddShiftTempView.checkOutTextField.text!
            self.breakDuration = self.customAddShiftTempView.breakDurationTextField.text!
            
            let checkIN  = getFormattedTimeStrSendInAPI(timeStr: self.checkIn)
            let checkOUT = getFormattedTimeStrSendInAPI(timeStr: self.checkOut)
            
            if isOpenFrom == "Edit"
            {
                //self.updatePositionApi(tagId: self.tagId, tagStr: self.tag)
                self.updateShiftTemplateApi(shiftId: self.shiftId, shiftName: self.shift, checkIn: checkIN, checkOut: checkOUT, breakDuration: self.breakDuration)
            }
            else
            {
                self.createShiftTemplateApi(shiftName: self.shift, checkIn: checkIN, checkOut: checkOUT, breakDuration: self.breakDuration)
            }
        }
        
    }
    
    func getCompanyShiftApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_COMPANY_SHIFT_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            //            let param:[String:Any] = [ "company_id": companyId]
            let param:[String:Any] = [ "page": "\(self.currentPageIndex)", "limit": "10","company_id": companyId]
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
                        self.companyShiftArr.removeAll()
                    }
                    //self.companyShiftArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let shift_name =  json["data"][i]["shift_name"].stringValue
                        let check_in =  json["data"][i]["check_in"].stringValue
                        let check_out =  json["data"][i]["check_out"].stringValue
                        let break_duration =  json["data"][i]["break_duration"].stringValue
                        
                        self.companyShiftArr.append(CompanyShiftStruct.init(id: id, shift_name: shift_name, check_in: check_in, check_out: check_out, break_duration: break_duration))
                    }
                }
                else {
                    self.companyShiftArr.removeAll()
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
                }
                
                DispatchQueue.main.async {
                    if self.companyShiftArr.count == 0
                    {
                        self.tblBackView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    else
                    {
                        self.tblBackView.isHidden = false
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
    
    
    func createShiftTemplateApi(shiftName:String,checkIn:String,checkOut:String,breakDuration:String)
    {
        
        let fullUrl = BASE_URL + PROJECT_URL.ADD_SHIFT_TEMPLATE_API
        let checkInTimeStr = localToGMT(dateStr: checkIn)
        let checkOutTimeStr = localToGMT(dateStr: checkOut)
        
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:String?] = ["shift_name":shiftName,"check_in": checkInTimeStr,"check_out": checkOutTimeStr,"break_duration":breakDuration, "user_id": userId,"company_id":companyId]
            
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getCompanyShiftApi()
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
                
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func updateShiftTemplateApi(shiftId:String, shiftName:String,checkIn:String,checkOut:String,breakDuration:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_SHIFT_TEMPLATE_API
        let checkInTimeStr = localToGMT(dateStr: checkIn)
        let checkOutTimeStr = localToGMT(dateStr: checkOut)
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["shift_name":shiftName,"check_in":checkInTimeStr,"check_out":checkOutTimeStr, "break_duration":breakDuration, "user_id": userId,"company_id":companyId,"shift_id":shiftId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getCompanyShiftApi()
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
    
    
    
    @objc func deleteBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.companyShiftArr[index]
        let shiftId = info.id
        if shiftId != ""
        {
            self.deleteApiCall(shiftID: shiftId)
        }
    }
    @objc func editBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.companyShiftArr[index]
        let shiftId = info.id
        if shiftId != ""
        {
            self.isOpenFrom = "Edit"
            self.shiftId = shiftId
            self.shift = info.shift_name
            self.checkIn = info.check_in
            self.checkOut = info.check_out
            self.breakDuration = info.break_duration
            self.showCustomAddShiftTempView()
        }
    }
    
    func deleteApiCall(shiftID:String)
    {
        let Alert = UIAlertController(title: "Alert", message: "Deleting a record will remove it from all employees linked to it. This record can not be recreated.\nAre you sure, You want to delete this shift template!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTagApi(shiftId: shiftID)
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
    func deleteTagApi(shiftId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_SHIFT_TEMPLATE_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:String?] = [ "user_id": userId, "shift_id":shiftId]
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getCompanyShiftApi()
                }
                else
                {
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
extension EmployeeShiftTemplatesVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.companyShiftArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeShiftTempBenefitCell") as! EmployeeShiftTempBenefitCell
        cell.selectionStyle = .none
        cell.benefitsBackView.isHidden = true
        
        let info = self.companyShiftArr[indexPath.row]
        cell.shiftNameLbl.text = info.shift_name
        //        let checkInStr = getFormattedTimeStr(timeStr: info.check_in)
        //        let checkOutStr = getFormattedTimeStr(timeStr: info.check_out)
        //        cell.shiftTimeLbl.text = "\(checkInStr) - \(checkOutStr)"
        let checkInStr  = gmtToLocal(dateStr: info.check_in)
        let checkOutStr = gmtToLocal(dateStr: info.check_out)
        cell.shiftTimeLbl.text = "\(checkInStr ?? "-") - \(checkOutStr ?? "-")"
        cell.breakDurationLbl.text = info.break_duration
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
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
        return 260
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.companyShiftArr.count - 1) {
            if (self.companyShiftArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getCompanyShiftApi()
            }
        }
    }
    
}
