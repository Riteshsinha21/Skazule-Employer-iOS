//
//  EmployeeDocumentsTableCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 19/01/23.
//

import UIKit

class EmployeeDocumentsTableCell: UITableViewCell {

    @IBOutlet weak var docIconImgView: UIImageView!
    @IBOutlet weak var docNameLLbl: UILabel!
    @IBOutlet weak var uploadedByNameLbl: UILabel!
    @IBOutlet weak var createdAtDateLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var sharedByTitleLbl: UILabel!
    @IBOutlet weak var sharedOnTitleLbl: UILabel!
    
    @IBOutlet weak var deleteBtnBackView: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
