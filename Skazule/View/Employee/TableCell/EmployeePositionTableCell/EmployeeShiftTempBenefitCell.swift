//
//  EmployeeShiftTempBenefitCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 28/12/22.
//

import UIKit

class EmployeeShiftTempBenefitCell: UITableViewCell {
    
    @IBOutlet weak var shiftBenefitsTopBackView: UIView!
    @IBOutlet weak var shiftNameLbl: UILabel!
    @IBOutlet weak var shiftTempBackView: UIView!
    @IBOutlet weak var benefitsBackView: UIView!
    @IBOutlet weak var shiftTimeLbl: UILabel!
    @IBOutlet weak var breakDurationLbl: UILabel!

    @IBOutlet weak var premiumPayLbl: UILabel!
    @IBOutlet weak var companyPayLbl: UILabel!
    @IBOutlet weak var employeePayLbl: UILabel!
    @IBOutlet weak var desLbl: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.shiftBenefitsTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
