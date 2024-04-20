//
//  CustomColorPickerView.swift
//  Skazule
//
//  Created by ChawTech Solutions on 28/12/22.
//

import UIKit
import IQKeyboardManagerSwift

protocol cancelColorPickerCustomDelegate {
    func alertFromCancelPopUp(Message: String)
}

class CustomColorPickerView: UIView {
    var view: UIView!
    var delegate: cancelColorPickerCustomDelegate?
    
    @IBOutlet weak var cancleButton: UIButton!
    
    @IBOutlet weak var addColor1Btn: UIButton!
    @IBOutlet weak var addColor2Btn: UIButton!
    @IBOutlet weak var addColor3Btn: UIButton!
    @IBOutlet weak var addColor4Btn: UIButton!
    @IBOutlet weak var addColor5Btn: UIButton!
    @IBOutlet weak var addColor6Btn: UIButton!
    @IBOutlet weak var addColor7Btn: UIButton!
    @IBOutlet weak var addColor8Btn: UIButton!
    @IBOutlet weak var addColor9Btn: UIButton!
    @IBOutlet weak var addColor10Btn: UIButton!
    @IBOutlet weak var addColor11Btn: UIButton!
    @IBOutlet weak var addColor12Btn: UIButton!
    @IBOutlet weak var addColor13Btn: UIButton!
    @IBOutlet weak var addColor14Btn: UIButton!
    @IBOutlet weak var addColor15Btn: UIButton!
    @IBOutlet weak var addColor16Btn: UIButton!
    @IBOutlet weak var addColor17Btn: UIButton!
    @IBOutlet weak var addColor18Btn: UIButton!

    
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
        let nib = UINib(nibName: "CustomColorPickerView", bundle: bundle)
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
    
    
    
    @IBAction func onTapColorBtn(_ sender: UIButton) {
                
    }
    

    
    
    
    
}
