//
//  CustomEmployeeListView.swift
//  Skazule
//
//  Created by ChawTech Solutions on 09/03/23.
//

import UIKit
import IQKeyboardManagerSwift

protocol cancelCustomEmployeeListViewCustomDelegate {
    func alertFromCancelPopUp(Message: String)
}

struct EmployeeNameIdListStruct{
    var name: String       = ""
    var employeeId: String = ""
    var checkIn: String    = ""
    var checkOut: String   = ""
}

class CustomEmployeeListView: UIView, UITableViewDataSource, UITableViewDelegate {
    var view: UIView!
    var delegate: cancelCustomEmployeeListViewCustomDelegate?
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var openShiftBtn: UIButton!
    
    @IBOutlet weak var openShiftBackView: UIView!
    
    var employeeID = "0"
    var employeeNameSelected = ""
    
    var employeeListArr = [EmployeeNameIdListStruct]()
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        //        let roundViewHeight : Int = upperRoundViewHeight
        //        upperRoundView.layer.cornerRadius = roundViewHeight/2
        
        // 3. Setup view from .xib file
        xibSetup()
        tbleView.delegate = self
        tbleView.dataSource = self
        tbleView.register(UINib(nibName: "EmployeeTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeTableCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        IQKeyboardManager.shared.enable = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // use bounds not frame or it'll be offset
        view.frame = bounds
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        currentPageIndex = 0
        self.getEmployeeListApi()
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomEmployeeListView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 140
                //self.view.frame.origin.y -= keyboardSize.height - 300
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    func getEmployeeListApi(searchText: String? = nil, searchFields: String? = nil)
    {
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_LIST_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            
            var param:[String:Any] = [:]
            if (searchStr != "")
            {
                param = ["page": 0,"company_id": companyId, "search":"\(searchStr)"]
                self.currentPageIndex = 0
            }
            else
            {
                param = ["page": "\(self.currentPageIndex)","limit": "10","company_id": companyId, "search":"\(searchStr)"]
            }
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
                        self.employeeListArr.removeAll()
                    }
                    //self.employeeListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let name =  json["data"][i]["name"].stringValue
                        let employee_id =  json["data"][i]["employee_id"].stringValue
                        let checkIn =  json["data"][i]["check_in"].stringValue
                        let checkOut =  json["data"][i]["check_out"].stringValue
                        
                        self.employeeListArr.append(EmployeeNameIdListStruct.init(name: name, employeeId: employee_id, checkIn: checkIn , checkOut: checkOut))
                    }
                }
                else {
                    self.employeeListArr.removeAll()
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
                        //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
                DispatchQueue.main.async {
                    if self.employeeListArr.count == 0
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
            self.getEmployeeListApi()
        }
    }
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        self.currentSearchFieldsText = nil
        self.currentSearchText = sender.text
        self.getEmployeeListApi(searchText: sender.text!)
    }
    
    @IBAction func onTapCancelBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTableCell") as! EmployeeTableCell
        cell.selectionStyle = .none
        cell.employeeLeftSideImgView.isHidden = true
        //cell.titleLeadingHeightConstraint.constant = 15
        let info = self.employeeListArr[indexPath.row]
        //        let checkInTime = gmtToLocal(dateStr: info.checkIn)
        //        let checkOutTime = gmtToLocal(dateStr: info.checkOut)
        //        cell.titleLbl.text = "\(info.name) (\(checkInTime ?? "") - \(checkOutTime ?? ""))"
        cell.titleLbl.text = "\(info.name)"
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let info = self.employeeListArr[indexPath.row]
        self.employeeID = info.employeeId
        self.employeeNameSelected = info.name
        let checkInTime = gmtToLocal(dateStr: info.checkIn)
        let checkOutTime = gmtToLocal(dateStr: info.checkOut)
        let shiftTime = "\(checkInTime ?? "") - \(checkOutTime ?? "")"
        
        //        let employeeDataDict:[String: String] = ["employeeName": self.employeeNameSelected, "employeeId": self.employeeID]
        let employeeDataDict:[String: String] = ["employeeName": self.employeeNameSelected, "employeeId": self.employeeID, "shiftTime":shiftTime]
        //Post Notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil, userInfo: employeeDataDict)
        self.removeFromSuperview()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70 //UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.employeeListArr.count - 1) {
            if (self.employeeListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getEmployeeListApi()
            }
        }
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    //    {
    //        let customView = HeaderView()
    //        customView.backgroundColor = .white
    //        customView.titleLblBackView.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9137254902, blue: 0.9843137255, alpha: 1)
    //        customView.titleLblBackView.cornerRadius = 10
    //        customView.titlelabel.text = "Open Shift"
    //        customView.rightBtn.tag = section
    //        customView.rightBtn.isHidden = true
    //
    ////        customView.rightBtn.setImage(UIImage.init(named: "addNew"), for: .normal)
    ////        customView.rightBtn.addTarget(self, action: #selector(addEmployeeBtnClicked), for: .touchUpInside)
    //        customView.titlelabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    //        return customView
    //    }
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    //    {
    //        return 70
    //        //return .leastNonzeroMagnitude
    //    }
    
    @IBAction func onTapOpenShiftBtn(_ sender: Any) {
        
        let employeeDataDict:[String: String] = ["employeeName": "Open Shift", "employeeId": "0"]
        //Post Notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil, userInfo: employeeDataDict)
        self.removeFromSuperview()
    }
    
}
extension CustomEmployeeListView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentSearchText = textField.text
        self.currentSearchFieldsText = nil
        self.getEmployeeListApi(searchText: textField.text!)
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
