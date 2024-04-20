//
//  WorkChatDetailChatVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 28/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct ChatViewModel11 {
    
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
            
            print(snapshot)
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
    //func uploadImageURLToFirebase(imageURL: String){
    //    func uploadImageURLToFirebase(request: Message1, imageURL: String, onSuccess:@escaping(String) -> Void){
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
                print("Error uploading image URL: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // You can get the download URL if you need it.
            imageRef.downloadURL { url, error in
                if let downloadURL = url {
                    print("Image download URL: \(downloadURL)")
                    
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
                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // You can also observe the progress of the upload task if needed.
        uploadTask.observe(.progress) { snapshot in
            // Handle progress here
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(percentComplete)%")
        }
        
        onSuccess("Sussesful uploaded ......")
    }
    
    
    
    //    func createChatRoom(userIDArr:[String],request: CreateChatRoom , timestamp:String){
    
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
    
    func getRoomId(senderID: String, recieverID: String, onSuccess:@escaping([FBDChatRoom]) -> Void){
        
        var chatRoomData = [FBDChatRoom]()
        
        fdbRef.child("chatRoom").queryOrdered(byChild: "users/"+senderID).queryEqual(toValue: true).observeSingleEvent(of: .value) { snapshot in
            print(snapshot)
            //            NotificationCenter.default.post(name: NSNotification.Name("Message"), object: nil)
            guard snapshot.exists() else { return }
            
            if let dataDict = snapshot.value as? [String:AnyObject]{
                
                var result: [String:AnyObject] = [:]
                for (key, _) in dataDict {
                    if dataDict[key]?.type != "group"
                    {
                        result = dataDict[key]?["users"] as! [String : AnyObject]
                        
                        for (userKey,_) in result
                        {
                            if(userKey != senderID){
                                
                                let lastMessageText     = dataDict[key]?["lastMessageText"] as? String
                                let lastMessage         = dataDict[key]?["lastMessage"] as? String
                                let type                = dataDict[key]?["type"] as? String
                                let creator             = dataDict[key]?["creator"] as? String
                                let meta                = dataDict[key]?["meta"] as? [String:Any]
                                let users               = dataDict[key]?["users"] as? [String:Any]
                                
                                var user: [String:Any] = dataDict
                                self.getMyFriendUser_async(user_id: userKey, roomId: key, roomData: &user)

                                
                               // let user = FBDChatRoom(lastMessageText: lastMessageText, lastMessage: lastMessage, type: type, creator: creator, meta: meta, users: users,user_key: "",meta2: [FirebaseUser1.init(email: "", profile: "", userId: "", userName: "", timestamp: "")])
//                                chatRoomData.append(user)
//                                self.getMyFriendUser_async(user_id: userKey, roomId: key, roomData: chatRoomData)
                            }
                        }
                    }
                   else{
//                        var list = [Any]()
//                        list.add(i)
//                        val myChatUserList = mutableListOf<ChatRoomUsers>()
//                        val roomId = i
//                        val roomData = tmpSnapshot
//                        val chatRoomUsers = ChatRoomUsers(roomId, roomData)
//                        myChatUserList.add(chatRoomUsers)
//                        Log.d("myChatUserList+++", myChatUserList.toString())
                    }
                }
                onSuccess(chatRoomData)
            }
        }
    }
    
    
    private func getMyFriendUser_async(
        user_id: String,
        roomId: String,
        roomData: inout [String:Any]
    ) {
        //roomData: [FBDChatRoom]
        var user = getMyFriendUser(userId: user_id)
        print(user)
            roomData["user_key"] = user_id
            roomData["meta2"]    = user
            var myChatUserList   = [ChatRoomUsers]()
            var chatRoomUsers    = ChatRoomUsers.init(roomId: roomId, roomData: roomData)
            myChatUserList.append(chatRoomUsers)
        
        
        //        roomData["user_key"] = user_id
//        roomData["meta2"]    = user
//        var myChatUserList   = mutableListOf<ChatRoomUsers>()
//        var roomId           = roomId
//        var roomData         = roomData
//        var chatRoomUsers    = ChatRoomUsers(roomId, roomData)
//        myChatUserList.add(chatRoomUsers)
        //Log.d("myChatUserList", myChatUserList.toString())
        //this.MychatUserList.push({"room_id":roomId,"data":roomData});
        //return user;
    }
    
//    private func getMyFriendUser(userId: String) -> [FirebaseUser1] {
    private func getMyFriendUser(userId: String) -> [FirebaseUser1] {

        var firebaseUserData = [FirebaseUser1]()
        print(userId)
        //let d = fdbRef.child("Users/"+userId)
        fdbRef.child("Users/"+userId).observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else { return }
            if let dataDict = snapshot.value as? [String:AnyObject]{
                let email         = dataDict["email"] as? String
                let profile       = dataDict["profile"] as? String
                let userId        = dataDict["userId"] as? String
                let userName      = dataDict["userName"] as? String
                let timestamp     = dataDict["timestamp"] as? String
                
                let user = FirebaseUser1(email: email, profile: profile, userId: userId, userName: userName, timestamp: timestamp)
                firebaseUserData.append(user)
                print(firebaseUserData)
            }
        }
        return firebaseUserData
    }
    
    
    
    
    
    
    
    
    //    async getMyFriendUser_async(user_id:any,roomId:any,roomData:any){
    //        let user = await this.getMyFriendUser(user_id);
    //        roomData['user_key']=user_id;
    //        roomData["meta2"]=user;
    //        this.MychatUserList.push({"room_id":roomId,"data":roomData});
    //        console.log(this.MychatUserList);
    //        return user;
    //    }
    //
    //    getMyFriendUser(user_id: string): Promise<any> {
    //        return new Promise((resolve, reject) => {
    //            this.firebasedb.object('Users/'+user_id).valueChanges().subscribe((snapshot:any) =>{
    //                if (snapshot) {
    //                    return resolve(snapshot);
    //                }else{
    //                    return resolve(false);
    //                }
    //            }, (error: any) => {
    //                return reject(error);
    //            });
    //        });
    //    }
    //    getAllConversation(){
    //      //this.firebasedb.list("chatRoom",(ref: any) => ref.orderByChild("users/"+this.myFirebaseId).equalTo(true)).valueChanges(["child_added", "child_changed", "child_moved", "child_removed"]).subscribe((snapshot: any) => {
    //      this.firebasedb.list("chatRoom", (ref: any) => ref.orderByChild("users/"+this.myFirebaseId).equalTo(true).once('value', (snapshot: any) => {
    //       if (snapshot.exists()) {
    //        // let tmpSnapshot: any = snapshot;
    //        // console.log(tmpSnapshot);
    //
    //        let tmpSnapshot: any = snapshot.val();
    //        var result:any = [];
    //        for(var i in tmpSnapshot){
    //          result.push({'room_id':i,'data':tmpSnapshot[i]}); //add
    //          if(tmpSnapshot[i].type!="group"){
    //            for(var userKey in tmpSnapshot[i].users){
    //              if(userKey!=this.myFirebaseId){
    //                this.getMyFriendUser_async(userKey,i,tmpSnapshot[i]);
    //              }
    //            }
    //          }else{
    //            this.MychatUserList.push({"room_id":i,"data":tmpSnapshot[i]});
    //          }
    //        }
    //          console.log(this.MychatUserList);
    //        } else {
    //          console.log("No data available");
    //        }
    //       }));
    //     }
    //
    //      async getMyFriendUser_async(user_id:any,roomId:any,roomData:any){
    //        let user = await this.getMyFriendUser(user_id);
    //        roomData['user_key']=user_id;
    //        roomData["meta2"]=user;
    //        this.MychatUserList.push({"room_id":roomId,"data":roomData});
    //        console.log(this.MychatUserList);
    //        return user;
    //      }
    //
    //      getMyFriendUser(user_id: string): Promise<any> {
    //        return new Promise((resolve, reject) => {
    //          this.firebasedb.object('Users/'+user_id).valueChanges().subscribe((snapshot:any) =>{
    //            if (snapshot) {
    //              return resolve(snapshot);
    //            }else{
    //              return resolve(false);
    //            }
    //          }, (error: any) => {
    //            return reject(error);
    //          });
    //        });
    //      }
    //
    
}










//
//struct ChatViewModel {
//
//    private let fdbRef = Database.database().reference()
//
//    func getUsersList(onSuccess:@escaping([FirebaseUser]) -> Void, onError:@escaping(String) -> Void){
//
//        var users = [FirebaseUser]()
//        fdbRef.child("Users").observeSingleEvent(of: .value) { snapshot in
//
//            if snapshot.exists(){
//
//                let enumrator = snapshot.children
//
//                while let snap = enumrator.nextObject() as? DataSnapshot{
//
//                    if let userDict = snap.value as? [String: AnyObject]{
//                        let uid                 = snap.key
//                        let currentUid          = Auth.auth().currentUser?.uid
//                        let dict                = userDict["Chat"] as? [String:AnyObject]
//                        let conversationDict    = dict?[currentUid!] as? [String:AnyObject]
//                        let lastMessage         = conversationDict?["lastMessage"] as? String
//                        let timeStamp           = conversationDict?["timestamp"] as? String
//                        let email               = userDict["email"] as? String
//                        let name                = userDict["userName"] as? String
//                        let profilePic          = userDict["profile"] as? String
//
//                        let user = FirebaseUser(uid: uid, email: email, lastMessage: lastMessage, name: name, profilePic: profilePic, timestamp: timeStamp)
//                        let currentUser = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMAIL)
//
//                        if email != currentUser
//                        {
//                            users.append(user)
//                        }
//                    }
//                }
//                let sortedUserArray = sortUsersListByTime(usersArray: users)
//                onSuccess(sortedUserArray)
//            }else{
//                onSuccess(users)
//            }
//        }
//    }
//
//    private func sortUsersListByTime(usersArray: [FirebaseUser]) -> [FirebaseUser]{
//
//        var arrayWithTimeStamp = [FirebaseUser]()
//        var arrayWithoutTimeStap = [FirebaseUser]()
//
//        usersArray.forEach { (user) in
//            if user.timestamp == nil{
//                arrayWithoutTimeStap.append(user)
//            }else{
//                arrayWithTimeStamp.append(user)
//            }
//        }
//
//        arrayWithTimeStamp = arrayWithTimeStamp.sorted(by: { $0.timestamp! > $1.timestamp! })
//        let newArray = arrayWithTimeStamp + arrayWithoutTimeStap
//        return newArray
//    }
//
//    func getConversationId(request: Message, onSuccess:@escaping(String?) -> Void, onError:@escaping(String) -> Void){
//
//        fdbRef.child("users").child(request.fromID!).child("Chat").child(request.toID!).observe( .value) { (snapshot) in
//
//            if snapshot.exists(){
//                if let dataDict = snapshot.value as? [String:AnyObject]{
//                    let conversationId = dataDict["location"]
//                    onSuccess(conversationId as? String)
//                }
//            }else{
//                onSuccess(nil)
//            }
//        }
//    }
//
//    func getMessages(senderID: String, recieverID: String, onSuccess:@escaping([Message]) -> Void){
//
//        var messages = [Message]()
//
//        //        fdbRef.child("Chat").child(conversationId ?? "abc").observe(.childAdded) { (snapshot) in
//        fdbRef.child("Chat").observe(.childAdded) { (snapshot) in
//
//            print(snapshot)
//            NotificationCenter.default.post(name: NSNotification.Name("Message"), object: nil)
//            guard snapshot.exists() else { return }
//            if let dataDict = snapshot.value as? [String:AnyObject]{
//
//                let content   = dataDict["message"] as? String
//                let fromId    = dataDict["senderId"] as? String
//                let toId      = dataDict["receiverId"] as? String
//                let isRead    = dataDict["isRead"] as? Bool
//                let timestamp = dataDict["timestamp"] as? String
//                let queryID   = dataDict["queryId"] as? String
//                let type      = dataDict["type"] as? String
//
//                if ((fromId == senderID) && (toId == recieverID)) || ((fromId == recieverID) && (toId == senderID))
//                {
//                    let message = Message(content: content, fromID: fromId, timestamp: timestamp, isRead: isRead, toID: toId, type: type,queryId : queryID)
//                    messages.append(message)
//                }
//                onSuccess(messages)
//            }
//        }
//    }
//    func sendMessage(request: Message1, onSuccess:@escaping(String) -> Void){
//
//        let messageDict = request.convertToDictionary()!
//
//        fdbRef.child("Users").child(request.senderId!).child("Chat").child(request.receiverId!).observeSingleEvent(of: .value) { (snapshot) in
//
//            //            var conversationDict: [String:AnyObject] = [:]
//            //            conversationDict = [
//            //                "timestamp" : request.timestamp!,
//            //                "lastMessage" : request.message!
//            //            ] as [String : AnyObject]
//
//            //            if let dataDict = snapshot.value as? [String : AnyObject]{
//            //                conversationDict = [
//            //                    "timestamp" : request.timestamp!,
//            //                    "lastMessage" : request.content!
//            //                ] as [String : AnyObject]
//            //
//            //            }else{
//            //                conversationDict = [
//            //                    "lastMessage" : request.content!,
//            //                    "timestamp" : request.timestamp!
//            //                ] as [String : AnyObject]
//            //            }
//
//            //            self.fdbRef.child("Users").child(request.senderId!).child("Chat").child(request.receiverId!).updateChildValues(conversationDict)
//            //
//            //            self.fdbRef.child("Users").child(request.receiverId!).child("Chat").child(request.senderId!).updateChildValues(conversationDict)
//
//            self.fdbRef.child("Chat").childByAutoId().updateChildValues(messageDict as [String:AnyObject])
//
//            onSuccess("conversationId")
//        }
//    }
//    // MARK: Upload Image url to firebase server
//    //func uploadImageURLToFirebase(imageURL: String){
//    //    func uploadImageURLToFirebase(request: Message1, imageURL: String, onSuccess:@escaping(String) -> Void){
//    func uploadImageURLToFirebase(request: Message1, imageURL: Data, onSuccess:@escaping(String) -> Void){
//
//        // Step 1: Get a reference to your Firebase Storage
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//
//        // Step 2: Create a reference to the image you want to upload (e.g., "images/imageName.jpg")
//        let imageName = "\(request.timestamp!)temp.jpg" //"imageName.jpg"
//        //let imageRef = storageRef.child("images").child(imageName)
//        let imageRef = storageRef.child(imageName) //(timestamp+imageUri!!.name)
//
//        // Step 3: Upload the image URL to Firebase Storage
//        let uploadTask = imageRef.putData(imageURL, metadata: nil) { metadata, error in
//            guard metadata != nil else {
//                print("Error uploading image URL: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            // You can get the download URL if you need it.
//            imageRef.downloadURL { url, error in
//                if let downloadURL = url {
//                    print("Image download URL: \(downloadURL)")
//
//                    var chatDict: [String:AnyObject] = [:]
//                    chatDict = [
//                        "senderId"      : request.senderId!,
//                        "receiverId"    : request.receiverId!,
//                        "message"       : "\(downloadURL)",
//                        "timestamp"     : request.timestamp!,
//                        "type"          : request.type!,
//                        "isSeen"        : request.isSeen!
//                    ] as [String : AnyObject]
//
//                    self.fdbRef.child("Chat").childByAutoId().updateChildValues(chatDict)
//
//                } else {
//                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }
//        }
//
//        // You can also observe the progress of the upload task if needed.
//        uploadTask.observe(.progress) { snapshot in
//            // Handle progress here
//            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
//            print("Upload progress: \(percentComplete)%")
//        }
//
//        onSuccess("Sussesful uploaded ......")
//    }
//
//
//
//    //    func sendMessage(request: Message, onSuccess:@escaping(String) -> Void){
//    //
//    //        let messageDict = request.convertToDictionary()!
//    //
//    //        fdbRef.child("users").child(request.fromID!).child("Chat").child(request.toID!).observeSingleEvent(of: .value) { (snapshot) in
//    //
//    //            var conversationId = ""
//    //            var conversationDict: [String:AnyObject] = [:]
//    //
//    //            if let dataDict = snapshot.value as? [String : AnyObject]{
//    //                conversationId = dataDict["location"] as! String
//    //                conversationDict = [
//    //                    "timestamp" : request.timestamp!,
//    //                    "lastMessage" : request.content!
//    //                ] as [String : AnyObject]
//    //
//    //            }else{
//    //                conversationId = NSUUID().uuidString.lowercased()
//    //
//    //                conversationDict = [
//    //                    "location" : conversationId,
//    //                    "lastMessage" : request.content!,
//    //                    "timestamp" : request.timestamp!
//    //                ] as [String : AnyObject]
//    //            }
//    //
//    //            self.fdbRef.child("users").child(request.fromID!).child("Chat").child(request.toID!).updateChildValues(conversationDict)
//    //
//    //            self.fdbRef.child("users").child(request.toID!).child("Chat").child(request.fromID!).updateChildValues(conversationDict)
//    //
//    //            self.fdbRef.child("Chat").child(conversationId).childByAutoId().updateChildValues(messageDict as [String:AnyObject])
//    //
//    //            onSuccess(conversationId)
//    //        }
//    //
//    //    }
//}
//
//
////class ImageUploader {
////    func uploadImageToFirebase(image: UIImage) {
////        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
////            print("Failed to convert image to data.")
////            return
////        }
////
////        // Step 1: Get a reference to your Firebase Storage
////        let storage = Storage.storage()
////        let storageRef = storage.reference()
////
////        // Step 2: Create a reference to the image you want to upload (e.g., "images/imageName.jpg")
////        let imageName = "imageName.jpg" //"ChatImages/" + "post_" + timestamp
////        let imageRef = storageRef.child("images").child(imageName)
////
////        // Step 3: Upload the image data to Firebase Storage
////        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
////            guard metadata != nil else {
////                print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
////                return
////            }
////
////            // You can get the download URL if you need it.
////            imageRef.downloadURL { url, error in
////                if let downloadURL = url {
////                    print("Image download URL: \(downloadURL)")
////                } else {
////                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
////                }
////            }
////        }
////
////        // You can also observe the progress of the upload task if needed.
////        uploadTask.observe(.progress) { snapshot in
////            // Handle progress here
////            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
////            print("Upload progress: \(percentComplete)%")
////        }
////    }
////}
////
////
////class ImageUploader1 {
////    func uploadImageURLToFirebase(imageURL: String) {
////        // Step 1: Get a reference to your Firebase Storage
////        let storage = Storage.storage()
////        let storageRef = storage.reference()
////
////        // Step 2: Create a reference to the image you want to upload (e.g., "images/imageName.jpg")
////        let imageName = "imageName.jpg"
////        let imageRef = storageRef.child("images").child(imageName)
////
////        // Step 3: Upload the image URL to Firebase Storage
////        let uploadTask = imageRef.putData(imageURL.data(using: .utf8)!, metadata: nil) { metadata, error in
////            guard metadata != nil else {
////                print("Error uploading image URL: \(error?.localizedDescription ?? "Unknown error")")
////                return
////            }
////
////            // You can get the download URL if you need it.
////            imageRef.downloadURL { url, error in
////                if let downloadURL = url {
////                    print("Image download URL: \(downloadURL)")
////                } else {
////                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
////                }
////            }
////        }
////
////        // You can also observe the progress of the upload task if needed.
////        uploadTask.observe(.progress) { snapshot in
////            // Handle progress here
////            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
////            print("Upload progress: \(percentComplete)%")
////        }
////    }
////}
//
////func uploadImageToFirebase(image: UIImage,timeStamp: String, completion: @escaping (String?) -> Void) {
////    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
////        completion(nil)
////        return
////    }
////
////    let storageRef = Storage.storage().reference()
////    let imageName = UUID().uuidString + ".jpg"       ///"ChatImages/" + "post_" + timestamp
////    let imageRef = storageRef.child("images/\(imageName)")
////
////    let metadata = StorageMetadata()
////    metadata.contentType = "image/jpeg"
////
////    let uploadTask = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
////        if let error = error {
////            print("Error uploading image: \(error.localizedDescription)")
////            completion(nil)
////        } else {
////            // Image uploaded successfully, get the download URL
////            imageRef.downloadURL { (url, error) in
////                if let error = error {
////                    print("Error retrieving download URL: \(error.localizedDescription)")
////                    completion(nil)
////                } else {
////                    // Return the download URL
////                    completion(url?.absoluteString)
////                }
////            }
////        }
////    }
////
////    // You can also monitor the upload progress if needed
////    uploadTask.observe(.progress) { snapshot in
////        // Update UI with upload progress if necessary
////        let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
////        print("Upload progress: \(percentComplete)%")
////    }
////}
//private fun createChatRoom(userEmail: String){
//    var refChatRoom: DatabaseReference? = FirebaseDatabase.getInstance().reference
//    val timestamp = ""+System.currentTimeMillis()
//    userIdArray.add(myEmail!!)
//    for (i in 0 until userIdArray.size){
//        userList.add(userEmail[i])
//    }
//    val hash: HashMap<String, Any> = HashMap()
//    hash["broadcat"] = false
//    val hashMapChatRm: HashMap<String, Any> = HashMap()
//    hashMapChatRm["users"] = userList
//    hashMapChatRm["lastMessageText"] = ""
//    hashMapChatRm["lastMessage"] = timestamp
//    hashMapChatRm["type"] = "individual"
//    hashMapChatRm["creator"] = Utility.UID
//    hashMapChatRm["meta"] = hash
//    refChatRoom!!.child("chatRoom").push().setValue(hashMapChatRm)
//}
