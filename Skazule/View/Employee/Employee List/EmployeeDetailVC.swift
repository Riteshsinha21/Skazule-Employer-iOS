//
//  EmployeeDetailVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 19/12/22.
//

import UIKit

class EmployeeDetailVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var employeeNameLbl: UILabel!
    @IBOutlet weak var employeePhoneNumberLbl: UILabel!
    @IBOutlet weak var employeeEmailLbl: UILabel!
    
    @IBOutlet weak var shiftTemplateLbl: UILabel!
    @IBOutlet weak var shiftTemplateTopBackView: UIView!
    @IBOutlet weak var tagTopBackView: UIView!
    @IBOutlet weak var benefitsTopBackView: UIView!
    @IBOutlet weak var tagCardBackView: CardView!
    @IBOutlet weak var benefitsCardBackView: CardView!
    
    @IBOutlet weak var shiftNameLbl: UILabel!
    @IBOutlet weak var breakDurationLbl: UILabel!
    @IBOutlet weak var positionLbl: UILabel!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var tagLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    
    var employeeDetail = EmployeeListStruct()
    var employeeBenefitsArr = [BenefitsStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customNavigationBar.titleLabel.text = "Employee Details"
        tblView.register(UINib(nibName: "EmployeeDetailBenefitsCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeDetailBenefitsCell")
        
        print(employeeDetail)
        self.setEmployeeDetail()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.shiftTemplateTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        self.tagTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        self.benefitsTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tblView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tblView.removeObserver(self, forKeyPath: "contentSize")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"
        {
            if let newValue = change?[.newKey]
            {
                let newsize = newValue as! CGSize
                self.tblViewHeightConstraint.constant = newsize.height
            }
        }
    }
    func setEmployeeDetail()
    {
        let info = employeeDetail
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        self.profilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        
        self.employeeNameLbl.text               = "\(info.name)"
        //        self.employeePhoneNumberLbl.text         = "\(info.mobile)"
        self.employeePhoneNumberLbl.text         = "\(info.c_code) \(info.mobile)"
        self.employeeEmailLbl.text              = "\(info.email)"
        
        //        let checkInStr = getFormattedTimeStr(timeStr: info.check_in)
        //        let checkOutStr = getFormattedTimeStr(timeStr: info.check_out)
        let checkInStr = gmtToLocal(dateStr: info.check_in)
        let checkOutStr = gmtToLocal(dateStr: info.check_out)
        
        if checkInStr == "" && checkOutStr == ""
        {
            self.shiftTemplateLbl.text      = "Shift Templates : --"
        }
        else
        {
            self.shiftTemplateLbl.text      = "Shift Templates : \(checkInStr ?? "-") - \(checkOutStr ?? "-")"
        }
        if info.shift_name == ""
        {
            self.shiftNameLbl.text      = "--"
        }
        else
        {
            self.shiftNameLbl.text      = "\(info.shift_name)"
        }
        //       self.shiftNameLbl.text      = "\(checkInStr ?? "")-\(checkOutStr ?? "")"
        
        self.breakDurationLbl.text   = "\(info.break_duration)"
        self.positionLbl.text       = "\(info.position)"
        self.roleLbl.text           = "\(info.role)"
        if info.tag == ""
        {
            self.tagCardBackView.isHidden = true
        }
        else
        {
            self.tagCardBackView.isHidden = false
            self.tagLbl.text            = "\(info.tag)"
        }
        let employeeID = info.id
        if employeeID != ""
        {
            getEmployeeDetailApi(employeeId: employeeDetail.id)
        }
    }
    func getEmployeeDetailApi(employeeId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_DETAIL_API
        if Reachability.isConnectedToNetwork() {
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "employee_id": employeeId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.employeeBenefitsArr.removeAll()
                    for i in 0..<json["data"]["benefits"].count
                    {
                        let id =  json["data"]["benefits"][i]["id"].stringValue
                        let benefit =  json["data"]["benefits"][i]["benefit"].stringValue
                        let description =  json["data"]["benefits"][i]["description"].stringValue
                        let premium_pay =  json["data"]["benefits"][i]["premium_pay"].stringValue
                        let company_pay =  json["data"]["benefits"][i]["company_pay"].stringValue
                        let employee_pay =  json["data"]["benefits"][i]["employee_pay"].stringValue
                        let gross_pay =  json["data"]["benefits"][i]["gross_pay"].stringValue
                        
                        self.employeeBenefitsArr.append(BenefitsStruct.init(id: id, benefit: benefit, description: description, premium_pay: premium_pay, company_pay: company_pay, employee_pay: employee_pay, gross_pay: gross_pay))
                    }
                }
                else {
                    self.employeeBenefitsArr.removeAll()
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
                    if self.employeeBenefitsArr.count == 0
                    {
                        self.benefitsCardBackView.isHidden = true
                    }
                    else
                    {
                        self.benefitsCardBackView.isHidden = false
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
    
    @objc func expendableBtnClicked(sender:UIButton)
    {
        sender.isSelected = !sender.isSelected
        let cell = (sender.superview?.superview?.superview?.superview?.superview as? EmployeeDetailBenefitsCell) // track your cell here
        
        if sender.isSelected == true
        {
            cell?.benefitsDetailBackView.isHidden = false
        }
        else
        {
            cell?.benefitsDetailBackView.isHidden = true
        }
        self.tblView.beginUpdates()
        self.tblView.endUpdates()
    }
    
}
extension EmployeeDetailVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeBenefitsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeDetailBenefitsCell") as! EmployeeDetailBenefitsCell
        cell.selectionStyle = .none
        let info = self.employeeBenefitsArr[indexPath.row]
        
        if info.benefit == ""
        {
            cell.BenefitNameLbl.text  = "--"
        }
        else
        {
            cell.BenefitNameLbl.text  = "\(info.benefit)"
        }
        if info.premium_pay == ""
        {
            cell.premiumPayLbl.text    = ":     --"
        }
        else
        {
            cell.premiumPayLbl.text    = ":     \(cuurrencyStr)\(info.premium_pay)"
        }
        
        if info.company_pay == ""
        {
            cell.companyPayLbl.text    = ":     --"
        }
        else
        {
            cell.companyPayLbl.text    = ":     \(cuurrencyStr)\(info.company_pay)"
        }
        
        if info.employee_pay == ""
        {
            cell.employeePayLbl .text  = ":     --"
        }
        else
        {
            cell.employeePayLbl .text  = ":     \(cuurrencyStr)\(info.employee_pay)"
        }
        cell.rightDownArrowBtn.tag = indexPath.row
        cell.rightDownArrowBtn.addTarget(self, action: #selector(expendableBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //        let vc = EmployeeDetailVC()
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
