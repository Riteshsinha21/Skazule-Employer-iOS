//
//  CustomHeaderView.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//

import Foundation
import UIKit
class CustomHeaderView: UIView {
    
    @IBOutlet weak var rightBtn: UIButton!
    
    @IBOutlet weak var fresherBtn: UIButton!
    
    @IBOutlet weak var experienceBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    var view : UIView?
    func xibSetup() {
        view = loadViewFromNib()
        view!.frame = bounds
        view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomHeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    
}
