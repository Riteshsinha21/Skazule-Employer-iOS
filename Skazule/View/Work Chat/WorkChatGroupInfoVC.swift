//
//  WorkChatGroupInfoVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 27/07/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

var updateGroupRoomId   = ""
var updateGroupTitle    = ""
var alreadyAddedUserArr = [String]()
var updateGroupUserInfoStatus = "1"
var groupImgFullUrlStr = ""

class WorkChatGroupInfoVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var groupImg: UIImageView!
    @IBOutlet weak var addParticipantBtn: UIButton!
    @IBOutlet weak var groupNameLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var myChatDetail    = FBDChatRoom()
    var userInfo        = [String:Any]()
    var usersDetailArr  = [FirebaseUser1]()
    private let fdbRef  = Database.database().reference()
    var fdbSenderId     = ""
    //For work chat with firebase
    private let loginUserViewModel = UserViewModel()
    //Custom View
    var addParticipantPopUP : WCAddParticipantPopUP!
    
    // Create a DispatchGroup
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.titleLabel.text = "Group Info"
        self.tblView.register(UINib(nibName: "WorkChatEmployeeListCell", bundle: .main), forCellReuseIdentifier: "WorkChatEmployeeListCell")
        
        let metaArray: [String:Any] = myChatDetail.meta!
        print(metaArray)
        self.groupNameLbl.text = metaArray["title"] as? String
        let imageUrl = metaArray["icon"] as? String
        groupImgFullUrlStr = imageUrl ?? ""
        self.groupImg.sd_setImage(with: URL(string:imageUrl ?? ""), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        
        self.userInfo.removeAll()
        if myChatDetail.users?.count ?? 0 > 0
        {
            self.userInfo = myChatDetail.users!
            
            alreadyAddedUserArr.removeAll()
            for (key,_) in self.userInfo
            {
                alreadyAddedUserArr.append(key)
            }
        }
        print(alreadyAddedUserArr)
        print(self.userInfo)
        /*
         self.getUserInfo()
         */
        if updateGroupUserInfoStatus == "1"
        {
            self.getFirstTimeUserInfo()
        }
        else
        {
            self.getUserInfo()
        }
        
        // Define a notification name as a string constant
        let myNotificationName = Notification.Name("MyCustomNotification")
        // Add the observer in your view controller or any other class
        NotificationCenter.default.addObserver(self, selector: #selector(handleCustomNotification), name: myNotificationName, object: nil)
        
    }
    // Define a function to handle the notification
    @objc func handleCustomNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            self.getUserInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fdbSenderId = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        updateGroupRoomId = myChatDetail.roomId ?? ""
    }
    
    func getFirstTimeUserInfo()
    {
        self.usersDetailArr.removeAll()
        for (key,_) in self.userInfo
        {
            print(key)
            dispatchGroup.enter()
            
            getUserInfoFromFirebase(userId: key) { result in
                self.dispatchGroup.leave()
                print(self.usersDetailArr.count)
            }
        }
        // Notify when all tasks are done
        dispatchGroup.notify(queue: .main) {
            // This code will be executed when all tasks are completed
            print("All Firebase calls completed.")
            
            //for remove duplicates from usersDetailArr
            var uniqueUsers = [FirebaseUser1]()
            for user in self.usersDetailArr {
                if !uniqueUsers.contains(where: { $0.email == user.email }) {
                    uniqueUsers.append(user)
                }
            }
            self.usersDetailArr.removeAll()
            self.usersDetailArr = uniqueUsers
            self.tblView.reloadData()
        }
    }
    
    private func getUserInfo() {
        
        if userIdArray.count > self.userInfo.count
        {
            for (index, value) in userIdArray.enumerated() {
                if let matchingKey = self.userInfo.keys.first(where: { $0 == value }) {
                    let matchingIndex = index
                    print("Value \(value) at index \(matchingIndex) matches key \(matchingKey) in the dictionary.")
                }
                else
                {
                    let arrayValue = userIdArray[index]
                    self.userInfo[arrayValue] = true
                }
            }
        }
        if (userIdArray.count < self.userInfo.count) && (userIdArray.count != 0)
        {
            
            self.userInfo.removeAll()
            for item in userIdArray {
                self.userInfo[item] = true
            }
        }
        
        self.usersDetailArr.removeAll()
        //        if self.userInfo.count == userIdArray.count
        //        {
        for (key,_) in self.userInfo
        {
            print(key)
            dispatchGroup.enter()
            
            getUserInfoFromFirebase(userId: key) { result in
                self.dispatchGroup.leave()
                print(self.usersDetailArr.count)
                
            }
        }
        // Notify when all tasks are done
        dispatchGroup.notify(queue: .main) {
            // This code will be executed when all tasks are completed
            print("All Firebase calls completed.")
            
            // We use code line 207 to 215(before tblView reloadData ) for remove duplicates from usersDetailArr
            var uniqueUsers = [FirebaseUser1]()
            for user in self.usersDetailArr {
                if !uniqueUsers.contains(where: { $0.email == user.email }) {
                    uniqueUsers.append(user)
                }
            }
            self.usersDetailArr.removeAll()
            self.usersDetailArr = uniqueUsers
            self.tblView.reloadData()
        }
    }
    func getUserInfoFromFirebase(userId: String, onSuccess:@escaping(String) -> Void){
        fdbRef.child("Users").queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists() else { return }
            
            if let dataDict = snapshot.value as? [String:AnyObject]{
                let email     = dataDict[userId]!["email"] as? String
                let profile   = dataDict[userId]!["profile"] as? String
                let userId1    = dataDict[userId]!["userId"] as? String
                let userName  = dataDict[userId]!["userName"] as? String
                let timestamp = dataDict[userId]!["timestamp"] as? String
                
                if userId == userId1
                {
                    
                    let user = FirebaseUser1(email: email, profile: profile, userId: userId1, userName: userName, timestamp: timestamp)
                    //                print(user)
                    print(self.usersDetailArr.count)
                    print(self.userInfo.count)
                    print(userIdArray.count)
                    self.usersDetailArr.append(user)
                }
                onSuccess("true")
                
            }
        }
        
    }
    
    @IBAction func onTapAddParticipantsBtn(_ sender: Any) {
        //self.showCustomPopUp()
        
        let groupTitle = self.groupNameLbl.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if groupTitle == ""
        {
            showMessageAlert(message: "Please enter group name first")
        }
        else
        {
            updateGroupTitle = groupTitle
            
            userIdArray.removeAll()
            for i in 0..<self.usersDetailArr.count {
                let employeeId = self.usersDetailArr[i].userId ?? ""
                userIdArray.append(employeeId)
            }
            
            self.showCustomPopUp()
        }
    }
    
    func showCustomPopUp(){
        self.addParticipantPopUP = WCAddParticipantPopUP(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        /*
         self.addParticipantPopUP.addParticipantBtn.addTarget(self, action: #selector(self.addParticipantButtonPressed), for: .touchUpInside)
         */
        self.view.addSubview(self.addParticipantPopUP)
    }
    @objc func addParticipantButtonPressed(sender: UIButton) {
        self.updateGroupUsers()
    }
    func updateGroupUsers()
    {
        let groupTitle = self.groupNameLbl.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !groupTitle.isEmpty else { return }
        guard let roomId = myChatDetail.roomId else { return }
        guard let senderID = UserDefaults.standard.string(forKey: "userId") else { return }
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let type = "group"
        var profileImgStr = ""
        
        profileImgStr = IMAGE_BASE_URL + "public/default_group_icon.jpg"
        print(profileImgStr)
        
        employeeIdArray.removeAll()
        for i in 0..<self.usersDetailArr.count {
            let employeeId = self.usersDetailArr[i].userId ?? ""
            employeeIdArray.append(employeeId)
        }
        
        let request = GroupChatRoom(users: employeeIdArray, lastMessageText: "", lastMessage: "\(timestamp)", type: type, creator: senderID, timestamp: "\(timestamp)", meta: GroupChatMeta(title: groupTitle, description: "", icon: profileImgStr, broadcat: false))
        
        loginUserViewModel.updateGroupRoom(request: request, roomId: roomId) { result in
            print(result as Any)
            self.addParticipantPopUP.removeFromSuperview()
            self.getUserInfo()
        } onError: { error in
            print(error)
        }
    }
    
    @objc func employeeDeleteBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        var info = self.usersDetailArr[index]
        guard let roomId = myChatDetail.roomId else { return }
        guard let userId = info.userId else { return }
        print(roomId)
        print(userId)
        
        //Remove value from child
        fdbRef.child("chatRoom").child("\(roomId)").child("users").child("\(userId)").removeValue()
        
        DispatchQueue.main.async {
            let valueToRemove = "\(userId)"
            // Find the index of the user detail in the array
            if let index = self.usersDetailArr.firstIndex(where: { $0.userId == valueToRemove }) {
                // Remove the user from the array
                self.usersDetailArr.remove(at: index)
            }
            userIdArray.removeAll()
            for i in 0..<self.usersDetailArr.count
            {
                userIdArray.append(self.usersDetailArr[i].userId ?? "")
            }
            
            // Print the updated array
            print(self.usersDetailArr)
            self.tblView.reloadData()
        }
        
        // For manage participant list
        updateGroupUserInfoStatus = "0"
    }
    
}
extension WorkChatGroupInfoVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.usersDetailArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkChatEmployeeListCell") as! WorkChatEmployeeListCell
        cell.selectionStyle = .none
        cell.employeeCheckBoxBackView.isHidden  = true
        cell.employeeDeleteBtnBackView.isHidden = false
        let info = self.usersDetailArr[indexPath.row]
        cell.employeeNameLbl.text               = info.userName
        cell.employeeLastMsgLbl.text            = ""
        
        cell.employeeLeftSideImgView.sd_setImage(with: URL(string: info.profile ?? ""), placeholderImage: UIImage(named: "profilePlaceHolder"))
        
        if fdbSenderId == info.userId
        {
            cell.employeeDeleteBtn.isHidden = true
        }
        else
        {
            cell.employeeDeleteBtn.isHidden = false
            cell.employeeDeleteBtn.tag = indexPath.row
            cell.employeeDeleteBtn.addTarget(self, action: #selector(employeeDeleteBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 95 //UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
}
