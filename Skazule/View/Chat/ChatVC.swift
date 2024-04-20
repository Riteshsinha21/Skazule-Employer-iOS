//
//  ChatVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit

class ChatVC: UIViewController {

    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var sendMsgTxtView: UITextView!
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigationBar.titleLabel.text = "Employee Name"
        customNavigationBar.customRightBarButton.isHidden = false
        let imageUrl = IMAGE_BASE_URL + "info.profile_pic"
        customNavigationBar.customRightBarButton.sd_setImage(with: URL(string:imageUrl), for: .normal, placeholderImage: #imageLiteral(resourceName: "profilePlaceHolder"))
        customNavigationBar.customRightBarButton.tintColor = UIColor(named: "ButtonColor")
        self.sendMsgTxtView.placeholder = "Type a message..."
        
//        var component = URLComponents(string: "")
//        component?.queryItems = [
//        URLQueryItem(name: "", value: "")
//        ]
        
        
    }
    
    @IBAction func onTapAttachBtn(_ sender: Any) {
    }
    
    @IBAction func onTapSendBtn(_ sender: Any) {
    }
}
