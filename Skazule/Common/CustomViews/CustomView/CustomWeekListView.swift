//
//  CustomWeekListView.swift
//  Skazule
//
//  Created by ChawTech Solutions on 14/12/22.
//

import UIKit
import IQKeyboardManagerSwift

protocol cancelWeekListCustomDelegate {
    func alertFromCancelIncidentPopUp(Message: String)
}

class CustomWeekListView: UIView {
    var view: UIView!
    var delegate: cancelWeekListCustomDelegate?
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    var checkBoxBtnStatusArr = [false,false,false,false,false,false,false]
    var checkBoxBtnStatusDict = ["Monday":false, "Tuesday":false, "Wednesday":false, "Thursday":false, "Friday":false, "Saturday":false, "Sunday":false]
    
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
        IQKeyboardManager.shared.enable = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // use bounds not frame or it'll be offset
        view.frame = bounds
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomWeekListView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 140
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    @IBAction func onTapCancelBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    @IBAction func onTapCheckBoxBtn(_ sender: UIButton) {
        
        switch sender.tag
        {
        case 101:
            sender.isSelected = !sender.isSelected
            self.checkBoxBtnStatusArr[0] = sender.isSelected
            self.checkBoxBtnStatusDict["Monday"] = sender.isSelected
            break
        case 102:
            sender.isSelected = !sender.isSelected
            self.checkBoxBtnStatusArr[1] = sender.isSelected
            self.checkBoxBtnStatusDict["Tuesday"] = sender.isSelected
            
            break
        case 103:
            sender.isSelected = !sender.isSelected
            self.checkBoxBtnStatusArr[2] = sender.isSelected
            self.checkBoxBtnStatusDict["Wednesday"] = sender.isSelected
            
            break
        case 104:
            sender.isSelected = !sender.isSelected
            self.checkBoxBtnStatusArr[3] = sender.isSelected
            self.checkBoxBtnStatusDict["Thursday"] = sender.isSelected
            
            break
        case 105:
            sender.isSelected = !sender.isSelected
            self.checkBoxBtnStatusArr[4] = sender.isSelected
            self.checkBoxBtnStatusDict["Friday"] = sender.isSelected
            
            break
        case 106:
            sender.isSelected = !sender.isSelected
            self.checkBoxBtnStatusArr[5] = sender.isSelected
            self.checkBoxBtnStatusDict["Saturday"] = sender.isSelected
            
            break
        case 107:
            sender.isSelected = !sender.isSelected
            self.checkBoxBtnStatusArr[6] = sender.isSelected
            self.checkBoxBtnStatusDict["Sunday"] = sender.isSelected
            
            
            break
        default: break
        }
        
    }
    
}
