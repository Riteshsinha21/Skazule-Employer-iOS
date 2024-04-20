//
//  CustomNavigationBar.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import UIKit

@objc protocol LeftBarButtonTappedDelegate {
    @objc optional func leftBarButtonTapped()
}

class CustomNavigationBar: UIView {
    
    @IBOutlet weak var leftBarButtonItem: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customRightBarButton: UIButton!
    @IBOutlet weak var customRightBarButton2: UIButton!

    
    @IBOutlet weak var customLeftBarButton: UIButton!
    var view : UIView?
    var leftBarButtonTappedDelegate : LeftBarButtonTappedDelegate?
    
    func xibSetup() {
        view = loadViewFromNib()
        view!.frame = bounds
        view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomNavigationBar", bundle: bundle)
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
    
    func hideLeftBarButtonItem() {
        leftBarButtonItem.isHidden = true
    }
    
    //MARK: UIButton Action Methods
    
   
    @IBAction func leftBarBtnTapped(_ sender: Any) {
        if leftBarButtonTappedDelegate != nil {
            leftBarButtonTappedDelegate?.leftBarButtonTapped!()
        } else {
            let controller = (self.superview)?.next as! UIViewController
            _ = controller.navigationController?.popViewController(animated: true)
        }
    }
}
