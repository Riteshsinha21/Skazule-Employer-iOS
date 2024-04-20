//
//  UpdateProfileVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 30/05/23.
//

import UIKit
import DropDown

class UpdateProfileVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var employerFullNameTxtField: UITextField!
    @IBOutlet weak var employerEmailIdTxtField: UITextField!
    @IBOutlet weak var employerMobileNoTxtField: UITextField!
    @IBOutlet weak var employerCompNameTxtField: UITextField!
    @IBOutlet weak var employerCompAddressTxtField: UITextField!
    @IBOutlet weak var employerNoOfEmployeeDDTxtField: UITextField!
    @IBOutlet weak var employerIndustryDDTxtField: UITextField!
    @IBOutlet weak var employerTimeZoneDDTxtField: UITextField!
    @IBOutlet weak var employerWeekOffTxtField: UITextField!
    @IBOutlet weak var updateProfileBtn: UIButton!
    
    //1
    @IBOutlet weak var countryPickerBtn: UIButton!
    var extensionCCode = ""
    
    let singleSelectionDropDown = DropDown()
    var profileData = CompanyProfileStruct()
    //Custom Alert View
    var customChooseImgView : CustomChooseImgView!
    var customWeekListView : CustomWeekListView!
    
    var employeeRangeArr = [EmployeeRangeStruct]()
    var industriesArr = [IndustriesStruct]()
    
    //MARK: Variables
    let imagePicker         = UIImagePickerController()
    var pickedImage : UIImage!
    var pickedImageUrl:URL?
    var noOfEmployeeDDArr      = [String]()
    var selectedNoOfEmployeeId   = ""
    var industryDDArr          = [String]()
    var selectedIndustryId       = ""
    var timeZoneArr         = [TimeZoneStruct]()
    var timeZoneDDArr       = [String]()
    var selectedTimeZoneId = ""
    var weekOffDict = ["Monday":"1", "Tuesday":"2", "Wednesday":"3", "Thursday":"4", "Friday":"5", "Saturday":"6", "Sunday":"0"]
    var selectedWeekOffIdsArr = [String]()
    
    var alreadySelectedCountryCode = defaultCountryCodeStr
    
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
            
            if (showOn == self.employerNoOfEmployeeDDTxtField)
            {
                let info = self.employeeRangeArr[selectedIndex!]
                self.selectedNoOfEmployeeId = info.id
            }
            if (showOn == self.employerIndustryDDTxtField)
            {
                let info = self.industriesArr[selectedIndex!]
                self.selectedIndustryId = info.id
            }
            if (showOn == self.employerTimeZoneDDTxtField)
            {
                let info = self.timeZoneArr[selectedIndex!]
                self.selectedTimeZoneId = info.id
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCountryCode()
        self.setUIData()
        self.getEmployeeRangeApi()
        self.getIndusrtiesApi()
        self.getTimeZoneApi()
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.COUNTRY_CODE), object: nil)
    }
    //2
    func setCountryCode()
    {
        let conCode = self.alreadySelectedCountryCode
        if conCode == ""
        {
            self.countryPickerBtn.setTitle("\(defaultCountryCodeStr)", for: .normal)
        }
        else
        {
            self.countryPickerBtn.setTitle("\(conCode)", for: .normal)
        }
        self.extensionCCode = conCode
        
        
        
        
        /*
         var countryCodeStr = defaultCountryCode
         if UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE) != nil
         {
         countryCodeStr = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE)!
         }
         if countryCodeStr == ""
         {
         countryCodeStr = defaultCountryCode
         }
         self.countryPickerBtn.setTitle("\(countryCodeStr)", for: .normal)
         
         let c_CodeStr = profileData.c_code
         self.extensionCCode = c_CodeStr
         
         */
    }
    //MARK:- Notification selector
    @objc func openNotification(_ notification: Notification)
    {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            
            if let countryCode = dict["countryCode"] as? String {
                // do something with your image
                /*
                 self.countryPickerBtn.setTitle("\(countryCode)", for: .normal)
                 */
            }
            if let extensionCode = dict["extensionCode"] as? String {
                self.countryPickerBtn.setTitle("\(extensionCode)", for: .normal)
                self.extensionCCode = "\(extensionCode)"
            }
        }
    }
    @IBAction func onTapCountryPicker(_ sender: Any) {
        let vc = CountryPickerVC()
        present(vc, animated: true)
    }
    
    func setUIData()
    {
        self.customNavigationBar.titleLabel.text = "Update Profile"
        let imageUrl = IMAGE_BASE_URL + profileData.profile_pic
        self.profileImg.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        self.employerFullNameTxtField.text = profileData.name
        self.employerEmailIdTxtField.text = profileData.email
        self.employerMobileNoTxtField.text = profileData.mobile
        self.employerCompNameTxtField.text = profileData.company_name
        self.employerCompAddressTxtField.text = profileData.company_address
        self.employerNoOfEmployeeDDTxtField.text = profileData.emp_range_value
        self.employerIndustryDDTxtField.text = profileData.industry_value
        self.employerTimeZoneDDTxtField.text = profileData.time_zone_value
        self.selectedTimeZoneId = profileData.time_zone_id
        self.selectedNoOfEmployeeId = profileData.emp_range
        self.selectedIndustryId     = profileData.industry
        
        if profileData.weekOffIdArr?.count != 0
        {
            var weekOffArr = [String]()
            for i in 0..<(profileData.weekOffIdArr?.count ?? 0)
            {
                if profileData.weekOffIdArr?[i] == "0"
                {
                    weekOffArr.append("monday")
                    self.selectedWeekOffIdsArr.append("0")
                }
                else if profileData.weekOffIdArr?[i] == "1"
                {
                    weekOffArr.append("tuesday")
                    self.selectedWeekOffIdsArr.append("1")
                }
                else if profileData.weekOffIdArr?[i] == "2"
                {
                    weekOffArr.append("wednesday")
                    self.selectedWeekOffIdsArr.append("2")
                }
                else if profileData.weekOffIdArr?[i] == "3"
                {
                    weekOffArr.append("thursday")
                    self.selectedWeekOffIdsArr.append("3")
                }
                else if profileData.weekOffIdArr?[i] == "4"
                {
                    weekOffArr.append("friday")
                    self.selectedWeekOffIdsArr.append("4")
                }
                else if profileData.weekOffIdArr?[i] == "5"
                {
                    weekOffArr.append("saturday")
                    self.selectedWeekOffIdsArr.append("5")
                }
                else if profileData.weekOffIdArr?[i] == "6"
                {
                    weekOffArr.append("sunday")
                    self.selectedWeekOffIdsArr.append("6")
                }
            }
            let selectedWeekOffStr = weekOffArr.joined(separator: ",")
            self.employerWeekOffTxtField.text = selectedWeekOffStr
        }
    }
    
    @IBAction func onTapDropDownBtn(_ sender: UIButton) {
        
        switch sender.tag
        {
        case 201:
            self.setupDropDown(arr: self.noOfEmployeeDDArr, showOn: self.employerNoOfEmployeeDDTxtField)
            break
        case 202:
            self.setupDropDown(arr: self.industryDDArr, showOn: self.employerIndustryDDTxtField)
            break
        case 203:
            self.setupDropDown(arr: self.timeZoneDDArr, showOn: self.employerTimeZoneDDTxtField)
            break
        case 204:
            self.showWeekActitivityPopup()
            break
        default: break
        }
    }
    
    func getEmployeeRangeApi()
    {
        if Reachability.isConnectedToNetwork()
        {
            showProgressOnView(appDelegateInstance.window!)
            let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_RANGE_API
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path:fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.employeeRangeArr.removeAll()
                    self.noOfEmployeeDDArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let emp_range_from =  json["data"][i]["emp_range_from"].stringValue
                        let emp_range_to =  json["data"][i]["emp_range_to"].stringValue
                        
                        self.employeeRangeArr.append(EmployeeRangeStruct.init(status: status, emp_range_from: emp_range_from, emp_range_to: emp_range_to, id: id))
                        self.noOfEmployeeDDArr.append("\(emp_range_from) - \(emp_range_to)")
                    }
                }
                else {
                    self.employeeRangeArr.removeAll()
                    self.noOfEmployeeDDArr.removeAll()
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
    func getIndusrtiesApi()
    {
        if Reachability.isConnectedToNetwork()
        {
            showProgressOnView(appDelegateInstance.window!)
            
            let fullUrl = BASE_URL + PROJECT_URL.GET_INDUSTRY_API
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path:fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.industriesArr.removeAll()
                    self.industryDDArr.removeAll()
                    
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let industry =  json["data"][i]["industry"].stringValue
                        
                        self.industriesArr.append(IndustriesStruct.init(status: status, industry: industry, id: id))
                        self.industryDDArr.append(industry)
                    }
                }
                else {
                    self.industriesArr.removeAll()
                    self.industryDDArr.removeAll()
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
    func getTimeZoneApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_TIMEZONE_API
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [:]
            //            dispatchGroup.enter()   // <<---
            
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.timeZoneArr.removeAll()
                    self.timeZoneDDArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let timezone_location =  json["data"][i]["timezone_location"].stringValue
                        let gmt =  json["data"][i]["gmt"].stringValue
                        let offset =  json["data"][i]["offset"].stringValue
                        
                        self.timeZoneArr.append(TimeZoneStruct.init(id: id, timezone_location: timezone_location, gmt: gmt, offset: offset))
                        self.timeZoneDDArr.append(timezone_location)
                    }
                }
                else {
                    self.timeZoneArr.removeAll()
                    self.timeZoneDDArr.removeAll()
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
                
                DispatchQueue.main.async {
                    //self.tbleView.reloadData()
                    //  self.dispatchGroup.leave()   // <<----
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
    
    @IBAction func onTapCameraBtn(_ sender: Any) {
        self.showAddProfilePicPopup()
    }
    @IBAction func onTapUpdateBtn(_ sender: Any) {
        
        if(self.employerFullNameTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter name")
        }
        else if(self.employerMobileNoTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter mobile number")
        }
        else if !(ValidationManager.validatePhone(no: employerMobileNoTxtField.text!))
        {
            showMessageAlert(message: "Please enter valid mobile number")
        }
        else if(self.employerCompNameTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter company name")
        }
        else if(self.employerCompAddressTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter company address")
        }
        else if(self.employerNoOfEmployeeDDTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please select number of employee")
        }
        else if(self.employerIndustryDDTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please select industry")
        }
        else if(self.employerWeekOffTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please select week of days")
        }
        else
        {
            var countryCode = self.extensionCCode
            if countryCode == ""
            {
                countryCode = defaultCountryCodeStr
            }
            
            let weekOffIds = selectedWeekOffIdsArr.joined(separator: ",")
            self.updateProfileApi(name: self.employerFullNameTxtField.text ?? "", mobile: self.employerMobileNoTxtField.text ?? "", compName:  self.employerCompNameTxtField.text ?? "", compAddress:  self.employerCompAddressTxtField.text ?? "", industry:  self.selectedIndustryId, empRange:  self.selectedNoOfEmployeeId, week_off: weekOffIds, time_zone_id: self.selectedTimeZoneId,c_code: "\(countryCode)")
        }
    }
    
    func showAddProfilePicPopup(){
        self.customChooseImgView = CustomChooseImgView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.customChooseImgView.cameraButton.addTarget(self, action: #selector(self.cameraButtonPressed), for: .touchUpInside)
        self.customChooseImgView.gallaryButton.addTarget(self, action: #selector(self.gallaryButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customChooseImgView)
    }
    @objc func cameraButtonPressed(sender: UIButton) {
        self.customChooseImgView.removeFromSuperview()
        self.openCamera()
    }
    @objc func gallaryButtonPressed(sender: UIButton) {
        self.customChooseImgView.removeFromSuperview()
        self.openGallery()
    }
    
    func showWeekActitivityPopup(){
        self.customWeekListView = CustomWeekListView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.customWeekListView.okButton.addTarget(self, action: #selector(self.okButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customWeekListView)
    }
    @objc func okButtonPressed(sender: UIButton) {
        self.customWeekListView.removeFromSuperview()
        let selectWeekOffDayArr = self.customWeekListView.checkBoxBtnStatusDict.filter { $0.value == true }.keys
        self.employerWeekOffTxtField.text = selectWeekOffDayArr.joined(separator: ", ")
        self.selectedWeekOffIdsArr.removeAll()
        for item in selectWeekOffDayArr
        {
            if item.lowercased() == "monday"
            {
                self.selectedWeekOffIdsArr.append("0")
            }
            else if item.lowercased() == "tuesday"
            {
                self.selectedWeekOffIdsArr.append("1")
            }
            else if item.lowercased() == "wednesday"
            {
                self.selectedWeekOffIdsArr.append("2")
            }
            else if item.lowercased() == "thursday"
            {
                self.selectedWeekOffIdsArr.append("3")
            }
            else if item.lowercased() == "friday"
            {
                self.selectedWeekOffIdsArr.append("4")
            }
            else if item.lowercased() == "saturday"
            {
                self.selectedWeekOffIdsArr.append("5")
            }
            else if item.lowercased() == "sunday"
            {
                self.selectedWeekOffIdsArr.append("6")
            }
        }
    }
    func updateProfileApi(name:String, mobile:String, compName:String, compAddress:String, industry:String,empRange:String, week_off:String, time_zone_id:String,c_code:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_PROFILE_API
        if Reachability.isConnectedToNetwork() {
            guard let employerId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            var param = [String:Any]()
            if pickedImageUrl == nil
            {
                param = ["user_id": employerId, "company_id":companyId, "name": name,"mobile": mobile,"company_name": compName,"company_address": compAddress,"industry": industry,"emp_range": empRange, "week_off":week_off, "time_zone_id":time_zone_id, "c_code": c_code]
            }
            else
            {
                param = ["user_id": employerId, "company_id":companyId, "name": name,"mobile": mobile,"company_name": compName,"company_address": compAddress,"industry": industry,"emp_range": empRange, "week_off":week_off, "time_zone_id":time_zone_id, "profile_pic":pickedImageUrl ?? "", "c_code": c_code]
            }
            print(param)
            
            ServerClass.sharedInstance.sendMultipartRequestToServer(urlString: fullUrl, fileName: "profile_pic", param, imageUrl: pickedImageUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UserDefaults.standard.setValue(self.extensionCCode, forKey: USER_DEFAULTS_KEYS.C_CODE)
                    UserDefaults.standard.setValue(selectedCountry, forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE)
                    
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
                    
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
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
    
    func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        var dialingCode = ""
        if self.extensionCCode == ""
        {
            dialingCode = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.C_CODE) as! String
        }
        else
        {
            dialingCode = self.extensionCCode
        }
        let regexString = "^\\\(dialingCode)\\d{10}$" // Adjust the regex pattern as needed
        let regex = try! NSRegularExpression(pattern: regexString)
        let range = NSRange(location: 0, length: phoneNumber.utf16.count)
        return regex.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }
    
    
}
extension UpdateProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Opening camera
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    // Opening Gallery
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK:- imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:  [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.profileImg.image = pickedImage
            saveImageDocumentDirectory(usedImage: pickedImage)
        }
        if let imgUrl = getImageUrl()
        {
            pickedImageUrl = imgUrl
        }
        dismiss(animated: true, completion: nil)
    }
}
