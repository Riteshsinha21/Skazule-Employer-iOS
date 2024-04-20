//
//  ValidationManager.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import UIKit

class ValidationManager: NSObject {

    class func validatePassword(password:String) -> Int {
        let characterSet = NSCharacterSet.whitespaces
        let range = password.rangeOfCharacter(from: characterSet)
        
        if range == nil {
            if password.count >= kPasswordMinimumLength  {
                return 2
            } else {
                return 0
            }
        } else {
            return 1
        }
    }
    
    class func validateEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    class func validateZipCode(zipCode:String) -> Bool {  //For US only
        let zipCodeRegEx = "^\\d{5}([\\-]?\\d{4})?$"
        let zipCodeTest = NSPredicate(format:"SELF MATCHES %@", zipCodeRegEx)
        return zipCodeTest.evaluate(with: zipCode)
    }
    
    class func validateUserFullName(name:String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedName.count < 2 {
            return false
        } else {
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ. ")
            if trimmedName.rangeOfCharacter(from: characterset.inverted) != nil {
                return false
            } else {
                return true
            }
        }
    }
    
    class func validateMobile(no:String) -> Bool {
        let mobileRegEx = NSString(format:"[0-9]{%d}",kPhoneNumberMaximumLength) as String
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", mobileRegEx)
        return phoneTest.evaluate(with: no)
    }
    class func validatePhone(no: String) -> Bool {
        //  let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
        //return (no.count == 10)
        return (no.count > 8) && (no.count < 14)
    }
    /*
     class func validatePhone(no: String) -> Bool {
     return (no.count == 10)
     }
     */
    
    class func validatePhoneWithCountryCode(no: String) -> Bool {
    // let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
        
        if self.isAllDigits(str: no) == true {
            let phoneRegex = "^((\\+)|(00))[0-9]{6,14}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return  predicate.evaluate(with: self)
        }else {
            return false
        }
     }
    
//    class func validatePhone(no: String)->Bool {
//        if self.isAllDigits(str: no) == true {
//            let phoneRegex = "[235689][0-9]{6}([0-9]{3})?"
//            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
//            return  predicate.evaluate(with: self)
//        }else {
//            return false
//        }
//    }
    
     class func isAllDigits(str:String)->Bool {
        let charcterSet  = NSCharacterSet(charactersIn: str).inverted
        let inputString = str.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  str == filtered
    }

    
    class func validateFieldForEmpty(text:String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedText.count == 0 {
            return false
        } else {
            return true
        }
    }
    
    class func validateAlphanumericAndLength(text:String,length: Int) -> Bool {
        let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedText.count < length {
            return false
        } else {
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 ")
            if trimmedText.rangeOfCharacter(from: characterset.inverted) != nil {
                return false
            } else {
                return true
            }
        }
    }
    
   

}
