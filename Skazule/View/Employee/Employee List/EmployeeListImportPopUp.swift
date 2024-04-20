//
//  EmployeeListImportPopUp.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 24/08/23.
//

import UIKit
import IQKeyboardManagerSwift

class EmployeeListImportPopUp: UIView {
    var view: UIView!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var uploadFileButton: UIButton!
    @IBOutlet weak var downloadFileButton: UIButton!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        // 2. call super.init(frame:)
        super.init(frame: frame)
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
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // use bounds not frame or it'll be offset
        view.frame = bounds
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "EmployeeListImportPopUp", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
