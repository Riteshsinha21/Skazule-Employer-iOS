//
//  EmployeeTableViewCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import UIKit

class EmployeeTableViewCell: UITableViewCell {

    @IBOutlet weak var employeeName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
