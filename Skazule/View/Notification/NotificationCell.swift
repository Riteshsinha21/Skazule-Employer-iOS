//
//  NotificationCell.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 17/08/23.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var employeeImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
