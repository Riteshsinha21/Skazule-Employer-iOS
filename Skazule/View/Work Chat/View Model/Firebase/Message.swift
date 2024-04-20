//
//  WorkChatDetailChatVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 28/06/23.
//

import Foundation

struct Message: Encodable {
    var content: String?
    var fromID: String?
    var timestamp: String?
    var isRead: Bool?
    var toID: String?
    var type: String?
    var queryId: String?
}
//company_id, email, role, profile_pic, message      keep these fields mandatory while sending message

struct Message1: Encodable {
    var message    : String?
    var senderId   : String? //fromID
    var receiverId : String? //toID
    var timestamp  : String?
    var type       : String?
    var isSeen     : Bool?
//    var companyId  : String?
//    var email      : String?
//    var role       : String?
//    var profileImg : String?
}
//                hashMap["senderId"] = senderId
//                hashMap["receiverId"] = receiverId
//                hashMap["message"] = message
//                hashMap["timestamp"] = timestamp
//                hashMap["type"] = "text"
//                hashMap["roomId"] = roomId!!


struct CreateChatRoom: Encodable {
    var senderId   : String? //fromID
    var receiverId : String? //toID
    var lastMessageText, lastMessage,type,creator  : String?
    var timestamp: String?
}

struct FBDChatRoom {
    var lastMessageText     : String?
    var lastMessage         : String? // this is time stamp
    var type                : String?
    var creator             : String?
    var meta                : [String:Any]?
    var users               : [String:Any]?
    
    var roomId              : String?
    var user_key            : String?
    var meta2               : Meta2?
}
struct Meta2 {
    var userId              : String?
    var userName            : String?
    var userEmail           : String?
    var userMobile          : String?
    var timestamp           : String?
    var profileImage        : String?
}



struct ChatRoomUsers {
    var roomId     : String?
    var roomData   : [String:Any]?
}



struct Message2: Encodable {
    var content     : String?
    var fromID      : String?
    var toID        : String?
    var roomId      : String?
    var timestamp   : String?
    var type        : String?
}

struct MessageStruct: Encodable {
    var message    : String
    var senderId   : String //fromID
    var receiverId : String //toID
    var timestamp  : String
    var type       : String
    var roomId     : String
}


struct GroupChatRoom: Encodable {
    var users           : [String]
    var lastMessageText : String
    var lastMessage     : String
    var type            : String
    var creator         : String
    var timestamp       : String
    var meta            : GroupChatMeta
}
struct GroupChatMeta: Encodable {
    var title        : String
    var description  : String
    var icon         : String
    var broadcat     : Bool
}
