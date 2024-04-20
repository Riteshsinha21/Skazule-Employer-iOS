//
//  AddNewEmployeeVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 13/12/22.
//

import UIKit
import DropDown
import Alamofire

class AddNewEmployeeVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var employeeFullNameTxtField: UITextField!
    @IBOutlet weak var employeeEmailIdTxtField: UITextField!
    @IBOutlet weak var employeeMobileNoTxtField: UITextField!
    @IBOutlet weak var employeeRoleDDTxtField: UITextField!
    @IBOutlet weak var employeeRoleDDBackView: UIView!
    
    @IBOutlet weak var employeeReportingToDDTxtField: UITextField!
    @IBOutlet weak var employeeReportingToDDBackView: UIView!
    
    @IBOutlet weak var employeeSchedulesDDTxtField: UITextField!
    
    @IBOutlet weak var employeeSchedulesDDBackView: UIView!
    @IBOutlet weak var employeePositionsDDTxtField: UITextField!
    
    @IBOutlet weak var employeePositionsDDBackView: UIView!
    @IBOutlet weak var employeeTagsDDTxtField: UITextField!
    
    @IBOutlet weak var employeeTagsDDBackView: UIView!
    @IBOutlet weak var employeeHourlyRateTxtField: UITextField!
    @IBOutlet weak var employeeMaxHoursTxtField: UITextField!
    @IBOutlet weak var employeeBenefitsTxtField: UITextField!
    
    @IBOutlet weak var employeeBenefitsBackView: UIView!
    
    @IBOutlet weak var employeeEmployeeIdTxtField: UITextField!
    @IBOutlet weak var employeeLogNotesTextView: UITextView!
    
    @IBOutlet weak var customTimeZoneBtn: UIButton!
    @IBOutlet weak var customTimeZoneBackView: UIView!
    @IBOutlet weak var customTimeZoneDDTxtField: UITextField!
    @IBOutlet weak var customWeekOffBtn: UIButton!
    @IBOutlet weak var customWeekOffBackView: UIView!
    @IBOutlet weak var customWeekOffDDTxtField: UITextField!
    
    @IBOutlet weak var addUpdateBtn: UIButton!
    @IBOutlet weak var SuccessfulBackView: UIView!
    @IBOutlet weak var successTitleLbl: UILabel!
    @IBOutlet weak var sucessGoBtn: UIButton!
    
    //1
    @IBOutlet weak var countryPickerBtn: UIButton!
    var extensionCCode = ""
    
    // MARK: Drop Down VArible
    let singleSelectionDropDown = DropDown()
    var singleDDSelectedIndex: Int? // Keeps track of the singleSelectionDropDown selected index
    let multiSelectionDropDown = DropDown()
    var preselectedIndices: Set<Int> = []
    var positionEditIndexArr    = [Int]()
    var tagEditIndexArr         = [Int]()
    var benifitsEditIndexArr    = [Int]()
    
    var multiDDSelectedIndexA: [Int]? // Keeps track of the selected index
    
    //Custom Alert View
    var customChooseImgView : CustomChooseImgView!
    var customWeekListView : CustomWeekListView!
    
    // For Update Employee
    var isOpenFrom = "Edit"
    var employeeDetail = EmployeeListStruct()
    var profileStr = ""
    
    //MARK: Variables
    let imagePicker = UIImagePickerController()
    var pickedImage : UIImage!
    var pickedImageUrl:URL?
    var userRolesArr = [UserRolesStruct]()
    var userRolesDDArr = [String]()
    var reportingToArr = [ReportingStruct]()
    var reportingToDDArr = [String]()
    var companyShiftArr = [CompanyShiftStruct]()
    var companyShiftDDArr = [String]()
    var companyPositionsArr = [CompanyPositionsStruct]()
    var companyPositionsDDArr = [String]()
    var companyTagsArr = [CompanyTagsStruct]()
    var companyTagsDDArr = [String]()
    var timeZoneArr = [TimeZoneStruct]()
    var timeZoneDDArr = [String]()
    var benefitsArr     = [BenefitsStruct]()
    var benefitsDDArr   = [String]()
    
    var userSelectedRoleId = ""
    var selectedReportingId = ""
    var selectedShiftId = ""
    var selectedPositionId = ""
    var selectedPositionIdsArr = [String]()
    var selectedTagId = ""
    var selectedTagIdsArr = [String]()
    var selectedBenefitsIdsArr = [String]()
    var selectedTimeZoneId = ""
    
    var weekOffDict = ["Monday":"1", "Tuesday":"2", "Wednesday":"3", "Thursday":"4", "Friday":"5", "Saturday":"6", "Sunday":"0"]
    var selectedWeekOffIdsArr = [String]()
    
    let dispatchGroup = DispatchGroup()
    
    func setupDropDown(arr:[String],showOn:UITextField, alreadySelectedValue:String)
    {
        singleSelectionDropDown.anchorView = showOn
        singleSelectionDropDown.bottomOffset = CGPoint(x: 0, y: showOn.bounds.height+10)
        singleSelectionDropDown.dataSource = arr
        singleSelectionDropDown.show()
        let valueToFind = alreadySelectedValue
        if let firstMatchingIndex = arr.firstIndex(of: valueToFind) {
            print(firstMatchingIndex) // Output: 3
            self.singleDDSelectedIndex = firstMatchingIndex
        } else {
            print("Value not found in the array")
        }
        singleSelectionDropDown.selectionAction = { [unowned self] (index, item) in
            print(self)
            let selectedIndex : Int? = index
            self.singleDDSelectedIndex = selectedIndex
            showOn.text = item
            
            if (showOn == self.employeeRoleDDTxtField)
            {
                let info = self.userRolesArr[selectedIndex!]
                self.userSelectedRoleId = info.id
                self.getReportingToApi(roleId: self.userSelectedRoleId)
            }
            if (showOn == self.employeeReportingToDDTxtField)
            {
                let info = self.reportingToArr[selectedIndex!]
                self.selectedReportingId = info.id
            }
            if (showOn == self.employeeSchedulesDDTxtField)
            {
                let info = self.companyShiftArr[selectedIndex!]
                self.selectedShiftId = info.id
            }
            //            if (showOn == self.employeePositionsDDTxtField)
            //            {
            //                let info = self.companyPositionsArr[selectedIndex!]
            //                self.selectedPositionId = info.id
            //            }
            //            if (showOn == self.employeeTagsDDTxtField)
            //            {
            //                let info = self.companyTagsArr[selectedIndex!]
            //                self.selectedTagId = info.id
            //            }
            if (showOn == self.customTimeZoneDDTxtField)
            {
                let info = self.timeZoneArr[selectedIndex!]
                self.selectedTimeZoneId = info.id
            }
            
        }
        
    }
    func setupDropDownForMultipleSelection(arr:[String],textfield:UITextField) {
        multiSelectionDropDown.anchorView = textfield
        multiSelectionDropDown.bottomOffset = CGPoint(x: 0, y: textfield.bounds.height+10)
        multiSelectionDropDown.dataSource = arr
        multiSelectionDropDown.show()
        multiSelectionDropDown.selectionBackgroundColor = UIColor.lightGray
        
        //        if self.isOpenFrom == "Update Open Shift"
        //        {
        // Preselect items based on preselectedIndices
        for index in preselectedIndices {
            if index >= 0 && index < multiSelectionDropDown.dataSource.count {
                multiSelectionDropDown.selectRow(index)
            }
        }
        //        }
        
        multiSelectionDropDown.multiSelectionAction = { [unowned self] (index, item) in
            if textfield == self.employeeBenefitsTxtField {
                //self.benefitsDDArr.removeAll()
                self.selectedBenefitsIdsArr.removeAll()
                var str : String! = ""
                for i in 0..<item.count {
                    str = str + "\(item[i])" + ", "
                    self.selectedBenefitsIdsArr.append(self.benefitsArr[self.benefitsDDArr.firstIndex(of: item[i])!].id)
                    // self.selectedStudentsIdArr.append(eventStudentListArr[eventStudentNameListArr.firstIndex(of: item[i])!].id)
                }
                textfield.text = String(str.dropLast(2))
            }
            if textfield == self.employeePositionsDDTxtField {
                self.selectedPositionIdsArr.removeAll()
                var str : String! = ""
                for i in 0..<item.count {
                    str = str + "\(item[i])" + ", "
                    self.selectedPositionIdsArr.append(self.companyPositionsArr[self.companyPositionsDDArr.firstIndex(of: item[i])!].id)
                }
                textfield.text = String(str.dropLast(2))
                
            }
            if textfield == self.employeeTagsDDTxtField {
                self.selectedTagIdsArr.removeAll()
                var str : String! = ""
                for i in 0..<item.count {
                    str = str + "\(item[i])" + ", "
                    self.selectedTagIdsArr.append(self.companyTagsArr[self.companyTagsDDArr.firstIndex(of: item[i])!].id)
                }
                textfield.text = String(str.dropLast(2))
            }
        }
        multiSelectionDropDown.reloadAllComponents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.updateUI()
        self.employeeLogNotesTextView.placeholder = "Enter Notes"
        
        self.setCountryCode()
        
    }
    func setCountryCode()
    {
        //        //2
        //        var countryCodeStr = defaultCountryCode
        //        if UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE) != nil
        //        {
        //            countryCodeStr = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE)!
        //        }
        //        if countryCodeStr == ""
        //        {
        //            countryCodeStr = defaultCountryCode
        //        }
        //        self.countryPickerBtn.setTitle("\(countryCodeStr)", for: .normal)
        //
        //
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.COUNTRY_CODE), object: nil)
    }
    
    //MARK:- Notification selector
    @objc func openNotification(_ notification: Notification)
    {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            
            if let countryCode = dict["countryCode"] as? String {
                // do something with your image
                //                self.countryPickerBtn.setTitle("\(countryCode)", for: .normal)
                
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
    //    func countryFlag(countryCode: String) -> String {
    //      return String(String.UnicodeScalarView(
    //         countryCode.unicodeScalars.compactMap(
    //           { UnicodeScalar(127397 + $0.value) })))
    //    }
    //    print(countryFlag(countryCode: "IN")) //OUTPUT: 🇮🇳print(countryFlag(countryCode: "US")) //OUTPUT: 🇺🇸
    func updateUI()
    {
        if isOpenFrom == "Edit"
        {
            let c_CodeStr = employeeDetail.c_code
            //            self.extensionCCode = c_CodeStr
            //2
            if c_CodeStr == ""
            {
                self.countryPickerBtn.setTitle("\(defaultCountryCodeStr)", for: .normal)
            }
            else
            {
                self.countryPickerBtn.setTitle("\(c_CodeStr)", for: .normal)
            }
            self.extensionCCode = c_CodeStr
            
            self.customNavigationBar.titleLabel.text = "Update Employee"
            self.addUpdateBtn.setTitle("UPDATE EMPLOYEE", for: .normal)
            
            self.getUserRolesApi()
            self.getCompanyShiftApi()
            self.getCompanyPositionApi()
            self.getCompanyTagsApi()
            self.getTimeZoneApi()
            self.getBenefitsApi()
            
            dispatchGroup.notify(queue: .main) {
                // your code here
                self.getEmployeeDetailApi(employeeId: self.employeeDetail.employee_id)
            }
            
            //            // to run something in 0.1 seconds
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //                // your code here
            //                self.getEmployeeDetailApi(employeeId: self.employeeDetail.employee_id)
            //            }
        }
        else
        {
            self.countryPickerBtn.setTitle("\(defaultCountryCodeStr)", for: .normal)
            /*
             self.getUserRolesApi()
             self.getCompanyShiftApi()
             self.getCompanyPositionApi()
             self.getCompanyTagsApi()
             self.getBenefitsApi()
             */
            self.getTimeZoneApi()
            self.customNavigationBar.titleLabel.text = "Add New Employee"
            self.addUpdateBtn.setTitle("ADD EMPLOYEE", for: .normal)
            self.employeeLogNotesTextView.placeholder = "Enter Notes"
        }
        //        let index = sender.tag
        //        let info = self.employeeListArr[index]
        //        let documentId = info.id
        //        if documentId != ""
        //        {
        //            self.isOpenFrom          = "Edit"
        //            self.documentsId         = documentId
        //            self.document            = info.document_name
        //            if info.document_file != ""
        //            {
        //                let uploadedDocumentNameArr = info.document_file.split(separator: "/")
        //                if let lastElement = uploadedDocumentNameArr.last {
        //                    self.uploadedDocumentURL = String(lastElement)
        //                }
        //            }
        //            self.showCustomUploadDocumentsView()
        //        }
        
    }
    func setEmployeeData()
    {
        //        @IBOutlet weak var profileImg: UIImageView!
        //        @IBOutlet weak var cameraBtn: UIButton!
        
        let info = employeeDetail
        self.employeeFullNameTxtField.text = info.name
        self.employeeEmailIdTxtField.text = info.email
        self.employeeMobileNoTxtField.text = info.mobile
        self.employeeRoleDDTxtField.text = info.role
        //@IBOutlet weak var employeeRoleDDBackView: UIView!
        
        
        self.employeeReportingToDDTxtField.text = ""//info.h
        // @IBOutlet weak var employeeReportingToDDBackView: UIView!
        
        self.employeeSchedulesDDTxtField.text = ""//info.s
        
        // @IBOutlet weak var employeeSchedulesDDBackView: UIView!
        self.employeePositionsDDTxtField.text = info.position
        
        //        @IBOutlet weak var employeePositionsDDBackView: UIView!
        self.employeeTagsDDTxtField.text = info.tag
        
        //        @IBOutlet weak var employeeTagsDDBackView: UIView!
        self.employeeHourlyRateTxtField.text = info.hourly_rate
        self.employeeMaxHoursTxtField.text = info.max_work_hour_weekly
        self.employeeBenefitsTxtField.text = ""//info
        
        //        @IBOutlet weak var employeeBenefitsBackView: UIView!
        
        self.employeeEmployeeIdTxtField.text = info.employee_id
        self.employeeLogNotesTextView.text = ""//info.d
        
        //        @IBOutlet weak var customTimeZoneBtn: UIButton!
        //        @IBOutlet weak var customTimeZoneBackView: UIView!
        self.customTimeZoneDDTxtField.text = info.timezone_location
        //        @IBOutlet weak var customWeekOffBtn: UIButton!
        //        @IBOutlet weak var customWeekOffBackView: UIView!
        self.customWeekOffDDTxtField.text = ""//info.
        
    }
    
    func getEmployeeDetailApi(employeeId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_EDIT_DETAIL_API
        if Reachability.isConnectedToNetwork() {
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "employee_id": employeeId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { [self] (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let profile_pic =  json["data"]["profile_pic"].stringValue
                    let hourly_rate =  json["data"]["hourly_rate"].stringValue
                    let email =  json["data"]["email"].stringValue
                    
                    //let employee_id =  json["data"]["employee_id"].stringValue
                    //let c_code =  json["data"]["c_code"].stringValue
                    let name =  json["data"]["name"].stringValue
                    let max_work_hour_weekly =  json["data"]["max_work_hour_weekly"].stringValue
                    let log_note =  json["data"]["log_note"].stringValue
                    //let id =  json["data"]["id"].stringValue
                    let emp_id =  json["data"]["emp_id"].stringValue
                    let mobile =  json["data"]["mobile"].stringValue
                    
                    if profile_pic != ""
                    {
                        let imageUrl = IMAGE_BASE_URL + profile_pic
                        self.profileImg.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
                        //                        self.pickedImageUrl = URL(string:imageUrl)
                        //                        self.profileStr = imageUrl
                    }
                    self.employeeFullNameTxtField.text = name
                    self.employeeEmailIdTxtField.text = email
                    self.employeeMobileNoTxtField.text = mobile
                    self.employeeHourlyRateTxtField.text = hourly_rate
                    self.employeeMaxHoursTxtField.text = max_work_hour_weekly
                    self.employeeEmployeeIdTxtField.text = emp_id
                    
                    if log_note == ""
                    {
                        self.employeeLogNotesTextView.placeholder = "Enter Notes"
                    }
                    else
                    {
                        self.employeeLogNotesTextView.placeholder = ""
                    }
                    self.employeeLogNotesTextView.text = log_note
                    
                    if json["data"]["week_off"].count != 0
                    {
                        self.customWeekOffBackView.isHidden = false
                        self.customWeekOffBtn.isSelected = true
                        var weekOffArr = [String]()
                        for i in 0..<json["data"]["week_off"].count
                        {
                            if json["data"]["week_off"][i] == "0"
                            {
                                weekOffArr.append("monday")
                                self.selectedWeekOffIdsArr.append("0")
                            }
                            else if json["data"]["week_off"][i] == "1"
                            {
                                weekOffArr.append("tuesday")
                                self.selectedWeekOffIdsArr.append("1")
                            }
                            else if json["data"]["week_off"][i] == "2"
                            {
                                weekOffArr.append("wednesday")
                                self.selectedWeekOffIdsArr.append("2")
                            }
                            else if json["data"]["week_off"][i] == "3"
                            {
                                weekOffArr.append("thursday")
                                self.selectedWeekOffIdsArr.append("3")
                            }
                            else if json["data"]["week_off"][i] == "4"
                            {
                                weekOffArr.append("friday")
                                self.selectedWeekOffIdsArr.append("4")
                            }
                            else if json["data"]["week_off"][i] == "5"
                            {
                                weekOffArr.append("saturday")
                                self.selectedWeekOffIdsArr.append("5")
                            }
                            else if json["data"]["week_off"][i] == "6"
                            {
                                weekOffArr.append("sunday")
                                self.selectedWeekOffIdsArr.append("6")
                            }
                        }
                        let selectedWeekOffStr = weekOffArr.joined(separator: ",")
                        self.customWeekOffDDTxtField.text = selectedWeekOffStr
                    }
                    
                    
                    let role_id =  json["data"]["role_id"].stringValue
                    if role_id != ""
                    {
                        var userRolesStr = ""
                        for i in 0..<self.userRolesArr.count
                        {
                            let id = self.userRolesArr[i].id
                            let role = self.userRolesArr[i].role
                            if  id == role_id {
                                userRolesStr = role
                                self.userSelectedRoleId = id
                            }
                        }
                        self.employeeRoleDDTxtField.text = userRolesStr
                    }
                    self.userSelectedRoleId = role_id
                    let reporting_to =  json["data"]["reporting_to"].stringValue
                    self.getReportingToApi(roleId: self.userSelectedRoleId, alreadyAddReportingToId: reporting_to)
                    //
                    //                    if reporting_to != ""
                    //                    {
                    //                        var reportingStr = ""
                    //                        for i in 0..<self.reportingToArr.count
                    //                        {
                    //                            let id = self.reportingToArr[i].id
                    //                            let name = self.reportingToArr[i].name
                    //                            if  id == reporting_to {
                    //                                reportingStr = name
                    //                                self.selectedReportingId = id
                    //                            }
                    //                        }
                    //                        self.employeeReportingToDDTxtField.text = reportingStr
                    //                    }
                    
                    
                    let shift_id =  json["data"]["shift_id"].stringValue
                    if shift_id != ""
                    {
                        var shiftNameStr = ""
                        for i in 0..<self.companyShiftArr.count
                        {
                            let id = self.companyShiftArr[i].id
                            let name = self.companyShiftArr[i].shift_name
                            //                            let checkInStr = self.companyShiftArr[i].check_in
                            //                            let checkOutStr = self.companyShiftArr[i].check_out
                            let checkInStr = gmtToLocal(dateStr: self.companyShiftArr[i].check_in)
                            let checkOutStr = gmtToLocal(dateStr: self.companyShiftArr[i].check_out)
                            
                            if  id == shift_id {
                                shiftNameStr = "\(name)(\(checkInStr ?? "--") - \(checkOutStr ?? "--"))"
                                self.selectedShiftId = id
                            }
                        }
                        self.employeeSchedulesDDTxtField.text = shiftNameStr
                    }
                    
                    let time_zone_id =  json["data"]["time_zone_id"].stringValue
                    if time_zone_id != "0"
                    {
                        self.customTimeZoneBackView.isHidden = false
                        self.customTimeZoneBtn.isSelected = true
                        var timeZoneStr = ""
                        for i in 0..<self.timeZoneArr.count
                        {
                            let id = self.timeZoneArr[i].id
                            let name = self.timeZoneArr[i].timezone_location
                            if  id == time_zone_id {
                                timeZoneStr = name
                                self.selectedTimeZoneId = id
                            }
                        }
                        self.customTimeZoneDDTxtField.text = timeZoneStr
                    }
                    
                    
                    
                    //                    {
                    //                      "tags" : ["301","298"],
                    //                      "benefits" : ["301","298"],
                    //                      "positions" : ["301","298"],
                    //                    }
                    self.employeeTagsDDTxtField.text = ""
                    self.employeeBenefitsTxtField.text = ""
                    
                    
                    let positions =  json["data"]["positions"].arrayValue
                    var positionsArr =  [String]()
                    for item in positions
                    {
                        positionsArr.append(item.rawValue as! String)
                    }
                    if positionsArr.count != 0
                    {
                        let indicesOfMatchingData = self.companyPositionsArr.enumerated().compactMap { (index, dict) in
                            if let id = dict.id as? String, positionsArr.contains(id) {
                                
                                return index
                            }
                            return nil
                        }
                        // Print the indices of matching data
                        print("Indices of Matching Data: \(indicesOfMatchingData)")
                        self.positionEditIndexArr.removeAll()
                        for item in indicesOfMatchingData
                        {
                            self.positionEditIndexArr.append(item)
                        }
                        
                        var positionStrArr = [String]()
                        for i in 0..<positionsArr.count
                        {
                            if let positionID = self.companyPositionsArr.first(where: {$0.id == positionsArr[i]}) {
                                self.selectedPositionIdsArr.append(positionID.id)
                                positionStrArr.append(positionID.position)
                            }
                        }
                        let selectedPositionStr = positionStrArr.joined(separator: ",")
                        self.employeePositionsDDTxtField.text = selectedPositionStr
                    }
                    
                    let tags =  json["data"]["tags"].arrayValue
                    var tagsArr =  [String]()
                    for item in tags
                    {
                        tagsArr.append(item.rawValue as! String)
                    }
                    if tagsArr.count != 0
                    {
                        let indicesOfMatchingData = self.companyTagsArr.enumerated().compactMap { (index, dict) in
                            if let id = dict.id as? String, tagsArr.contains(id) {
                                
                                return index
                            }
                            return nil
                        }
                        // Print the indices of matching data
                        print("Indices of Matching Data: \(indicesOfMatchingData)")
                        self.tagEditIndexArr.removeAll()
                        for item in indicesOfMatchingData
                        {
                            self.tagEditIndexArr.append(item)
                        }
                        
                        
                        var tagsStrArr = [String]()
                        for i in 0..<tagsArr.count
                        {
                            if let tagID = self.companyTagsArr.first(where: {$0.id == tagsArr[i]}) {
                                self.selectedTagIdsArr.append(tagID.id)
                                tagsStrArr.append(tagID.tag)
                            }
                        }
                        let selectedTagsStr = tagsStrArr.joined(separator: ",")
                        self.employeeTagsDDTxtField.text = selectedTagsStr
                    }
                    
                    let benefits =  json["data"]["benefits"].arrayValue
                    var benefitsArr =  [String]()
                    for item in benefits
                    {
                        benefitsArr.append(item.rawValue as! String)
                    }
                    if benefitsArr.count != 0
                    {
                        let indicesOfMatchingData = self.benefitsArr.enumerated().compactMap { (index, dict) in
                            if let id = dict.id as? String, benefitsArr.contains(id) {
                                
                                return index
                            }
                            return nil
                        }
                        // Print the indices of matching data
                        print("Indices of Matching Data: \(indicesOfMatchingData)")
                        self.benifitsEditIndexArr.removeAll()
                        for item in indicesOfMatchingData
                        {
                            self.benifitsEditIndexArr.append(item)
                        }
                        
                        var benefitsStrArr = [String]()
                        for i in 0..<benefitsArr.count
                        {
                            if let benefitsID = self.benefitsArr.first(where: {$0.id == benefitsArr[i]}) {
                                self.selectedBenefitsIdsArr.append(benefitsID.id)
                                benefitsStrArr.append(benefitsID.benefit)
                            }
                        }
                        let selectedBenefitsStr = benefitsStrArr.joined(separator: ",")
                        self.employeeBenefitsTxtField.text = selectedBenefitsStr
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
    
    @IBAction func onTapDropDownBtn(_ sender: UIButton) {
        var selectItem = ""
        //singleDDSelectedIndex = 0
        switch sender.tag
        {
        case 201:
            if isOpenFrom == "Edit"
            {
                
                //selectItem = self.employeeRoleDDTxtField.text ?? ""
                
                self.setupDropDown(arr: self.userRolesDDArr, showOn: self.employeeRoleDDTxtField, alreadySelectedValue: selectItem)
                // Preselect the dropdown option during editing
                if let singleDDSelectedIndex = singleDDSelectedIndex {
                    singleSelectionDropDown.clearSelection() // Clear any previous selection
                    singleSelectionDropDown.selectRow(at: singleDDSelectedIndex)
                }
            }
            else
            {
                self.getUserRolesApi()
            }
            
            
            break
        case 202:
            if self.reportingToDDArr.count == 0
            {
                UIAlertController.showInfoAlertWithTitle("Message", message: "Reporting To data not Found!", buttonTitle: "Okay")
                return
            }
            
            if isOpenFrom == "Edit"
            {
                //selectItem = self.employeeReportingToDDTxtField.text ?? ""
            }
            self.setupDropDown(arr: self.reportingToDDArr, showOn: self.employeeReportingToDDTxtField, alreadySelectedValue: selectItem)
            // Preselect the dropdown option during editing
            if let singleDDSelectedIndex = singleDDSelectedIndex {
                singleSelectionDropDown.clearSelection() // Clear any previous selection
                singleSelectionDropDown.selectRow(at: singleDDSelectedIndex)
            }
            break
        case 203:
            if isOpenFrom == "Edit"
            {
                //selectItem = self.employeeSchedulesDDTxtField.text ?? ""
                
                self.setupDropDown(arr: self.companyShiftDDArr, showOn: self.employeeSchedulesDDTxtField, alreadySelectedValue: selectItem)
                // Preselect the dropdown option during editing
                if let singleDDSelectedIndex = singleDDSelectedIndex {
                    singleSelectionDropDown.clearSelection() // Clear any previous selection
                    singleSelectionDropDown.selectRow(at: singleDDSelectedIndex)
                }
            }
            else
            {
                self.getCompanyShiftApi()
            }
            break
        case 204:
            //            self.setupDropDown(arr: self.companyPositionsDDArr, showOn: self.employeePositionsDDTxtField)
            
            if isOpenFrom == "Edit"
            {
                self.preselectedIndices.removeAll()
                for item in self.positionEditIndexArr
                {
                    self.preselectedIndices.insert(item)
                }
                self.setupDropDownForMultipleSelection(arr: self.companyPositionsDDArr, textfield: self.employeePositionsDDTxtField)
            }
            else
            {
                self.getCompanyPositionApi()
            }
            
            
            //            self.setupDropDownForMultipleSelection(arr: self.companyPositionsDDArr, textfield: self.employeePositionsDDTxtField)
            
            
            break
        case 205:
            //            self.setupDropDown(arr: self.companyTagsDDArr, showOn: self.employeeTagsDDTxtField)
            //            self.setupDropDownForMultipleSelection(arr: self.companyTagsDDArr, textfield: self.employeeTagsDDTxtField)
            
            if isOpenFrom == "Edit"
            {
                self.preselectedIndices.removeAll()
                for item in self.tagEditIndexArr
                {
                    self.preselectedIndices.insert(item)
                }
                self.setupDropDownForMultipleSelection(arr: self.companyTagsDDArr, textfield: self.employeeTagsDDTxtField)
            }
            else
            {
                self.getCompanyTagsApi()
            }
            
            break
        case 206:
            if isOpenFrom == "Edit"
            {
                //selectItem = self.customTimeZoneDDTxtField.text ?? ""
            }
            self.setupDropDown(arr: self.timeZoneDDArr, showOn: self.customTimeZoneDDTxtField, alreadySelectedValue: selectItem)
            // Preselect the dropdown option during editing
            if let singleDDSelectedIndex = singleDDSelectedIndex {
                singleSelectionDropDown.clearSelection() // Clear any previous selection
                singleSelectionDropDown.selectRow(at: singleDDSelectedIndex)
            }
            
            break
        case 207:
            self.showWeekActitivityPopup()
            break
        case 208:
            //            self.setupDropDownForMultipleSelection(arr: self.benefitsDDArr, textfield: self.employeeBenefitsTxtField)
            
            if isOpenFrom == "Edit"
            {
                self.preselectedIndices.removeAll()
                for item in self.benifitsEditIndexArr
                {
                    self.preselectedIndices.insert(item)
                }
                self.setupDropDownForMultipleSelection(arr: self.benefitsDDArr, textfield: self.employeeBenefitsTxtField)
            }
            else
            {
                self.getBenefitsApi()
            }
            
            break
        default: break
        }
        
        //        switch sender.tag
        //        {
        //        case 201:
        //            self.setupDropDown(arr: self.userRolesDDArr, showOn: self.employeeRoleDDTxtField, view: self.employeeRoleDDBackView)
        //            break
        //        case 202:
        //            self.setupDropDown(arr: self.reportingToDDArr, showOn:  self.employeeReportingToDDTxtField,view: self.employeeReportingToDDBackView)
        //            break
        //        case 203:
        //            self.setupDropDown(arr: self.companyShiftDDArr, showOn: self.employeeSchedulesDDTxtField, view: self.employeeSchedulesDDBackView)
        //            break
        //        case 204:
        //            self.setupDropDown(arr: self.companyPositionsDDArr, showOn: self.employeePositionsDDTxtField, view: self.employeePositionsDDBackView)
        //            break
        //        case 205:
        //            self.setupDropDown(arr: self.companyTagsDDArr, showOn: self.employeeTagsDDTxtField, view: self.employeeTagsDDBackView)
        //            break
        //        case 206:
        //            self.setupDropDown(arr: self.timeZoneDDArr, showOn: self.customTimeZoneDDTxtField, view: self.customTimeZoneDDBackView)
        //            break
        //        case 207:
        //            self.showWeekActitivityPopup()
        //            break
        //        default: break
        //        }
    }
    
    @IBAction func onTapCameraBtn(_ sender: Any) {
        self.showAddProfilePicPopup()
    }
    
    @IBAction func onTapCustomTimeZoneBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true
        {
            self.customTimeZoneBackView.isHidden = false
        }
        else
        {
            self.customTimeZoneBackView.isHidden = true
        }
    }
    
    @IBAction func onTapCustomWeekOffBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected  == true
        {
            self.customWeekOffBackView.isHidden = false
        }
        else
        {
            self.customWeekOffBackView.isHidden = true
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
        self.customWeekOffDDTxtField.text = selectWeekOffDayArr.joined(separator: ", ")
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
    
    @IBAction func onTapAddEmployeeBtn(_ sender: Any) {
        
        if(self.employeeFullNameTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter full name")
        }
        else if(self.employeeEmailIdTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter email")
        }
        else if !(ValidationManager.validateEmail(email: employeeEmailIdTxtField.text!))
        {
            showMessageAlert(message: "Please enter valid email")
        }
        else if(self.employeeMobileNoTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter mobile number")
        }
        else if !(ValidationManager.validatePhone(no: employeeMobileNoTxtField.text!))
        {
            showMessageAlert(message: "Please enter valid mobile number")
        }
        else if(self.employeeRoleDDTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please select role")
        }
        else
        {
            //selectWeekOffDayArr.joined(separator: ", ")
            let benefitsStr = selectedBenefitsIdsArr.joined(separator: ",")
            let selectedWeekOffIdsStr = selectedWeekOffIdsArr.joined(separator: ",")
            let positionsStr = selectedPositionIdsArr.joined(separator: ",")
            let tagsStr = selectedTagIdsArr.joined(separator: ",")
            //            self.AddEmployeeApi(name: self.employeeFullNameTxtField.text!, email: self.employeeEmailIdTxtField.text!, password: "", mobile: self.employeeMobileNoTxtField.text!, c_code: "+91", role_id: self.userSelectedRoleId, shift_id: self.selectedShiftId, position_id: self.selectedPositionId , tag_id:  self.selectedTagId , hourly_rate: self.employeeHourlyRateTxtField.text!, max_work_hour_weekly: self.employeeMaxHoursTxtField.text!, week_off: selectedWeekOffIdsStr, benefits: benefitsStr, time_zone_id: self.selectedTimeZoneId, log_note: self.employeeLogNotesTextView.text!)
            
            if isOpenFrom == "Edit"
            {
                //                let c_CodeStr = employeeDetail.c_code
                //                self.extensionCCode = c_CodeStr
                //
                
                self.updateEmployeeApi(name: self.employeeFullNameTxtField.text!, email: self.employeeEmailIdTxtField.text!, password: "", mobile: self.employeeMobileNoTxtField.text!, c_code: "\(self.extensionCCode)", role_id: self.userSelectedRoleId, shift_id: self.selectedShiftId, position_id:positionsStr , tag_id: tagsStr, hourly_rate: self.employeeHourlyRateTxtField.text ?? "", max_work_hour_weekly: self.employeeMaxHoursTxtField.text ?? "", week_off: selectedWeekOffIdsStr, benefits: benefitsStr, time_zone_id: self.selectedTimeZoneId, log_note: self.employeeLogNotesTextView.text ?? "",empId: self.employeeEmployeeIdTxtField.text ?? "",id: self.employeeDetail.id, employeeId:self.employeeDetail.employee_id, reportingTo: self.selectedReportingId)
            }
            else
            {
                //var countryCode = (UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.C_CODE) ?? "+91") as String
                var countryCode = self.extensionCCode
                if countryCode == ""
                {
                    countryCode = defaultCCode
                }
                
                self.AddEmployeeApi(name: self.employeeFullNameTxtField.text!, email: self.employeeEmailIdTxtField.text!, password: "", mobile: self.employeeMobileNoTxtField.text!, c_code: "\(countryCode)", role_id: self.userSelectedRoleId, shift_id: self.selectedShiftId, position_id:positionsStr , tag_id: tagsStr, hourly_rate: self.employeeHourlyRateTxtField.text ?? "", max_work_hour_weekly: self.employeeMaxHoursTxtField.text ?? "", week_off: selectedWeekOffIdsStr, benefits: benefitsStr, time_zone_id: self.selectedTimeZoneId, log_note: self.employeeLogNotesTextView.text ?? "",empId: self.employeeEmployeeIdTxtField.text ?? "",reportingTo: self.selectedReportingId)
            }
        }
    }
    
    func getUserRolesApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_USER_ROLES_API
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [:]
            
            dispatchGroup.enter()   // <<---
            
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.userRolesArr.removeAll()
                    self.userRolesDDArr.removeAll()
                    
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let role =  json["data"][i]["role"].stringValue
                        
                        self.userRolesArr.append(UserRolesStruct.init(id: id, role: role))
                        self.userRolesDDArr.append(role)
                    }
                    
                    DispatchQueue.main.async {
                        
                        if self.isOpenFrom != "Edit"
                        {
                            self.setupDropDown(arr: self.userRolesDDArr, showOn: self.employeeRoleDDTxtField, alreadySelectedValue: "")
                        }
                    }
                }
                else {
                    self.userRolesArr.removeAll()
                    self.userRolesDDArr.removeAll()
                    
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
                    //self.tbleView.reloadData()
                    self.dispatchGroup.leave()   // <<----
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
    func getReportingToApi(roleId: String, alreadyAddReportingToId: String? = nil)
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_REPORTING_TO_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "role_id": roleId, "company_id": companyId]
            print(param)
            
            dispatchGroup.enter()   // <<---
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.reportingToArr.removeAll()
                    self.reportingToDDArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id          =  json["data"][i]["id"].stringValue
                        let name        =  json["data"][i]["name"].stringValue
                        let email       =  json["data"][i]["email"].stringValue
                        let c_code      =  json["data"][i]["c_code"].stringValue
                        let mobile      =  json["data"][i]["mobile"].stringValue
                        let profile_pic =  json["data"][i]["profile_pic"].stringValue
                        let role =  json["data"][i]["role"].stringValue
                        
                        self.reportingToArr.append(ReportingStruct.init(id: id, name: name, email: email, c_code: c_code, mobile: mobile, profile_pic: profile_pic, role: role))
                        let nameWithRoleStr = "\(name)(\(role))"
                        self.reportingToDDArr.append(nameWithRoleStr)
                    }
                    
                    if self.isOpenFrom == "Edit"
                    {
                        
                        DispatchQueue.main.async {
                            if alreadyAddReportingToId != ""
                            {
                                var reportingStr = ""
                                for i in 0..<self.reportingToArr.count
                                {
                                    let id = self.reportingToArr[i].id
                                    let name = self.reportingToArr[i].name
                                    let role = self.reportingToArr[i].role
                                    
                                    if  id == alreadyAddReportingToId {
                                        reportingStr = "\(name)(\(role))"
                                        self.selectedReportingId = id
                                    }
                                }
                                self.employeeReportingToDDTxtField.text = reportingStr
                            }
                        }
                    }
                    
                }
                else {
                    self.reportingToArr.removeAll()
                    self.reportingToDDArr.removeAll()
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
                        //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
                
                DispatchQueue.main.async {
                    //self.tbleView.reloadData()
                    self.dispatchGroup.leave()   // <<----
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
    
    
    
    func getCompanyShiftApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_COMPANY_SHIFT_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "company_id": companyId]
            print(param)
            dispatchGroup.enter()   // <<---
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.companyShiftArr.removeAll()
                    self.companyShiftDDArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let shift_name =  json["data"][i]["shift_name"].stringValue
                        let check_in =  json["data"][i]["check_in"].stringValue
                        let check_out =  json["data"][i]["check_out"].stringValue
                        let break_duration =  json["data"][i]["break_duration"].stringValue
                        
                        self.companyShiftArr.append(CompanyShiftStruct.init(id: id, shift_name: shift_name, check_in: check_in, check_out: check_out, break_duration: break_duration))
                        
                        //                        let checkInStr = getFormattedTimeStr(timeStr: check_in)
                        //                        let checkOutStr = getFormattedTimeStr(timeStr: check_out)
                        let checkInStr = gmtToLocal(dateStr: check_in)
                        let checkOutStr = gmtToLocal(dateStr: check_out)
                        let timeIntervalStr = "\(shift_name)(\(checkInStr ?? "-") - \(checkOutStr ?? "-"))"
                        
                        self.companyShiftDDArr.append(timeIntervalStr)
                    }
                    DispatchQueue.main.async {
                        
                        if self.isOpenFrom != "Edit"
                        {
                            self.setupDropDown(arr: self.companyShiftDDArr, showOn: self.employeeSchedulesDDTxtField, alreadySelectedValue: "")
                        }
                    }
                }
                else {
                    self.companyShiftArr.removeAll()
                    self.companyShiftDDArr.removeAll()
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
                    //self.tbleView.reloadData()
                    self.dispatchGroup.leave()   // <<----
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
    
    func getCompanyPositionApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_COMPANY_POSITIONS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "company_id": companyId]
            print(param)
            dispatchGroup.enter()   // <<---
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.companyPositionsArr.removeAll()
                    self.companyPositionsDDArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let industry_id =  json["data"][i]["industry_id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let position =  json["data"][i]["position"].stringValue
                        
                        self.companyPositionsArr.append(CompanyPositionsStruct.init(id: id, industry_id: industry_id, position: position, status: status))
                        self.companyPositionsDDArr.append(position)
                    }
                    
                    DispatchQueue.main.async {
                        
                        if self.isOpenFrom != "Edit"
                        {
                            self.setupDropDownForMultipleSelection(arr: self.companyPositionsDDArr, textfield: self.employeePositionsDDTxtField)
                        }
                    }
                }
                else {
                    self.companyPositionsArr.removeAll()
                    self.companyPositionsDDArr.removeAll()
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
                    //self.tbleView.reloadData()
                    self.dispatchGroup.leave()   // <<----
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
    
    //    static let GET_TIMEZONE_API = "api/get-timezone"
    //    //company_id:2
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
            dispatchGroup.enter()   // <<---
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.companyTagsArr.removeAll()
                    self.companyTagsDDArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let tag =  json["data"][i]["tag"].stringValue
                        
                        self.companyTagsArr.append(CompanyTagsStruct.init(id: id, tag: tag))
                        self.companyTagsDDArr.append(tag)
                    }
                    DispatchQueue.main.async {
                        
                        if self.isOpenFrom != "Edit"
                        {
                            self.setupDropDownForMultipleSelection(arr: self.companyTagsDDArr, textfield: self.employeeTagsDDTxtField)
                        }
                    }
                }
                else {
                    self.companyTagsArr.removeAll()
                    self.companyTagsDDArr.removeAll()
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
                    //self.tbleView.reloadData()
                    self.dispatchGroup.leave()   // <<----
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
    func getBenefitsApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_BENEFITS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "company_id": companyId]
            print(param)
            dispatchGroup.enter()   // <<---
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.benefitsArr.removeAll()
                    self.benefitsDDArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let benefit =  json["data"][i]["benefit"].stringValue
                        let description =  json["data"][i]["description"].stringValue
                        let premium_pay =  json["data"][i]["premium_pay"].stringValue
                        let company_pay =  json["data"][i]["company_pay"].stringValue
                        let employee_pay =  json["data"][i]["employee_pay"].stringValue
                        let gross_pay =  json["data"][i]["gross_pay"].stringValue
                        
                        self.benefitsArr.append(BenefitsStruct.init(id: id, benefit: benefit, description: description, premium_pay: premium_pay, company_pay: company_pay, employee_pay: employee_pay, gross_pay: gross_pay))
                        self.benefitsDDArr.append(benefit)
                    }
                    DispatchQueue.main.async {
                        
                        if self.isOpenFrom != "Edit"
                        {
                            self.setupDropDownForMultipleSelection(arr: self.benefitsDDArr, textfield: self.employeeBenefitsTxtField)
                        }
                    }
                }
                else {
                    self.benefitsArr.removeAll()
                    self.benefitsDDArr.removeAll()
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
                DispatchQueue.main.async {
                    if self.isOpenFrom != "Edit"
                    {
                        self.setupDropDownForMultipleSelection(arr: self.benefitsDDArr, textfield: self.employeeBenefitsTxtField)
                    }
                    //self.tbleView.reloadData()
                    self.dispatchGroup.leave()   // <<----
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
            dispatchGroup.enter()   // <<---
            
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
                    self.dispatchGroup.leave()   // <<----
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
    func AddEmployeeApi(name:String, email:String, password:String, mobile:String, c_code:String, role_id:String, shift_id:String,position_id:String, tag_id:String, hourly_rate:String, max_work_hour_weekly:String, week_off:String, benefits:String, time_zone_id:String, log_note:String, empId:String,reportingTo:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.ADD_EMPLOYEE_API
        if Reachability.isConnectedToNetwork() {
            guard let employerId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            var param = [String:Any]()
            if pickedImageUrl == nil
            {
                param = ["user_id": employerId, "company_id":companyId, "name": name,"email": email,"password":password, "mobile":mobile, "c_code": c_code, "role_id":role_id, "shift_id":shift_id, "position_id":position_id,"tag_id":tag_id, "hourly_rate":hourly_rate, "max_work_hour_weekly":max_work_hour_weekly, "week_off":week_off, "benefits":benefits, "time_zone_id":time_zone_id, "log_note":log_note, "emp_id":empId, "reporting_person": reportingTo]
            }
            else
            {
                param = ["user_id": employerId, "company_id":companyId, "name": name,"email": email,"password":password, "mobile":mobile, "c_code": c_code, "role_id":role_id, "shift_id":shift_id, "position_id":position_id,"tag_id":tag_id, "hourly_rate":hourly_rate, "max_work_hour_weekly":max_work_hour_weekly, "week_off":week_off, "benefits":benefits, "time_zone_id":time_zone_id, "log_note":log_note, "profile_pic":pickedImageUrl ?? "", "emp_id":empId, "reporting_person": reportingTo]
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
                    
                    //                    let Alert = UIAlertController(title: "Message", message: json["message"].stringValue, preferredStyle: UIAlertController.Style.alert)
                    //                    Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    //                        let vc = CreateCompanyScedulerSetupVC()
                    //                        self.navigationController?.pushViewController(vc, animated: true)
                    //                    }))
                    //                    if let presenter = Alert.popoverPresentationController {
                    //                        presenter.sourceView = self.view
                    //                        presenter.sourceRect = self.view.bounds
                    //                    }
                    //                    DispatchQueue.main.async {
                    //                        self.present(Alert, animated: true, completion: nil)
                    //                    }
                    
                    //                    let vc = CompanyRegistrationCompleteVc()
                    //                    vc.isCommingFrom = "Add Employee"
                    //                    self.navigationController?.pushViewController(vc, animated: true)
                    self.SuccessfulBackView.isHidden = false
                    self.SuccessfulBackView.isHidden = false
                    self.successTitleLbl.text = "You Have Added Employee Successfully."
                    self.sucessGoBtn.setTitle("Add More Employees", for: .normal)
                    
                    //                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay", viewController: self)
                }
                else
                {
                    self.SuccessfulBackView.isHidden = true
                    
                    //self.jobPositionsArr.removeAll()
                    //                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
    func updateEmployeeApi(name:String, email:String, password:String, mobile:String, c_code:String, role_id:String, shift_id:String,position_id:String, tag_id:String, hourly_rate:String, max_work_hour_weekly:String, week_off:String, benefits:String, time_zone_id:String, log_note:String, empId:String,id:String, employeeId:String,reportingTo: String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_EMPLOYEE_API
        if Reachability.isConnectedToNetwork() {
            guard let employerId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            var param = [String:Any]()
            if pickedImageUrl == nil
            {
                param = ["user_id": employerId, "company_id":companyId, "name": name,"email": email,"password":password, "mobile":mobile, "c_code": c_code, "role_id":role_id, "shift_id":shift_id, "position_id":position_id,"tag_id":tag_id, "hourly_rate":hourly_rate, "max_work_hour_weekly":max_work_hour_weekly, "week_off":week_off, "benefits":benefits, "time_zone_id":time_zone_id, "log_note":log_note,"emp_id":empId,"id":id, "employee_id":employeeId, "reporting_person": reportingTo]
            }
            else
            {
                param = ["user_id": employerId, "company_id":companyId, "name": name,"email": email,"password":password, "mobile":mobile, "c_code": c_code, "role_id":role_id, "shift_id":shift_id, "position_id":position_id,"tag_id":tag_id, "hourly_rate":hourly_rate, "max_work_hour_weekly":max_work_hour_weekly, "week_off":week_off, "benefits":benefits, "time_zone_id":time_zone_id, "log_note":log_note, "profile_pic":pickedImageUrl ?? "","emp_id":empId,"id":id, "employee_id":employeeId, "reporting_person": reportingTo]
            }
            print(param)
            
            ServerClass.sharedInstance.sendMultipartRequestToServer(urlString: fullUrl, fileName: "profile_pic", param, imageUrl: pickedImageUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    //                    UserDefaults.standard.setValue(selectedCountry, forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE)
                    UserDefaults.standard.setValue(self.extensionCCode, forKey: USER_DEFAULTS_KEYS.C_CODE)
                    UserDefaults.standard.setValue(selectedCountry, forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE)
                    
                    
                    self.SuccessfulBackView.isHidden = false
                    self.successTitleLbl.text = "You Have Updated Employee Successfully."
                    self.sucessGoBtn.setTitle("Go To Employee List", for: .normal)
                }
                else
                {
                    self.SuccessfulBackView.isHidden = true
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
    @IBAction func onTapAddMoreEmployeeBtn(_ sender: Any) {
        self.SuccessfulBackView.isHidden = true
        self.navigationController?.popViewController(animated: true)
    }
}
extension AddNewEmployeeVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
