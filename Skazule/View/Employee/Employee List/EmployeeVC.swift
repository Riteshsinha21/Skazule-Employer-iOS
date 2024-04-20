//
//  EmployeeVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit

class EmployeeVC: UIViewController {
    
    @IBOutlet weak var customNavigationBarForDrawer: CustomNavigationBarForDrawer!
    @IBOutlet weak var tbleView: UITableView!
    
    let employeeCellIconsArr = [#imageLiteral(resourceName: "employee_list"), #imageLiteral(resourceName: "positions"), #imageLiteral(resourceName: "tags"), #imageLiteral(resourceName: "shift_template"), #imageLiteral(resourceName: "documents"), #imageLiteral(resourceName: "employee_benefits")]
    let employeeCellLblArr = ["Employee List", "Positions", "Tags", "Shift Templates", "Documents", "Benefits"]
    
    // For Notification
    var notificationDetailArr = [NotificationDetailStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.customNavigationBarForDrawer.titleLabel.text = "Employee"
        // self.getNotificationDetailApi()
        customNavigationBarForDrawer.rightBtn.isHidden = true
        customNavigationBarForDrawer.rightBtn.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
        tbleView.register(UINib(nibName: "EmployeeTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeTableCell")
    }
    @objc func didTapNotificationButton (_ sender:UIButton) {
        print("Notification Button is selected")
        let vc = NotificationVC ()
        vc.notificationDetail = self.notificationDetailArr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getNotificationDetailApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_NOTIFICATION_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else { return }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "user_id": userId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { [self] (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    let totalCount = json["total_record_count"].stringValue
                    notificationCount = totalCount
                    if notificationCount != "0"
                    {
                        customNavigationBarForDrawer.notificationCountLbl.isHidden = false
                        customNavigationBarForDrawer.notificationCountLbl.text = notificationCount
                    }
                    else
                    {
                        customNavigationBarForDrawer.notificationCountLbl.isHidden = true
                    }
                    self.notificationDetailArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let id              = json["data"][i]["id"].stringValue
                        let company_id      = json["data"][i]["company_id"].stringValue
                        let user_id         = json["data"][i]["user_id"].stringValue
                        let type            = json["data"][i]["type"].stringValue
                        let title           = json["data"][i]["title"].stringValue
                        let message         = json["data"][i]["message"].stringValue
                        let from_id         = json["data"][i]["from_id"].stringValue
                        let redirect_url    = json["data"][i]["redirect_url"].stringValue
                        let status          = json["data"][i]["status"].stringValue
                        let created_at      = json["data"][i]["created_at"].stringValue
                        let updated_at      = json["data"][i]["updated_at"].stringValue
                        let sender_name     = json["data"][i]["sender_name"].stringValue
                        let sender_profile_pic = json["data"][i]["sender_profile_pic"].stringValue
                        
                        self.notificationDetailArr.append(NotificationDetailStruct.init(id: id, company_id: company_id, user_id: user_id, type: type, title: title, message: message, from_id: from_id, redirect_url: redirect_url, status: status, created_at: created_at, updated_at: updated_at,sender_name: sender_name,sender_profile_pic: sender_profile_pic))
                    }
                    print(self.notificationDetailArr)
                    
                }
                else {
                    
                }
                
                DispatchQueue.main.async {
                    
                }
                
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
}
extension EmployeeVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeCellLblArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTableCell") as! EmployeeTableCell
        cell.selectionStyle = .none
        
        cell.employeeLeftSideImgView.image = self.employeeCellIconsArr[indexPath.row]
        cell.titleLbl.text = self.employeeCellLblArr[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectRow(indexPath: indexPath as NSIndexPath)
    }
    func selectRow(indexPath:NSIndexPath)
    {
        switch indexPath.row
        {
        case 0:
            let vc = EmployeeListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = EmployeePositionsVC()
            self.navigationController?.pushViewController(vc, animated: true)
            print("EmployeePositionsVC")
        case 2:
            let vc = EmployeeTagsVC()
            self.navigationController?.pushViewController(vc, animated: true)
            print("EmployeeTagsVC")
        case 3:
            let vc = EmployeeShiftTemplatesVC()
            self.navigationController?.pushViewController(vc, animated: true)
            print("EmployeeShiftTemplatesVC")
        case 4:
            let vc = EmployeeDocumentsVC()
            self.navigationController?.pushViewController(vc, animated: true)
            print("EmployeeDocumentsVC")
        case 5:
            let vc = EmployeeBenefitsVC()
            self.navigationController?.pushViewController(vc, animated: true)
            print("EmployeeBenefitsVC")
        default: break
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
}
