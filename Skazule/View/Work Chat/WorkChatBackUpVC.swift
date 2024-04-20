//
//  WorkChatBackUpVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 17/07/23.
//

import UIKit

class WorkChatBackUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
//import UIKit
//import SwiftyJSON
//import FirebaseAuth
//import FirebaseDatabase
//import FirebaseStorage
//
//var myChatUserList   = [FBDChatRoom]()
//var myChatUserListArrDict   = [String: Any]()
//var userIdArray = [String]()
//var userList = [String:Any]()
//var chatType = "individual"
//var roomDataDictArr = [String: AnyObject]()
//
//class WorkChatVC: UIViewController {
//    
//    @IBOutlet weak var customNavigationBarForDrawer: CustomNavigationBarForDrawer!
//    @IBOutlet weak var tblView: UITableView!
//    
//    var group = DispatchGroup()
//    
//    
//    var segmentIndex    = 0
//    var actionSheetOption1Title = "New Chat"
//    var users = [FirebaseUser]()
//    let chatViewModel = ChatViewModel()
//    var email = ""
//    
//    // MARK: - Pull-to-Refresh   // PtR 1
//    lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action:
//                                    #selector(self.handleRefresh(_:)),
//                                 for: .valueChanged)
//        refreshControl.tintColor = .black
//        return refreshControl
//    }()
//    // PtR 2
//    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
//        //currentPageIndex = 1
//        //self.getTimeLineListApi()
//        //refreshControl.endRefreshing()
//        self.getUserListByRoomId()
//        
//        async {
//            do {
//                let data = try await downloadData(from: urls)
//                print("Downloaded data:", data)
//            } catch {
//                print("Error:", error)
//            }
//        }
//        
//        
//        
//        
//        
//        
//        
//        //self.getUsersList()
//        refreshControl.endRefreshing()
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        self.customNavigationBarForDrawer.titleLabel.text = "Work Chat"
//        customNavigationBarForDrawer.rightBtn.isHidden    = false
//        let moreBtnImage =  #imageLiteral(resourceName: "dots")
//        customNavigationBarForDrawer.rightBtn.setImage(moreBtnImage, for: .normal)
//        customNavigationBarForDrawer.rightBtn.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
//        
//        if segmentIndex == 0
//        {
//            //customNavigationBarForDrawer.rightBtn.isHidden = true
//            //self.getUsersList()
//            //            self.getUserListByRoomId()
////            var cds = self.getUserListByRoomId()
////
////            print("Count - \(cds.count)")
//            
//            //            self.group.notify(queue: .main) {
//            //
//            //                      //  print("&&&&&&%%%%%%$$$$$$#####\(myChatUserList.count)")
//            //                    }
//            
//            
//            
//            
//            
//        }
//        else
//        {
//            //customNavigationBarForDrawer.rightBtn.isHidden = false
//        }
//        self.tblView.register(UINib(nibName: "WorkChatEmployeeListCell", bundle: .main), forCellReuseIdentifier: "WorkChatEmployeeListCell")
//        
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
//        tblView.addSubview(refreshControl) //
//    }
//    
//    @objc func didTapMoreButton (_ sender:UIButton) {
//        print("More Button is selected")
//        openActionSheet()
//    }
//    @objc func refresh(_ sender: AnyObject) {
//        //getUsersList()
//        self.getUserListByRoomId()
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        
//        // add the UIRefreshControl object to the UITableView object. // PtR 3
//        self.tblView.addSubview(self.refreshControl)
//        
//        self.getUserListByRoomId()
//        
//        print("Count - \(myChatUserList.count)")
//        
//    }
//    @IBAction func onClickSegment(_ sender: UISegmentedControl) {
//        if sender.selectedSegmentIndex == 0
//        {
//            self.segmentIndex = 0
//            //self.getUsersList()
//            
//           // self.getUserListByRoomId()
//            
//            
//            
//            
//            
//            
//            //customNavigationBarForDrawer.rightBtn.isHidden = true
//            self.actionSheetOption1Title = "New Chat"
//            self.tblView.reloadData()
//        }
//        else
//        {
//            self.segmentIndex = 1
//            self.actionSheetOption1Title = "New Group"
//            //self.getGroupUsersList()
//            //customNavigationBarForDrawer.rightBtn.isHidden = false
//            //            let moreBtnImage =  #imageLiteral(resourceName: "dots")
//            //            customNavigationBarForDrawer.rightBtn.setImage(moreBtnImage, for: .normal)
//            //            customNavigationBarForDrawer.rightBtn.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
//            self.tblView.reloadData()
//        }
//    }
//    
//    func dnkffks()
//    {
//        print("Get users list")
//        chatViewModel.getUsersList { (usersList) in
//            self.users = usersList
//            DispatchQueue.main.async {
//                self.tblView.refreshControl?.endRefreshing()
//                self.tblView.reloadData()
//                //                self.messagesTableView.reloadData()
//                //                self.hideLoading()
//            }
//            
//        } onError: { (errorMessage) in
//            print(errorMessage)
//        }
//    }
//    
//    
//    //    func getUserListByRoomId(){
//    //        guard let employerId = UserDefaults.standard.string(forKey: "userId") else { return }
//    //        chatViewModel.getRoomId(senderID: employerId)
//    ////        self.group.notify(queue: .main) {
//    ////
//    ////            print("&&&&&&%%%%%%$$$$$$#####\(myChatUserList.count)")
//    ////        }
//    ////
//    //    }
//    private let fdbRef = Database.database().reference()
//    
//    func getUserListByRoomId() async throws -> [FBDChatRoom]{
//        
//        let result = [FBDChatRoom]()
//        
//        var UserID = [String]()
//        var RoomID = [String]()
//        var RoomData = [NSMutableDictionary]()
//        
//        
//        let senderID = UserDefaults.standard.string(forKey: "userId")
//        myChatUserList.removeAll()
//        
//        //        group.enter()
//        fdbRef.child("chatRoom").queryOrdered(byChild: "users/"+(senderID ?? "")).queryEqual(toValue: true).observeSingleEvent(of: .value) { snapshot in
//            // print(snapshot)
//            // NotificationCenter.default.post(name: NSNotification.Name("Message"), object: nil)
//            guard snapshot.exists() else { return }
//            if let dataDict = snapshot.value as? [String:AnyObject]{
//                var result: [String:AnyObject] = [:]
//                
// 
//                    
//                for (key, _) in dataDict {
//                    if dataDict[key]?["type"] as! String != "group"
//                    {
//                        result = dataDict[key]?["users"] as! [String : AnyObject]
//                        
//                        RoomID.append(key)
//
//                        
//                        for (userKey,_) in result
//                        {
//                            if(userKey != senderID){
//                                
//                                var user = dataDict[key] as! NSMutableDictionary//[String : Any]
//                                UserID.append(userKey)
//                                RoomData.append(user)
//
//                            }
//                        }
////                        Task{
////                            try? await (self.getMyFriendUser_async(user_id: UserID, roomId: RoomID, roomData: RoomData))
////                        }
//                        let data = try await self.getMyFriendUser_async(user_id: UserID, roomId: RoomID, roomData: RoomData)
//
//                        
//                    }
//                    else{
//                        //want this check and modify this accordin to our condition
//                        var list = [Any]()
//                        list.append(key)
//                        var myChatUserList = [ChatRoomUsers]()
//                        let roomId = key
//                        let roomData = dataDict
//                        let chatRoomUsers = ChatRoomUsers.init(roomId: roomId, roomData: roomData)
//                        myChatUserList.append(chatRoomUsers)
//                    }
//                }
//                
//
//            }
//
//        }
//        
//        return result
//        //        group.leave()
//        //print("##################################################################\(myChatUserList.count)")
//    }
//    
//    private func getMyFriendUser_async(
//        user_id: [String] ,
//        roomId: [String],
//        roomData: [NSMutableDictionary]
//    ) {
//        var firebaseUserData = [Meta2]()
//        
//   
//
//        for  item in user_id {
//                
//                self.fdbRef.child("Users/"+item).observeSingleEvent(of: .value, with: { snapshot in
//                    guard snapshot.exists() else { return }
//                    
//                    
//                    if let dataDict = snapshot.value as? [String:AnyObject]{
//                        
//                        
//                        
//                        let email         = dataDict["email"] as? String
//                        let profile       = dataDict["profile"] as? String
//                        let userId        = dataDict["userId"] as? String
//                        let userName      = dataDict["userName"] as? String
//                        let timestamp     = dataDict["timestamp"] as? String
//                        
//                        let user = Meta2(userId: userId, userName: userName, userEmail: email, userMobile: "", timestamp: timestamp, profileImage: profile)
//                        firebaseUserData.append(user)
//                        
//                        
//                        
//                        let lastMessageText   = roomData[0]["lastMessageText"]
//                        let lastMessage       = roomData[0]["lastMessage"]
//                        let type              = roomData[0]["type"]
//                        let creator           = roomData[0]["creator"]
//                        let meta              = roomData[0]["meta"] as! [String : Any]
//                        let users             = roomData[0]["users"] as! [String : Any]
//                        let user_key          = item
//                        
//                        //                    FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users, user_key: user_key, meta2: user)
//                        //chatRoomObj = FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users, user_key: user_key, meta2: user)
//                        
//                        myChatUserList.append(FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users, user_key: user_key, meta2: user))
//                        
//                        print("valueee------->\(myChatUserList)")
//                        
//                        //print("*************************************************************************\(myChatUserList)")
//                        //print("################################################################3##\(myChatUserList.count)")
//                        
//                    }
//                    //            miniGroup.leave()
//                    //                print("Count   ################################################################3##\(myChatUserList.count)")
//                    
//                    
//                    
//                    
//                })
//            }
//        print("Count-------->>>>###############################################################3##\( myChatUserList.count)")
//
//        }
//     
//
//    
//    
//    func openActionSheet1()
//    {
//        
//        //        let actionSheetAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        //
//        //        for cat in roleListArr {
//        //
//        //            let action = UIAlertAction(title: "", style: .default) { (action) in
//        //                self.lblRoleType.text = cat.name
//        //
//        //            }
//        //
//        //            action.setValue(CATextLayerAlignmentMode.center, forKey: "titleTextAlignment")
//        //            actionSheetAlertController.addAction(action)
//        //        }
//        //
//        //        let cancelActionButton = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
//        //        actionSheetAlertController.addAction(cancelActionButton)
//        //
//        //        self.present(actionSheetAlertController, animated: true, completion: nil)
//        //
//    }
//    
//    func openActionSheet()
//    {
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        
//        let option1 = UIAlertAction(title: self.actionSheetOption1Title, style: .default) { _ in
//            // Handle the selection of option 1
//            if self.segmentIndex == 0
//            {
//                let vc = WCEmployeeListVC()
//                vc.isCommingFrom = self.actionSheetOption1Title
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//            else
//            {
//                let vc = WCCreateGroupVC()
//                vc.isCommingFrom = self.actionSheetOption1Title
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//            
//        }
//        let option1Icon = UIImage(named: "add-group.png")
//        //        option1.setValue(option1Icon?.imageWithSize(scaledToSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal), forKey: "image")
//        option1.setValue(option1Icon?.imageWithSize(scaledToSize: CGSize(width: 25, height: 25)), forKey: "image")
//        
//        let option2 = UIAlertAction(title: "Setting", style: .default) { _ in
//            // Handle the selection of option 2
//        }
//        let option2Icon = UIImage(named: "setting.png")
//        //        option2.setValue(option2Icon?.imageWithSize(scaledToSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal), forKey: "image")
//        option2.setValue(option2Icon?.imageWithSize(scaledToSize: CGSize(width: 25, height: 25)), forKey: "image")
//        
//        
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
//            // Handle the cancellation of the action sheet
//        }
//        
//        actionSheet.addAction(option1)
//        actionSheet.addAction(option2)
//        actionSheet.addAction(cancel)
//        
//        present(actionSheet, animated: true, completion: nil)
//    }
//    func getUsersList(){
//        //print("Get users list")
//        chatViewModel.getUsersList { (usersList) in
//            self.users = usersList
//            DispatchQueue.main.async {
//                self.tblView.refreshControl?.endRefreshing()
//                self.tblView.reloadData()
//                //                self.messagesTableView.reloadData()
//                //                self.hideLoading()
//            }
//            
//        } onError: { (errorMessage) in
//            print(errorMessage)
//        }
//    }
//    
//    
//    
//}
//extension WorkChatVC : UITableViewDelegate,UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        if (self.segmentIndex == 0)
//        {
//            return users.count
//        }
//        else
//        {
//            return 5//groups.count
//        }
//        
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkChatEmployeeListCell", for: indexPath) as? WorkChatEmployeeListCell else {
//            return UITableViewCell()
//        }
//        cell.selectionStyle = .none
//        if (self.segmentIndex == 0)
//        {
//            let info = users[indexPath.row]
//            let imageUrl = info.profilePic ?? ""
//            //            cell.employeeLeftSideImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
//            if imageUrl == ""
//            {
//                cell.employeeLeftSideImgView.image = #imageLiteral(resourceName: "dummy-user")
//            }
//            else
//            {
//                cell.employeeLeftSideImgView.setImage(with: imageUrl)
//            }
//            cell.employeeNameLbl.text = info.name
//            cell.employeeLastMsgLbl.text = info.email
//        }
//        else if (self.segmentIndex == 1)
//        {
//            //            let info = groups[indexPath.row]
//            //            cell.userNameLbl.text = info.name
//        }
//        return cell
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let vc = WorkChatDetailChatVC()
//        vc.receiverId = self.users[indexPath.row].uid ?? "0"
//        vc.name = self.users[indexPath.row].name ?? ""
//        vc.profilePhoto = self.users[indexPath.row].profilePic ?? ""
//        self.navigationController?.pushViewController(vc, animated: true)
//        
//        //        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        //        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
//        //        if (self.segmentIndex == 0)
//        //        {
//        //
//        //            let usersInfo    = self.users[indexPath.row]
//        //            //comment for one to one app
//        //            //let groupsInfo   = self.groups[indexPath.row]
//        //            vc.user = usersInfo
//        //        }
//        //        else if (self.segmentIndex == 1)
//        //        {
//        //
//        //            // let usersInfo    = self.users[indexPath.row]
//        //            let groupsInfo   = self.groups[indexPath.row]
//        //            vc.groupId      = groupsInfo.groupId ?? ""
//        //            let curentUserId = Auth.auth().currentUser?.uid ?? ""
//        //            vc.senderId     = curentUserId
//        //        }
//        //        self.navigationController?.pushViewController(vc, animated: true)
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        95
//    }
//}
//extension UIImage {
//    
//    func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {
//        
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return newImage
//    }
//    
//}
//
//
//
////
////func getUserListByRoomId() -> [FBDChatRoom]{
////
////    //        let group = DispatchGroup()
////
////
////    let senderID = UserDefaults.standard.string(forKey: "userId")
////    myChatUserList.removeAll()
////
////    //        group.enter()
////    fdbRef.child("chatRoom").queryOrdered(byChild: "users/"+(senderID ?? "")).queryEqual(toValue: true).observeSingleEvent(of: .value) { snapshot in
////        // print(snapshot)
////        // NotificationCenter.default.post(name: NSNotification.Name("Message"), object: nil)
////        guard snapshot.exists() else { return }
////        if let dataDict = snapshot.value as? [String:AnyObject]{
////            var result: [String:AnyObject] = [:]
////            for (key, _) in dataDict {
////                if dataDict[key]?["type"] as! String != "group"
////                {
////                    result = dataDict[key]?["users"] as! [String : AnyObject]
////                    for (userKey,_) in result
////                    {
////                        if(userKey != senderID){
////
////                            var user = dataDict[key] as! [String : Any]
////
////                            //                                group.enter()
////                            //myChatUserList.append(self.getMyFriendUser_async(user_id: userKey, roomId: key, roomData: user))
////
////                            let user_id = userKey
////                            let roomId = key
////                            let roomData = user
////                            var firebaseUserData = [Meta2]()
////
////                            self.fdbRef.child("Users/"+user_id).observeSingleEvent(of: .value, with: { snapshot in
////                                guard snapshot.exists() else { return }
////                                //            miniGroup.enter()
////
////                                if let dataDict = snapshot.value as? [String:AnyObject]{
////
////                                    let email         = dataDict["email"] as? String
////                                    let profile       = dataDict["profile"] as? String
////                                    let userId        = dataDict["userId"] as? String
////                                    let userName      = dataDict["userName"] as? String
////                                    let timestamp     = dataDict["timestamp"] as? String
////
////                                    let user = Meta2(userId: userId, userName: userName, userEmail: email, userMobile: "", timestamp: timestamp, profileImage: profile)
////                                    firebaseUserData.append(user)
////
////                                    let lastMessageText   = roomData["lastMessageText"] ?? ""
////                                    let lastMessage       = roomData["lastMessage"] ?? ""
////                                    let type              = roomData["type"] ?? ""
////                                    let creator           = roomData["creator"] ?? ""
////                                    let meta              = roomData["meta"] as! [String : Any]
////                                    let users             = roomData["users"] as! [String : Any]
////                                    let user_key          = user_id
////
////                                    //                                        chatRoomObj = FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users, user_key: user_key, meta2: user)
////                                    myChatUserList.append(FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users, user_key: user_key, meta2: user))
////                                    //print("*************************************************************************\(myChatUserList)")
////                                    print("################################################################3##\(myChatUserList.count)")
////                                }
////                                //            miniGroup.leave()
////                            })
////
////
////
////
////
////
////
////
////
////
////
////                            //                                group.leave()
////                        }
////                    }
////                }
////                else{
////                    //want this check and modify this accordin to our condition
////                    var list = [Any]()
////                    list.append(key)
////                    var myChatUserList = [ChatRoomUsers]()
////                    let roomId = key
////                    let roomData = dataDict
////                    let chatRoomUsers = ChatRoomUsers.init(roomId: roomId, roomData: roomData)
////                    myChatUserList.append(chatRoomUsers)
////                }
////            }
////        }
////    }
////    //        group.leave()
////    print("##################################################################\(myChatUserList.count)")
////
////    return myChatUserList
////
////}
//
///*
// 
// private func getMyFriendUser_async(
//     user_id: String,
//     roomId: String,
//     roomData: [String:Any]
// ) {
//     var firebaseUserData = [Meta2]()
//     var chatRoomObj = FBDChatRoom()
//     //let miniGroup = DispatchGroup()
//     //        miniGroup.enter()
//     fdbRef.child("Users/"+user_id).observeSingleEvent(of: .value, with: { snapshot in
//         guard snapshot.exists() else { return }
//         //            miniGroup.enter()
//         
//         if let dataDict = snapshot.value as? [String:AnyObject]{
//             
//             let email         = dataDict["email"] as? String
//             let profile       = dataDict["profile"] as? String
//             let userId        = dataDict["userId"] as? String
//             let userName      = dataDict["userName"] as? String
//             let timestamp     = dataDict["timestamp"] as? String
//             
//             let user = Meta2(userId: userId, userName: userName, userEmail: email, userMobile: "", timestamp: timestamp, profileImage: profile)
//             firebaseUserData.append(user)
//             
//             let lastMessageText   = roomData["lastMessageText"] ?? ""
//             let lastMessage       = roomData["lastMessage"] ?? ""
//             let type              = roomData["type"] ?? ""
//             let creator           = roomData["creator"] ?? ""
//             let meta              = roomData["meta"] as! [String : Any]
//             let users             = roomData["users"] as! [String : Any]
//             let user_key          = user_id
//             
//             chatRoomObj = FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users, user_key: user_key, meta2: user)
//             //                myChatUserList.append(FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users, user_key: user_key, meta2: user))
//             //print("*************************************************************************\(myChatUserList)")
//             //print("################################################################3##\(myChatUserList.count)")
//         }
//         //            miniGroup.leave()
//     })
//  
// }
// */
