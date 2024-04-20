//
//  WCViewImagePopUp.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 11/08/23.
//

import UIKit
import WebKit

class WCViewImagePopUp: UIView {
    
    var view: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var imageView: UIImageView!
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
        
        if webViewImgUrlStr != ""
        {
            let imgUrl = URL(string: webViewImgUrlStr)
            self.imageView.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: "gallery"))
        }
        
        /*
         if webViewImgUrlStr != ""
         {
         self.openInWebView(urlStr: webViewImgUrlStr)
         }
         */
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "WCViewImagePopUp", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    @IBAction func onTapCancelBtn(_ sender: Any) {
        self.removeFromSuperview()
    }
    func openInWebView(urlStr:String)
    {
        //TODO:- check network connection
        if Reachability.isConnectedToNetwork()
        {
            //            showProgressOnView(self.view)
            self.openImage(img_path: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        else
        {
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func openImage(img_path: String)
    {
        //showProgressOnView(self.view)
        let imgUrl = URL.init(string: img_path)
        let req = NSURLRequest(url: imgUrl!)
        self.webView.load(req as URLRequest)
        
    }
    
}
