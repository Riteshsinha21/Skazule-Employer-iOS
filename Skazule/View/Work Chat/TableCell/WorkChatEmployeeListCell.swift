//
//  WorkChatEmployeeListCell.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 27/06/23.
//

import UIKit

class WorkChatEmployeeListCell: UITableViewCell {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var employeeLeftSideImgView: UIImageView!
    @IBOutlet weak var employeeNameLbl: UILabel!
    @IBOutlet weak var employeeLastMsgLbl: UILabel!
    
    @IBOutlet weak var employeeDeleteBtnBackView: UIView!
    @IBOutlet weak var employeeCheckBox: UIButton!
    
    @IBOutlet weak var employeeCheckBoxBackView: UIView!
    @IBOutlet weak var employeeDeleteBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
