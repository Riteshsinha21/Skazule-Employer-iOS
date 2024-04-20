//
//  CustomEditTimeTrackingView.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 29/05/23.
//

import UIKit
import IQKeyboardManagerSwift
import APJTextPickerView

class CustomEditTimeTrackingView: UIView {

    var view: UIView!
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var headerTitleLbl: UILabel!
    @IBOutlet weak var shifttNameTextField: UITextField!
    @IBOutlet weak var shifttTypeTextField: UITextField!
    @IBOutlet weak var shifttCheckInTextField: APJTextPickerView!
    @IBOutlet weak var shifttCheckOutTextField: APJTextPickerView!
    @IBOutlet weak var inDateTextField: APJTextPickerView!
    @IBOutlet weak var outDateTextField: APJTextPickerView!
    @IBOutlet weak var checkInTimeTextField: APJTextPickerView!
    @IBOutlet weak var checkOutTimeTextField: APJTextPickerView!
        
    @IBOutlet weak var updateButton: UIButton!
    
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
        
        self.setDatePicker()
        self.setTimePicker()
    }
    func setDatePicker()
    {
        //Apjextextpicker
        self.inDateTextField.datePicker?.datePickerMode = .date
        self.inDateTextField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        self.inDateTextField.dateFormatter.dateFormat = "yyyy-MM-dd"
        self.outDateTextField.datePicker?.datePickerMode = .date
        self.outDateTextField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        self.outDateTextField.dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    func setTimePicker()
    {
        //Apjextextpicker
        self.shifttCheckInTextField.datePicker?.datePickerMode = .time
        self.shifttCheckInTextField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        self.shifttCheckInTextField.dateFormatter.dateFormat = "h:mm a"
        self.shifttCheckOutTextField.datePicker?.datePickerMode = .time
        self.shifttCheckOutTextField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        self.shifttCheckOutTextField.dateFormatter.dateFormat = "h:mm a"
        
        self.checkInTimeTextField.datePicker?.datePickerMode = .time
        self.checkInTimeTextField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        self.checkInTimeTextField.dateFormatter.dateFormat = "h:mm a"
        self.checkOutTimeTextField.datePicker?.datePickerMode = .time
        self.checkOutTimeTextField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        self.checkOutTimeTextField.dateFormatter.dateFormat = "h:mm a"
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomEditTimeTrackingView", bundle: bundle)
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
