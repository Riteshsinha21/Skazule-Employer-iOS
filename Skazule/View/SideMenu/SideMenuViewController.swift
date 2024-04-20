//
//  SideMenuViewController.swift
//  Skazule
//
//  Created by Demo on 09/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController
{
    @IBOutlet weak var userProfileBtn: UIButton!
    @IBOutlet weak var employerNameLbl: UILabel!
    @IBOutlet weak var employerEmailLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var logoutBtn: UIButton!
    
    var cellReuseIdentifier = "SideMenuTableViewCell"
    var menuTitleArr = ["Dashboard", "Employee", "Scheduler", "Time off Request", "Time Tracking", "Work Chat", "Delete Account"]
    var menuTitleImgArr = [#imageLiteral(resourceName: "dashboard"), #imageLiteral(resourceName: "employee"), #imageLiteral(resourceName: "scheduler"), #imageLiteral(resourceName: "time_off_request"), #imageLiteral(resourceName: "time_tracking"), #imageLiteral(resourceName: "workchat"), #imageLiteral(resourceName: "delete-account")]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tblView.register(UINib(nibName: "SideMenuTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: cellReuseIdentifier)
        DispatchQueue.main.async
        {
            self.tblView.reloadData()
        }
    }
    // MARK:- viewWillAppear
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        self.setprofileData()
    }
    func setprofileData()
    {
        let placeholderImage = UIImage(named: "profilePlaceHolder")?.withRenderingMode(.alwaysTemplate)
        placeholderImage?.sd_tintedImage(with: UIColor.red)
        
        let employerPhoto = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_PROFILE_PIC) ?? ""
        let employerEmail = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMAIL)
        let employerName = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_NAME)
        let companyName = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_NAME)
        
        let imageUrl = IMAGE_BASE_URL + employerPhoto
        self.userProfileBtn.sd_setImage(with: URL(string:imageUrl), for: .normal, placeholderImage:  #imageLiteral(resourceName: "profilePlaceHolder"))
        
        self.employerNameLbl.text = employerName
        self.employerEmailLbl.text = employerEmail
        self.companyNameLbl.text = companyName
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.EMPLOYER_PROFILE_PIC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.EMPLOYER_NAME), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.EMAIL), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.COMPANY_NAME), object: nil)
    }
    //MARK:- viewDidDisappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    //MARK:- Notification selector
    @objc func openNotification(_ notification: Notification)
    {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            
            if let photo = dict["employerPhoto"] as? String {
                // do something with your image
                let imageUrl = IMAGE_BASE_URL + photo
                self.userProfileBtn.sd_setImage(with: URL(string:imageUrl), for: .normal, placeholderImage:  #imageLiteral(resourceName: "profilePlaceHolder"))
            }
            
            if let employerName = dict["employerName"] as? String {
                // do something with your image
                self.employerNameLbl.text = employerName
            }
            if let email = dict["email"] as? String {
                // do something with your image
                self.employerEmailLbl.text = email
            }
            if let companyName = dict["companyName"] as? String {
                // do something with your image
                self.companyNameLbl.text = companyName
            }
        }
    }
    
    @IBAction func profileBtnClicked(_ sender: UIButton)
    {
        let rootController = (sideMenuViewController.rootViewController as! UINavigationController)
        var tabbarController = UITabBarController()
        tabbarController = rootController.viewControllers.last as! UITabBarController
        removeController(rootController: rootController)
        sideMenuViewController.hideLeftView(animated: true, completion: nil)
        rootController.pushViewController(ProfileVC(), animated: false)
        NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
    }
    private func deleteEmployerAccount()
    {
        let Alert = UIAlertController(title: "We are sorry to see you go !", message: "Are you sure, You want to Delete this account! \n Please note that once you choose to delete your account, your account will no longer be available to you and you will not be able to use the account again.", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteAccountApi()
        }))
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
    }
    
    func deleteAccountApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_ACCOUNT_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            
            var param:[String:Any] = ["user_id": userId]
            print(param)
            ///*
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UserDefaults.standard.set(false, forKey: USER_DEFAULTS_KEYS.IS_REMEMBER_USER)
                    logoutUser()
                }
                else {
                    var errorMsg = ""
                    let errorDict = json["error"].dictionaryValue
                    // enumerate all of the keys and values
                    for (key, value) in errorDict {
                        print("\(key) -> \(value)")
                        for i in 0..<value.count
                        {
                            errorMsg = " \(json["error"][key][i].stringValue)"
                        }
                        print(errorMsg)
                    }
                    if errorMsg == ""
                    {
                        //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            //*/
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    @IBAction func logoutBtnClicked(_ sender: UIButton)
    {
        let Alert = UIAlertController(title: "Alert", message: "Are you sure, You want to Logout!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            logoutUser()
        }))
        /*
         Alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action: UIAlertAction!) in
         }))
         */
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
    }
}
extension SideMenuViewController : UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.menuTitleArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
        cell.selectionStyle = .none
        let title =  self.menuTitleArr[indexPath.row]
        cell.titleLbl.text = title
        cell.sideIconImgView.image = self.menuTitleImgArr[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectRow(indexPath: indexPath as NSIndexPath)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func selectRow(indexPath:NSIndexPath)
    {
        let rootController = (sideMenuViewController.rootViewController as! UINavigationController)
        var   tabbarController = UITabBarController()
        //        if  rootController.viewControllers.first is UITabBarController
        //        {
        //            tabbarController = rootController.viewControllers.first as! UITabBarController
        //        }
        //        else if  rootController.viewControllers.last is UITabBarController
        //        {
        //            tabbarController = rootController.viewControllers.last as! UITabBarController
        //        }
        
        tabbarController = rootController.viewControllers.last as! UITabBarController
        removeController(rootController: rootController)
        
        switch indexPath.row
        {
        case 0:
            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            tabbarController.selectedIndex = 2
            //rootController.pushViewController(DashboardVC(), animated: false)
            
            NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
            break
        case 1:
            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            tabbarController.selectedIndex = 0
            NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
            
            //let selectedIndexItem = ["index": 0]
            //            NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil, userInfo: selectedIndexItem)
            //rootController.pushViewController(EmployeeVC(), animated: false)
            break
        case 2:
            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            tabbarController.selectedIndex = 1
            NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
            // rootController.pushViewController(SchedulerVC(), animated: false)
            break
        case 3:
            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            rootController.pushViewController(TimeOffRequestVC(), animated: false)
            break
        case 4:
            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            tabbarController.selectedIndex = 3
            NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
            //            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            //            rootController.pushViewController(TimeTrackingVC(), animated: false)
            //            //print("Click on Time Traking")
            break
            //        case 5:
            //            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            //            tabbarController.selectedIndex = 4
            //            NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
            //            //rootController.pushViewController(WorkChatVC(), animated: false)
            //            break
            //        case 6:
            //            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            //            rootController.pushViewController(BonusVC(), animated: false)
            //            print("BonusVC")
            //            break
            //        case 7:
            //            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            //            rootController.pushViewController(BenefitsVC(), animated: false)
            //            break
        case 5:
            sideMenuViewController.hideLeftView(animated: true, completion: nil)
            tabbarController.selectedIndex = 4
            NotificationCenter.default.post(name: NSNotification.Name("CommingFromSideMenu"),object: nil)
            //rootController.pushViewController(PayrollVC(), animated: false)
            break
        case 6:
            print("twrywteryuweteywr")
            self.deleteEmployerAccount()
            break
        default: break
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
}

