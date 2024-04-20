//
//  ProfilePurchasedListCell.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 30/05/23.
//

import UIKit

class ProfilePurchasedListCell: UITableViewCell {
    
    @IBOutlet weak var statusBackView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var planLbl: UILabel!
    @IBOutlet weak var transactionIdLbl: UILabel!
    @IBOutlet weak var paymenModetLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var purchaseLbl: UILabel!
    @IBOutlet weak var expireDateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        statusBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    //    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
