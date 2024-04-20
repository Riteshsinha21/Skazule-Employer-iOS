//
//  CreateCompanyScheduledPositionsVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit

struct JobPositionsStruct
{
    var status: String = ""
    var id: String = ""
    var position: String = ""
    var checkBoxSelected : Bool
}

class CreateCompanyScheduledPositionsVC: UIViewController {
    
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var addPositionTxtField: UITextField!
    
    @IBOutlet weak var tbleViewHeightConstraint: NSLayoutConstraint!
    
    var jobPositionsArr = [JobPositionsStruct]()
    var positionsIdArr = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tbleView.register(UINib(nibName: "CreateCompanyScheduledPositionsTableCell", bundle: Bundle.main), forCellReuseIdentifier: "CreateCompanyScheduledPositionsTableCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getJobPositionApi()
        self.tbleView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tbleView.removeObserver(self, forKeyPath: "contentSize")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"
        {
            if let newValue = change?[.newKey]
            {
                let newsize = newValue as! CGSize
                // self.tbleViewHeightConstraint.constant = newsize.height
            }
        }
    }
    
    // MARK: - Add Position button tapped
    @IBAction func onTapAddPositionButton(_ sender: Any) {
        
        if addPositionTxtField.text == ""
        {
            showMessageAlert(message: "Please enter position")
        }
        else
        {
            self.createJobPositionApi(position: self.addPositionTxtField.text!)
            
        }
        
    }
    // MARK: - Skip button tapped
    @IBAction func onTapSkipButton(_ sender: Any) {
        let vc = CreateCompanyEmployeeSetupNewVC()//CreateCompanyEmployeeSetupVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Next button tapped
    @IBAction func onTapNextButton(_ sender: Any) {
        //        let vc = CreateCompanyEmployeeSetupVC()
        //        self.navigationController?.pushViewController(vc, animated: true)
        //
        //        var positionsIdArr = [String]()
        //        for i in 0..<self.jobPositionsArr.count
        //        {
        //            let checkStatus = self.jobPositionsArr[i].checkBoxSelected
        //            let checkStatusId = self.jobPositionsArr[i].id
        //            if checkStatus
        //            {
        //                positionsIdArr.append(checkStatusId)
        //            }
        //        }
        //        print(positionsIdArr)
        
        
        
        for i in 0..<self.jobPositionsArr.count
        {
            let checkStatus = self.jobPositionsArr[i].checkBoxSelected
            let checkStatusId = self.jobPositionsArr[i].id
            if checkStatus
            {
                positionsIdArr.append(checkStatusId)
            }
        }
        print(positionsIdArr)//
        if self.positionsIdArr.count > 0
        {
            self.setJobPositionApi()
        }
        else
        {
            showMessageAlert(message: "Please select atleast one common position or skip")
        }
    }
    
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getJobPositionApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_JOB_POSITIONS_API
        if Reachability.isConnectedToNetwork() {
            guard let industryId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.INDUSTRY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:String?] = [ "industry_id": industryId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.jobPositionsArr.removeAll()
                    
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let position =  json["data"][i]["position"].stringValue
                        
                        self.jobPositionsArr.append(JobPositionsStruct.init(status: status, id: id, position: position,checkBoxSelected: false))
                    }
                }
                else {
                    self.jobPositionsArr.removeAll()
                    
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
    func createJobPositionApi(position:String)
    {
        
        let fullUrl = BASE_URL + PROJECT_URL.CREATE_JOB_POSITIONS_API
        
        if Reachability.isConnectedToNetwork() {
            
            guard let employerId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            guard let industryId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.INDUSTRY_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String?] = [ "user_id": employerId, "position":position,"industry_id":industryId,"company_id":companyId,"color_code":"(255,0,0)"]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.addPositionTxtField.text = ""
                    self.getJobPositionApi()
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    
                    //                    let companyId = json["data"]["company_id"].stringValue
                    //                    let industryId = json["data"]["industry_id"].stringValue
                    //                    //save data in userdefault..
                    //                    UserDefaults.standard.setValue(json["token"].stringValue, forKey: USER_DEFAULTS_KEYS.LOGIN_TOKEN)
                    //                    UserDefaults.standard.setValue(true, forKey: USER_DEFAULTS_KEYS.IS_LOGIN)
                    //                    UserDefaults.standard.setValue(companyId, forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
                    //                    UserDefaults.standard.setValue(industryId, forKey: USER_DEFAULTS_KEYS.INDUSTRY_ID)
                    //
                    //                    let vc = CreateCompanyEmployeeSetupVC()
                    //                    self.navigationController?.pushViewController(vc, animated: true)
                    //
                }
                else {
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
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func setJobPositionApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.SET_COMPANY_POSITIONS_API
        
        if Reachability.isConnectedToNetwork() {
            
            guard let employerId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            
            
            var positionsIdStr = ""
            positionsIdStr = json(from: self.positionsIdArr)!
            
            let param:[String:Any] = ["user_id": employerId, "company_id":companyId, "position_id": positionsIdStr]
            
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.addPositionTxtField.text = ""
                    let vc = CreateCompanyEmployeeSetupNewVC()//CreateCompanyEmployeeSetupVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
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
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    @objc func jobPositionCheckBoxBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        var info = self.jobPositionsArr
        
        sender.isSelected = !sender.isSelected
        info[index].checkBoxSelected = sender.isSelected
        self.jobPositionsArr = info
        self.tbleView.reloadData()
    }
    
}


extension CreateCompanyScheduledPositionsVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.jobPositionsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCompanyScheduledPositionsTableCell") as! CreateCompanyScheduledPositionsTableCell
        cell.selectionStyle = .none
        
        let info = self.jobPositionsArr[indexPath.row]
        cell.jobPositionNameLbl.text = info.position
        
        if info.checkBoxSelected == true
        {
            cell.jobPositionCheckBox.isSelected = true
        }
        else
        {
            cell.jobPositionCheckBox.isSelected = false
        }
        
        cell.jobPositionCheckBox.tag = indexPath.row
        cell.jobPositionCheckBox.addTarget(self, action: #selector(jobPositionCheckBoxBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
}
