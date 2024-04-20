//
//  UserDefaultUtility.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

struct UserDefaultUtility
{
    func saveUserId(userId: String)
    {
        UserDefaults.standard.set(userId, forKey: "userId")
    }

    func getUserId() -> Int
    {
        return UserDefaults.standard.value(forKey: "userId") as! Int
    }
}
