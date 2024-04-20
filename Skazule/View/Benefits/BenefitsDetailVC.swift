//
//  BenefitsDetailVC.swift
//  Skazule
//
//  Created by Chawtech on 24/01/23.
//

import UIKit

class BenefitsDetailVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var employeeNameLbl: UILabel!
    @IBOutlet weak var employeePhoneNumberLbl: UILabel!
    @IBOutlet weak var employeeEmailLbl: UILabel!
    
    @IBOutlet weak var tblBackView: UIView!
    @IBOutlet weak var tblBackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var employeeBenefitsDetail = BenefitsListStruct()
    var benefitsArr        = [BenefitsStruct]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.customNavigationBar.titleLabel.text = "Benefits Details"
        tblView.register(UINib(nibName: "EmployeeShiftTempBenefitCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeShiftTempBenefitCell")
        self.setBenefitsDetail()
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
                self.tblBackViewHeightConstraint.constant = newsize.height
            }
        }
    }
    func setBenefitsDetail()
    {
        let info = employeeBenefitsDetail
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        self.profilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        
        self.employeeNameLbl.text               = "\(info.employee_name)"
        self.employeePhoneNumberLbl.text         = "\(info.mobile)"
        self.employeeEmailLbl.text              = "\(info.email)"
        
        //        DispatchQueue.main.async {
        //            if self.benefitsArr.count == 0
        //            {
        //                self.tblBackView.isHidden = true
        //                self.emptyView.isHidden = false
        //            }
        //            else
        //            {
        //                self.tblBackView.isHidden = false
        //                self.emptyView.isHidden = true
        //            }
        //            self.tblView.reloadData()
        //        }
        
        
        
        self.getEmployeeBenefitsListApi(employeeId: employeeBenefitsDetail.employee_id)
        
        
        
        
        
    }
    func getEmployeeBenefitsListApi(employeeId:String)
    {
        //employee_id:118
        let fullUrl = BASE_URL + PROJECT_URL.GET_BENEFITS_DETAIL_API
        if Reachability.isConnectedToNetwork() {
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["employee_id": employeeId]
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.benefitsArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id          =  json["data"][i]["id"].stringValue
                        let benefit     =  json["data"][i]["benefit"].stringValue
                        let description =  json["data"][i]["description"].stringValue
                        let premium_pay =  json["data"][i]["premium_pay"].stringValue
                        let company_pay =  json["data"][i]["company_pay"].stringValue
                        let employee_pay =  json["data"][i]["employee_pay"].stringValue
                        let gross_pay   =  json["data"][i]["gross_pay"].stringValue
                        self.benefitsArr.append(BenefitsStruct.init(id: id, benefit: benefit, description: description, premium_pay: premium_pay, company_pay: company_pay, employee_pay: employee_pay, gross_pay: gross_pay))
                    }
                    
                    DispatchQueue.main.async {
                        if self.benefitsArr.count == 0
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
                }
                else
                {
                    self.benefitsArr.removeAll()
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
                //                DispatchQueue.main.async {
                //                    if self.benefitsListArr.count == 0
                //                    {
                //                        self.tbleView.isHidden = true
                //                        self.emptyView.isHidden = false
                //                    }
                //                    else
                //                    {
                //                        self.tbleView.isHidden = false
                //                        self.emptyView.isHidden = true
                //                    }
                //                    self.tbleView.reloadData()
                //                }
                
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
        let info = self.benefitsArr[index]
        let benefitsId = info.id
        if benefitsId != ""
        {
            self.deleteApiCall(idStr: benefitsId)
        }
    }
    func deleteApiCall(idStr:String)
    {
        let Alert = UIAlertController(title: "Alert", message: "Are you sure, You want to delete this benefits!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTagApi(id: idStr)
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
    
    func deleteTagApi(id:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_SINGLE_BENEFITS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "user_id": userId, "id":id]
            
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getEmployeeBenefitsListApi(employeeId: self.employeeBenefitsDetail.employee_id)
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
extension BenefitsDetailVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.benefitsArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeShiftTempBenefitCell") as! EmployeeShiftTempBenefitCell
        cell.selectionStyle = .none
        cell.shiftTempBackView.isHidden  = true
        
        let info = self.benefitsArr[indexPath.row]
        
        cell.shiftNameLbl.text     = "\(info.benefit)"
        cell.premiumPayLbl.text    = "\(cuurrencyStr)\(info.premium_pay)"
        cell.companyPayLbl.text    = "\(cuurrencyStr)\(info.company_pay)"
        cell.employeePayLbl .text  = "\(cuurrencyStr)\(info.employee_pay)"
        cell.desLbl .text          = "\(info.description)"
        cell.deleteBtn.isHidden    = false
        cell.editBtn.isHidden      = true
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        //        cell.editBtn.tag = indexPath.row
        //        cell.editBtn.addTarget(self, action: #selector(editBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
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
}
