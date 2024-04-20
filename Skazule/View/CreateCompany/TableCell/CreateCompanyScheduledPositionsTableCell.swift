//
//  CreateCompanyScheduledPositionsTableCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 23/11/22.
//

import UIKit

class CreateCompanyScheduledPositionsTableCell: UITableViewCell {
    
    
    @IBOutlet weak var cellBackView: UIView!
    @IBOutlet weak var jobPositionNameLbl: UILabel!
    @IBOutlet weak var jobPositionCheckBox: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
