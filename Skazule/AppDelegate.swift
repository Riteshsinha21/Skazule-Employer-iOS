//
//  AppDelegate.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window:UIWindow?
    var fcmToke: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //keyboard management
        IQKeyboardManager.shared.enable = true
        sleep(UInt32(0.5))
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        setupRemotePushNotifications()
        
        if (UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.IS_LOGIN) == nil)
        {
            UserDefaults.standard.set(false, forKey: USER_DEFAULTS_KEYS.IS_LOGIN)
        }
        // /*
        if ((UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.IS_LOGIN)) as! Bool == false)
        {
            //logoutUserFromAutoLogIn()
            initialiseAppWithController(LoginVC())
        }
        else
        {
            (UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.COMPANY_ID) as! String != "") ? initialiseAppWithController(loadTabBar()) : initialiseAppWithController(LoginVC())
        }
        // */
       // initialiseAppWithController(CreateCompanyScedulerSetupVC())
        //initialiseAppWithController(CreateCompanyEmployeeSetupVC())
        
        return true
    }
}

//extension AppDelegate: MessagingDelegate {
//    // [START refresh_token]
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase registration token: \(String(describing: fcmToken))")
//        let FCMTOKEN = fcmToken ?? ""
//        let dataDict: [String: String] = ["token": fcmToken ?? ""]
//        NotificationCenter.default.post(
//            name: Notification.Name("FCMToken"),
//            object: nil,
//            userInfo: dataDict
//        )
//        // TODO: If necessary send token to application server.
//        // Note: This callback is fired at each app startup and whenever a new token is generated.
//    }
//
//    // [END refresh_token]
//}
//var FCMTOKEN = ""
//var isFROMNotification = ""
//var appid = ""
//var token = ""
//var insert_id = ""
//var channel_name = ""
//
//var ChatEmail = ""
//var ChatqueryID = ""

//
extension AppDelegate : UNUserNotificationCenterDelegate {
    private func setupRemotePushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { [weak self] granted, error in
                if granted {
                    self?.getNotificationSettingsAndRegister()
                } else {
                    print(" error")
                }
            })
        
        Messaging.messaging().delegate = self
        
        UIApplication.shared.registerForRemoteNotifications()
        
        processPushToken()
    }
    
    private func getNotificationSettingsAndRegister() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    private func processPushToken() {
        if let token = Messaging.messaging().fcmToken {
            print("FCM TOKEN \(token)")
            UserDefaults.standard.set(token, forKey: USER_DEFAULTS_KEYS.FCM_KEY)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

public extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        processPushToken()
    }
}

