//
//  TodayOpenShiftCell.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 18/08/23.
//

import UIKit

class TodayOpenShiftCell: UITableViewCell {
    
    @IBOutlet weak var scheduleTimeLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var viewBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
