//
//  ChatViewModelTest.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 17/07/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//var myChatUserList   = [FBDChatRoom]()
//var myChatUserListArrDict   = [String: Any]()
//var userIdArray = [String]()
//var userList = [String:Any]()
//var chatType = "individual"
//var roomDataDictArr = [String: AnyObject]()

struct ChatViewModelTest {
    
    private let fdbRef = Database.database().reference()
    
    func getUsersList(onSuccess:@escaping([FirebaseUser]) -> Void, onError:@escaping(String) -> Void){
        
        var users = [FirebaseUser]()
        fdbRef.child("Users").observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.exists(){
                
                let enumrator = snapshot.children
                
                while let snap = enumrator.nextObject() as? DataSnapshot{
                    
                    if let userDict = snap.value as? [String: AnyObject]{
                        let uid                 = snap.key
                        let currentUid          = Auth.auth().currentUser?.uid
                        let dict                = userDict["Chat"] as? [String:AnyObject]
                        let conversationDict    = dict?[currentUid!] as? [String:AnyObject]
                        let lastMessage         = conversationDict?["lastMessage"] as? String
                        let timeStamp           = conversationDict?["timestamp"] as? String
                        let email               = userDict["email"] as? String
                        let name                = userDict["userName"] as? String
                        let profilePic          = userDict["profile"] as? String
                        
                        let user = FirebaseUser(uid: uid, email: email, lastMessage: lastMessage, name: name, profilePic: profilePic, timestamp: timeStamp)
                        let currentUser = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMAIL)
                        
                        if email != currentUser
                        {
                            users.append(user)
                        }
                    }
                }
                let sortedUserArray = sortUsersListByTime(usersArray: users)
                onSuccess(sortedUserArray)
            }else{
                onSuccess(users)
            }
        }
    }
    
    private func sortUsersListByTime(usersArray: [FirebaseUser]) -> [FirebaseUser] {
        
        var arrayWithTimeStamp = [FirebaseUser]()
        var arrayWithoutTimeStap = [FirebaseUser]()
        
        usersArray.forEach { (user) in
            if user.timestamp == nil{
                arrayWithoutTimeStap.append(user)
            }else{
                arrayWithTimeStamp.append(user)
            }
        }
        
        arrayWithTimeStamp = arrayWithTimeStamp.sorted(by: { $0.timestamp! > $1.timestamp! })
        let newArray = arrayWithTimeStamp + arrayWithoutTimeStap
        return newArray
    }
    
    func getConversationId(request: Message, onSuccess:@escaping(String?) -> Void, onError:@escaping(String) -> Void){
        
        fdbRef.child("users").child(request.fromID!).child("Chat").child(request.toID!).observe( .value) { (snapshot) in
            
            if snapshot.exists(){
                if let dataDict = snapshot.value as? [String:AnyObject]{
                    let conversationId = dataDict["location"]
                    onSuccess(conversationId as? String)
                }
            }else{
                onSuccess(nil)
            }
        }
    }
    
    func getMessages(senderID: String, recieverID: String, onSuccess:@escaping([Message]) -> Void){
        
        var messages = [Message]()
        
        //        fdbRef.child("Chat").child(conversationId ?? "abc").observe(.childAdded) { (snapshot) in
        fdbRef.child("Chat").observe(.childAdded) { (snapshot) in
            
            // print(snapshot)
            NotificationCenter.default.post(name: NSNotification.Name("Message"), object: nil)
            guard snapshot.exists() else { return }
            if let dataDict = snapshot.value as? [String:AnyObject]{
                
                let content   = dataDict["message"] as? String
                let fromId    = dataDict["senderId"] as? String
                let toId      = dataDict["receiverId"] as? String
                let isRead    = dataDict["isRead"] as? Bool
                let timestamp = dataDict["timestamp"] as? String
                let queryID   = dataDict["queryId"] as? String
                let type      = dataDict["type"] as? String
                
                if ((fromId == senderID) && (toId == recieverID)) || ((fromId == recieverID) && (toId == senderID))
                {
                    let message = Message(content: content, fromID: fromId, timestamp: timestamp, isRead: isRead, toID: toId, type: type,queryId : queryID)
                    messages.append(message)
                }
                onSuccess(messages)
            }
        }
    }
    func sendMessage(request: Message1, onSuccess:@escaping(String) -> Void){
        
        let messageDict = request.convertToDictionary()!
        
        fdbRef.child("Users").child(request.senderId!).child("Chat").child(request.receiverId!).observeSingleEvent(of: .value) { (snapshot) in
            
            //            var conversationDict: [String:AnyObject] = [:]
            //            conversationDict = [
            //                "timestamp" : request.timestamp!,
            //                "lastMessage" : request.message!
            //            ] as [String : AnyObject]
            
            //            if let dataDict = snapshot.value as? [String : AnyObject]{
            //                conversationDict = [
            //                    "timestamp" : request.timestamp!,
            //                    "lastMessage" : request.content!
            //                ] as [String : AnyObject]
            //
            //            }else{
            //                conversationDict = [
            //                    "lastMessage" : request.content!,
            //                    "timestamp" : request.timestamp!
            //                ] as [String : AnyObject]
            //            }
            
            //            self.fdbRef.child("Users").child(request.senderId!).child("Chat").child(request.receiverId!).updateChildValues(conversationDict)
            //
            //            self.fdbRef.child("Users").child(request.receiverId!).child("Chat").child(request.senderId!).updateChildValues(conversationDict)
            
            self.fdbRef.child("Chat").childByAutoId().updateChildValues(messageDict as [String:AnyObject])
            
            onSuccess("conversationId")
        }
    }
    // MARK: Upload Image url to firebase server
    func uploadImageURLToFirebase(request: Message1, imageURL: Data, onSuccess:@escaping(String) -> Void){
        
        // Step 1: Get a reference to your Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Step 2: Create a reference to the image you want to upload (e.g., "images/imageName.jpg")
        let imageName = "\(request.timestamp!)temp.jpg" //"imageName.jpg"
        //let imageRef = storageRef.child("images").child(imageName)
        let imageRef = storageRef.child(imageName) //(timestamp+imageUri!!.name)
        
        // Step 3: Upload the image URL to Firebase Storage
        let uploadTask = imageRef.putData(imageURL, metadata: nil) { metadata, error in
            guard metadata != nil else {
                // print("Error uploading image URL: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // You can get the download URL if you need it.
            imageRef.downloadURL { url, error in
                if let downloadURL = url {
                    // print("Image download URL: \(downloadURL)")
                    
                    var chatDict: [String:AnyObject] = [:]
                    chatDict = [
                        "senderId"      : request.senderId!,
                        "receiverId"    : request.receiverId!,
                        "message"       : "\(downloadURL)",
                        "timestamp"     : request.timestamp!,
                        "type"          : request.type!,
                        "isSeen"        : request.isSeen!
                    ] as [String : AnyObject]
                    
                    self.fdbRef.child("Chat").childByAutoId().updateChildValues(chatDict)
                    
                } else {
                    // print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // You can also observe the progress of the upload task if needed.
        uploadTask.observe(.progress) { snapshot in
            // Handle progress here
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            // print("Upload progress: \(percentComplete)%")
        }
        
        onSuccess("Sussesful uploaded ......")
    }
    
    func createChatRoom(userIDArr:[String],receiverId:String, request: CreateChatRoom , timestamp:String, onSuccess:@escaping(String) -> Void){
        var userIdArray = [String]()
        var userList = [String:Any]()
        var metaDict = [String:Any]()
        
        let senderId = Auth.auth().currentUser?.uid
        userIdArray.append(senderId ?? "")
        userIdArray.append(receiverId)
        
        for item in userIdArray {
            userList[item] = true
        }
        metaDict["broadcat"] = false
        
        var chatRoomDict: [String:AnyObject] = [:]
        chatRoomDict = [
            "users"             : userList,
            "lastMessageText"   : "",
            "lastMessage"       : request.timestamp!,
            "type"              : request.type!,
            "creator"           : request.creator!,
            "meta"              : metaDict
        ] as [String : AnyObject]
        
        let messageDict = request.convertToDictionary()!
        fdbRef.child("chatRoom").updateChildValues(chatRoomDict)
        onSuccess("")
    }
    
    func createChatRoom(){
        
        guard let senderId = UserDefaults.standard.string(forKey: "userId") else { return } // Employer ID
        let timestamp = Int(Date().timeIntervalSince1970*1000)
        //let userId = Auth.auth().currentUser?.uid ?? ""
        userIdArray.append(senderId)
        
        for item in userIdArray {
            userList[item] = true
        }
        var metaDict = [String:Any]()
        metaDict["broadcat"] = false
        
        var chatRoomDict: [String:AnyObject] = [:]
        chatRoomDict = [
            "users"             : userList,
            "lastMessageText"   : "",
            "lastMessage"       : "\(timestamp)",
            "type"              : chatType,
            "creator"           : senderId,
            "meta"              : metaDict
        ] as [String : AnyObject]

        fdbRef.child("chatRoom").childByAutoId().updateChildValues(chatRoomDict)
    }
    
    func getRoomId(senderID: String, onSuccess:@escaping([FBDChatRoom]) -> Void){
//    func getRoomId(senderID: String){

        myChatUserList.removeAll()
        var chatRoomData = [FBDChatRoom]()
        
        fdbRef.child("chatRoom").queryOrdered(byChild: "users/"+senderID).queryEqual(toValue: true).observeSingleEvent(of: .value) { snapshot in
            // print(snapshot)
            // NotificationCenter.default.post(name: NSNotification.Name("Message"), object: nil)
            guard snapshot.exists() else { return }
            if let dataDict = snapshot.value as? [String:AnyObject]{
                var result: [String:AnyObject] = [:]
                for (key, _) in dataDict {
                    if dataDict[key]?["type"] as! String != "group"
                    {
                        result = dataDict[key]?["users"] as! [String : AnyObject]
                        for (userKey,_) in result
                        {
                            if(userKey != senderID){
                                var user = dataDict[key] as! [String : Any]
                                self.getMyFriendUser_async(user_id: userKey, roomId: key, roomData: user)
//                                Task {
//                                    await self.getMyFriendUser_async(user_id: userKey, roomId: key, roomData: &user)
//                                }
                            }
                        }
                    }
                    else{
                        //want this check and modify this accordin to our condition
                        var list = [Any]()
                        list.append(key)
                        var myChatUserList = [ChatRoomUsers]()
                        let roomId = key
                        let roomData = dataDict
                        let chatRoomUsers = ChatRoomUsers.init(roomId: roomId, roomData: roomData)
                        myChatUserList.append(chatRoomUsers)
                    }
                }
                onSuccess(chatRoomData)
            }
        }
    }
    private func getMyFriendUser_async(
        user_id: String,
        roomId: String,
        roomData: [String:Any]
    ) {
        var firebaseUserData = [Meta2]()
        
        fdbRef.child("Users/"+user_id).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else { return }
            if let dataDict = snapshot.value as? [String:AnyObject]{
                
                let email         = dataDict["email"] as? String
                let profile       = dataDict["profile"] as? String
                let userId        = dataDict["userId"] as? String
                let userName      = dataDict["userName"] as? String
                let timestamp     = dataDict["timestamp"] as? String
                
                let user = Meta2(userId: userId, userName: userName, userEmail: email, userMobile: "", timestamp: timestamp, profileImage: profile)
                firebaseUserData.append(user)
    
                let lastMessageText   = roomData["lastMessageText"] ?? ""
                let lastMessage       = roomData["lastMessage"] ?? ""
                let type              = roomData["type"] ?? ""
                let creator           = roomData["creator"] ?? ""
                let meta              = roomData["meta"] as! [String : Any]
                let users             = roomData["users"] as! [String : Any]
                let user_key          = user_id
                
                myChatUserList.append(FBDChatRoom.init(lastMessageText: lastMessageText as? String, lastMessage: lastMessage as? String, type: type as? String, creator: creator as? String, meta: meta, users: users, user_key: user_key, meta2: user))
                print("*************************************************************************\(myChatUserList)")
                //print("################################################################3##\(myChatUserList.count)")
            }
        })
    }
    
    
//    private func getMyFriendUser_async(
//        user_id: String,
//        roomId: String,
//        roomData: [String:AnyObject]
//    ) {
////        var firebaseUserData = [FirebaseUser1]()
//        var firebaseUserData = [Meta2]()
//
//
//        roomDataDictArr = roomData
//
//        fdbRef.child("Users/"+user_id).observeSingleEvent(of: .value) { snapshot in
//            guard snapshot.exists() else { return }
//            print(snapshot.value as? [String:AnyObject])
//            if let dataDict = snapshot.value as? [String:AnyObject]{
//
//                let email         = dataDict["email"] as? String
//                let profile       = dataDict["profile"] as? String
//                let userId        = dataDict["userId"] as? String
//                let userName      = dataDict["userName"] as? String
//                let timestamp     = dataDict["timestamp"] as? String
//
////                let user = FirebaseUser1(email: email, profile: profile, userId: userId, userName: userName, timestamp: timestamp)
////                firebaseUserData.append(user)
//
//                let user = Meta2(userId: userId, userName: userName, userEmail: email, userMobile: "", timestamp: timestamp, profileImage: profile)
//                firebaseUserData.append(user)
//
//
////                print("*************************************************************************\(roomData)")
////                print("################################################################3##\(roomDataDictArr)")
////                roomDataDictArr["user_key"] = user_id
////                roomDataDictArr["meta2"]    = user as AnyObject
//
//                let lastMessageText = roomDataDictArr["lastMessageText"] ?? ""
//                let lastMessage = roomDataDictArr["lastMessage"]  ?? ""
//                let type = roomDataDictArr["type"] ?? ""
//                let creator = roomDataDictArr["creator"] ?? ""
//                let meta = roomDataDictArr["meta"] as! [String : Any]
//                let users = roomDataDictArr["users"] as! [String : Any]
//                let user_key = user_id as AnyObject
//
////              myChatUserList.append(FBDChatRoom.init(lastMessageText: lastMessageText, lastMessage: lastMessage, type: type, creator: creator, meta: meta, users: users, user_key: user_key, meta2: user))
//
//                print("*************************************************************************\(myChatUserList)")
//
//
////                roomData["user_key"] = user_id as AnyObject
////                roomData["meta2"]    = user as AnyObject
//
//
////                let chatRoomUsers    = ChatRoomUsers.init(roomId: roomId, roomData: roomDataDictArr)
////                myChatUserList.append(chatRoomUsers)
//
//                //                let chatRoomUsers    = ChatRoomUsers.init(roomId: roomId, roomData: roomDataDictArr)
//                //                myChatUserList.append(chatRoomUsers)
//
//                //myChatUserList
//
//
////                print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\(myChatUserList)")
//                print(myChatUserList.count)
//
//                // print(firebaseUserData)
//            }
//        }
//    }
    
//    private func getMyFriendUser(userId: String, roomDataDict: inout [String:Any]) -> [FirebaseUser1] {
//        var firebaseUserData = [FirebaseUser1]()
//        fdbRef.child("Users/"+userId).observeSingleEvent(of: .value){ snapshot in
//            guard snapshot.exists() else { return }
//            if let dataDict = snapshot.value as? [String:AnyObject]{
//                let email         = dataDict["email"] as? String
//                let profile       = dataDict["profile"] as? String
//                let userId        = dataDict["userId"] as? String
//                let userName      = dataDict["userName"] as? String
//                let timestamp     = dataDict["timestamp"] as? String
//
//                let user = FirebaseUser1(email: email, profile: profile, userId: userId, userName: userName, timestamp: timestamp)
//                firebaseUserData.append(user)
//
//                roomDataDict["user_key"] = user_id
//                roomDataDict["meta2"]    = user
//                let chatRoomUsers    = ChatRoomUsers.init(roomId: roomId, roomData: roomData)
//                myChatUserList.append(chatRoomUsers)
//                print(myChatUserList)
//                print(myChatUserList.count)
//
//                // print(firebaseUserData)
//            }
//        }
//        return firebaseUserData
//    }
//
    
//    private func getMyFriendUser_async(
//        user_id: String,
//        roomId: String,
//        roomData: inout [String:Any]
//    ) async {
//        do {
//            let user = try await getMyFriendUser(userId: user_id)
//            print(user)
//            roomData["user_key"] = user_id
//            roomData["meta2"]    = user
//            let chatRoomUsers    = ChatRoomUsers.init(roomId: roomId, roomData: roomData)
//            myChatUserList.append(chatRoomUsers)
//            print(myChatUserList)
//            print(myChatUserList.count)
//        } catch {
//            // print("Oops something went wrong!")
//        }
//    }
//
//    private func getMyFriendUser(userId: String) async throws -> [FirebaseUser1] {
//        var firebaseUserData = [FirebaseUser1]()
//        fdbRef.child("Users/"+userId).observeSingleEvent(of: .value){ snapshot in
//            guard snapshot.exists() else { return }
//            if let dataDict = snapshot.value as? [String:AnyObject]{
//                let email         = dataDict["email"] as? String
//                let profile       = dataDict["profile"] as? String
//                let userId        = dataDict["userId"] as? String
//                let userName      = dataDict["userName"] as? String
//                let timestamp     = dataDict["timestamp"] as? String
//
//                let user = FirebaseUser1(email: email, profile: profile, userId: userId, userName: userName, timestamp: timestamp)
//                firebaseUserData.append(user)
//                // print(firebaseUserData)
//            }
//        }
//        return firebaseUserData
//    }
}

