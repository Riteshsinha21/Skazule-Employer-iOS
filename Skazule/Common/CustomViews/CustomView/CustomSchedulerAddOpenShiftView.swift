//
//  CustomSchedulerAddOpenShiftView.swift
//  Skazule
//
//  Created by ChawTech Solutions on 06/03/23.
//

import UIKit
import IQKeyboardManagerSwift

protocol cancelCustomSchedulerAddOpenShiftCustomDelegate {
    func alertFromCancelPopUp(Message: String)
}

class CustomSchedulerAddOpenShiftView: UIView {
    var view: UIView!
    var delegate: cancelCustomSchedulerAddOpenShiftCustomDelegate?
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var headerTitleLbl: UILabel!
    @IBOutlet weak var assignBackView: UIView!
    @IBOutlet weak var assignDDTextField: UITextField!
    @IBOutlet weak var assignDDBtn: UIButton!
    @IBOutlet weak var noOfOpeningBackView: UIView!
    @IBOutlet weak var noOfOpeningTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeInTextField: UITextField!
    @IBOutlet weak var timeOutTextField: UITextField!
    
    @IBOutlet weak var unpaidBreakTextField: UITextField!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var positionTagBackView: UIView!
    @IBOutlet weak var positionDDTextField: UITextField!
    @IBOutlet weak var positionDDBtn: UIButton!
    
    @IBOutlet weak var tagDDTextField: UITextField!
    @IBOutlet weak var tagDDBtn: UIButton!
    
    @IBOutlet weak var shitfNoteTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    
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
        let nib = UINib(nibName: "CustomSchedulerAddOpenShiftView", bundle: bundle)
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
    
    
}
