//
//  CustomAppliedShiftEmployeeListView.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 08/05/23.
//

import UIKit
import IQKeyboardManagerSwift

class CustomAppliedShiftEmployeeListView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var view: UIView!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var emptyView: UIImageView!
    
    @IBOutlet weak var tableBackView: UIView!
    var employeeListArr = [AssignEmployeeListStruct]()
    var scheduleID = ""
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
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomAppliedShiftEmployeeListView", bundle: bundle)
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
    
    @IBAction func onTapCancelBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    
    @IBAction func onTapConfirmBtn(_ sender: Any) {
        
        //        self.employeeIdArr.removeAll()
        var scheduledEmployeeArr = [String]()
        for i in 0..<self.employeeListArr.count
        {
            let checkStatus = self.employeeListArr[i].checkBoxSelected
            let checkStatusId = self.employeeListArr[i].employee_id
            if checkStatus
            {
                employeeIdArr.append(checkStatusId)
            }
            let scheduleStatus = self.employeeListArr[i].schedule_status
            if scheduleStatus == "1"
            {
                scheduledEmployeeArr.append("true")
            }
            
        }
        print(employeeIdArr.count)
        
        print(employeeIdArr)//
        if self.employeeIdArr.count > 0
        {
            var employeeIdStr = ""
            employeeIdStr = employeeIdArr.joined(separator: ",") //json(from: self.employeeIdArr)!
            self.confirmEmployeeShiftApi(scheduleId: self.scheduleID, employeeId: employeeIdStr)
        }
        else if (self.employeeListArr.count == scheduledEmployeeArr.count)
        {
            showMessageAlert(message: "No employee has applied.")
        }
        else
        {
            showMessageAlert(message: "Please select atleast one employee")
        }
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
        if info.schedule_status == "1"
        {
            cell.assignImgView.isHidden = false
            cell.employeeCheckBox.isHidden  = true
        }
        else
        {
            cell.assignImgView.isHidden = true
            cell.employeeCheckBox.isHidden  = false
        }
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
//    {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTableCell") as! EmployeeTableCell
//        cell.selectionStyle = .none
//        cell.employeeLeftSideImgView.isHidden = true
//        cell.employeeCheckBox.isHidden = false
//        let info = self.employeeListArr[indexPath.row]
//        cell.titleLbl.text = "\(info.name)"
//
//        if info.schedule_status == "1"
//        {
//            cell.assignImgView.isHidden = false
//            cell.employeeCheckBox.isHidden  = true
//        }
//        else
//        {
//            cell.assignImgView.isHidden = true
//            cell.employeeCheckBox.isHidden  = false
//        }
////        if (info.checkBoxSelected == true)
////        {
////            let image = UIImage(named: "checked") as UIImage?
////            cell.employeeCheckBox.setImage(image, for: .normal)
////        }
////        else if (info.checkBoxSelected == false)
////        {
////            let image = UIImage(named: "checkbox") as UIImage?
////            cell.employeeCheckBox.setImage(image, for: .normal)
////        }
//        cell.employeeCheckBox.tag = indexPath.row
//        cell.employeeCheckBox.addTarget(self, action: #selector(employeeCheckBoxBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
//
//        return cell
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70 //UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func confirmEmployeeShiftApi(scheduleId:String,employeeId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.CONFIRM_SCHEDULE_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["schedule_id":scheduleId,"user_id": userId,"employee_id":employeeId]
            
            print(param)
            //var imageUrl:URL?
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                //            ServerClass.sharedInstance.sendMultipartRequestToServer(urlString: fullUrl, fileName: "", param, imageUrl: imageUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYEE_SHIFT_STATUS), object: nil)
                    self.removeFromSuperview()
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
    
    
}

