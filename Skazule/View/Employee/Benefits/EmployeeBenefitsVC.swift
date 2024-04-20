//
//  EmployeeBenefitsVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 13/12/22.
//

import UIKit

class EmployeeBenefitsVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var tblBackView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var benefitsArr     = [BenefitsStruct]()
    
    //Custom View
    var customAddBenefitsView : CustomAddBenefitsView!
    
    // For Update Tags
    var isOpenFrom  = "Add"
    var benefitsId  = ""
    var benefit     = ""
    var employeePay = ""
    var premiumPay  = ""
    var companyPay  = ""
    var des         = ""
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customNavigationBar.titleLabel.text = "Benefits"
        self.customNavigationBar.customRightBarButton.isHidden = false
        self.customNavigationBar.customRightBarButton.setBackgroundImage(UIImage.init(named: "add_employee"), for: .normal)
        self.customNavigationBar.customRightBarButton.addTarget(self, action: #selector(onClickAddBenefitsBtn), for: .touchUpInside)
        
        tblView.register(UINib(nibName: "EmployeeShiftTempBenefitCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeShiftTempBenefitCell")
        self.getBenefitsApi()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
    }
    
    @objc func onClickAddBenefitsBtn(_ sender:UIButton)
    {
        self.isOpenFrom = "Add"
        self.showCustomAddBenefitsView()
    }
    func showCustomAddBenefitsView (){
        self.customAddBenefitsView = CustomAddBenefitsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        if self.isOpenFrom == "Edit"
        {
            self.customAddBenefitsView.benefitNameTextField.text = self.benefit
            self.customAddBenefitsView.premiumPayTextField.text = self.premiumPay
            self.customAddBenefitsView.companyPayTextField.text = self.companyPay
            self.customAddBenefitsView.employeePayTextField.text = self.employeePay
            self.customAddBenefitsView.desTextView.text = self.des
            self.customAddBenefitsView.headerTitleLbl.text = "Update Benefits"
            self.customAddBenefitsView.addButton.setTitle("UPDATE", for: .normal)
        }
        else
        {
            self.customAddBenefitsView.benefitNameTextField.text  = ""
            self.customAddBenefitsView.premiumPayTextField.text   = ""
            self.customAddBenefitsView.companyPayTextField.text   = ""
            self.customAddBenefitsView.employeePayTextField.text  = ""
            self.customAddBenefitsView.desTextView.text = ""
            self.customAddBenefitsView.desTextView.placeholder = "Enter Description"
            self.customAddBenefitsView.headerTitleLbl.text = "Add Benefits"
            self.customAddBenefitsView.addButton.setTitle("ADD", for: .normal)
        }
        self.customAddBenefitsView.addButton.addTarget(self, action: #selector(self.addBenefitsButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customAddBenefitsView)
    }
    @objc func addBenefitsButtonPressed(sender: UIButton) {
        
        if self.customAddBenefitsView.benefitNameTextField.text == ""
        {
            showMessageAlert(message: "Please enter benefit name")
        }
        else if self.customAddBenefitsView.premiumPayTextField.text == ""
        {
            showMessageAlert(message: "Please enter premium pay")
        }
        else if self.customAddBenefitsView.companyPayTextField.text == ""
        {
            showMessageAlert(message: "Please enter company pay")
        }
        else if self.customAddBenefitsView.employeePayTextField.text == ""
        {
            showMessageAlert(message: "Please enter employee pay")
        }
        else if self.customAddBenefitsView.desTextView.text == ""
        {
            showMessageAlert(message: "Please enter description")
        }
        else
        {
            self.customAddBenefitsView.removeFromSuperview()
            self.benefit     = self.customAddBenefitsView.benefitNameTextField.text!
            self.premiumPay  = self.customAddBenefitsView.premiumPayTextField.text!
            self.companyPay  = self.customAddBenefitsView.companyPayTextField.text!
            self.employeePay = self.customAddBenefitsView.employeePayTextField.text!
            self.des = self.customAddBenefitsView.desTextView.text
            
            if isOpenFrom == "Edit"
            {
                //self.updatePositionApi(tagId: self.tagId, tagStr: self.tag)
                self.updateShiftTemplateApi(benefitId: self.benefitsId,benefitName:self.benefit,premiumPay:self.premiumPay,companyPay:self.companyPay,employeePay:self.employeePay,desc:self.des)
            }
            else
            {
                self.createShiftTemplateApi(benefitName:self.benefit,premiumPay:self.premiumPay,companyPay:self.companyPay,employeePay:self.employeePay,desc:self.des)
            }
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
            //            let param:[String:Any] = [ "company_id": companyId]
            let param:[String:Any] = [ "page": "\(self.currentPageIndex)", "limit": "10","company_id": companyId]
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
                        self.benefitsArr.removeAll()
                    }
                    //self.benefitsArr.removeAll()
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
                    }
                }
                else {
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
                
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func createShiftTemplateApi(benefitName:String,premiumPay:String,companyPay:String,employeePay:String,desc:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.ADD_BENEFITS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["benefit":benefitName,"premium_pay":premiumPay,"company_pay":companyPay,"employee_pay":employeePay,"description":desc, "user_id": userId,"company_id":companyId]
            
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getBenefitsApi()
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
    
    func updateShiftTemplateApi(benefitId:String, benefitName:String,premiumPay:String,companyPay:String,employeePay:String,desc:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_BENEFITS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["benefit":benefitName,"premium_pay":premiumPay,"company_pay":companyPay,"employee_pay":employeePay,"description":desc, "user_id": userId,"company_id":companyId, "benefit_id":benefitId]
            
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getBenefitsApi()
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
    
    
    
    @objc func deleteBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.benefitsArr[index]
        let benefitsId = info.id
        if benefitsId != ""
        {
            self.deleteApiCall(benefitID: benefitsId)
        }
    }
    @objc func editBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.benefitsArr[index]
        let benefitsId = info.id
        if benefitsId != ""
        {
            self.isOpenFrom = "Edit"
            self.benefitsId = benefitsId
            self.benefit = info.benefit
            self.employeePay = info.employee_pay
            self.premiumPay = info.premium_pay
            self.companyPay = info.company_pay
            self.des = info.description
            self.showCustomAddBenefitsView()
        }
    }
    
    func deleteApiCall(benefitID:String)
    {
        let Alert = UIAlertController(title: "Alert", message: "Deleting a record will remove it from all employees linked to it. This record can not be recreated.\nAre you sure, You want to delete this benefits!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTagApi(benefitId: benefitID)
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
    
    func deleteTagApi(benefitId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_BENEFITS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "user_id": userId, "benefit_id":benefitId]
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getBenefitsApi()
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
extension EmployeeBenefitsVC : UITableViewDataSource, UITableViewDelegate
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
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        cell.editBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(editBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
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
        return 260
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.benefitsArr.count - 1) {
            if (self.benefitsArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getBenefitsApi()
            }
        }
    }
}
