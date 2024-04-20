//
//  AddEditSchedulerShiftViewController.swift
//  Skazule
//
//  Created by ChawTech Solutions on 09/03/23.
//

import UIKit
import DropDown
import APJTextPickerView

class AddEditSchedulerShiftViewController: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var assignBackView: UIView!
    @IBOutlet weak var assignDDTextField: UITextField!
    @IBOutlet weak var assignDDBtn: UIButton!
    @IBOutlet weak var noOfOpeningBackView: UIView!
    @IBOutlet weak var noOfOpeningTextField: UITextField!
    @IBOutlet weak var dateTextField: APJTextPickerView!
    @IBOutlet weak var timeInTextField: APJTextPickerView!
    @IBOutlet weak var timeOutTextField: APJTextPickerView!
    @IBOutlet weak var unpaidBreakTextField: UITextField!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var positionTagBackView: UIView!
    @IBOutlet weak var positionDDTextField: UITextField!
    @IBOutlet weak var positionDDBtn: UIButton!
    @IBOutlet weak var tagDDTextField: UITextField!
    @IBOutlet weak var tagDDBtn: UIButton!
    @IBOutlet weak var shitfNoteTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    
    //Drop Down
    let singleSelectionDropDown = DropDown()
    var singleDDSelectedIndex: Int? // Keeps track of the singleSelectionDropDown selected index
    
    var selectedPositionId = ""
    let multiSelectionDropDown = DropDown()
    var preselectedIndices: Set<Int> = []
    var selectedEmployeeId = "0"
    var companyPositionsArr = [CompanyPositionsStruct]()
    var companyPositionsDDArr = [String]()
    var companyTagsArr = [CompanyTagsStruct]()
    var companyTagsDDArr = [String]()
    var selectedPositionIdsArr = [String]()
    var selectedTagIdsArr = [String]()
    
    // Define a selected options array to store preselected options
    var selectedOptions = [String]()
    
    //Custom View
    var customEmployeeListView : CustomEmployeeListView!
    var customColorPickerView : CustomColorPickerView!
    var colorCode = ""
    var isOpenFromShift = ""
    var isOpenFrom = ""
    var updateDetail = OpenScheduleDataStruct()
    var scheduleId = ""
    var numberOfOpening = 1
    var numberOfAssignedOpening = 0
    let dispatchGroup = DispatchGroup()
    var employeeName = ""
    
    var byDefaultDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(byDefaultDate)
        
        self.setUIData()
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil)
    }
    func gmtDateTimeStringFromCheckInString(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            return dateFormatter.string(from: date)
        }
        return ""
    }
    func localDateTimeStringFromCheckInString(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.string(from: date)
        }
        return ""
    }
    func gmtTimeStringFromCheckOutString(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            return dateFormatter.string(from: date)
        }
        return ""
    }
    @objc func openNotification(_ notification: Notification)
    {
        print(notification.userInfo ?? "")
        
        if let dict = notification.userInfo as NSDictionary? {
            if let name = dict["employeeName"] as? String {
                self.assignDDTextField.text = name
            }
            if let employeeId = dict["employeeId"] as? String {
                self.selectedEmployeeId = employeeId
            }
            //            if let shiftTime = dict["shiftTime"] as? String {
            //                self.assignDDTextField.text = "\(self.assignDDTextField.text ?? "") (\(shiftTime))"
            //            }
        }
        
        if self.assignDDTextField.text == "Open Shift"
        {
            self.assignBackView.isHidden = false
            self.noOfOpeningBackView.isHidden = false
            self.positionTagBackView.isHidden = false
            self.getCompanyPositionApi()
            self.getCompanyTagsApi()
            self.setOpenAddEditScheduleShiftData()
        }
        else
        {
            self.noOfOpeningBackView.isHidden = true
            self.positionTagBackView.isHidden = true
            self.setEmployeeAddEditScheduleShiftData()
        }
        
    }
    func setupDropDown(arr:[String],showOn:UITextField,alreadySelectedValue:String)
    {
        singleSelectionDropDown.anchorView = showOn
        singleSelectionDropDown.bottomOffset = CGPoint(x: 0, y: showOn.bounds.height+10)
        singleSelectionDropDown.dataSource = arr
        singleSelectionDropDown.show()
        //singleSelectionDropDown.selectionBackgroundColor = UIColor.lightGray
        
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
            
            if (showOn == self.positionDDTextField)
            {
                let info = self.companyPositionsArr[selectedIndex!]
                self.selectedPositionId = info.id
            }
        }
    }
    func setupDropDownForMultipleSelection(arr:[String],textfield:UITextField) {
        multiSelectionDropDown.anchorView = textfield
        multiSelectionDropDown.bottomOffset = CGPoint(x: 0, y: textfield.bounds.height+10)
        multiSelectionDropDown.dataSource = arr
        multiSelectionDropDown.show()
        multiSelectionDropDown.selectionBackgroundColor = UIColor.lightGray
        
        if self.isOpenFrom == "Update Open Shift"
        {
            // Preselect items based on preselectedIndices
            for index in preselectedIndices {
                if index >= 0 && index < multiSelectionDropDown.dataSource.count {
                    multiSelectionDropDown.selectRow(index)
                }
            }
        }
        multiSelectionDropDown.multiSelectionAction = { [unowned self] (index, item) in
            
            if textfield == self.self.tagDDTextField {
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
    
    func setUIData()
    {
        //Apjextextpicker
        self.dateTextField.datePicker?.datePickerMode = .date
        self.dateTextField.dateFormatter.dateFormat = "yyyy-MM-dd"
        self.dateTextField.datePicker?.minimumDate = Date()
        
        self.timeInTextField.datePicker?.datePickerMode = .time
        self.timeInTextField.datePicker?.locale = Locale(identifier: "en-US")
        //        self.timeInTextField.dateFormatter.dateFormat = "hh:mm a"
        self.timeInTextField.dateFormatter.dateFormat = "hh:mm a"
        self.timeOutTextField.datePicker?.datePickerMode = .time
        self.timeOutTextField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        //        self.timeOutTextField.dateFormatter.dateFormat = "hh:mm a"
        self.timeOutTextField.dateFormatter.dateFormat = "hh:mm a"
        
        self.customNavigationBar.titleLabel.text = "\(isOpenFrom)"
        
        
        if self.isOpenFromShift == "Open Shift"
        {
            self.assignBackView.isHidden = false
            self.noOfOpeningBackView.isHidden = false
            self.positionTagBackView.isHidden = false
            self.setOpenAddEditScheduleShiftData()
        }
        else
        {
            self.assignBackView.isHidden = true
            //self.assignBackView.isHidden = false
            self.noOfOpeningBackView.isHidden = true
            self.positionTagBackView.isHidden = true
            self.setEmployeeAddEditScheduleShiftData()
        }
    }
    
    func setOpenAddEditScheduleShiftData(){
        
        self.getCompanyPositionApi()
        self.getCompanyTagsApi()
        
        if self.isOpenFrom == "Update Open Shift"
        {
            self.colorCode = self.updateDetail.color_code
            dispatchGroup.notify(queue: .main) {
                // your code here
                self.getScheduleDetailApi(scheduleId: self.updateDetail.schedule_id)
            }
            self.assignDDTextField.text  = "Open Shift"
            self.noOfOpeningTextField.text   = self.updateDetail.nubmer_of_opening
            let dateString = self.updateDetail.date + " " + self.updateDetail.check_in
            let convertedLocalDateStr = gmtToLocalDate(dateStr: dateString)
            let convertedLocalCheckInStr = gmtToLocal(dateStr: self.updateDetail.check_in)
            let convertedLocalCheckOutStr = gmtToLocal(dateStr: self.updateDetail.check_out)
            
            self.dateTextField.text   = convertedLocalDateStr
            self.timeInTextField.text  = convertedLocalCheckInStr
            self.timeOutTextField.text = convertedLocalCheckOutStr
            
            self.unpaidBreakTextField.text   = self.updateDetail.break_duration
            self.positionDDTextField.text  = self.updateDetail.position
            self.tagDDTextField.text = ""
            //  self.shitfNoteTextView.placeholder = "Enter Shift Note"
            self.shitfNoteTextView.text = self.updateDetail.note
            let colorCode = self.updateDetail.color_code
            let colorCodeStr = colorCode.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            let colorCodeArr = colorCodeStr.components(separatedBy: ",")
            let r = Double(colorCodeArr[0]) ?? 0.0
            let g = Double(colorCodeArr[1]) ?? 0.0
            let b = Double(colorCodeArr[2]) ?? 0.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorPickerButton.backgroundColor = color
            self.addButton.setTitle("UPDATE", for: .normal)
            
            self.assignDDTextField.isUserInteractionEnabled = false
            self.assignDDBtn.isUserInteractionEnabled = false
        }
        else
        {
            self.assignDDTextField.text    = "Open Shift"
            self.noOfOpeningTextField.text = ""
            let currentDateStr             = currentDate()
            self.dateTextField.text        = byDefaultDate//currentDateStr
            self.timeInTextField.text      = ""
            self.timeOutTextField.text     = ""
            self.unpaidBreakTextField.text = ""
            self.positionDDTextField.text  = ""
            self.tagDDTextField.text       = ""
            self.shitfNoteTextView.placeholder = "Enter Shift Note"
            self.addButton.setTitle("ADD", for: .normal)
        }
    }
    func setEmployeeAddEditScheduleShiftData(){
        if self.isOpenFrom == "Update Employee Shift"
        {
            self.colorCode = self.updateDetail.color_code
            let dateString = self.updateDetail.date + " " + self.updateDetail.check_in
            let convertedLocalDateStr = gmtToLocalDate(dateStr: dateString)
            let convertedLocalCheckInStr = gmtToLocal(dateStr: self.updateDetail.check_in)
            let convertedLocalCheckOutStr = gmtToLocal(dateStr: self.updateDetail.check_out)
            
            self.dateTextField.text   = convertedLocalDateStr
            self.timeInTextField.text  = convertedLocalCheckInStr
            self.timeOutTextField.text = convertedLocalCheckOutStr
            
            self.unpaidBreakTextField.text   = self.updateDetail.break_duration
            let colorCode = self.updateDetail.color_code
            let colorCodeStr = colorCode.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            let colorCodeArr = colorCodeStr.components(separatedBy: ",")
            let r = Double(colorCodeArr[0]) ?? 0.0
            let g = Double(colorCodeArr[1]) ?? 0.0
            let b = Double(colorCodeArr[2]) ?? 0.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorPickerButton.backgroundColor = color
            // self.shitfNoteTextView.placeholder = "Enter Shift Note"
            self.shitfNoteTextView.text = self.updateDetail.note
            self.addButton.setTitle("UPDATE", for: .normal)
            
            //         self.assignDDTextField.text = self.employeeName
            //            self.assignDDTextField.isUserInteractionEnabled = false
            //            self.assignDDBtn.isUserInteractionEnabled = false
        }
        else
        {
            let currentDateStr         = currentDate()
            self.dateTextField.text    = byDefaultDate //currentDateStr
            self.timeInTextField.text  = ""
            self.timeOutTextField.text = ""
            self.unpaidBreakTextField.text   = ""
            self.shitfNoteTextView.placeholder = "Enter Shift Note"
            self.addButton.setTitle("ADD", for: .normal)
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
                    let noOfOpening =  json["data"]["nubmer_of_opening"].stringValue
                    let noOfAssignedopening =  json["data"]["nubmer_of_assigned_opening"].stringValue
                    
                    self.numberOfOpening = Int(noOfOpening) ?? 1
                    self.numberOfAssignedOpening = Int(noOfAssignedopening) ?? 0
                    
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
                        self.preselectedIndices.removeAll()
                        for item in indicesOfMatchingData
                        {
                            self.preselectedIndices.insert(item)
                        }
                        ///*
                        var tagsStrArr = [String]()
                        for i in 0..<tagsArr.count
                        {
                            if let tagID = self.companyTagsArr.first(where: {$0.id == tagsArr[i]}) {
                                self.selectedTagIdsArr.append(tagID.id)
                                tagsStrArr.append(tagID.tag)
                            }
                        }
                        //*/
                        self.selectedTagIdsArr = self.selectedTagIdsArr.uniqued()
                        print(self.selectedTagIdsArr)
                        tagsStrArr = tagsStrArr.uniqued()
                        let selectedTagsStr = tagsStrArr.joined(separator: ",")
                        self.tagDDTextField.text = selectedTagsStr
                    }
                    let positionId =  json["data"]["position_id"].stringValue
                    if positionId != ""
                    {
                        var positionStr = ""
                        for i in 0..<self.companyPositionsArr.count
                        {
                            let id = self.companyPositionsArr[i].id
                            let positionName = self.companyPositionsArr[i].position
                            if  id == positionId {
                                positionStr = positionName
                                self.selectedPositionId = id
                            }
                        }
                        self.positionDDTextField.text = positionStr
                    }
                    self.selectedPositionId = positionId
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
    
    @IBAction func onTapAssignToDDBtn(_ sender: Any) {
        self.customEmployeeListView = CustomEmployeeListView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(self.customEmployeeListView)
    }
    @IBAction func onTapColorPickerBtn(_ sender: Any) {
        //self.customAddPositionView.removeFromSuperview()
        self.customColorPickerView = CustomColorPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.customColorPickerView.addColor1Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor2Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor3Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor4Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor5Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor6Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor7Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor8Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor9Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor10Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor11Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor12Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor13Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor14Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor15Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor16Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor17Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        self.customColorPickerView.addColor18Btn.addTarget(self, action: #selector(self.selectColorButtonPressed), for: .touchUpInside)
        
        
        self.view.addSubview(self.customColorPickerView)
        
    }
    @objc func selectColorButtonPressed(sender: UIButton) {
        
        var color = UIColor()
        switch sender.tag
        {
        case 1001:
            r = 0.0
            g = 255.0
            b = 255.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1002:
            r = 255.0
            g = 140.0
            b = 0.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1003:
            r = 188.0
            g = 143.0
            b = 143.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1004:
            r = 205.0
            g = 92.0
            b = 92.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1005:
            r = 0.0
            g = 0.0
            b = 255.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1006:
            r = 255.0
            g = 255.0
            b = 0.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1007:
            r = 255.0
            g = 0.0
            b = 255.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1008:
            //            r = 0.0
            //            g = 0.0
            //            b = 128.0
            r = 0.0
            g = 75.0
            b = 144.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1009:
            r = 0.0
            g = 128.0
            b = 128.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10010:
            r = 128.0
            g = 0.0
            b = 128.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10011:
            r = 0.0
            g = 128.0
            b = 0.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10012:
            r = 233.0
            g = 150.0
            b = 122.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10013:
            r = 220.0
            g = 20.0
            b = 60.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10014:
            //            r = 0.0
            //            g = 250.0
            //            b = 154.0
            r = 153.0
            g = 0.0
            b = 76.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10015:
            r = 0.0
            g = 255.0
            b = 127.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10016:
            r = 0.0
            g = 206.0
            b = 209.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(r),\(g),\(b))"
            break
        case 10017:
            r = 100.0
            g = 149.0
            b = 237.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10018:
            r = 47.0
            g = 79.0
            b = 79.0
            color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        default: break
        }
        self.colorPickerButton.backgroundColor = color
        self.customColorPickerView.removeFromSuperview()
    }
    @IBAction func onTapPositionDDBtn(_ sender: Any) {
        var selectItem = ""
        if self.isOpenFrom == "Update Open Shift"
        {
            // self.positionDDTextField.text ?? ""
            self.setupDropDown(arr: self.companyPositionsDDArr, showOn: self.positionDDTextField, alreadySelectedValue: selectItem)
            // Preselect the dropdown option during editing
            if let singleDDSelectedIndex = singleDDSelectedIndex {
                singleSelectionDropDown.clearSelection() // Clear any previous selection
                singleSelectionDropDown.selectRow(at: singleDDSelectedIndex)
            }
        }
        else
        {
            self.setupDropDown(arr: self.companyPositionsDDArr, showOn: self.positionDDTextField, alreadySelectedValue: "")
            
        }
        //        self.setupDropDown(arr: self.companyPositionsDDArr, showOn: self.positionDDTextField)
    }
    @IBAction func onTapTagDDBtn(_ sender: Any) {
        
        self.setupDropDownForMultipleSelection(arr: self.companyTagsDDArr, textfield: self.tagDDTextField)
    }
    func currentDate() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        //        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: date)
        return currentDate
    }
    @IBAction func onTapAddUpdateBtn(_ sender: Any) {
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "h:mm a"//"yyyy-MM-dd HH:mm:ss"
        //        let date = Date()
        //        let currentTimeStr = dateFormatter.string(from: date)
        
        let dateString  = Date().toString(dateFormat: "yyyy-MM-dd")
        let timeString  = Date().toString(dateFormat: "h:mm a")
        
        if (self.assignDDTextField.text == "Open Shift") && (self.noOfOpeningTextField.text == "")
        {
            showMessageAlert(message: "Please enter number of opening")
        }
        else if (self.assignDDTextField.text == "Open Shift") && (self.noOfOpeningTextField.text!.trimmingCharacters(in: .whitespaces) == "0")
        {
            showMessageAlert(message: "Please enter number of opening greater than 0.")
        }
        else if self.dateTextField.text == ""
        {
            showMessageAlert(message: "Please enter date")
        }
        else if self.timeInTextField.text == ""
        {
            showMessageAlert(message: "Please enter In Time")
        }
        else if self.timeOutTextField.text == ""
        {
            showMessageAlert(message: "Please enter Out Time")
        }
        else if self.unpaidBreakTextField.text == ""
        {
            showMessageAlert(message: "Please enter break duration in min's.")
        }
        else if (self.assignDDTextField.text == "Open Shift") && (self.positionDDTextField.text == "")
        {
            showMessageAlert(message: "Please select positions")
        }
        //        else if (self.assignDDTextField.text == "Open Shift") && (self.tagDDTextField.text == "")
        //        {
        //            showMessageAlert(message: "Please select tags")
        //        }
        //        else if self.shitfNoteTextView.text == ""
        //        {
        //            showMessageAlert(message: "Please enter Shift Note")
        //        }
        else if (self.dateTextField.text! == dateString) && (isTimeCompareFromCurrentTime(currentTimeStr: timeString, timeIn: self.timeInTextField.text!) == false)
        {
            showMessageAlert(message: "In time should be greater than current time")
        }
        //        else if (self.dateTextField.text! == dateString)
        //        {
        //            print(timeString)
        //            print(self.timeInTextField.text!)
        //            let isTime = isTimeCompareFromCurrentTime(currentTimeStr: "\(timeString)", timeIn: self.timeInTextField.text!)
        //            print(isTime)
        //            if isTime == false
        //            {
        //                showMessageAlert(message: "In time should be greater than current time")
        //            }
        //        }
        else if (Int(self.unpaidBreakTextField.text!) ?? 0) >= (Int(self.findTimeDiff(timeInStr: self.timeInTextField.text!, timeOutStr: self.timeOutTextField.text!)) ?? 0)
        //        else if (self.unpaidBreakTextField.text!) >= (self.findTimeDiff(timeInStr: self.timeInTextField.text!, timeOutStr: self.timeOutTextField.text!))
        {
            showMessageAlert(message:  "Please enter an unpaid break shorter than the shift duration.")
        }
        else
        {
            if isOpenFrom == "Update Open Shift"
            {
                let dateStr = self.dateTextField.text!
                let scheduleId = self.scheduleId
                let positionsStr = self.selectedPositionId
                let tagsStr = selectedTagIdsArr.joined(separator: ",")
                let checkInStr = getFormattedTimeStrSendInAPI(timeStr: self.timeInTextField.text!)
                let checkOutStr = getFormattedTimeStrSendInAPI(timeStr: self.timeOutTextField.text!)
                
                let noOfOpening = Int(self.noOfOpeningTextField.text!)
                if (noOfOpening ?? 1) < (self.numberOfAssignedOpening)
                {
                    showMessageAlert(message: "Number of openings should be greater than \(self.numberOfAssignedOpening)")
                }
                else
                {
                    self.updateSchedulerApi(employeeId: self.selectedEmployeeId, schedule_id: scheduleId, position_id: positionsStr, tags: tagsStr, date: dateStr, check_in: checkInStr, check_out: checkOutStr, break_duration: self.unpaidBreakTextField.text!, color_code: self.colorCode, note: self.shitfNoteTextView.text!, numberOfOpening: String(noOfOpening ?? 1))
                }
            }
            else  if isOpenFrom == "Update Employee Shift"
            {
                let dateStr = self.dateTextField.text!
                let checkInStr = getFormattedTimeStrSendInAPI(timeStr: self.timeInTextField.text!)
                let checkOutStr = getFormattedTimeStrSendInAPI(timeStr: self.timeOutTextField.text!)
                print(self.updateDetail.employee_id)
                let noOfOpening = Int(self.noOfOpeningTextField.text!)
                if (noOfOpening ?? 1) < (self.numberOfAssignedOpening)
                {
                    showMessageAlert(message: "Number of openings should be greater than \(self.numberOfAssignedOpening)")
                }
                else
                {
                    self.updateSchedulerApi(employeeId: self.updateDetail.employee_id, schedule_id: self.scheduleId,position_id: "0", tags: "0", date: dateStr, check_in: checkInStr, check_out: checkOutStr, break_duration: self.unpaidBreakTextField.text!, color_code: self.colorCode, note: self.shitfNoteTextView.text ?? "", numberOfOpening: String(noOfOpening ?? 1))
                }
            }
            else
            {
                var colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
                
                if r == 0.0 && g == 0.0 && b == 0.0
                {
                    colorCode = "(\(0),\(75),\(144))"
                }
                else
                {
                    colorCode = "\(colorCode)"
                }
                
                let positionsStr = self.selectedPositionId
                let tagsStr = selectedTagIdsArr.joined(separator: ",")
                let dateStr = self.dateTextField.text!
                let checkInStr = getFormattedTimeStrSendInAPI(timeStr: self.timeInTextField.text!)
                let checkOutStr = getFormattedTimeStrSendInAPI(timeStr: self.timeOutTextField.text!)
                print(colorCode)
                
                if self.assignDDTextField.text == "Open Shift"
                {
                    self.addSchedulerApi(employeeId: self.selectedEmployeeId, date: dateStr, checkIn: checkInStr, checkOut: checkOutStr, breakDuration: self.unpaidBreakTextField.text!, colorCode: colorCode, openingNo: self.noOfOpeningTextField.text!, note: self.shitfNoteTextView.text, positionId: positionsStr, tagId: tagsStr)
                }
                else
                {
                    self.addSchedulerApi(employeeId: self.selectedEmployeeId, date: dateStr, checkIn: checkInStr, checkOut: checkOutStr, breakDuration: self.unpaidBreakTextField.text!, colorCode: colorCode, openingNo: self.noOfOpeningTextField.text!, note: self.shitfNoteTextView.text, positionId: "0", tagId: "0")
                    
                    //                    self.updateSchedulerApi(employeeId: self.selectedEmployeeId, schedule_id: self.scheduleId,position_id: "0", tags: "0", date: dateStr, check_in: checkInStr, check_out: checkOutStr, break_duration: self.unpaidBreakTextField.text!, color_code: colorCode, note: self.shitfNoteTextView.text!, numberOfOpening: self.noOfOpeningTextField.text!)
                }
            }
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
    @objc func handleDateSelection()
    {
        let datePicker = UIDatePicker()
        
        let dateFormetter = DateFormatter()
        dateFormetter.dateStyle = .medium
        dateFormetter.timeStyle = .none
        self.dateTextField.text = dateFormetter.string(from: datePicker.date)
    }
    
    func changeDateTimeToGMT(checkInDateTimeStr: String, checkOutTimeStr: String) -> (convertedGMTDate: String, convertedGMTTime: String, convertedGMTCheckOutTime: String) {
        let gmtDateTime = gmtDateTimeStringFromCheckInString(dateStr: checkInDateTimeStr)
        let convertedDateArr = gmtDateTime.split(separator: " ")
        let convertedDate = String(convertedDateArr[0])
        let convertedCheckInTime = String(convertedDateArr[1])
        let convertedCheckOutTime = self.gmtTimeStringFromCheckOutString(dateStr: checkOutTimeStr)
        
        return (convertedDate, convertedCheckInTime, convertedCheckOutTime)
    }
    
    func checkEmployeeAvailityApi(employeeId:String, date: String, checkIn: String, checkOut: String, breakDuration:String, colorCode:String,openingNo:String,note:String, positionId:String, tagId:String)
    {
        let dateString = date + " " + checkIn
        let convertedDateStr = localToGMTDate(dateStr: dateString)
        let convertedCheckInStr = localToGMT(dateStr: checkIn)
        let convertedCheckOutStr = localToGMT(dateStr: checkOut)
        let fullUrl = BASE_URL + PROJECT_URL.CHECK_EMPLOYEE_AVAILITY_API
        if Reachability.isConnectedToNetwork() {
            
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["user_id": userId,"employee_id": employeeId,"date": convertedDateStr ?? "","check_in": convertedCheckInStr ?? "","check_out": convertedCheckOutStr ?? "","break_duration": breakDuration,"color_code": colorCode]
            
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    if self.isOpenFrom == "Update Employee Shift"
                    {
                        self.updateSchedulerApi(employeeId: self.selectedEmployeeId, schedule_id: self.scheduleId,position_id: "0", tags: "0", date: date, check_in: checkIn, check_out: checkOut, break_duration: breakDuration, color_code: colorCode, note: note, numberOfOpening: openingNo)
                    }
                    else
                    {
                        self.addSchedulerApi(employeeId: self.selectedEmployeeId, date: date, checkIn: checkIn, checkOut: checkOut, breakDuration: breakDuration, colorCode: colorCode, openingNo: openingNo, note: note, positionId: positionId, tagId: tagId)
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
    func showAlert(msg: String, datestr: String)
    {
        let Alert = UIAlertController(title: "Message", message: msg, preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewController(animated: true)
            let schedulerDateDataDict:[String: String] = ["date": datestr]
            //Post Notification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.SCHEDULE_CREATED_STATUS), object: nil, userInfo: schedulerDateDataDict)
        }))
        if let presenter = Alert.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        DispatchQueue.main.async {
            self.present(Alert, animated: true, completion: nil)
        }
    }
    func addSchedulerApi(employeeId:String, date: String, checkIn: String, checkOut: String, breakDuration:String, colorCode:String,openingNo:String,note:String, positionId:String, tagId:String)
    {
        let dateString = date + " " + checkIn
        let convertedDateStr = localToGMTDate(dateStr: dateString)
        let convertedCheckInStr = localToGMT(dateStr: checkIn)
        let convertedCheckOutStr = localToGMT(dateStr: checkOut)
        let fullUrl = BASE_URL + PROJECT_URL.ADD_SCHEDULER_API
        if Reachability.isConnectedToNetwork() {
            
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)else{return}
            
            showProgressOnView(appDelegateInstance.window!)
            
            var param = [String:Any]()
            if self.assignDDTextField.text == "Open Shift"
            {
                param = ["company_id":companyId, "user_id": userId,"employee_id": employeeId,"date": convertedDateStr ?? "", "check_in": convertedCheckInStr ?? "","check_out": convertedCheckOutStr ?? "","break_duration": breakDuration,"color_code": colorCode,"nubmer_of_opening":openingNo,"note":note, "position_id":positionId, "tags":tagId]
            }
            else
            {
                param = ["company_id":companyId, "user_id": userId,"employee_id": employeeId,"date": convertedDateStr ?? "","check_in": convertedCheckInStr ?? "", "check_out": convertedCheckOutStr ?? "","break_duration": breakDuration,"color_code": colorCode,"note":note,"position_id":"0"]
            }
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.showAlert(msg: json["message"].stringValue, datestr: date)
                    //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
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
    func updateSchedulerApi(employeeId:String,schedule_id:String, position_id:String, tags:String, date:String, check_in:String, check_out:String, break_duration:String, color_code:String, note:String, numberOfOpening:String)
    {
        let dateString = date + " " + check_in
        let convertedDateStr = localToGMTDate(dateStr: dateString)
        let convertedCheckInStr = localToGMT(dateStr: check_in)
        let convertedCheckOutStr = localToGMT(dateStr: check_out)
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_SCHEDULER_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            //  let param:[String:Any] = ["employee_id":employeeId, "schedule_id":schedule_id, "user_id": userId ,"position_id":position_id,"tags": tags,"date": convertedDateStr ?? "","check_in": convertedCheckInStr ?? "", "check_out": convertedCheckOutStr ?? "","break_duration": break_duration,"color_code": color_code, "note": note, "nubmer_of_opening": numberOfOpening]
            print(employeeId)
            var param = [String:Any]()
            if employeeId == "0"
            {
                param = ["employee_id":employeeId, "schedule_id":schedule_id, "user_id": userId ,"position_id":position_id,"tags": tags,"date": convertedDateStr ?? "","check_in": convertedCheckInStr ?? "", "check_out": convertedCheckOutStr ?? "","break_duration": break_duration,"color_code": color_code, "note": note, "nubmer_of_opening": numberOfOpening]
            }
            else
            {
                param = ["employee_id":employeeId, "schedule_id":schedule_id, "user_id": userId ,"position_id":position_id,"tags": tags,"date": convertedDateStr ?? "","check_in": convertedCheckInStr ?? "", "check_out": convertedCheckOutStr ?? "","break_duration": break_duration,"color_code": color_code, "note": note]
            }
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.showAlert(msg: json["message"].stringValue, datestr: date)
                    
                    //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
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
    
    func findTimeDiff(timeInStr: String, timeOutStr: String) -> String {
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "hh:mm a"
        guard let timeIn = timeformatter.date(from: timeInStr),
              let timeOut = timeformatter.date(from: timeOutStr) else { return "" }
        //You can directly use from here if you have two dates
        let interval = timeOut.timeIntervalSince(timeIn)
        //let hour = interval / 3600;
        //let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
        let intervalInt = Int(interval)
        //return "\(intervalInt < 0 ? "-" : "+") \(Int(hour)) Hours \(Int(minute)) Minutes"
        var timeInMinute = 0
        if intervalInt < 0
        {
            timeInMinute = (24*60) + (intervalInt/60)
        }
        else
        {
            timeInMinute = (intervalInt/60)
        }
        print("$$$$$$$$$$$$$$$$$$$$$$$$$ \(timeInMinute)")
        return "\(timeInMinute)"
    }
}
