//
//  WCEmployeeListVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 06/07/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct WCEmployeeStruct
{
    var counter: Int = 0
    var email: String = ""
    var profile_pic: String = ""
    var status: String = ""
    var id: String = ""
    var name: String = ""
    var role: String = ""
    var checkBoxSelected : Bool
}

class WCEmployeeListVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var createGroupBtn: UIButton!
    
    var isCommingFrom = ""
    
    var employeeNameSelected = ""
    var employeeListArr = [WCEmployeeStruct]()
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    
    ///For work chat with firebase
    private let loginUserViewModel = UserViewModel()
    private let fdbRef = Database.database().reference()
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         if isCommingFrom == "New Chat"
         {
         self.customNavigationBar.titleLabel.text = "Employee List"
         }
         else
         {
         self.customNavigationBar.titleLabel.text = "Add Participants"
         }
         */
        self.customNavigationBar.titleLabel.text = "Employee List"
        
        
        self.tblView.register(UINib(nibName: "WorkChatEmployeeListCell", bundle: .main), forCellReuseIdentifier: "WorkChatEmployeeListCell")
        
        self.getEmployeeListApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
        /*
         if isCommingFrom == "New Chat"
         {
         self.createGroupBtn.isHidden = true
         }
         else
         {
         self.createGroupBtn.isHidden = false
         }
         */
        self.createGroupBtn.isHidden = true
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
            //            let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId, "search":"\(searchStr)"]
            
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
                        let profile_pic =  json["data"][i]["profile_pic"].stringValue
                        let id          =  json["data"][i]["employee_id"].stringValue
                        let status      =  json["data"][i]["status"].stringValue
                        let name        =  json["data"][i]["name"].stringValue
                        let role        =  json["data"][i]["role"].stringValue
                        let email       =  json["data"][i]["email"].stringValue
                        
                        self.employeeListArr.append(WCEmployeeStruct.init(email: email,profile_pic: profile_pic, status: status, id: id, name: name, role: role, checkBoxSelected: false))
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
                        self.tblView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    else
                    {
                        self.tblView.isHidden = false
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
    
    /*
     private func getUserInfo(email: String, password: String, userName: String, profilePic: String, role:String) {
     
     let fcmKey = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.FCM_KEY)
     let timestamp = Int(Date().timeIntervalSince1970*1000)
     
     userIdArray.removeAll()
     DispatchQueue.main.async {
     showProgressOnView(appDelegateInstance.window!)
     }
     //
     
     fdbRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
     
     if snapshot.exists(){
     //                DispatchQueue.main.async {
     //                    hideAllProgressOnView(appDelegateInstance.window!)
     //                }
     
     if let dataDict = snapshot.value as? [String:AnyObject]{
     
     for (key,_) in dataDict {
     
     let emailStr  = dataDict[key]!["email"] as? String
     let userId    = dataDict[key]!["userId"] as? String
     
     if emailStr != email
     {
     //self.signUpIntoFirebase(email: email, userId: "ID", userName: userName, profile: profilePic, timestamp: String(timestamp), role: "Employer")
     self.signUpIntoFirebase(email: email, password: "123456", userName: userName, role: role, timestamp: String(timestamp), profilePic: profilePic, fcmKey: "", checkedUnCheck: "")
     }
     else
     {
     
     //                            var chatDict: [String:AnyObject] = [:]
     //                            chatDict = [
     //                                "fcmKey" : fcmKey
     //                            ] as [String : AnyObject]
     //
     if userId != ""
     {
     // userIdArray.append(userId!)
     //userIdArray.removeAll()
     DispatchQueue.main.async {
     hideAllProgressOnView(appDelegateInstance.window!)
     
     self.navigationController?.popViewController(animated: true)
     // create chat room here
     }
     
     //                                let chatViewModel = ChatViewModel()
     //                                chatViewModel.createChatRoom()
     // self.fdbRef.child("Users").child("\(userId!)").updateChildValues(chatDict)
     
     }
     //                            let chatViewModel = ChatViewModel()
     //                            chatViewModel.createChatRoom()
     //                            fdbRef.child("Users").child(employeeId).updateChildValues(userDict as [AnyHashable : Any])
     }
     }
     }
     }
     else
     {
     //                DispatchQueue.main.async {
     //                    hideAllProgressOnView(appDelegateInstance.window!)
     //                }
     self.signUpIntoFirebase(email: email, password: "123456", userName: userName, role: role, timestamp: String(timestamp), profilePic: profilePic, fcmKey: "", checkedUnCheck: "")
     }
     }
     }
     */
    private func getUserInfo(email: String, password: String, userName: String, profilePic: String, role:String) {
        
        let fcmKey = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.FCM_KEY)
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        
        userIdArray.removeAll()
        DispatchQueue.main.async {
            showProgressOnView(appDelegateInstance.window!)
        }
        //
        
        fdbRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.exists(){
                //                DispatchQueue.main.async {
                //                    hideAllProgressOnView(appDelegateInstance.window!)
                //                }
                
                if let dataDict = snapshot.value as? [String:AnyObject]{
                    
                    for (key,_) in dataDict {
                        
                        let emailStr  = dataDict[key]!["email"] as? String
                        let userId    = dataDict[key]!["userId"] as? String
                        
                        if emailStr != email
                        {
                            //self.signUpIntoFirebase(email: email, userId: "ID", userName: userName, profile: profilePic, timestamp: String(timestamp), role: "Employer")
                            self.signUpIntoFirebase(email: email, password: "123456", userName: userName, role: role, timestamp: String(timestamp), profilePic: profilePic, fcmKey: "", checkedUnCheck: "")
                        }
                        else
                        {
                            
                            //                            var chatDict: [String:AnyObject] = [:]
                            //                            chatDict = [
                            //                                "fcmKey" : fcmKey
                            //                            ] as [String : AnyObject]
                            //
                            if userId != ""
                            {
                                print(myChatUserList.count)
                                //print(myChatUserList)
                                //print(myChatUserList[0].meta2?.userEmail)
                                
                                let matchingEntries = myChatUserList.filter { $0.meta2?.userEmail == emailStr }
                                print(matchingEntries)
                                //Check here single chat employee is there or not
                                if !matchingEntries.isEmpty {
                                    DispatchQueue.main.async {
                                        hideAllProgressOnView(appDelegateInstance.window!)
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                }
                                else
                                {
                                    self.signUpIntoFirebase(email: email, password: "123456", userName: userName, role: role, timestamp: String(timestamp), profilePic: profilePic, fcmKey: "", checkedUnCheck: "")
                                }
                                
                                //                                print(userIdArray.count)
                                //                                print(userIdArray)
                                //                                userIdArray.append(userId ?? "")
                                //                                let chatViewModel = ChatViewModel()
                                //                                chatViewModel.createChatRoom()
                                
                                
                                /*
                                 // userIdArray.append(userId!)
                                 //userIdArray.removeAll()
                                 DispatchQueue.main.async {
                                 hideAllProgressOnView(appDelegateInstance.window!)
                                 
                                 self.navigationController?.popViewController(animated: true)
                                 // create chat room here
                                 }
                                 
                                 //                                let chatViewModel = ChatViewModel()
                                 //                                chatViewModel.createChatRoom()
                                 // self.fdbRef.child("Users").child("\(userId!)").updateChildValues(chatDict)
                                 
                                 */
                                
                            }
                            //                            let chatViewModel = ChatViewModel()
                            //                            chatViewModel.createChatRoom()
                            //                            fdbRef.child("Users").child(employeeId).updateChildValues(userDict as [AnyHashable : Any])
                        }
                    }
                }
            }
            else
            {
                //                DispatchQueue.main.async {
                //                    hideAllProgressOnView(appDelegateInstance.window!)
                //                }
                self.signUpIntoFirebase(email: email, password: "123456", userName: userName, role: role, timestamp: String(timestamp), profilePic: profilePic, fcmKey: "", checkedUnCheck: "")
            }
        }
    }
    
}

extension WCEmployeeListVC: UITableViewDelegate, UITableViewDataSource
{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkChatEmployeeListCell") as! WorkChatEmployeeListCell
        cell.selectionStyle = .none
        
        /*
         if self.isCommingFrom == "New Chat"
         {
         cell.employeeCheckBoxBackView.isHidden = true
         }
         else
         {
         cell.employeeCheckBoxBackView.isHidden = false
         }
         */
        cell.employeeCheckBoxBackView.isHidden = true
        
        let info = self.employeeListArr[indexPath.row]
        let imageUrl =  IMAGE_BASE_URL + info.profile_pic
        if imageUrl != ""
        {
            cell.employeeLeftSideImgView.setImage(with: imageUrl)
        }
        else
        {
            cell.employeeLeftSideImgView.image = #imageLiteral(resourceName: "dummy-user")
        }
        cell.employeeNameLbl.text = "\(info.name)"
        cell.employeeLastMsgLbl.text = "\(info.email)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let info = self.employeeListArr[indexPath.row]
        let imageUrl =  IMAGE_BASE_URL + info.profile_pic
        
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        //        self.signUpIntoFirebase(email: info.email, userId: "ID", userName: info.name, profile: imageUrl, timestamp: String(timestamp), role: info.role)
        
        self.getUserInfo(email: info.email, password: "123456", userName: info.name, profilePic: imageUrl, role: info.role)
        //  self.signUpIntoFirebase(email: info.email, password: "123456", userName: info.name, role: info.role, timestamp: String(timestamp), profilePic: imageUrl, fcmKey: "", checkedUnCheck: "")
        
        
        
        
        
        
        
        
        //        email: info.email, userId: "ID", userName: info.name, profile: imageUrl, timestamp: String(timestamp), role: info.role)
        
        
        
        //        let info = self.employeeListArr[indexPath.row]
        //        self.employeeID = info.employeeId
        //        self.employeeNameSelected = info.name
        //        let checkInTime = gmtToLocal(dateStr: info.checkIn)
        //        let checkOutTime = gmtToLocal(dateStr: info.checkOut)
        //        let shiftTime = "\(checkInTime ?? "") - \(checkOutTime ?? "")"
        //
        //        //        let employeeDataDict:[String: String] = ["employeeName": self.employeeNameSelected, "employeeId": self.employeeID]
        //        let employeeDataDict:[String: String] = ["employeeName": self.employeeNameSelected, "employeeId": self.employeeID, "shiftTime":shiftTime]
        //        //Post Notification
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil, userInfo: employeeDataDict)
        //        self.removeFromSuperview()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 95 //UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
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
}
extension WCEmployeeListVC: UITextFieldDelegate {
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

extension WCEmployeeListVC
{
    //MARK:  firebase login
    private func signUpIntoFirebase(email: String, password: String, userName: String, role: String, timestamp: String, profilePic: String, fcmKey: String?, checkedUnCheck: String) {
        
        let pass = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD) ?? ""
        
        loginUserViewModel.signUpWithFirebase(email: email, password: pass, userId : "userId", userName : "userName", profile: profilePic, timestamp:timestamp, role:role) { (success) in
            
            //guard let userId = Auth.auth().currentUser?.uid  else { return }
            //save Employer Firebase userId in userdefault..
            //UserDefaults.standard.setValue(userId, forKey: USER_DEFAULTS_KEYS.FIREBASE_EMPLOYER_USER_ID)
            
            self.loginWithFirebase(email: email, password: password, userName: userName, role: role, timestamp: timestamp, profilePic: profilePic, fcmKey: fcmKey, checkedUnCheck: checkedUnCheck, alreadyExist: success)
        } onError: { (errorMessage) in
            DispatchQueue.main.async {
                hideProgressOnView(self.view)
                showMessageAlert(message: errorMessage)
            }
        }
    }
    
    private func loginWithFirebase(email: String, password: String, userName: String, role: String, timestamp: String, profilePic: String, fcmKey: String?, checkedUnCheck: String, alreadyExist: Bool){
        
        let pass = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD) ?? ""
        
        loginUserViewModel.employeeLoginWithFirebase(email: email, password: password, userName: userName, role: role, timestamp: timestamp, profilePic: profilePic, fcmKey: fcmKey, checkedUnCheck: checkedUnCheck, alreadyExistEmployee: alreadyExist) { (success) in
            //  if self.user != nil{
            //   self.saveDataToUserDefaults(user: self.user!)
            DispatchQueue.main.async {
                hideProgressOnView(self.view)
                print("Logged in with firebase successfully")
                self.navigationController?.popViewController(animated: true)
            }
        } onError: { (errorMessage) in
            DispatchQueue.main.async {
                hideProgressOnView(self.view)
                showMessageAlert(message: errorMessage)
            }
        }
    }
}
