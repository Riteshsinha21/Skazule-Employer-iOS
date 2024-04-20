//
//  PushNotificationSender.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String,email : String,queryID : String, image: String,fcmServerKey:String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : [
                                            "title" : title,
                                            "body" : body,
                                            "sound": "default",
                                            "email" : email,
                                            "queryID" : queryID
                                           ],
                                           "data" : ["icon" : "app_icon", "title": title, "body": body, "email" : email,"queryID" : queryID],
                                           "priority": "high",
                                           "podcast-image": image
                                            ]
        print(paramString)
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("key=AAAAcbuEb50:APA91bHe28sZTqDtrsKcMcdeQWcDkQVwu1Km19Qhv4NTI4RSLI6iNDw4_jUfg46coN0E_HGVziKDJ8hU10R6Fw7ltSpzqFm3TWx9bYR503oWhJXT2-Rfb-ipjKxOTvzuO-ruX5YR46ld", forHTTPHeaderField: "Authorization")
     print("key=AAAAz8eOx3c:APA91bFR5T-Ij_ReEWqHAE_SkF-u7vTtqNiakvxgdpgo-Hq7JLJvZbtYgF_wwcgRVPn1FRIH2oGj315BgnGmcgVtSRmKI2PqxpiQ3ebE3SDrv8w31pw_hpuBSv2VUXMXcLvxNRqQflXv")
      print("key=\(fcmServerKey)")
        request.setValue("key=\(fcmServerKey)", forHTTPHeaderField: "Authorization")
//        AAAArQFhByI:APA91bEjAYj2KCHL4kU0wggvTCpNpmKVUHGW9zD90SUvFlCIGK5PlOKK1bU2Sc8Mm36MKw-pYIuyzhL3VgorN4MPFaPBg2trB-AXSugGNpF4Pwye74CQIFxFYEuVPL8iT2A0oTnR_C3F

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
