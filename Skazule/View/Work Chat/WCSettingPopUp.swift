//
//  WCSettingPopUp.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 27/07/23.
//

import UIKit
import IQKeyboardManagerSwift

class WCSettingPopUp: UIView {
    var view: UIView!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var broadcastBtn: UIButton!
    @IBOutlet weak var discussionBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        //        let roundViewHeight : Int = upperRoundViewHeight
        //        upperRoundView.layer.cornerRadius = roundViewHeight/2
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        // 3. Setup view from .xib file
        xibSetup()
    }
    func xibSetup() {
        view = loadViewFromNib()
        //IQKeyboardManager.shared.enable = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // use bounds not frame or it'll be offset
        view.frame = bounds
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        
        
        if broadcastSelectionStatus {
            broadcastSelectionStatus  = true
            discussionSelectionStatus = true
        }
        else
        {
            broadcastSelectionStatus  = false
            discussionSelectionStatus = false
        }
        
        self.broadcastBtn.isSelected  = broadcastSelectionStatus
        self.discussionBtn.isSelected = discussionSelectionStatus
        
        
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "WCSettingPopUp", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func onTapCancelBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func onTapRadioBtn(_ sender: Any) {
    }
    
    @IBAction func onTapAddBtn(_ sender: Any) {
    }
}
