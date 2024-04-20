//
//  WorkChatVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit
import SwiftyJSON
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

var myChatUserList   = [FBDChatRoom]()
var myGroupChatUserList   = [FBDChatRoom]()
var myChatUserListArrDict   = [String: Any]()
var userIdArray = [String]()
var userList = [String:Any]()
var chatType = "individual"
var roomDataDictArr = [String: AnyObject]()

class WorkChatVC: UIViewController {
    
    @IBOutlet weak var customNavigationBarForDrawer: CustomNavigationBarForDrawer!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    //1 For search
    var filterUserList   = [FBDChatRoom]()
    var filterGroupUserList   = [FBDChatRoom]()
    
    @IBOutlet weak var emptyView: UIView!
    private let fdbRef = Database.database().reference()
    
    var segmentIndex    = 0
    var actionSheetOption1Title = "New Chat"
    var users = [FirebaseUser]()
    let chatViewModel = ChatViewModel()
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        // Apply the font attributes to the segmented control's text
        self.segmentControl.setTitleTextAttributes(segmentFontAttributes, for: .normal)
    }
    override func viewDidDisappear(_ animated: Bool) {
        hideAllProgressOnView(appDelegateInstance.window!)
        // Apply the font attributes to the segmented control's text
        self.segmentControl.setTitleTextAttributes(segmentFontAttributes, for: .normal)
    }
    private func configure()
    {
        // Set Cutom navigation
        self.customNavigationBarForDrawer.titleLabel.text = "Work Chat"
        customNavigationBarForDrawer.rightBtn.isHidden    = false
        let moreBtnImage =  #imageLiteral(resourceName: "dots")
        customNavigationBarForDrawer.rightBtn.setImage(moreBtnImage, for: .normal)
        customNavigationBarForDrawer.rightBtn.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        //Register Table cell
        self.tblView.register(UINib(nibName: "WorkChatEmployeeListCell", bundle: .main), forCellReuseIdentifier: "WorkChatEmployeeListCell")
        //For search
        self.searchTextField.delegate = self
        self.searchTextField.text = ""
    }
    @objc func didTapMoreButton (_ sender:UIButton) {
        print("More Button is selected")
        self.openActionSheet()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.segmentIndex = 0
        self.segmentControl.selectedSegmentIndex = 0
        updateGroupUserInfoStatus = "1"
        // Firstly get FBRoom Id
        let senderID = UserDefaults.standard.string(forKey: "userId") ?? ""
        showProgressOnView(appDelegateInstance.window!)
        self.getFirebaseRoomId(senderID: senderID) { user in
            print(user.count)
            print("call and get api response")
            DispatchQueue.main.async {
                hideAllProgressOnView(appDelegateInstance.window!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 ) {
                    self.filterUserList = myChatUserList
                    self.filterGroupUserList = myGroupChatUserList
                    
                    if myChatUserList.count == 0
                    {
                        self.tblView.isHidden   = true
                        self.emptyView.isHidden = false
                    }
                    else
                    {
                        self.tblView.isHidden   = false
                        self.emptyView.isHidden = true
                    }
                    self.tblView.reloadData()
                }
                self.tblView.reloadData()
            }
        }
    }
    func getFirebaseRoomId(senderID: String, onSuccess:@escaping([FBDChatRoom]) -> Void){
        self.filterUserList.removeAll()
        self.filterGroupUserList.removeAll()
        myChatUserList.removeAll()
        myGroupChatUserList.removeAll()
        fdbRef.child("chatRoom").queryOrdered(byChild: "users/"+senderID).queryEqual(toValue: true).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists()
            {}
            else
            {
                hideAllProgressOnView(appDelegateInstance.window!)
                if myChatUserList.count == 0
                {
                    self.tblView.isHidden   = true
                    self.emptyView.isHidden = false
                }
                else
                {
                    self.tblView.isHidden   = false
                    self.emptyView.isHidden = true
                }
            }
            guard snapshot.exists() else {
                hideAllProgressOnView(appDelegateInstance.window!)
                return
            }
            if let dataDict = snapshot.value as? [String:AnyObject]{
                var result: [String:AnyObject] = [:]
                for (key, _) in dataDict {
                    
                    if dataDict[key]?["type"] as! String != "group"
                    {
                        result = dataDict[key]?["users"] as! [String : AnyObject]
                        for (userKey,_) in result
                        {
                            if(userKey != senderID){
                                let user1 = dataDict[key] as! [String : Any]
                                var firebaseUserData = [Meta2]()
                                
                                self.fdbRef.child("Users/"+userKey).observeSingleEvent(of: .value, with: { snapshot in
                                    guard snapshot.exists() else { return }
                                    
                                    if let dataDict = snapshot.value as? [String:AnyObject]{
                                        
                                        let email         = dataDict["email"] as? String
                                        let profile       = dataDict["profile"] as? String
                                        let userId        = dataDict["userId"] as? String
                                        let userName      = dataDict["userName"] as? String
                                        let timestamp     = dataDict["timestamp"] as? String
                                        
                                        let user = Meta2(userId: userId, userName: userName, userEmail: email, userMobile: "", timestamp: timestamp, profileImage: profile)
                                        firebaseUserData.append(user)
                                        
                                        let lastMessageText   = user1["lastMessageText"] ?? ""
                                        let lastMessage       = user1["lastMessage"] ?? ""
                                        let type              = user1["type"] ?? ""
                                        let creator           = user1["creator"] ?? ""
                                        let meta              = user1["meta"] as! [String : Any]
                                        let users             = user1["users"] as! [String : Any]
                                        let user_key          = userKey
                                        let roomId            = key
                                        
                                        myChatUserList.append(FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users,roomId: roomId, user_key: user_key, meta2: user))
                                        print("****************************\(myChatUserList)")
                                        
                                        DispatchQueue.main.async {
                                            let sortedUserArray = self.sortSingleChatUsersListByTime(usersArray: myChatUserList)
                                            myChatUserList.removeAll()
                                            myChatUserList = sortedUserArray
                                            onSuccess(myChatUserList)
                                        }
                                    }
                                })
                            }
                        }
                    }
                    else
                    {
                        let groupUserData     = dataDict[key] as! [String : Any]
                        let lastMessageText   = groupUserData["lastMessageText"] ?? ""
                        let lastMessage       = groupUserData["lastMessage"] ?? ""
                        let type              = groupUserData["type"] ?? ""
                        let creator           = groupUserData["creator"] ?? ""
                        let meta              = groupUserData["meta"] as! [String : Any]
                        let users             = groupUserData["users"] as! [String : Any]
                        let roomId            = key
                        
                        myGroupChatUserList.append(FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users,roomId: roomId))
                        
                        DispatchQueue.main.async {
                            let sortedUserArray = self.sortGroupChatUsersListByTime(usersArray: myGroupChatUserList)
                            myGroupChatUserList.removeAll()
                            myGroupChatUserList = sortedUserArray
                            onSuccess(myGroupChatUserList)
                        }
                    }
                }
                onSuccess(myChatUserList)
            }
        }
    }
    
    /*
     private func sortSingleChatUsersListByTime(usersArray: [FBDChatRoom]) -> [FBDChatRoom] {
     
     var arrayWithTimeStamp = [FBDChatRoom]()
     var arrayWithoutTimeStap = [FBDChatRoom]()
     
     usersArray.forEach { (user) in
     if user.meta2?.timestamp == nil{
     arrayWithoutTimeStap.append(user)
     }else{
     arrayWithTimeStamp.append(user)
     }
     }
     arrayWithTimeStamp = arrayWithTimeStamp.sorted(by: { ($0.meta2?.timestamp)! > ($1.meta2?.timestamp)! })
     let newArray = arrayWithTimeStamp + arrayWithoutTimeStap
     return newArray
     }
     */
    private func sortSingleChatUsersListByTime(usersArray: [FBDChatRoom]) -> [FBDChatRoom] {
        
        var arrayWithTimeStamp = [FBDChatRoom]()
        var arrayWithoutTimeStap = [FBDChatRoom]()
        
        usersArray.forEach { (user) in
            if user.lastMessage == nil{
                arrayWithoutTimeStap.append(user)
            }else{
                arrayWithTimeStamp.append(user)
            }
        }
        arrayWithTimeStamp = arrayWithTimeStamp.sorted(by: { ($0.lastMessage)! > ($1.lastMessage)! })
        let newArray = arrayWithTimeStamp + arrayWithoutTimeStap
        return newArray
    }
    
    private func sortGroupChatUsersListByTime(usersArray: [FBDChatRoom]) -> [FBDChatRoom] {
        
        var arrayWithTimeStamp = [FBDChatRoom]()
        var arrayWithoutTimeStap = [FBDChatRoom]()
        
        usersArray.forEach { (user) in
            if user.lastMessage == nil{
                arrayWithoutTimeStap.append(user)
            }else{
                arrayWithTimeStamp.append(user)
            }
        }
        arrayWithTimeStamp = arrayWithTimeStamp.sorted(by: { ($0.lastMessage)! > ($1.lastMessage)! })
        let newArray = arrayWithTimeStamp + arrayWithoutTimeStap
        return newArray
    }
    @IBAction func onClickSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0
        {
            self.searchTextField.text = ""
            self.segmentIndex = 0
            self.filterUserList.removeAll()
            self.filterUserList = myChatUserList
            self.actionSheetOption1Title = "New Chat"
            if myChatUserList.count == 0
            {
                self.tblView.isHidden   = true
                self.emptyView.isHidden = false
            }
            else
            {
                self.tblView.isHidden   = false
                self.emptyView.isHidden = true
            }
            //self.tblView.reloadData()
        }
        else
        {
            self.searchTextField.text = ""
            self.segmentIndex = 1
            self.filterGroupUserList.removeAll()
            self.filterGroupUserList = myGroupChatUserList
            self.actionSheetOption1Title = "New Group"
            if myGroupChatUserList.count == 0
            {
                self.tblView.isHidden   = true
                self.emptyView.isHidden = false
            }
            else
            {
                self.tblView.isHidden   = false
                self.emptyView.isHidden = true
            }
            //self.tblView.reloadData()
        }
        DispatchQueue.main.async {
            self.tblView.reloadData()
        }
    }
    private func openActionSheet()
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let option1 = UIAlertAction(title: "New Chat", style: .default) { _ in
            let vc = WCEmployeeListVC()
            vc.isCommingFrom = self.actionSheetOption1Title
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let option1Icon = UIImage(named: "newChat.png")
        option1.setValue(option1Icon?.imageWithSize(scaledToSize: CGSize(width: 25, height: 25)), forKey: "image")
        
        let option2 = UIAlertAction(title: "New Group", style: .default) { _ in
            let vc = WCCreateGroupVC()
            vc.isCommingFrom = self.actionSheetOption1Title
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let option2Icon = UIImage(named: "add-group.png")
        option2.setValue(option2Icon?.imageWithSize(scaledToSize: CGSize(width: 25, height: 25)), forKey: "image")
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Handle the cancellation of the action sheet
        }
        //        // Change icon color
        //        let iconColor = UIColor.black // Change the desired icon color
        //        option1.setValue(iconColor, forKey: "imageTintColor")
        //        option2.setValue(iconColor, forKey: "imageTintColor")
        
        actionSheet.addAction(option1)
        actionSheet.addAction(option2)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    // Helper function to filter data based on search text
    func filterData(searchText: String) {
        
        print(self.segmentIndex)
        if (self.segmentIndex == 0)
        {
            if searchText.isEmpty {
                self.filterUserList = myChatUserList
            } else {
                print(self.filterUserList.count)
                self.filterUserList = myChatUserList.filter { $0.meta2?.userName!.lowercased().contains(searchText.lowercased()) ?? false }
                print(self.filterUserList.count)
            }
        }
        else
        {
            if searchText.isEmpty
            {
                self.filterGroupUserList = myGroupChatUserList
            }
            else
            {
                print(self.filterGroupUserList.count)
                self.filterGroupUserList = searchGroupUser(searchText: searchText)
                print(self.filterGroupUserList.count)
            }
        }
        tblView.reloadData()
    }
    func searchGroupUser(searchText:String) -> [FBDChatRoom] {
        return myGroupChatUserList.filter { model in
            guard let value = model.meta!["title"] as? String else {
                return false
            }
            return value.localizedCaseInsensitiveContains(searchText)
        }
    }
}
extension WorkChatVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.segmentIndex == 0)
        {
            return self.filterUserList.count//myChatUserList.count
        }
        else
        {
            return self.filterGroupUserList.count //myGroupChatUserList.count //5//groups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkChatEmployeeListCell", for: indexPath) as? WorkChatEmployeeListCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        if (self.segmentIndex == 0)
        {
            if (myChatUserList.count > 0)
            {
                //let info = myChatUserList[indexPath.row]
                let info = self.filterUserList[indexPath.row]
                
                print(info)
                
                if info.type == "group"
                {
                    let metaArray: [String:Any] = info.meta!
                    print(metaArray)
                    cell.employeeNameLbl.text = metaArray["title"] as? String
                    cell.employeeLastMsgLbl.text = info.lastMessageText
                    
                    let imageUrl = metaArray["icon"] as? String
                    cell.employeeLeftSideImgView.sd_setImage(with: URL(string:imageUrl ?? ""), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
                    /*
                     if imageUrl == ""
                     {
                     cell.employeeLeftSideImgView.image = #imageLiteral(resourceName: "dummy-user")
                     }
                     else
                     {
                     cell.employeeLeftSideImgView.setImage(with: imageUrl!)
                     }
                     */
                }
                else
                {
                    let imageUrl = info.meta2?.profileImage ?? ""
                    if imageUrl == ""
                    {
                        cell.employeeLeftSideImgView.image = #imageLiteral(resourceName: "dummy-user")
                    }
                    else
                    {
                        cell.employeeLeftSideImgView.setImage(with: imageUrl)
                    }
                    cell.employeeNameLbl.text = info.meta2?.userName
                    cell.employeeLastMsgLbl.text = info.lastMessageText
                }
                print("&&&&&&%%%%%%$$$$$$#####\(info.type ?? "")")
            }
        }
        else
        {
            if (myGroupChatUserList.count > 0)
            {
                //                let info = myGroupChatUserList[indexPath.row]
                let info = filterGroupUserList[indexPath.row]
                let metaArray: [String:Any] = info.meta!
                print(metaArray)
                cell.employeeNameLbl.text = metaArray["title"] as? String
                cell.employeeLastMsgLbl.text = info.lastMessageText
                
                let imageUrl = metaArray["icon"] as? String
                cell.employeeLeftSideImgView.sd_setImage(with: URL(string:imageUrl ?? ""), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WorkChatDetailChatVC()
        vc.isCommingFrom = "\(actionSheetOption1Title)"
        if (self.segmentIndex == 0)
        {
            //if (myChatUserList.count > 0){
            if (filterUserList.count > 0){
                //let info = myChatUserList[indexPath.row]
                let info = filterUserList[indexPath.row]
                print(info)
                if (info.meta?["broadcat"]) as! Int == 0
                {
                    vc.isBroadcast   = false
                }
                else
                {
                    vc.isBroadcast   = true
                }
                vc.name = info.meta2?.userName ?? ""
                vc.roomId = info.roomId ?? ""
                vc.receiverId = info.meta2?.userId ?? ""
                vc.profilePhoto = info.meta2?.profileImage ?? ""
                vc.myChatUserDetail = info
            }
        }
        else
        {
            //if (myGroupChatUserList.count > 0){
            if (filterGroupUserList.count > 0){
                //let info = myGroupChatUserList[indexPath.row]
                let info = filterGroupUserList[indexPath.row]
                print(info)
                if (info.meta?["broadcat"]) as! Int == 0
                {
                    vc.isBroadcast   = false
                }
                else
                {
                    vc.isBroadcast   = true
                }
                vc.name = info.meta2?.userName ?? ""
                vc.roomId = info.roomId ?? ""
                vc.receiverId = info.meta2?.userId ?? ""
                vc.profilePhoto = info.meta2?.profileImage ?? ""
                vc.myChatUserDetail = info
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        95
    }
}
extension WorkChatVC: UITextFieldDelegate
{
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        self.filterData(searchText: searchText)
        return true
    }
}
