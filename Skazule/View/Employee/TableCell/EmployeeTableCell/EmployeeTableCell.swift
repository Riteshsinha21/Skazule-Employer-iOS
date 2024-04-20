//
//  EmployeeTableCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 13/12/22.
//

import UIKit

class EmployeeTableCell: UITableViewCell {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var employeeLeftSideImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var employeeCheckBox: UIButton!
    @IBOutlet weak var assignImgView: UIImageView!

    @IBOutlet weak var titleLeadingHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
