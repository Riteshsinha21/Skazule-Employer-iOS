//
//  CustomEmployeeListDocShareView.swift
//  Skazule
//
//  Created by ChawTech Solutions on 21/03/23.
//

import UIKit
import IQKeyboardManagerSwift

protocol cancelCustomEmployeeListDocShareViewCustomDelegate {
    func alertFromCancelPopUp(Message: String)
}

struct EmployeeNameIdsStruct{
    var name: String = ""
    var employeeId: String = ""
    var checkBoxSelected : Bool
}

class CustomEmployeeListDocShareView: UIView, UITableViewDataSource, UITableViewDelegate {
    var view: UIView!
    var delegate: cancelCustomEmployeeListDocShareViewCustomDelegate?
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var emptyView: UIImageView!
    @IBOutlet weak var shareBtnBackView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var slectAllCheckBoxBtn: UIButton!
    
    var employeeID = "0"
    var employeeNameSelected = ""
    
    var employeeListArr = [EmployeeNameIdsStruct]()
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    var employeeIdArr = [String]()
    
    
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
        self.getEmployeeListApi()
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomEmployeeListDocShareView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                //self.view.frame.origin.y -= keyboardSize.height - 140
                self.view.frame.origin.y -= keyboardSize.height - 240
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
            let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId, "search":"\(searchStr)"]
            
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.employeeListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let name =  json["data"][i]["name"].stringValue
                        let employee_id =  json["data"][i]["employee_id"].stringValue
                        self.employeeListArr.append(EmployeeNameIdsStruct.init(name: name, employeeId: employee_id,checkBoxSelected: false))
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
                        self.shareBtnBackView.isHidden = true
                    }
                    else
                    {
                        self.tbleView.isHidden = false
                        self.emptyView.isHidden = true
                        self.shareBtnBackView.isHidden = false
                        
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
    
    @IBAction func onTapSelectAllBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var info = self.employeeListArr
        if sender.isSelected
        {
            for i in 0..<info.count
            {
                info[i].checkBoxSelected = true
                let checkStatusId = info[i].employeeId
                employeeIdArr.append(checkStatusId)
            }
            print(employeeIdArr)
        }
        else
        {
            for i in 0..<info.count
            {
                info[i].checkBoxSelected = false
            }
            self.employeeIdArr.removeAll()
        }
        print(employeeIdArr.count)
        self.employeeListArr = info
        self.tbleView.reloadData()
        
    }
    
    @IBAction func shareDocButtonPressed(sender: UIButton) {
        
        self.employeeIdArr.removeAll()
        for i in 0..<self.employeeListArr.count
        {
            let checkStatus = self.employeeListArr[i].checkBoxSelected
            let checkStatusId = self.employeeListArr[i].employeeId
            if checkStatus
            {
                employeeIdArr.append(checkStatusId)
            }
        }
        print(employeeIdArr.count)
        
        print(employeeIdArr)//
        if self.employeeIdArr.count > 0
        {
            var employeeIdStr = ""
            employeeIdStr = employeeIdArr.joined(separator: ",") //json(from: self.employeeIdArr)!
            
            let employeeDataDict:[String: String] = ["employeeName": "", "employeeId": employeeIdStr]
            //Post Notification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil, userInfo: employeeDataDict)
            self.removeFromSuperview()
        }
        else
        {
            showMessageAlert(message: "Please select atleast one employee")
        }
    }
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    @objc func employeeCheckBoxBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        var info = self.employeeListArr
        
        sender.isSelected = !sender.isSelected
        info[index].checkBoxSelected = sender.isSelected
        self.employeeListArr = info
        self.tbleView.reloadData()
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
        cell.employeeCheckBox.isHidden = false
        //cell.titleLeadingHeightConstraint.constant = 15
        
        let info = self.employeeListArr[indexPath.row]
        cell.titleLbl.text = info.name
        
        if info.checkBoxSelected == true
        {
            cell.employeeCheckBox.isSelected = true
        }
        else
        {
            cell.employeeCheckBox.isSelected = false
        }
        
        cell.employeeCheckBox.tag = indexPath.row
        cell.employeeCheckBox.addTarget(self, action: #selector(employeeCheckBoxBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //        let info = self.employeeListArr[indexPath.row]
        //        self.employeeID = info.employeeId
        //        self.employeeNameSelected = info.name
        //
        //        let employeeDataDict:[String: String] = ["employeeName": self.employeeNameSelected, "employeeId": self.employeeID]
        //        //Post Notification
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil, userInfo: employeeDataDict)
        //        self.removeFromSuperview()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70 //UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    @IBAction func onTapOpenShiftBtn(_ sender: Any) {
        
        //        let employeeDataDict:[String: String] = ["employeeName": "Open Shift", "employeeId": "0"]
        //        //Post Notification
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil, userInfo: employeeDataDict)
        //        self.removeFromSuperview()
    }
    
}
extension CustomEmployeeListDocShareView: UITextFieldDelegate {
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
