//
//  SchedulerShiftTableCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 02/03/23.
//

import UIKit

class SchedulerShiftTableCell: UITableViewCell {
    
    @IBOutlet weak var cellBackView: CardView!
    @IBOutlet weak var cellTopView: UIView!
    
    @IBOutlet weak var scheduleTimeLbl: UILabel!
    @IBOutlet weak var positionNameLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var assignImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
