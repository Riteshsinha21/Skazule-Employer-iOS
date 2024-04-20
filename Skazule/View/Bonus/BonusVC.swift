//
//  BonusVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit
import APJTextPickerView

class BonusVC: UIViewController, APJTextPickerViewDelegate {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var monthTxtField: UITextField!
    @IBOutlet weak var assignBonusBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var emptyView: UIImageView!
    
    @IBOutlet weak var fromDateTextField: APJTextPickerView!
    @IBOutlet weak var toDateTextField: APJTextPickerView!
    var fromDateStr = ""
    var toDateStr = ""
    let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    // For pagination  1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    var employeeBonusListArr = [BonusStruct]()
    var bonusIdArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customNavigationBar.titleLabel.text = "Bonus"
        tbleView.register(UINib(nibName: "EmployeeListTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeListTableCell")
        
        //Apjextextpicker
        self.fromDateTextField.pickerDelegate = self
        self.fromDateTextField.datePicker?.datePickerMode = .date
        self.fromDateTextField.dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.toDateTextField.pickerDelegate = self
        self.toDateTextField.datePicker?.datePickerMode = .date
        self.toDateTextField.dateFormatter.dateFormat = "yyyy-MM-dd"
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getEmployeeBonusListApi()
    }
    
    func textPickerView(_ textPickerView: APJTextPickerView, didSelectDate date: Date?) {
        guard let date = date else { return }
        print("Date Selected: \(date)")
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        
        switch textPickerView.tag
        {
        case 101:
            self.fromDateStr = dateStr
        case 102:
            self.toDateStr = dateStr
        default:
            print("")
        }
        
        if (self.fromDateStr != "") && (self.toDateStr != "")
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let firstDate = formatter.date(from: self.fromDateStr)
            let secondDate = formatter.date(from: self.toDateStr)
            
            //            if firstDate?.compare(secondDate!) == .orderedSame {
            //                print("Both dates are same")
            //            }
            //            if firstDate?.compare(secondDate!) == .orderedAscending {
            //                print("First Date is greater then second date")
            //            }
            //            if (firstDate?.compare(secondDate!) == .orderedDescending) || (firstDate?.compare(secondDate!) == .orderedSame) {
            if (firstDate?.compare(secondDate!) == .orderedDescending){
                showMessageAlert(message: "To Date should be greater than From Date")
            }
            else
            {
                self.getEmployeeBonusListApi(fromDate: self.fromDateStr, toDate: self.toDateStr)
            }
        }
    }
    
    func getEmployeeBonusListApi(fromDate: String? = nil, toDate: String? = nil)
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_BONUS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            //        from_date:2023-07-02 //optional
            //        to_date:2023-08-28  //optional
            showProgressOnView(appDelegateInstance.window!)
            //            let param:[String:Any] = ["page": "0","limit": "100","company_id": companyId, "search":""]
            //            print(param)
            
            var param = [String:Any]()
            if (fromDate != nil) && (toDate != nil)
            {
                param = [ "page": 0,"limit": "100","company_id": companyId,"from_date":fromDate!, "to_date":toDate!]
            }
            else
            {
                param = [ "page": 0,"limit": "100","company_id": companyId]
            }
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.employeeBonusListArr.removeAll()
                    
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue //4
                        var role =  json["data"][i]["role"].stringValue // 3
                        let color_code =  json["data"][i]["color_code"].stringValue //2
                        let profile_pic =  json["data"][i]["profile_pic"].stringValue
                        let position =  json["data"][i]["position"].stringValue
                        var employee_name =  json["data"][i]["employee_name"].stringValue //1
                        let email =  json["data"][i]["email"].stringValue
                        let employee_id =  json["data"][i]["employee_id"].stringValue
                        let c_code =  json["data"][i]["c_code"].stringValue
                        let status =  json["data"][i]["status"].stringValue //1
                        var bonus_amount =  json["data"][i]["bonus_amount"].stringValue
                        var description =  json["data"][i]["description"].stringValue
                        var mobile =  json["data"][i]["mobile"].stringValue
                        var approvedDate =  json["data"][i]["approved_at"].stringValue
                        
                        
                        if employee_name == ""
                        {
                            employee_name = "--"
                        }
                        if role == ""
                        {
                            role = "--"
                        }
                        if bonus_amount == ""
                        {
                            bonus_amount = "--"
                        }
                        if mobile == ""
                        {
                            mobile = "--"
                        }
                        if description == ""
                        {
                            description = "--"
                        }
                        if approvedDate == ""
                        {
                            approvedDate = "--"
                        }
                        self.employeeBonusListArr.append(BonusStruct.init(id: id, role: role, color_code: color_code, position: position, status: status, bonus_amount: bonus_amount, desc: description, mobile: mobile, c_code: c_code, employee_name: employee_name, employee_id: employee_id, profile_pic: profile_pic, email: email, checkBoxStatus: false, approvedDate: approvedDate))
                    }
                }
                else
                {
                    self.employeeBonusListArr.removeAll()
                    
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
                    if self.employeeBonusListArr.count == 0
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
    
    func approveBonusApi(bonusIdStr : String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.APPROVE_BONUS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["bonus_id": bonusIdStr,"company_id": companyId, "user_id":userId]
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.bonusApprovedAlert(msg: json["message"].stringValue)
                }
                else
                {
                    self.employeeBonusListArr.removeAll()
                    
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
    func bonusApprovedAlert(msg:String)
    {
        let Alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.getEmployeeBonusListApi()
        }))
        if let presenter = Alert.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        DispatchQueue.main.async {
            self.present(Alert, animated: true, completion: nil)
        }
    }
    @IBAction func onTapAssignBonusBtn(_ sender: Any) {
        let vc = AssignBonusVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onTapMonthCalenderBtn(_ sender: Any) {
    }
    @IBAction func onTapApproveBtn(_ sender: Any) {
        
        let bonusIdsStr = bonusIdArr.joined(separator: ",")
        print(bonusIdsStr)
        if bonusIdsStr == ""
        {
            showMessageAlert(message: "Please select Employee")
            
        }
        else
        {
            self.approveBonusApi(bonusIdStr: bonusIdsStr)
        }
    }
    @objc func checkBoxBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        var info = self.employeeBonusListArr
        var checkBoxStatus = info[index].checkBoxStatus
        checkBoxStatus = !checkBoxStatus
        info[index].checkBoxStatus = checkBoxStatus
        var bonusId = info[index].id
        if checkBoxStatus == true
        {
            bonusIdArr.append(bonusId)
        }
        else
        {
            if let index = bonusIdArr.firstIndex(of: bonusId) {
                bonusIdArr.remove(at: index)
            }
        }
        print(bonusIdArr)
        self.employeeBonusListArr = info
        self.tbleView.reloadData()
    }
}
extension BonusVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeBonusListArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeListTableCell") as! EmployeeListTableCell
        cell.selectionStyle = .none
        let info = self.employeeBonusListArr[indexPath.row]
        cell.nameTextField.text = info.employee_name
        cell.roleTextField.text = info.role
        cell.mobileTextField.text = "Contact Number : \(info.mobile)"
        cell.tagTextField.text = "Paid Bonus : \(cuurrencyStr)\(info.bonus_amount)"
        //cell.shiftNameTextField.text = "Des : \(info.desc)"
        cell.shiftNameTextField.text = "Approved at : \(info.approvedDate)"
        
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        cell.employeeProfilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        
        if info.status == "1"
        {
            cell.assignImgView.isHidden = false
            cell.checkBoxBtn.isHidden  = true
        }
        else
        {
            cell.assignImgView.isHidden = true
            cell.checkBoxBtn.isHidden  = false
        }
        if info.checkBoxStatus == true
        {
            let image = UIImage(named: "checked") as UIImage?
            cell.checkBoxBtn.setImage(image, for: .normal)
        }
        else
        {
            let image = UIImage(named: "checkbox") as UIImage?
            cell.checkBoxBtn.setImage(image, for: .normal)
        }
        cell.checkBoxBtn.tag = indexPath.row
        cell.checkBoxBtn.addTarget(self, action: #selector(checkBoxBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = BonusDetailVC()
        vc.bonusDetail = self.employeeBonusListArr[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
