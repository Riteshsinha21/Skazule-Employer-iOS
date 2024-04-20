//
//  WorkChatDetailChatVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 28/06/23.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

var employeeIdArray = [String]()
var userListDict    = [String:Bool]()

struct UserViewModel {
    
    private let fdbRef = Database.database().reference()
    
    func loginWithFirebase(email:String, userId:String, userName:String, profile:String, timestamp : String, role : String, onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
        
        let fcmKey = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.FCM_KEY) as? String
        
        Auth.auth().signIn(withEmail: email, password: "123456") { (result, error) in
            
            if error != nil{
                onError(error!.localizedDescription)
            }else{
                
                guard let userId = Auth.auth().currentUser?.uid  else { return }
                UserDefaults.standard.set(userId, forKey: "userId")
                
                let userDict = [
                    "userId"    : userId,
                    "userName"  : userName,
                    "profile"   : profile,
                    "email"     : email,
                    "timestamp" : timestamp,
                    "role"      : role,
                    "fcmKey"    : "\(fcmKey ?? "")"
                ]
                
                fdbRef.child("Users").child(userId).updateChildValues(userDict as [AnyHashable : Any])
                onSuccess(true)
            }
        }
    }
    //    func employeeLoginWithFirebase(email:String, userId:String, userName:String, profile:String, timestamp : String, role : String, alreadyExistEmployee: Bool, onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
    //
    //        Auth.auth().signIn(withEmail: email, password: "123456") { (result, error) in
    //
    //            if error != nil{
    //                onError(error!.localizedDescription)
    //            }else{
    //                guard let employeeId = Auth.auth().currentUser?.uid  else { return }
    //                let userDict = [
    //                    "userId"    : employeeId,
    //                    "userName"  : userName,
    //                    "profile"   : profile,
    //                    "email"     : email,
    //                    "timestamp" : timestamp,
    //                    "role"      : role
    //                ]
    ////                if alreadyExistEmployee == false
    ////                {
    ////                    userIdArray.append(employeeId)
    ////                }
    //                userIdArray.append(employeeId)
    //                let chatViewModel = ChatViewModel()
    //                chatViewModel.createChatRoom()
    //                fdbRef.child("Users").child(employeeId).updateChildValues(userDict as [AnyHashable : Any])
    //                onSuccess(true)
    //            }
    //        }
    //    }
    //
    
    func employeeLoginWithFirebase(email: String, password: String, userName: String, role: String, timestamp: String, profilePic: String, fcmKey: String?, checkedUnCheck: String?, alreadyExistEmployee: Bool, onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: "123456") { (result, error) in
            
            if error != nil{
                hideAllProgressOnView(appDelegateInstance.window!)
                onError(error!.localizedDescription)
            }else{
                guard let employeeId = Auth.auth().currentUser?.uid  else { return }
                let userDict = [
                    "userId"    : employeeId,
                    "userName"  : userName,
                    "profile"   : profilePic,
                    "email"     : email,
                    "timestamp" : timestamp,
                    "role"      : role,
                    "fcmKey"    : "\(fcmKey ?? "")"
                ]
                userIdArray.append(employeeId)
                let chatViewModel = ChatViewModel()
                chatViewModel.createChatRoom()
                fdbRef.child("Users").child(employeeId).updateChildValues(userDict as [AnyHashable : Any])
                onSuccess(true)
            }
        }
    }
    /*
     func addEmployeeLoginWithFirebase(email: String, password: String, userName: String, role: String, timestamp: String, profilePic: String, fcmKey: String?, checkedUnCheck: String?, alreadyExistEmployee: Bool, onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
     
     Auth.auth().signIn(withEmail: email, password: "123456") { (result, error) in
     
     if error != nil{
     onError(error!.localizedDescription)
     }else{
     guard let employeeId = Auth.auth().currentUser?.uid  else { return }
     let userDict = [
     "userId"    : employeeId,
     "userName"  : userName,
     "profile"   : profilePic,
     "email"     : email,
     "timestamp" : timestamp,
     "role"      : role,
     "fcmKey"    : "\(fcmKey ?? "")"
     ]
     //userIdArray.append(employeeId)
     if (checkedUnCheck == "true")
     {
     employeeIdArray.append(employeeId)   //.add(userId!!)
     }
     else
     {
     if let index = employeeIdArray.firstIndex(of: employeeId) {
     employeeIdArray.remove(at: index)
     }
     
     }
     //              let chatViewModel = ChatViewModel()
     //               chatViewModel.createChatRoom()
     
     fdbRef.child("Users").child(employeeId).updateChildValues(userDict as [AnyHashable : Any])
     //                fdbRef.child("Users").child(employeeId).setValue(userDict as [AnyHashable : Any])
     
     onSuccess(true)
     }
     }
     }
     */
    func addEmployeeLoginWithFirebase(email: String, password: String, userName: String, role: String, timestamp: String, profilePic: String, fcmKey: String?, checkedUnCheck: String?, alreadyExistEmployee: Bool, onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: "123456") { (result, error) in
            
            if error != nil{
                hideAllProgressOnView(appDelegateInstance.window!)
                onError(error!.localizedDescription)
            }else{
                guard let employeeId = Auth.auth().currentUser?.uid  else { return }
                let userDict = [
                    "userId"    : employeeId,
                    "userName"  : userName,
                    "profile"   : profilePic,
                    "email"     : email,
                    "timestamp" : timestamp,
                    "role"      : role,
                    "fcmKey"    : "\(fcmKey ?? "")"
                ]
                //userIdArray.append(employeeId)
                if (checkedUnCheck == "true")
                {
                    employeeIdArray.append(employeeId)   //.add(userId!!)
                    fdbRef.child("Users").child(employeeId).updateChildValues(userDict as [AnyHashable : Any])
                }
                else
                {
                    if let index = employeeIdArray.firstIndex(of: employeeId) {
                        employeeIdArray.remove(at: index)
                        
                        fdbRef.child("Users").child(employeeId).removeValue()
                        
                        //                        FirebaseDatabase.getInstance().getReference("Users").child(db_userId!!).removeValue()
                    }
                    
                    
                }
                //              let chatViewModel = ChatViewModel()
                //               chatViewModel.createChatRoom()
                
                /*
                 fdbRef.child("Users").child(employeeId).updateChildValues(userDict as [AnyHashable : Any])
                 */
                
                //                fdbRef.child("Users").child(employeeId).setValue(userDict as [AnyHashable : Any])
                
                onSuccess(true)
            }
        }
    }
    
    func addParticipantLoginWithFirebase(email: String, password: String, userName: String, role: String, timestamp: String, profilePic: String, fcmKey: String?, checkedUnCheck: String?, alreadyExistEmployee: Bool, onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: "123456") { (result, error) in
            
            if error != nil{
                onError(error!.localizedDescription)
            }else{
                guard let employeeId = Auth.auth().currentUser?.uid  else { return }
                let userDict = [
                    "userId"    : employeeId,
                    "userName"  : userName,
                    "profile"   : profilePic,
                    "email"     : email,
                    "timestamp" : timestamp,
                    "role"      : role,
                    "fcmKey"    : "\(fcmKey ?? "")"
                ]
                //userIdArray.append(employeeId)
                if (checkedUnCheck == "true")
                {
                    employeeIdArray.append(employeeId)   //.add(userId!!)
                    
                    //                    if (!userIdArray.contains(userId)){
                    //                        userIdArray.add(userId!!)
                    //                    }else{
                    //                        showToast("user already exist in the group")
                    //                    }
                    
                }
                else
                {
                    if let index = employeeIdArray.firstIndex(of: employeeId) {
                        employeeIdArray.remove(at: index)
                    }
                }
                let chatViewModel = ChatViewModel()
                //                fdbRef.child("Users").child(employeeId).updateChildValues(userDict as [AnyHashable : Any])
                fdbRef.child("Users").child(employeeId).setValue(userDict as [AnyHashable : Any])
                
                onSuccess(true)
            }
        }
    }
    
    
    func createGroupRoom(request: GroupChatRoom, onSuccess:@escaping(String?) -> Void, onError:@escaping(String) -> Void) {
        
        let groupDetailDict = request.convertToDictionary()!
        guard let employerId = UserDefaults.standard.value(forKey: "userId") as? String else {
            return
        }
        employeeIdArray.append(employerId)
        userListDict.removeAll()
        for item in employeeIdArray
        {
            userListDict[item] = true
        }
        var metaDict: [String:AnyObject] = [:]
        metaDict = [
            "title"        : request.meta.title,
            "description"  : "",
            "icon"         : request.meta.icon,
            "broadcat"     : false
        ] as [String : AnyObject]
        var GroupChatRoomDict: [String:AnyObject] = [:]
        GroupChatRoomDict = [
            "users"             : userListDict,
            "lastMessageText"   : "",
            "lastMessage"       : request.timestamp,
            "type"              : "group",
            "creator"           : employerId,
            "timestamp"         : request.timestamp,
            "meta"              : metaDict
        ] as [String : AnyObject]
        
        //        fdbRef.child("chatRoom").childByAutoId().updateChildValues(GroupChatRoomDict)
        fdbRef.child("chatRoom").childByAutoId().setValue(GroupChatRoomDict)
        
        
        onSuccess("true")
    }
    func updateGroupRoom(request: GroupChatRoom, roomId:String, onSuccess:@escaping(String?) -> Void, onError:@escaping(String) -> Void) {
        
        let groupDetailDict = request.convertToDictionary()!
        guard let employerId = UserDefaults.standard.value(forKey: "userId") as? String else {
            hideAllProgressOnView(appDelegateInstance.window!)
            return
        }
        //        employeeIdArray.append(employerId)
        //        for item in employeeIdArray
        //        {
        //            userListDict[item] = true
        //        }
        
        userListDict.removeAll()
        for item in userIdArray
        {
            userListDict[item] = true
        }
        var metaDict: [String:AnyObject] = [:]
        metaDict = [
            "title"        : request.meta.title,
            "description"  : "",
            "icon"         : request.meta.icon,
            "broadcat"     : false
        ] as [String : AnyObject]
        var GroupChatRoomDict: [String:AnyObject] = [:]
        GroupChatRoomDict = [
            "users"             : userListDict,
            "lastMessageText"   : "",
            "lastMessage"       : request.timestamp,
            "type"              : "group",
            "creator"           : employerId,
            "timestamp"         : request.timestamp,
            "meta"              : metaDict
        ] as [String : AnyObject]
        
        fdbRef.child("chatRoom").child(roomId).updateChildValues(GroupChatRoomDict)
        fdbRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else { return }
            if let dataDict = snapshot.value as? [String:AnyObject]{
                print(dataDict)
            }
            onSuccess("true")
        }
        
    }
    
    
    //    func loginWithFirebase(email: String, password: String, id : String, name : String,ID : String,onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
    //
    //        Auth.auth().signIn(withEmail: email, password: "123456") { (result, error) in
    //
    //            if error != nil{
    //                onError(error!.localizedDescription)
    //            }else{
    //
    //                guard let userId = Auth.auth().currentUser?.uid  else { return }
    //
    //                let userDict = [
    //                    "email": email,
    //                    "name" : name
    //                ]
    //
    //                fdbRef.child("users").child(userId).updateChildValues(userDict as [AnyHashable : Any])
    //                onSuccess(true)
    //            }
    //        }
    //    }
    //    (email:String, userId:String, userName:String, profile:String, timestamp : String, role : String)
    
    //    func signUpWithFirebase(email: String, password: String ,id : String, name : String,ID : String, onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
    
    func signUpWithFirebase(email: String, password: String ,userId : String, userName : String, profile : String, timestamp : String, role : String, onSuccess:@escaping(Bool) -> Void, onError:@escaping(String) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: "123456") { (result, error) in
            
            if let err = error{
                let error = err as NSError
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    onSuccess(true)
                default:
                    onError(error.localizedDescription)
                }
            }else{
                onSuccess(true)
            }
        }
    }
    
}
