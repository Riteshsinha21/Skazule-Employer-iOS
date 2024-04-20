//
//  EmployeeTimeTrackingCell.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 12/05/23.
//

import UIKit

class EmployeeTimeTrackingCell: UITableViewCell {

    @IBOutlet weak var employeeNameTopBackView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var employeeNameLbl: UILabel!
    @IBOutlet weak var employeeShiftTimeLbl: UILabel!
    @IBOutlet weak var employeeInTimeLbl: UILabel!
    @IBOutlet weak var employeeOutTimeLbl: UILabel!
    
    @IBOutlet weak var shiftHoursBackView: UIStackView!
    @IBOutlet weak var paidHoursBackView: UIStackView!
    @IBOutlet weak var otHoursBackView: UIStackView!
    
    @IBOutlet weak var shiftHoursLbl: UILabel!
    @IBOutlet weak var piadHoursLbl: UILabel!
    @IBOutlet weak var otHoursLbl: UILabel!
    @IBOutlet weak var rightArrowBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
