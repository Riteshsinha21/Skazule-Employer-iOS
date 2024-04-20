//
//  EmployeeListTableCell.swift
//  Skazule
//
//  Created by Chawtech on 13/12/22.
//

import UIKit

class EmployeeListTableCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var roleTextField: UILabel!
    @IBOutlet weak var mobileTextField: UILabel!
    @IBOutlet weak var tagTextField: UILabel!
    @IBOutlet weak var shiftNameTextField: UILabel!
    @IBOutlet weak var assignImgView: UIImageView!
    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var employeeProfilePicImgView: UIImageView!
    
    
    @IBOutlet weak var statusBackView: UIStackView!
    @IBOutlet weak var statusLbl: UILabel!

    
    @IBOutlet weak var editDeleteBackView: UIStackView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
