//
//  EmployeePositionsVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 13/12/22.
//

import UIKit

class EmployeePositionsVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var positionTopBackView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblBackView: UIView!
    @IBOutlet weak var emptyView: UIView!
    
    var customPositionsArr = [EmployeePositionsStruct]()
    //Custom View
    var customAddPositionView : CustomAddPositionView!
    var customColorPickerView : CustomColorPickerView!
    // For Update Position
    var isOpenFrom = "Add"
    var industryId = ""
    var positionId = ""
    var colorCode = ""
    var position = ""
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customNavigationBar.titleLabel.text = "Position"
        tblView.register(UINib(nibName: "EmployeePositionTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeePositionTableCell")
        self.positionTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        self.getCustomCompanyPositionApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.positionTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
    }
    @IBAction func onClickAddEmployeePositionBtn(_ sender: Any) {
        self.isOpenFrom = "Add"
        self.showCustomAddPositionView()
    }
    func showCustomAddPositionView (){
        self.customAddPositionView = CustomAddPositionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        if self.isOpenFrom == "Edit"
        {
            self.customAddPositionView.addPositionTextField.text = self.position
            let colorCodeStr = self.colorCode.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
            let colorCodeArr = colorCodeStr.components(separatedBy: ",")
            let r = Double(colorCodeArr[0]) ?? 0.0
            let g = Double(colorCodeArr[1]) ?? 0.0
            let b = Double(colorCodeArr[2]) ?? 0.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.customAddPositionView.headerTitleLbl.text = "Update Position"
            self.customAddPositionView.addButton.setTitle("UPDATE", for: .normal)
        }
        else
        {
            r = 0.0
            g = 255.0
            b = 255.0
            self.customAddPositionView.addPositionTextField.text =  ""
            self.customAddPositionView.headerTitleLbl.text = "Add Position"
            self.customAddPositionView.addButton.setTitle("ADD", for: .normal)
        }
        self.customAddPositionView.addButton.addTarget(self, action: #selector(self.addPositionButtonPressed), for: .touchUpInside)
        self.customAddPositionView.colorBtn.addTarget(self, action: #selector(self.addColorButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customAddPositionView)
    }
    @objc func addPositionButtonPressed(sender: UIButton) {
        self.customAddPositionView.removeFromSuperview()
        if self.customAddPositionView.addPositionTextField.text == ""
        {
            showMessageAlert(message: "Please enter position")
        }
        else
        {
            self.position = self.customAddPositionView.addPositionTextField.text!
            let colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            
            if isOpenFrom == "Edit"
            {
                self.updatePositionApi(industryId: self.industryId, positionId:  self.positionId, colorCode: self.colorCode, position:self.position)
            }
            else
            {
                self.createJobPositionApi(position: self.customAddPositionView.addPositionTextField.text!, colorCode: colorCode)
            }
            
        }
    }
    @objc func addColorButtonPressed(sender: UIButton) {
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
        
        switch sender.tag
        {
        case 1001:
            r = 0.0
            g = 255.0
            b = 255.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1002:
            r = 255.0
            g = 140.0
            b = 0.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1003:
            r = 188.0
            g = 143.0
            b = 143.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1004:
            r = 205.0
            g = 92.0
            b = 92.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1005:
            r = 0.0
            g = 0.0
            b = 255.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1006:
            r = 255.0
            g = 255.0
            b = 0.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1007:
            r = 255.0
            g = 0.0
            b = 255.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1008:
            r = 0.0
            g = 0.0
            b = 128.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 1009:
            r = 0.0
            g = 128.0
            b = 128.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10010:
            r = 128.0
            g = 0.0
            b = 128.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10011:
            r = 0.0
            g = 128.0
            b = 0.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10012:
            r = 233.0
            g = 150.0
            b = 122.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10013:
            r = 220.0
            g = 20.0
            b = 60.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10014:
            r = 153.0
            g = 0.0
            b = 76.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10015:
            r = 0.0
            g = 255.0
            b = 127.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10016:
            r = 0.0
            g = 206.0
            b = 209.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10017:
            r = 100.0
            g = 149.0
            b = 237.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        case 10018:
            r = 47.0
            g = 79.0
            b = 79.0
            let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
            self.customAddPositionView.colorBtn.backgroundColor = color
            self.colorCode = "(\(Int(r)),\(Int(g)),\(Int(b)))"
            break
        default: break
        }
        self.customColorPickerView.removeFromSuperview()
    }
    
    
    
    func getCustomCompanyPositionApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_COMPANY_POSITIONS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "page": "\(self.currentPageIndex)", "limit": "20","company_id": companyId]
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
                        self.customPositionsArr.removeAll()
                    }
                    //self.customPositionsArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id =  json["data"][i]["id"].stringValue
                        let industry_id =  json["data"][i]["industry_id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        let position =  json["data"][i]["position"].stringValue
                        let colorCode =  json["data"][i]["color_code"].stringValue
                        let industryId =  json["data"][i]["industry_id"].stringValue
                        let checked =  json["data"][i]["checked"].stringValue
                        
                        self.customPositionsArr.append(EmployeePositionsStruct.init(status: status, id: id, position: position,colorCode:colorCode,industryId:industryId,checked:checked,checkBoxSelected: false))
                    }
                    //                    if json["data"].count == 0
                    //                    {
                    //                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    //                    }
                    
                }
                else {
                    self.customPositionsArr.removeAll()
                    //  UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
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
                    if self.customPositionsArr.count == 0
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
    
    
    
    func createJobPositionApi(position:String, colorCode: String)
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
            
            let param:[String:String?] = [ "user_id": employerId, "position":position,"industry_id":industryId,"company_id":companyId,"color_code":colorCode]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getCustomCompanyPositionApi()
                    //                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
                else
                {
                    //                    var errorMsg = ""
                    //                    let arr = json["error"].dictionaryValue
                    //                    if arr.containsKey("position") {
                    //                        errorMsg = json["error"]["position"][0].stringValue
                    //                    }
                    //                    print(errorMsg)
                    //                    UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
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
    
    func updatePositionApi(industryId:String, positionId:String, colorCode:String,position:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_POSITION_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "user_id":userId, "position": position, "industry_id": industryId, "position_id": positionId, "color_code":colorCode]
            
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getCustomCompanyPositionApi()
                }
                else {
                    //self.customPositionsArr.removeAll()
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
                    //                    if self.customPositionsArr.count == 0
                    //                    {
                    //                        self.tblBackView.isHidden = true
                    //                    }
                    //                    else
                    //                    {
                    //                        self.tblBackView.isHidden = false
                    //                    }
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
        let info = self.customPositionsArr[index]
        let positionId = info.id
        if positionId != ""
        {
            self.deleteApiCall(positionID: positionId)
        }
    }
    @objc func editBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.customPositionsArr[index]
        let positionId = info.id
        if positionId != ""
        {
            self.isOpenFrom = "Edit"
            self.industryId = info.industryId
            self.positionId = positionId
            self.colorCode = info.colorCode
            self.position = info.position
            self.showCustomAddPositionView()
        }
    }
    
    func deleteApiCall(positionID:String)
    {
        let Alert = UIAlertController(title: "Alert", message: "Deleting a record will remove it from all employees linked to it. This record can not be recreated.\nAre you sure, You want to delete this position!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteCustomPositionApi(positionId: positionID)
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
    
    func deleteCustomPositionApi(positionId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_CUSTOM_POSITION_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:String?] = [ "user_id": userId, "position_id":positionId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getCustomCompanyPositionApi()
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
extension EmployeePositionsVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.customPositionsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeePositionTableCell") as! EmployeePositionTableCell
        cell.selectionStyle = .none
        
        let info = self.customPositionsArr[indexPath.row]
        cell.tagLbl.text = info.position
        
        var colorCodeStr = "10,75,144"
        if  info.colorCode != ""
        {
            colorCodeStr = info.colorCode.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        }
        let colorCodeArr = colorCodeStr.components(separatedBy: ",")
        
        r = Double(colorCodeArr[0]) ?? 0.0
        g = Double(colorCodeArr[1]) ?? 0.0
        b = Double(colorCodeArr[2]) ?? 0.0
        
        let color = UIColor(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
        cell.colorTagView.backgroundColor = color
        
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
        return 60
    }
    
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.customPositionsArr.count - 1) {
            if (self.customPositionsArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getCustomCompanyPositionApi()
            }
        }
    }
    
    
}
extension UIColor {
    convenience init(r: CGFloat,g:CGFloat,b:CGFloat,a:CGFloat = 1) {
        self.init(
            red: r / 255.0,
            green: g / 255.0,
            blue: b / 255.0,
            alpha: a
        )
    }
}
