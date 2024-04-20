//
//  SchedulerWeekCollectionCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 02/03/23.
//

import UIKit

class SchedulerWeekCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var cellBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
//    override var isSelected: Bool {
//        didSet {
//            //            self.contentView.backgroundColor = isSelected ? UIColor.white : UIColor.systemGray6
//            self.cellView.backgroundColor = isSelected ? .white : .systemGray6
//        }
//    }
    // Add this inside your cell configuration.
    private func setupSelectionColor() {
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = .white
//        self.backgroundView = backgroundView
        self.cellView.backgroundColor  = .white

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .orange
        self.selectedBackgroundView = selectedBackgroundView
    }
}
