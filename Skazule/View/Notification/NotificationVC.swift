//
//  NotificationVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 17/08/23.
//

import UIKit

class NotificationVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var tblView: UITableView!
    var notificationDetail = [NotificationDetailStruct]()
    
    @IBOutlet weak var emptyView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.titleLabel.text = "Notification"
        self.tblView.register(UINib(nibName: "NotificationCell", bundle: .main), forCellReuseIdentifier: "NotificationCell")
        //self.tblView.reloadData()
        
        DispatchQueue.main.async {
            if self.notificationDetail.count == 0
            {
                self.tblView.isHidden = true
                self.emptyView.isHidden = false
            }
            else
            {
                self.tblView.isHidden = false
                self.emptyView.isHidden = true
            }
            self.tblView.reloadData()
        }
    }
}
extension NotificationVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.notificationDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        cell.selectionStyle = .none
        let info = self.notificationDetail[indexPath.row]
        cell.userNameLbl.text = info.sender_name
        cell.titleLbl.text = info.title
        cell.messageLbl.text = "\(info.message)\n\(info.created_at)"
        
        let imageUrl = IMAGE_BASE_URL + info.sender_profile_pic
        cell.employeeImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        UITableView.automaticDimension
    }
}
