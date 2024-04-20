//
//  WCAddParticipantPopUP.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 03/08/23.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class WCAddParticipantPopUP: UIView {
    
    var view: UIView!
    @IBOutlet weak var addParticipantBtn: UIButton!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    
    var employeeNameSelected = ""
    var employeeListArr = [WCEmployeeStruct]()
    
    //1 For search locally
    var isFilter = false
    var employeeListArrDuplicate  = [WCEmployeeStruct]()
    
    ///For work chat with firebase
    private let loginUserViewModel = UserViewModel()
    private let fdbRef = Database.database().reference()
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        // 2. call super.init(frame:)
        super.init(frame: frame)
        // 3. Setup view from .xib file
        xibSetup()
        tblView.delegate = self
        tblView.dataSource = self
        tblView.register(UINib(nibName: "WorkChatEmployeeListCell", bundle: Bundle.main), forCellReuseIdentifier: "WorkChatEmployeeListCell")
        //For search locally
        self.searchTxtField.delegate = self
        self.searchTxtField.text = ""
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
        // For pagination 2
        currentPageIndex = 0
        self.getEmployeeListApi()
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "WCAddParticipantPopUP", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 140
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
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
            /*
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
             */
            let param:[String:Any] = [ "page": "0","company_id": companyId, "search":"\(searchStr)"]
            
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    /*
                     // For pagination 3
                     self.totalPageIndexCount = json["total_record_count"].intValue
                     if (self.currentPageIndex == 0) || (searchStr != "") {
                     self.employeeListArr.removeAll()
                     }
                     */
                    self.employeeListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let profile_pic =  json["data"][i]["profile_pic"].stringValue
                        let id          =  json["data"][i]["employee_id"].stringValue
                        let status      =  json["data"][i]["status"].stringValue
                        let name        =  json["data"][i]["name"].stringValue
                        let role        =  json["data"][i]["role"].stringValue
                        let email       =  json["data"][i]["email"].stringValue
                        
                        self.employeeListArr.append(WCEmployeeStruct.init(counter: i + 1,email: email,profile_pic: profile_pic, status: status, id: id, name: name, role: role, checkBoxSelected: false))
                    }
                }
                else {
                    self.employeeListArr.removeAll()
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
    @objc func employeeCheckBoxBtnClicked(sender:UIButton)
    {
        //        let index = sender.tag
        //        var info = self.employeeListArr
        //        sender.isSelected = !sender.isSelected
        //        info[index].checkBoxSelected = sender.isSelected
        //        self.employeeListArr = info
        //        self.tblView.reloadData()
        //        /*
        //         // add and remove or update on firebase
        //         let info1 = self.employeeListArr[index]
        //         let imageUrl =  IMAGE_BASE_URL + info1.profile_pic
        //         let timestamp = Int(Date().timeIntervalSince1970*1000)
        //
        //         let fcmStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.FCM_KEY) as? String ?? "qwerty"
        //         let checkUncheckStr = "\(info1.checkBoxSelected)"
        //
        //         self.signUpIntoFirebase(email: info1.email, password: "", userName: info1.name, role: info1.role, timestamp: "\(timestamp)", profilePic: imageUrl, fcmKey: fcmStr , checkedUnCheck: checkUncheckStr)
        //         */
        
        let index = sender.tag
        if self.isFilter {
            var info = self.employeeListArrDuplicate[index]
            
            sender.isSelected = !sender.isSelected
            info.checkBoxSelected = sender.isSelected
            self.employeeListArr[info.counter - 1] = info
            self.employeeListArrDuplicate[index] = info
        } else {
            var info = self.employeeListArr[index]
            sender.isSelected = !sender.isSelected
            info.checkBoxSelected = sender.isSelected
            self.employeeListArr[index] = info
        }
        print("*********************************************************************************************\(self.employeeListArr.count)")
        self.tblView.reloadData()
    }
    // Helper function to filter data based on search text
    func filterData(searchText: String) {
        
        if searchText.isEmpty
        {
            self.isFilter = false
            //            self.filterEmployeeListArr = self.employeeListArr
            self.employeeListArr = self.employeeListArr.sorted(by: {$0.counter < $1.counter})
            
            //print(self.filterEmployeeListArr.count)
        }
        else
        {
            self.isFilter = true
            self.employeeListArrDuplicate = self.employeeListArr.filter { $0.name.lowercased().contains(searchText.lowercased())}
            
            
        }
        tblView.reloadData()
    }
    
    @IBAction func onTapCancelBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func onTapAddParticipantBtn(_ sender: Any) {
        self.removeFromSuperview()
        
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        
        for i in 0..<self.employeeListArr.count
        {
            if self.employeeListArr[i].checkBoxSelected == true
            {
                let email = self.employeeListArr[i].email
                
                
                fdbRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
                    
                    if snapshot.exists(){
                        
                        let enumrator = snapshot.children
                        while let snap = enumrator.nextObject() as? DataSnapshot{
                            
                            if let userDict = snap.value as? [String: AnyObject]{
                                
                                let userId  = userDict["userId"] as? String
                                
                                if userIdArray.contains("\(userId ?? "")")
                                {
                                    print("user already exist in the group")
                                    //showMessageAlert(message: "user already exist in the group")
                                }
                                else
                                {
                                    userIdArray.append(userId ?? "")
                                    self.updateGroupUsers()
                                }
                            }
                        }
                    }
                    else
                    {
                        let databaseRef = Database.database().reference().child("Users")
                        let ref = Database.database().reference().child("Users").childByAutoId()
                        let key = ref.key
                        
                        var chatRoomDict: [String:AnyObject] = [:]
                        chatRoomDict = [
                            "userId"    : key,
                            "userName"  : "\(self.employeeListArr[i].name)",
                            "profile"   : "\(IMAGE_BASE_URL)\(self.employeeListArr[i].profile_pic)",
                            "email"     : "\(self.employeeListArr[i].email)",
                            "role"      : "\(self.employeeListArr[i].role)",
                            "timestamp" : "\(timestamp)",
                            "fcmKey"    : ""
                        ] as [String : AnyObject]
                        
                        
                        databaseRef.child(key!).updateChildValues(chatRoomDict)
                        
                        if userIdArray.contains("\(key ?? "")")
                        {
                            print("user already exist in the group")
                            // showMessageAlert(message: "user already exist in the group")
                        }
                        else
                        {
                            userIdArray.append(key ?? "")
                            self.updateGroupUsers()
                        }
                        
                    }
                    // For manage participant list
                    updateGroupUserInfoStatus = "0"
                }
            }
        }
        
    }
    
    func updateGroupUsers()
    {
        let groupTitle      = updateGroupTitle
        let roomId          = updateGroupRoomId
        guard let senderID  = UserDefaults.standard.string(forKey: "userId") else { return }
        let timestamp       = Int(Date().timeIntervalSince1970*1000)
        let type            = "group"
        var profileImgStr   = ""
        
        //        if self.profileImg.image != nil{
        //            profileImgStr = "\(pickedImageUrl ?? URL(fileURLWithPath: IMAGE_BASE_URL + "public/default_group_icon.jpg"))"
        //
        //            print(profileImgStr)
        //        }
        //        else
        //        {
        //            profileImgStr = IMAGE_BASE_URL + "public/default_group_icon.jpg"
        //        }
        //        profileImgStr = IMAGE_BASE_URL + "public/default_group_icon.jpg"
        //        print(profileImgStr)
        
        if groupImgFullUrlStr != ""
        {
            profileImgStr = groupImgFullUrlStr
        }
        else
        {
            profileImgStr = IMAGE_BASE_URL + "public/default_group_icon.jpg"
        }
        print(profileImgStr)
        
        //        employeeIdArray.removeAll()
        //        for i in 0..<alreadyAddedUserArr.count {
        //            let employeeId = alreadyAddedUserArr[i]
        //            employeeIdArray.append(employeeId)
        //        }
        //
        //        for i in 0..<userIdArray.count
        //        {
        //            if employeeIdArray.contains("\(userIdArray)")
        //            {
        //
        //            }
        //            else
        //            {
        //                employeeIdArray.append(userIdArray[i])
        //            }
        //        }
        
        let request = GroupChatRoom(users: userIdArray, lastMessageText: "", lastMessage: "\(timestamp)", type: type, creator: senderID, timestamp: "\(timestamp)", meta: GroupChatMeta(title: groupTitle, description: "", icon: profileImgStr, broadcat: false))
        
        showProgressOnView(appDelegateInstance.window!)
        loginUserViewModel.updateGroupRoom(request: request, roomId: roomId) { result in
            print(result as Any)
            hideAllProgressOnView(appDelegateInstance.window!)
            // Define a notification name as a string constant
            let myNotificationName = Notification.Name("MyCustomNotification")
            // Post the notification with optional data
            NotificationCenter.default.post(name: myNotificationName, object: nil, userInfo: ["key": "value"])
            
            // self.addParticipantPopUP.removeFromSuperview()
            //self.getUserInfo()
        } onError: { error in
            print(error)
        }
    }
    
    
    
}

extension WCAddParticipantPopUP: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //        return self.employeeListArr.count
        if self.isFilter {
            return self.employeeListArrDuplicate.count
        } else {
            return self.employeeListArr.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkChatEmployeeListCell") as! WorkChatEmployeeListCell
        cell.selectionStyle = .none
        cell.employeeCheckBoxBackView.isHidden = false
        
        //let info = self.employeeListArr[indexPath.row]
        let info = self.isFilter ? self.employeeListArrDuplicate[indexPath.row] : self.employeeListArr[indexPath.row]
        
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
        //        let imageUrl =  IMAGE_BASE_URL + info.profile_pic
        //        let timestamp = Int(Date().timeIntervalSince1970*1000)
        //
        //        let fcmStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.FCM_KEY) as? String ?? "qwerty"
        //        let checkUncheckStr = "\(info.checkBoxSelected)"
        //
        //        //self.getUserInfo(email: info.email, password: "", userName: info.name, profilePic: imageUrl,role: info.role, checkedUnCheck: checkUncheckStr)
        //        self.signUpIntoFirebase(email: info.email, password: "", userName: info.name, role: info.role, timestamp: "\(timestamp)", profilePic: imageUrl, fcmKey: fcmStr , checkedUnCheck: checkUncheckStr)
        //
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
        /*
         if indexPath.row == (self.employeeListArr.count - 1) {
         if (self.employeeListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
         currentPageIndex = currentPageIndex + 1
         self.getEmployeeListApi()
         }
         }
         */
    }
}

extension WCAddParticipantPopUP: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        self.filterData(searchText: searchText)
        return true
    }
    /*
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
     */
}

extension WCAddParticipantPopUP
{
    private func getUserInfo(email: String, password: String, userName: String, profilePic: String, role:String, checkedUnCheck:String ) {
        
        var fcmKey = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.FCM_KEY)
        if fcmKey == nil
        {
            fcmKey = " "
        }
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        
        fdbRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                if let dataDict = snapshot.value as? [String:AnyObject]{
                    
                    for (key,_) in dataDict {
                        
                        let emailStr  = dataDict[key]!["email"] as? String
                        let userId    = dataDict[key]!["userId"] as? String
                        if emailStr != email
                        {
                            //                            self.signUpIntoFirebase(email: email, userId: "ID", userName: userName, profile: profilePic, timestamp: String(timestamp), role: role)
                            
                            self.signUpIntoFirebase(email: email, password: "", userName: userName, role: role, timestamp: "\(timestamp)", profilePic: profilePic, fcmKey: fcmKey , checkedUnCheck: checkedUnCheck)
                        }
                        else
                        {
                            if userId != ""
                            {
                                userIdArray.append(userId!)
                            }
                        }
                    }
                }
            }
            else
            {
                //self.signUpIntoFirebase(email: email, userId: "ID", userName: userName, profile: profilePic, timestamp: String(timestamp), role: "Employer")
                
                self.signUpIntoFirebase(email: email, password: "", userName: userName, role: role, timestamp: "\(timestamp)", profilePic: profilePic, fcmKey: fcmKey , checkedUnCheck: checkedUnCheck)
                
            }
        }
    }
    
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
        
        loginUserViewModel.addParticipantLoginWithFirebase(email: email, password: pass, userName: userName, role: role, timestamp: timestamp, profilePic: profilePic, fcmKey: fcmKey, checkedUnCheck: checkedUnCheck, alreadyExistEmployee: alreadyExist) { (success) in
            //  if self.user != nil{
            //   self.saveDataToUserDefaults(user: self.user!)
            DispatchQueue.main.async {
                hideProgressOnView(self.view)
                print("Logged in with firebase successfully")
                //                self.navigationController?.popViewController(animated: true)
            }
        } onError: { (errorMessage) in
            DispatchQueue.main.async {
                hideProgressOnView(self.view)
                showMessageAlert(message: errorMessage)
            }
        }
    }
}
