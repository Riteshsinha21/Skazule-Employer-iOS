//
//  CustomNavigationBarForDrawer.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import UIKit

@objc protocol LeftBarButtonDrawerDelegate {
    @objc optional func leftBarButtonTapped()
}

class CustomNavigationBarForDrawer: UIView  {
    
    @IBOutlet weak var leftSideMenuButtonItem: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    var view : UIView?
    var delegate : LeftBarButtonDrawerDelegate?
    var senderController : UIViewController?
    
    func xibSetup() {
        view = loadViewFromNib()
        view!.frame = bounds
        view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomNavigationBarForDrawer", bundle: bundle)
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
        leftSideMenuButtonItem.isHidden = true
    }
    
    //MARK: UIButton Action Methods
    
    @IBAction func leftSideMenuBtnTapped(_ sender: Any) {
        if delegate != nil {
            delegate?.leftBarButtonTapped!()
        } else {
            sideMenuViewController.showLeftView() //.showLeftViewAnimated()
        }
    }
}
