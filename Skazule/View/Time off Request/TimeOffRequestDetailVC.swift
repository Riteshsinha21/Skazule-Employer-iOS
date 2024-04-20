//
//  TimeOffRequestDetailVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 20/03/23.
//

import UIKit

class TimeOffRequestDetailVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var employeeNameLbl: UILabel!
    @IBOutlet weak var employeePhoneNumberLbl: UILabel!
    @IBOutlet weak var employeeEmailLbl: UILabel!
    
    @IBOutlet weak var rollTypeBackView: UIView!
    @IBOutlet weak var rollTypeLbl: UILabel!
    @IBOutlet weak var requestTypeLbl: UILabel!
    @IBOutlet weak var leaveNoteLbl: UILabel!
    @IBOutlet weak var appliedAtLbl: UILabel!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var requestDateLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var approveRejectBackView: UIView!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    
    var employeeLeaveDetail = EmployeeLeaveListStruct()
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rollTypeBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        self.customNavigationBar.titleLabel.text = "Request Detail"
        self.setEmployeeLeaveDetail()
        //        print(employeeDetail)
        //        self.setEmployeeDetail()
    }
    func setEmployeeLeaveDetail()
    {
        let info = employeeLeaveDetail
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        self.profilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        self.employeeNameLbl.text               = "\(info.employee_name)"
        self.employeePhoneNumberLbl.text         = "\(info.mobile)"
        self.employeeEmailLbl.text              = "\(info.email)"
        
        
        self.rollTypeLbl.text              = "Roll : \(info.role)"
        self.requestTypeLbl.text              = "\(info.leave_type)"
        self.leaveNoteLbl.text              = "\(info.description)"
        if info.status == "0"
        {
            self.statusLbl.text = "Pending"
            self.statusLbl.textColor = .orange
            self.approveRejectBackView.isHidden = false
            
        }
        else if info.status == "1"
        {
            self.statusLbl.text = "Approved"
            self.statusLbl.textColor = .systemGreen
            self.approveRejectBackView.isHidden = true
        }
        else if info.status == "3"
        {
            self.statusLbl.text = "Rejeted"
            self.statusLbl.textColor = .red
            self.approveRejectBackView.isHidden = true
            
        }
        if info.role == ""
        {
            self.rollTypeLbl.text      = "--"
        }
        
        let iD = info.id
        if iD != ""
        {
            self.getEmployeeLeaveDetailApi(id: iD)
        }
    }
    @IBAction func onTapRejectBtn(_ sender: Any) {
        let urlStr = PROJECT_URL.REJECT_LEAVE_REQUST_API
        self.getLeaveStatusChangeApi(id: self.id, url: urlStr)
    }
    
    @IBAction func approveBtn(_ sender: Any) {
        let urlStr = PROJECT_URL.APPROVE_LEAVE_REQUST_API
        self.getLeaveStatusChangeApi(id: self.id, url: urlStr)
        
    }
    func getEmployeeLeaveDetailApi(id:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.VIEW_LEAVE_REQUST_API
        if Reachability.isConnectedToNetwork() {
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "id": id]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let start_date =  json["data"]["start_date"].stringValue
                    let end_date =  json["data"]["end_date"].stringValue
                    let created_at =  json["data"]["created_at"].stringValue
                    let leave_count =  json["data"]["leave_count"].stringValue
                    let id =  json["data"]["id"].stringValue
                    self.id = id
                    
                    //                    let appliedAtStr = getFormattedTimeStr(timeStr: created_at)
                    //                    let fromDateStr = getFormattedTimeStr(timeStr: start_date)
                    //                    let toDateStr = getFormattedTimeStr(timeStr: end_date)
                    
                    if created_at == ""
                    {
                        self.appliedAtLbl.text      = "--"
                    }
                    else
                    {
                        let appliedDateTime = gmtToLocalWithDate(dateStr: created_at)
                        self.appliedAtLbl.text  = "\(appliedDateTime ?? "--")"
                        //                        self.appliedAtLbl.text  = "\(created_at)"
                    }
                    if start_date == ""
                    {
                        self.fromDateLbl.text   = "--"
                    }
                    else
                    {
                        self.fromDateLbl.text   = "\(start_date)"
                        
                    }
                    if end_date == ""
                    {
                        self.toDateLbl.text      = "--"
                    }
                    else
                    {
                        self.toDateLbl.text      = "\(end_date)"
                        
                    }
                    if leave_count != ""
                    {
                        self.requestDateLbl.text    = "\(leave_count) days"
                    }
                    else
                    {
                        self.requestDateLbl.text    = "0 days"
                        
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
    func getLeaveStatusChangeApi(id:String,url:String)
    {
        let fullUrl = BASE_URL + url
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "id": id, "user_id": userId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
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
