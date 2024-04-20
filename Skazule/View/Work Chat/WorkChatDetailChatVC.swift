//
//  WorkChatDetailChatVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 28/06/23.
//

import UIKit
import FirebaseAuth
import MobileCoreServices
import SwiftyJSON
import FirebaseDatabase
import FirebaseStorage

struct NotificationKeys {
    static let MESSAGE = "Message"
}
var broadcastSelectionStatus  = false
var discussionSelectionStatus = true
var webViewImgUrlStr = ""

class WorkChatDetailChatVC: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var sendMsgTxtView: UITextView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var messageViewBottomConstraint: NSLayoutConstraint!
    
    var senderProfilePic = ""
    
    var isCommingFrom       = ""
    var isBroadcast         = false
    private let fdbRef      = Database.database().reference()
    var myChatUserDetail    = FBDChatRoom()
    
    //Custom View
    var imagePopUp : WCViewImagePopUp!
    var settingPopUp : WCSettingPopUp!
    var roomId = ""
    var user: FirebaseUser?
    var profilePhoto = String()
    let imagePicker = UIImagePickerController()
    var name = ""
    var profilePicUrl = ""
    var firstmessages = ""
    var fcmKeys = [JSON]()
    private let chatViewModel = ChatViewModel()
    var messages = [Message2]()
    var senderId   = ""
    var receiverId = ""
    
    @IBOutlet weak var receiverProfileImgView: UIImageView!
    @IBOutlet weak var receiverName: UILabel!
    
    var userInfo   = [String:Any]()
    var usersInfoDetailArr  = [FirebaseUser1]()
    var reciverFCMKey = ""
    //private let fdbRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\(myChatUserDetail)")
        print("\(isCommingFrom)")
        
        self.setDetail()
        self.userInfoDetail()
        
        /*
         if isCommingFrom == "New Group"
         {
         }
         */
        
        customNavigationBar.customRightBarButton.isHidden    = false
        
        if myChatUserDetail.type == "group"
        {
            let moreBtnImage =  #imageLiteral(resourceName: "dots")
            customNavigationBar.customRightBarButton.setImage(moreBtnImage, for: .normal)
        }
        else
        {
            let moreBtnImage =  #imageLiteral(resourceName: "setting")
            customNavigationBar.customRightBarButton.setImage(moreBtnImage, for: .normal)
        }
        customNavigationBar.customRightBarButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        
        // LongPress on click cell
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tblView.addGestureRecognizer(longPressGesture)
        
        //For keyboard
        self.addNotificationObserver()
        sendMsgTxtView.delegate = self
    }
    
    func setSenderImg()
    {
        let employerPhoto = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PROFILE_PIC) ?? ""
        let imageUrl = IMAGE_BASE_URL + employerPhoto
        self.senderProfilePic = imageUrl
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tblView)
            
            if let indexPath = tblView.indexPathForRow(at: touchPoint) {
                // Long press started on cell at indexPath
                // You can perform actions on the cell here
                let Alert = UIAlertController(title: "Alert", message: "Do you want to delete this message", preferredStyle: UIAlertController.Style.alert)
                Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    let info = self.messages[indexPath.row]
                    let msgTimeStamp = info.timestamp ?? ""
                    self.fdbRef.child("Chat").queryOrdered(byChild: "timestamp").queryEqual(toValue: "\(msgTimeStamp)").observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists(){
                            let enumrator = snapshot.children
                            while let snap = enumrator.nextObject() as? DataSnapshot{
                                snap.ref.removeValue()
                            }
                        }else{}
                    }
                }))
                //                Alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action: UIAlertAction!) in
                //                }))
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
                
                //                let info = messages[indexPath.row]
                //                let msgTimeStamp = info.timestamp ?? ""
                //                fdbRef.child("Chat").queryOrdered(byChild: "timestamp").queryEqual(toValue: "\(msgTimeStamp)").observeSingleEvent(of: .value) { snapshot in
                //                    if snapshot.exists(){
                //                        let enumrator = snapshot.children
                //                        while let snap = enumrator.nextObject() as? DataSnapshot{
                //                            snap.ref.removeValue()
                //                        }
                //                    }else{
                //                    }
                //                }
            }
        }
    }
    
    @objc func didTapMoreButton (_ sender:UIButton) {
        print("More Button is selected")
        //if isCommingFrom == "New Chat"
        if myChatUserDetail.type == "group"
        {
            openActionSheet()
        }
        else
        {
            self.showCustomPopUp()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        // self.userInfoDetail()
//        //For keyboard
//        self.addNotificationObserver()
        self.setSenderImg()
    }
    
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func handleKeyboard(_ notification: Notification){
        
        if notification.name == UIResponder.keyboardWillShowNotification{
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                let bottomSafeArea = view.safeAreaInsets.bottom
                self.messageViewBottomConstraint.constant = keyboardHeight - bottomSafeArea
                //self.messageViewBottomConstraint.constant = keyboardHeight - 30.0
                print(bottomSafeArea)
                if messages.count != 0{
                    DispatchQueue.main.async {
                        self.tblView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            }
        }else if notification.name == UIResponder.keyboardWillHideNotification{
            self.messageViewBottomConstraint.constant = 0
        }
    }
    func userInfoDetail()
    {
        self.userInfo.removeAll()
        if self.myChatUserDetail.users?.count ?? 0 > 0
        {
            self.userInfo = self.myChatUserDetail.users!
        }
        self.getUserInfo()
    }
    
    private func getUserInfo() {
        
        guard let senderID = UserDefaults.standard.string(forKey: "userId") else { return }
        
        self.usersInfoDetailArr.removeAll()
        for (key,_) in self.userInfo
        {
            print(key)
            fdbRef.child("Users").queryOrdered(byChild: "userId").queryEqual(toValue: key).observeSingleEvent(of: .value) { snapshot in
                
                guard snapshot.exists() else { return }
                
                if let dataDict = snapshot.value as? [String:AnyObject]{
                    
                    let email     = dataDict[key]!["email"] as? String
                    let profile   = dataDict[key]!["profile"] as? String
                    let userId    = dataDict[key]!["userId"] as? String
                    let userName  = dataDict[key]!["userName"] as? String
                    let timestamp = dataDict[key]!["timestamp"] as? String
                    let fcmKey    = dataDict[key]!["fcmKey"] as? String
                    
                    if senderID != userId
                    {
                        self.reciverFCMKey = fcmKey ?? ""
                    }
                    
                    if key == userId
                    {
                        let user = FirebaseUser1(email: email, profile: profile, userId: userId, userName: userName, timestamp: timestamp)
                        self.usersInfoDetailArr.append(user)
                        print(user)
                    }
                    print("&&&&&&&&&&&&&&@@@@@@@@@@@@@!!!!!!!1234567890 --- \(self.usersInfoDetailArr)")
                    self.tblView.reloadData()
                }
            }
        }
        print(self.usersInfoDetailArr)
        
    }
    private func openActionSheet()
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let option1 = UIAlertAction(title: "View", style: .default) { _ in
            let vc = WorkChatGroupInfoVC()
            vc.myChatDetail  = self.myChatUserDetail
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let option1Icon = UIImage(named: "view")
        option1.setValue(option1Icon?.imageWithSize(scaledToSize: CGSize(width: 25, height: 25)), forKey: "image")
        
        let option2 = UIAlertAction(title: "Setting", style: .default) { _ in
            self.showCustomPopUp()
        }
        let option2Icon = UIImage(named: "setting.png")
        option2.setValue(option2Icon?.imageWithSize(scaledToSize: CGSize(width: 25, height: 25)), forKey: "image")
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Handle the cancellation of the action sheet
        }
        actionSheet.addAction(option1)
        actionSheet.addAction(option2)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showCustomPopUp(){
        
        broadcastSelectionStatus = isBroadcast
        
        self.settingPopUp = WCSettingPopUp(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.settingPopUp.broadcastBtn.addTarget(self, action: #selector(self.radioButtonPressed), for: .touchUpInside)
        self.settingPopUp.discussionBtn.addTarget(self, action: #selector(self.radioButtonPressed), for: .touchUpInside)
        self.settingPopUp.addBtn.addTarget(self, action: #selector(self.addButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.settingPopUp)
    }
    @objc func radioButtonPressed(sender: UIButton) {
        if sender.tag == 501
        {
            self.settingPopUp.broadcastBtn.isSelected   = true
            self.settingPopUp.discussionBtn.isSelected  = true
        }
        else if sender.tag == 502
        {
            self.settingPopUp.broadcastBtn.isSelected   = false
            self.settingPopUp.discussionBtn.isSelected  = false
        }
    }
    @objc func addButtonPressed(sender: UIButton) {
        
        //        var broadcastSelectionStatus  = false
        //        var discussionSelectionStatus = true
        
        if self.settingPopUp.broadcastBtn.isSelected == false
        {
            broadcastSelectionStatus  = false
            discussionSelectionStatus = true
        }
        else
        {
            broadcastSelectionStatus  = true
            discussionSelectionStatus = false
        }
        
        print(broadcastSelectionStatus)
        print(discussionSelectionStatus)
        self.chatSetting(broadcast: broadcastSelectionStatus)
    }
    
    private func chatSetting(broadcast: Bool) {
        
        fdbRef.child("chatRoom").child("\(self.roomId)").child("meta").child("broadcat").setValue(broadcast)
        
        isBroadcast = broadcast
        broadcastSelectionStatus = isBroadcast
        
        self.settingPopUp.removeFromSuperview()
    }
    
    
    func creatRoom()
    {
        //        let message = sendMsgTxtView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        //        guard !message.isEmpty else { return }
        guard let senderID = UserDefaults.standard.string(forKey: "userId") else { return }//Auth.auth().currentUser?.uid
        
        //        guard let senderID = Auth.auth().currentUser?.uid else { return }
        let receiverID = self.receiverId
        if receiverID == ""
        {
            return
        }
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        let isRead = false
        let type = "individual"
        
        let request =  CreateChatRoom(senderId: senderID, receiverId: receiverID, lastMessageText: "", lastMessage: "\(timestamp)", type: type, creator: senderID, timestamp: "\(timestamp)")
        var userIdArr = [String]()
        userIdArr.append(senderID)
        userIdArr.append(receiverID)
        
        chatViewModel.createChatRoom(userIDArr: userIdArr, receiverId: receiverID, request: request, timestamp: "\(timestamp)") { result in
            print(result)
        }
    }
    
    
    
    //    private func createChatRoom(userEmail: String){
    //        var refChatRoom: DatabaseReference? = FirebaseDatabase.getInstance().reference
    //        val timestamp = ""+System.currentTimeMillis()
    //        userIdArray.add(myEmail!!)
    //        for (i in 0 until userIdArray.size){
    //            userList.add(userEmail[i])
    //        }
    //        val hash: HashMap<String, Any> = HashMap()
    //        hash["broadcat"] = false
    //        val hashMapChatRm: HashMap<String, Any> = HashMap()
    //        hashMapChatRm["users"] = userList
    //        hashMapChatRm["lastMessageText"] = ""
    //        hashMapChatRm["lastMessage"] = timestamp
    //        hashMapChatRm["type"] = "individual"
    //        hashMapChatRm["creator"] = Utility.UID
    //        hashMapChatRm["meta"] = hash
    //        refChatRoom!!.child("chatRoom").push().setValue(hashMapChatRm)
    //    }
    
    
    
    private func setDetail()
    {
        if myChatUserDetail.type == "group"
        {
            let metaArray: [String:Any] = myChatUserDetail.meta!
            self.receiverName.text = metaArray["title"] as? String
            let imageUrlStr = metaArray["icon"] as? String
            let imageUrl = URL(string: imageUrlStr ?? "")
            self.receiverProfileImgView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "profilePlaceHolder"))
        }
        else
        {
            self.receiverName.text = self.name
            let imageUrl = URL(string: self.profilePhoto)
            self.receiverProfileImgView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "profilePlaceHolder"))
        }
        //        if profilePicUrl != "" {
        //            let imageUrl = URL(string: self.profilePhoto)
        //            self.receiverProfileImgView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "profilePlaceHolder"))
        //        }
        //        else
        //        {
        //            self.receiverProfileImgView.image = UIImage(named: "profilePlaceHolder")
        //        }
        customNavigationBar.titleLabel.isHidden = true
        self.sendMsgTxtView.placeholder = "Type a message..."
        
        self.tblView.register(UINib(nibName: "SenderCell", bundle: .main), forCellReuseIdentifier: "SenderCell")
        self.tblView.register(UINib(nibName: "SenderImageCell", bundle: .main), forCellReuseIdentifier: "SenderImageCell")
        self.tblView.register(UINib(nibName: "ReceiverCell", bundle: .main), forCellReuseIdentifier: "ReceiverCell")
        self.tblView.register(UINib(nibName: "ReceiverImageCell", bundle: .main), forCellReuseIdentifier: "ReceiverImageCell")
        self.getMessages()
        
        //getRoomId()
    }
    
    func getMessages(){
        
        self.senderId = UserDefaults.standard.string(forKey: "userId") ?? ""
        
        chatViewModel.getMessage2(roomId: self.roomId) { (messages) in
            self.messages = messages
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.MESSAGE), object: nil)
            DispatchQueue.main.async {
                self.tblView.reloadData()
                print("Scroll to bottom in chat vc")
                if self.messages.count != 0
                {
                    self.tblView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
        
        //        self.senderId = Auth.auth().currentUser?.uid ?? "0"
        //        chatViewModel.getMessages(senderID: self.senderId, recieverID: self.receiverId) { (messages) in
        //            self.messages = messages
        //            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.MESSAGE), object: nil)
        //            DispatchQueue.main.async {
        //                self.tblView.reloadData()
        //                print("Scroll to bottom in chat vc")
        //                if self.messages.count != 0
        //                {
        //                    self.tblView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        //                }
        //            }
        //        }
    }
    
    //    func getRoomId(){
    //        guard let employerId = UserDefaults.standard.string(forKey: "userId") else { return }
    //        self.senderId = employerId //Auth.auth().currentUser?.uid ?? "0"
    //        chatViewModel.getRoomId(senderID: self.senderId) { (messages) in
    //
    ////            self.messages = messages
    ////            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.MESSAGE), object: nil)
    ////            DispatchQueue.main.async {
    ////                self.tblView.reloadData()
    ////                print("Scroll to bottom in chat vc")
    ////                if self.messages.count != 0
    ////                {
    ////                    self.tblView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
    ////                }
    ////            }
    //        }
    //    }
    
    @IBAction func onClickSend()
    {
        sendButton.isEnabled = false
        
        let message = sendMsgTxtView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else {
            self.sendButton.isEnabled = true
            return
        }
        guard let senderId = UserDefaults.standard.string(forKey: "userId") else {
            self.sendButton.isEnabled = true
            return
        }
        var receiverID = self.receiverId
        
        if myChatUserDetail.type == "group"
        {
            receiverID = ""
        }
        else
        {
            if receiverID == ""
            {
                self.sendButton.isEnabled = true
                return
            }
        }
        
        let roomId = self.roomId
        if roomId == ""
        {
            self.sendButton.isEnabled = true
            return
        }
        let type      = "text"
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        self.sendNotification(message: message, image: message)
        
        //        let request = Message2(content: message, fromID: senderId, toID: receiverID, roomId: self.roomId, timestamp: "\(timestamp)", type: type)
        
        // push notification
        // send notification
        //var notificationSend =
        //FcmNotificationsSender(MyConstant.SERVER_KEY, userFcmKey!! as String?, "Skazule", message, userEmail, "", this)
        //notificationSend.SendNotifications()
        
        let request = MessageStruct(message: "\(message)", senderId: "\(senderId)", receiverId: "\(receiverID)", timestamp: "\(timestamp)", type: "\(type)", roomId: "\(roomId)")
        
        chatViewModel.sendMessage(request: request) { (conversationId) in
            //            if self.conversationId == nil{
            //                self.conversationId = conversationId
            //                self.getMessages()
            //            }
            self.sendButton.isEnabled = true
            self.getMessages()
            self.sendMsgTxtView.text = ""
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 )
        {
            self.sendButton.isEnabled = true
        }
    }
    
    func sendNotification(message : String, image: String) {
        let sender = PushNotificationSender()
        let name = UserDefaults.standard.string( forKey: USER_DEFAULTS_KEYS.EMPLOYER_NAME)
        let serverKey = FCM_SERVER_KEY
        let token = self.reciverFCMKey
        
        if token != "" {
            sender.sendPushNotification(to: token , title: "New Message from \(name ?? "")", body: message, email : "", queryID : "", image: image,fcmServerKey: serverKey)
        }
        /*
         // let val = self.Totlegallry_Arr[0]["deviceTokens"].arrayValue
         for i in 0..<fcmKeys.count {
         let token  = fcmKeys[i].stringValue
         if token != "" {
         sender.sendPushNotification(to: token , title: "New Message from \(name ?? "")", body: message, email : "self.patientEmail", queryID : "queryID", image: image,fcmServerKey: serverKey)
         }
         }
         */
    }
    
    @IBAction func onClickPickImage(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        let CameraAction = UIAlertAction(title: "Camera", style: .default, handler:
                                            {
            (alert: UIAlertAction!) -> Void in
            self.openCamera()
        })
        let LibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler:
                                            {
            (alert: UIAlertAction!) -> Void in
            self.openGallery()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(CameraAction)
        optionMenu.addAction(LibraryAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
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
            imagePicker.sourceType =   .photoLibrary//.savedPhotosAlbum
            
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:  [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            
            
            // Step 1: Convert the picked image to data
            guard let imageData = pickedImage.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to data.")
                return
            }
            
            deleteDirectory(name: "temp.jpeg")
            let pickedImageUrl = getImageUrl()
            
            // self.profileimg.image = pickedImage
            let imgUrlStr = String(describing: pickedImageUrl!)
            print("\(imgUrlStr)")
            
            saveImageDocumentDirectory(usedImage: pickedImage)
            //UPDATEprofile(imagepath : pickedImage, isType: "image", docurl: "")
            // update profile from firebase
            
            guard let senderId = UserDefaults.standard.string(forKey: "userId") else { return }
            var receiverID = self.receiverId
            //            if receiverID == ""
            //            {
            //                return
            //            }
            if myChatUserDetail.type == "group"
            {
                receiverID = ""
            }
            else
            {
                if receiverID == ""
                {
                    return
                }
            }
            let roomId = self.roomId
            if roomId == ""
            {
                return
            }
            let type      = "image"
            let timestamp = Int(Date().timeIntervalSince1970*1000)
            self.sendNotification(message: sendMsgTxtView.text!, image: "")
            
            //            let request = Message2(content: "\(pickedImage)", fromID: senderId, toID: receiverID, roomId: self.roomId, timestamp: "\(timestamp)", type: type)
            
            let request = MessageStruct(message: "\(pickedImage)", senderId: "\(senderId)", receiverId: "\(receiverID)", timestamp: "\(timestamp)", type: "\(type)", roomId: "\(roomId)")
            
            chatViewModel.uploadImageURLToFirebase(request: request, imageURL: imageData, onSuccess: { (result) in
                print(result)
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func sendmessages(message: String, receiverId:String,roomId:String, type: String) {
        
        let message = message
        guard !message.isEmpty else { return }
        guard let senderId = UserDefaults.standard.string(forKey: "userId") else { return }
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        
        let request = Message2(content: message, fromID: senderId, toID: receiverId, roomId: roomId, timestamp: "\(timestamp)", type: type)
        
        self.sendNotification(message: message, image: message)
        //        chatViewModel.sendMessage(request: request) { (conversationId) in
        //            //            if self.conversationId == nil{
        //            //                self.conversationId = conversationId
        //            //                self.getMessages()
        //            //            }
        //            self.getMessages()
        //            self.sendMsgTxtView.text = ""
        //        }
        
        
        
        
        
        
        //        let message = message
        //        guard !message.isEmpty else { return }
        //
        //        guard let fromId = Auth.auth().currentUser?.uid else { return }
        //        guard let toId = self.user?.uid else { return }
        //        let timestamp = Int(Date().timeIntervalSince1970*1000)
        //        let isRead = false
        //        let type = type
        //
        //        let request = Message(content: message, fromID: fromId, timestamp: "\(timestamp)", isRead: isRead, toID: toId, type: type,queryId: "")
        //        self.sendNotification(message: message, image: message)
        //        chatViewModel.sendMessage(request: request) { (conversationId) in
        ////            if self.conversationId == nil{
        ////                self.conversationId = conversationId
        ////                self.getMessages()
        ////            }
        //            self.getMessages()
        //            self.sendMsgTxtView.text = ""
        //        }
    }
    //MARK:- UPDATE profile photo API
    func UPDATEprofile(imagepath : UIImage,isType : String,docurl : String){
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(self.view)
            
            //            let fileNames = "file"
            //            //            let teacherphotoUrl = URL(string: imagepath)
            //            //           print(teacherphotoUrl!)
            //            let param:[String:String] = [:]
            //
            //
            //
            //            ServerClass.sharedInstance.sendMultipartRequestFROMCHAT(urlString: BASE_URL + PROJECT_URL.UPLOAD_FILE_CHAT, fileNames: isType, param, imageUrl: imagepath ,docurl : docurl, successBlock: { (json) in
            //
            //                print(json)
            //
            //                hideProgressOnView(self.view)
            //                let success = json["code"].stringValue
            //                if success  == "E0000"
            //                {
            //
            //                    let file = json["file"].stringValue
            //                    self.sendmessages(message: file, type: isType)
            //                }
            //                else {
            //                    UIAlertController.showInfoAlertWithTitle("Message", message: json["frontendmessage"].stringValue, buttonTitle: "Okay")
            //                }
            //            }, errorBlock: { (NSError) in
            //                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
            //                hideProgressOnView(self.view)
            //            })
            
        }else{
            hideProgressOnView(self.view)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    @objc func imageBtnClicked(sender:UIButton)
    {
        webViewImgUrlStr = ""
        let index    = sender.tag
        let message  = messages[index]
        let imgUrl   = message.content ?? ""
        /*
         self.callWebView(imageUrl: imgUrl ?? "")
         */
        webViewImgUrlStr = imgUrl
        self.showImgCustomPopUp()
        
    }
    func showImgCustomPopUp(){
        self.imagePopUp = WCViewImagePopUp(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(self.imagePopUp)
    }
    private func callWebView(imageUrl:String)
    {
        let webView = WebKitViewController()
        webView.urlStr = imageUrl
        webView.headerTitle = "View Full Image"
        webView.isCommingFrom = "Image"
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    // MARK :- Delete message
    @objc func deleteMessageClicked(sender:UIButton)
    {
        
    }
    
    
}
extension WorkChatDetailChatVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let senderId = Auth.auth().currentUser?.uid
        let senderId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let message  = messages[indexPath.row]
        if message.fromID == senderId {
            if message.type == "image"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                cell.message = message
                //cell.messageView.isHidden = true
                // Find the index of the user detail in the array
                if let index = self.usersInfoDetailArr.firstIndex(where: { $0.userId == senderId }) {
                    let info = self.usersInfoDetailArr[index]
                    cell.userName.text = info.userName
                    /*
                     cell.userPhotoImgView.sd_setImage(with: URL(string: info.profile!), placeholderImage: UIImage(named: "profilePlaceHolder"))
                     */
                    cell.userPhotoImgView.sd_setImage(with: URL(string: self.senderProfilePic), placeholderImage: UIImage(named: "profilePlaceHolder"))
                }
                cell.imageBtn.tag = indexPath.row
                cell.imageBtn.addTarget(self, action: #selector(imageBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
                cell.message = message
                // Find the index of the user detail in the array
                if let index = self.usersInfoDetailArr.firstIndex(where: { $0.userId == senderId }) {
                    let info = self.usersInfoDetailArr[index]
                    cell.userName.text = info.userName
                    /*
                     cell.userPhotoImgView.sd_setImage(with: URL(string: info.profile!), placeholderImage: UIImage(named: "profilePlaceHolder"))
                     */
                    cell.userPhotoImgView.sd_setImage(with: URL(string: self.senderProfilePic), placeholderImage: UIImage(named: "profilePlaceHolder"))
                }
                return cell
            }
        }
        else {
            if message.type == "image"
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                cell.message = message
                // Find the index of the user detail in the array
                if let index = self.usersInfoDetailArr.firstIndex(where: { $0.userId == message.fromID }) {
                    let info = self.usersInfoDetailArr[index]
                    cell.userName.text = info.userName
                    cell.userPhotoImgView.sd_setImage(with: URL(string: info.profile!), placeholderImage: UIImage(named: "profilePlaceHolder"))
                }
                cell.imageBtn.tag = indexPath.row
                cell.imageBtn.addTarget(self, action: #selector(imageBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
                cell.message = message
                // Find the index of the user detail in the array
                if let index = self.usersInfoDetailArr.firstIndex(where: { $0.userId == message.fromID }) {
                    let info = self.usersInfoDetailArr[index]
                    cell.userName.text = info.userName
                    cell.userPhotoImgView.sd_setImage(with: URL(string: info.profile!), placeholderImage: UIImage(named: "profilePlaceHolder"))
                }
                return cell
            }
        }
        
        
        
        //        if ((message.fromID == senderId) && (message.toID == self.receiverId)) || ((message.fromID == self.receiverId) && (message.toID == senderId))
        //        {
        //            if message.fromID == senderId{
        //                if message.type == "image" {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
        //                    cell.message = message
        //                    return cell
        //                }else {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
        //                    cell.message = message
        //                    return cell
        //                }
        //            }
        //            else{
        //                if message.type == "image" {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
        //                    cell.message = message
        //                    return cell
        //                }else {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
        //                    cell.message = message
        //                    return cell
        //                }
        //            }
        //        }
        //        else {
        //            return UITableViewCell()
        //        }
        
        
        
        //        if receiverId == self.receiverID {
        //            if message.fromID == senderId{
        //                if message.type == "image" {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
        //                    cell.message = message
        //                    return cell
        //                }else {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
        //                    cell.message = message
        //                    return cell
        //                }
        //            }else{
        //                if message.type == "image" {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
        //                    cell.message = message
        //                    return cell
        //                }else {
        //                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
        //                    cell.message = message
        //                    return cell
        //                }
        //            }
        //        }
        //        else {
        //            return UITableViewCell()
        //        }
        
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
        //return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let message = messages[indexPath.row]
        //        if message.type == "image" || message.type == "file"{
        //            if let VC = self.storyboard?.instantiateViewController(withIdentifier: "webVC") as? webVC{
        //                VC.urls = message.content ?? ""
        //                VC.modalPresentationStyle = .fullScreen
        //                self.navigationController?.pushViewController(VC, animated: true)
        //            }
        //        }
    }
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        print(tableView.contentSize.height)
    //        print(tableView.frame.size.height)
    //        let pos = (tableView.contentSize.height - tableView.frame.size.height * 2 - 400)
    //        tableView.isScrollEnabled = pos > tableView.frame.size.height ? true : false
    //    }
    
    /*    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     let offsetY = scrollView.contentOffset.y
     let contentHeight = scrollView.contentSize.height
     
     print(offsetY,contentHeight,scrollView.frame.size.height )
     
     if offsetY > contentHeight - scrollView.frame.size.height {
     
     scrollView.isScrollEnabled = true
     
     }else{
     scrollView.isScrollEnabled = false
     }
     } */
}
extension WorkChatDetailChatVC: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray{
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.textColor = .lightGray
            textView.placeholder = "Type something..."
        }
    }
}
