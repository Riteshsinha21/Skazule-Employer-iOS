//
//  WCCreateGroupVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 06/07/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class WCCreateGroupVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var groupNameTxtField: UITextField!
    @IBOutlet weak var createGroupBtn: UIButton!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var isCommingFrom = ""
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    
    var employeeNameSelected = ""
    var employeeListArr  = [WCEmployeeStruct]()
    
    //MARK: Variables
    var customChooseImgView : CustomChooseImgView!
    let imagePicker = UIImagePickerController()
    var pickedImage : UIImage!
    var pickedImageUrl:URL?
    var groupFirebaseUrlStr = ""
    
    ///For work chat with firebase
    private let loginUserViewModel = UserViewModel()
    private let fdbRef = Database.database().reference()
    
    let chatViewModel = ChatViewModel()
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    //1 For search locally
    var isFilter = false
    var employeeListArrDuplicate  = [WCEmployeeStruct]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customNavigationBar.titleLabel.text = "Create Group"
        //self.typeDDTxtField.text = chatTypeDDArr[0]
        self.tblView.register(UINib(nibName: "WorkChatEmployeeListCell", bundle: .main), forCellReuseIdentifier: "WorkChatEmployeeListCell")
        self.getEmployeeListApi()
        
        //For search locally
        self.searchTxtField.delegate = self
        self.searchTxtField.text = ""
        
        // Add this for testing
        employeeIdArray.removeAll()
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
    }
    @IBAction func onTapCameraBtn(_ sender: Any) {
        self.showAddProfilePicPopup()
    }
    func showAddProfilePicPopup(){
        self.customChooseImgView = CustomChooseImgView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.customChooseImgView.cameraButton.addTarget(self, action: #selector(self.cameraButtonPressed), for: .touchUpInside)
        self.customChooseImgView.gallaryButton.addTarget(self, action: #selector(self.gallaryButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customChooseImgView)
    }
    @objc func cameraButtonPressed(sender: UIButton) {
        self.customChooseImgView.removeFromSuperview()
        self.openCamera()
    }
    @objc func gallaryButtonPressed(sender: UIButton) {
        self.customChooseImgView.removeFromSuperview()
        self.openGallery()
    }
    @IBAction func onTapCreateGroupBtn(_ sender: UIButton)
    {
        self.createGroupRoom()
        
        //        let vc = WCEmployeeListVC()
        //        vc.isCommingFrom = "New Group"
        //        self.navigationController?.pushViewController(vc, animated: true)
        
        /*
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
         }
         else
         {
         userIdArray.append(userId ?? "")
         // self.createGroupRoom()
         }
         }
         }
         }
         else
         {
         let ref = Database.database().reference().child("Users").childByAutoId()
         let key = ref.key
         
         var chatRoomDict: [String:AnyObject] = [:]
         chatRoomDict = [
         "userId"    : key,
         "userName"  : "\(self.employeeListArr[i].name)",
         "profile"   : "\(self.employeeListArr[i].profile_pic)",
         "email"     : "\(self.employeeListArr[i].email)",
         "role"      : "\(self.employeeListArr[i].role)",
         "timestamp" : "\(timestamp)",
         "fcmKey"    : ""
         ] as [String : AnyObject]
         
         ref.child(key!).updateChildValues(chatRoomDict)
         
         if userIdArray.contains("\(key ?? "")")
         {
         print("user already exist in the group")
         }
         else
         {
         userIdArray.append(key ?? "")
         // self.createGroupRoom()
         }
         
         }
         }
         }
         }
         
         */
        /*
         // add and remove or update on firebase
         let info1 = self.employeeListArr[index]
         let imageUrl =  IMAGE_BASE_URL + info1.profile_pic
         let timestamp = Int(Date().timeIntervalSince1970*1000)
         
         let fcmStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.FCM_KEY) as? String ?? "qwerty"
         let checkUncheckStr = "\(info1.checkBoxSelected)"
         
         self.signUpIntoFirebase(email: info1.email, password: "", userName: info1.name, role: info1.role, timestamp: "\(timestamp)", profilePic: imageUrl, fcmKey: fcmStr , checkedUnCheck: checkUncheckStr)
         */
        //        createGroupRoom()
        
        //        // Call the Firebase group method
        //        firebaseGroupMethod {
        //            // This block will be executed after all Firebase operations are completed
        //            // Call your own method here
        //            self.createGroupRoom()
        //        }
        
        
    }
    
    func firebaseGroupMethod(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        // Perform some asynchronous Firebase operations
        //        group.enter()
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        for i in 0..<self.employeeListArr.count
        {
            group.enter()
            if self.employeeListArr[i].checkBoxSelected == true
            {
                let email = self.employeeListArr[i].email
                group.enter()
                fdbRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists(){
                        let enumrator = snapshot.children
                        
                        while let snap = enumrator.nextObject() as? DataSnapshot{
                            if let userDict = snap.value as? [String: AnyObject]{
                                let userId  = userDict["userId"] as? String
                                
                                if userIdArray.contains("\(userId ?? "")")
                                {
                                    print("user already exist in the group")
                                }
                                else
                                {
                                    userIdArray.append(userId ?? "")
                                    // self.createGroupRoom()
                                }
                            }
                        }
                    }
                    else
                    {
                        let ref = Database.database().reference().child("Users").childByAutoId()
                        let key = ref.key
                        
                        var chatRoomDict: [String:AnyObject] = [:]
                        chatRoomDict = [
                            "userId"    : key,
                            "userName"  : "\(self.employeeListArr[i].name)",
                            "profile"   : "\(self.employeeListArr[i].profile_pic)",
                            "email"     : "\(self.employeeListArr[i].email)",
                            "role"      : "\(self.employeeListArr[i].role)",
                            "timestamp" : "\(timestamp)",
                            "fcmKey"    : ""
                        ] as [String : AnyObject]
                        
                        ref.child(key!).updateChildValues(chatRoomDict)
                        
                        if userIdArray.contains("\(key ?? "")")
                        {
                            print("user already exist in the group")
                        }
                        else
                        {
                            userIdArray.append(key ?? "")
                            // self.createGroupRoom()
                        }
                        
                    }
                    group.leave()
                }
            }
        }
        //        group.leave()
        
        // When all Firebase operations are finished, execute the completion block
        group.notify(queue: .main) {
            completion()
        }
    }
    
    //    import Firebase
    //
    //    func firebaseGroupMethod(completion: @escaping () -> Void) {
    //        let group = DispatchGroup()
    //
    //        // Perform some asynchronous Firebase operations
    //        group.enter()
    //        yourFirebaseAsyncMethod1 { result in
    //            // Handle the result of the first Firebase operation
    //            // ...
    //            group.leave()
    //        }
    //
    //        group.enter()
    //        yourFirebaseAsyncMethod2 { result in
    //            // Handle the result of the second Firebase operation
    //            // ...
    //            group.leave()
    //        }
    //
    //        // Add more Firebase operations if needed...
    //
    //        // When all Firebase operations are finished, execute the completion block
    //        group.notify(queue: .main) {
    //            completion()
    //        }
    //    }
    
    //    // Call the Firebase group method
    //    firebaseGroupMethod {
    //        // This block will be executed after all Firebase operations are completed
    //        // Call your own method here
    //        yourOwnMethod()
    //    }
    
    
    
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
                        
                        self.employeeListArr.append(WCEmployeeStruct.init(counter: i + 1, email: email,profile_pic: profile_pic, status: status, id: id, name: name, role: role, checkBoxSelected: false))
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
        /*
         let index = sender.tag
         var info = self.employeeListArr
         sender.isSelected = !sender.isSelected
         info[index].checkBoxSelected = sender.isSelected
         self.employeeListArr = info
         print("*********************************************************************************************\(self.employeeListArr)")
         self.tblView.reloadData()
         */
        
        ///*
        let index = sender.tag
        if self.isFilter {
            //            let index = sender.tag
            var info = self.employeeListArrDuplicate[index]
            
            sender.isSelected = !sender.isSelected
            info.checkBoxSelected = sender.isSelected
            //            self.employeeListArr.remove(at: index)
            self.employeeListArr[info.counter - 1] = info
            self.employeeListArrDuplicate[index] = info
        } else {
            //            let index = sender.tag
            var info = self.employeeListArr[index]
            
            sender.isSelected = !sender.isSelected
            info.checkBoxSelected = sender.isSelected
            //            self.employeeListArr.remove(at: index)
            self.employeeListArr[index] = info
        }
        print("*********************************************************************************************\(self.employeeListArr.count)")
        self.tblView.reloadData()
        
        // add and remove or update on firebase
        //let info1 = self.employeeListArr[index]
        let info1 = self.isFilter ? self.employeeListArrDuplicate[index] : self.employeeListArr[index]
        print(info1.email)
        let imageUrl =  IMAGE_BASE_URL + info1.profile_pic
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        
        let fcmStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.FCM_KEY) as? String ?? "qwerty"
        let checkUncheckStr = "\(info1.checkBoxSelected)"
        
        self.signUpIntoFirebase(email: info1.email, password: "", userName: info1.name, role: info1.role, timestamp: "\(timestamp)", profilePic: imageUrl, fcmKey: fcmStr , checkedUnCheck: checkUncheckStr)
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
}
extension WCCreateGroupVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Opening camera
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    // Opening Gallery
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK:- imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:  [UIImagePickerController.InfoKey : Any])
    {
        if let pickedImage = info[.originalImage] as? UIImage {
            // Step 1: Convert the picked image to data
            guard let imageData = pickedImage.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to data.")
                return
            }
            deleteDirectory(name: "temp.jpeg")
            let pickedImageUrl = getImageUrl()
            let imgUrlStr = String(describing: pickedImageUrl!)
            print("\(imgUrlStr)")
            saveImageDocumentDirectory(usedImage: pickedImage)
            // update profile from firebase
            let type      = "image"
            let timestamp = Int(Date().timeIntervalSince1970*1000)
            let request = MessageStruct(message: "\(pickedImage)", senderId: "", receiverId: "", timestamp: "", type: "\(type)", roomId: "")
            chatViewModel.uploadGroupIconToFirebase(request: request, imageURL: imageData, onSuccess: { (result) in
                print(result)
                self.groupFirebaseUrlStr = result
                let imgUrl = URL(string: self.groupFirebaseUrlStr)
                
                self.profileImg.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: "default_group_icon"))
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    //    {
    //        if let pickedImage = info[.originalImage] as? UIImage {
    //            self.profileImg.image = pickedImage
    //            saveImageDocumentDirectory(usedImage: pickedImage)
    //        }
    //        if let imgUrl = getImageUrl()
    //        {
    //            pickedImageUrl = imgUrl
    //        }
    //        dismiss(animated: true, completion: nil)
    //    }
}
extension WCCreateGroupVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //return self.employeeListArr.count
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
        /*
         let info = self.employeeListArr[indexPath.row]
         let imageUrl =  IMAGE_BASE_URL + info.profile_pic
         let timestamp = Int(Date().timeIntervalSince1970*1000)
         
         let fcmStr = UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.FCM_KEY) as? String ?? "qwerty"
         let checkUncheckStr = "\(info.checkBoxSelected)"
         
         self.signUpIntoFirebase(email: info.email, password: "", userName: info.name, role: info.role, timestamp: "\(timestamp)", profilePic: imageUrl, fcmKey: fcmStr , checkedUnCheck: checkUncheckStr)
         */
        
        //        self.signUpIntoFirebase(email: info.email, userId: "ID", userName: info.name, profile: imageUrl, timestamp: String(timestamp), role: info.role)
        
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
extension WCCreateGroupVC: UITextFieldDelegate {
    
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


extension WCCreateGroupVC {
    
    //MARK:  firebase login
    private func signUpIntoFirebase(email: String, password: String, userName: String, role: String, timestamp: String, profilePic: String, fcmKey: String?, checkedUnCheck: String) {
        
        let pass = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD) ?? ""
        
        showProgressOnView(appDelegateInstance.window!)
        loginUserViewModel.signUpWithFirebase(email: email, password: pass, userId : "userId", userName : "userName", profile: profilePic, timestamp:timestamp, role:role) { (success) in
            
            //guard let userId = Auth.auth().currentUser?.uid  else { return }
            //save Employer Firebase userId in userdefault..
            //UserDefaults.standard.setValue(userId, forKey: USER_DEFAULTS_KEYS.FIREBASE_EMPLOYER_USER_ID)
            hideAllProgressOnView(appDelegateInstance.window!)
            self.loginWithFirebase(email: email, password: password, userName: userName, role: role, timestamp: timestamp, profilePic: profilePic, fcmKey: fcmKey, checkedUnCheck: checkedUnCheck, alreadyExist: success)
        } onError: { (errorMessage) in
            DispatchQueue.main.async {
                hideAllProgressOnView(appDelegateInstance.window!)
                hideProgressOnView(self.view)
                showMessageAlert(message: errorMessage)
            }
        }
    }
    
    private func loginWithFirebase(email: String, password: String, userName: String, role: String, timestamp: String, profilePic: String, fcmKey: String?, checkedUnCheck: String, alreadyExist: Bool){
        
        let pass = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PASSWORD) ?? ""
        
        loginUserViewModel.addEmployeeLoginWithFirebase(email: email, password: pass, userName: userName, role: role, timestamp: timestamp, profilePic: profilePic, fcmKey: fcmKey, checkedUnCheck: checkedUnCheck, alreadyExistEmployee: alreadyExist) { (success) in
            //  if self.user != nil{
            //   self.saveDataToUserDefaults(user: self.user!)
            DispatchQueue.main.async {
                
                hideProgressOnView(self.view)
                print("Logged in with firebase successfully")
                //                self.navigationController?.popViewController(animated: true)
            }
        } onError: { (errorMessage) in
            DispatchQueue.main.async {
                hideAllProgressOnView(appDelegateInstance.window!)
                hideProgressOnView(self.view)
                showMessageAlert(message: errorMessage)
            }
        }
    }
    
    func createGroupRoom()
    {
        let groupTitle =  self.groupNameTxtField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !groupTitle.isEmpty else {
            showMessageAlert(message: "Please enter group name")
            return
        }
        if employeeIdArray.count > 0
        {}
        else
        {
            showMessageAlert(message: "Please enter atleast one employee")
            return
        }
        guard let senderID = UserDefaults.standard.string(forKey: "userId") else { return }
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let type = "group"
        //        var profileImgStr = ""
        if self.groupFirebaseUrlStr == ""
        {
            self.groupFirebaseUrlStr = IMAGE_BASE_URL + "public/default_group_icon.jpg"
        }
        
        print(self.groupFirebaseUrlStr)
        
        //        profileImgStr = IMAGE_BASE_URL + "public/default_group_icon.jpg"
        //        print(profileImgStr)
        
        let request = GroupChatRoom(users: employeeIdArray, lastMessageText: "", lastMessage: "\(timestamp)", type: type, creator: senderID, timestamp: "\(timestamp)", meta: GroupChatMeta(title: groupTitle, description: "", icon: self.groupFirebaseUrlStr, broadcat: false))
        
        //        let request = GroupChatRoom(users: userIdArray, lastMessageText: "", lastMessage: "\(timestamp)", type: type, creator: senderID, timestamp: "\(timestamp)", meta: GroupChatMeta(title: groupTitle, description: "", icon: profileImgStr, broadcat: false))
        
        loginUserViewModel.createGroupRoom(request: request) { result in
            print(result as Any)
            self.navigationController?.popViewController(animated: true)
            
        } onError: { error in
            print(error)
        }
    }
    
}
