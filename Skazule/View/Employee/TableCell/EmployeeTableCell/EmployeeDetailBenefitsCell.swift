//
//  EmployeeDetailBenefitsCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 19/12/22.
//

import UIKit

class EmployeeDetailBenefitsCell: UITableViewCell {
    
    
    @IBOutlet weak var BenefitNameLbl: UILabel!
    @IBOutlet weak var rightDownArrowBtn: UIButton!
    @IBOutlet weak var premiumPayLbl: UILabel!
    @IBOutlet weak var companyPayLbl: UILabel!
    @IBOutlet weak var employeePayLbl: UILabel!
    @IBOutlet weak var benefitsDetailBackView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
