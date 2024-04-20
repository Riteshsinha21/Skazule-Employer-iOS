//
//  TabBarViewController.swift
//  KidyView
//
//  Created by Demo on 10/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiddleButton()
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(CommingFromSideMenu),
                         name: NSNotification.Name ("CommingFromSideMenu"),                                           object: nil)
    }
    @objc func CommingFromSideMenu()
    {
        DispatchQueue.main.async {
            
            if self.selectedIndex == 2
            {
                self.menuButton.setBackgroundImage(UIImage(named: "dashboard_selected"), for: .normal)
            }
            else
            {
                self.menuButton.setBackgroundImage(UIImage(named: "dashboardTab"), for: .normal)
            }
        }
    }
    func setupMiddleButton() {
        
        var tabHeight = 50
        var isBottom: Bool {
            if #available(iOS 13.0, *), UIApplication.shared.windows[0].safeAreaInsets.bottom > 0 {
                return true
            }
            return false
        }
        if isBottom == true
        {
            tabHeight = 50
        }
        else
        {
            tabHeight = 26
        }
        //let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height - CGFloat(tabHeight)
        menuButtonFrame.origin.x = view.bounds.width/2 - menuButtonFrame.size.width/2
        print(menuButtonFrame.origin.y)
        print(menuButtonFrame.origin.x)
        menuButton.frame = menuButtonFrame
        menuButton.layer.cornerRadius = 32.0 //menuButtonFrame.height/2
        view.addSubview(menuButton)
        menuButton.setBackgroundImage(UIImage(named: "dashboard_selected"), for: .normal)
        
        menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    @objc private func menuButtonAction(sender: UIButton) {
        selectedIndex = 2
        menuButton.setBackgroundImage(UIImage(named: "dashboard_selected"), for: .normal)
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
        let dashboard_select = UIImage(named : "dashboard_selected")
        
        if item.selectedImage == dashboard_select
        {
            menuButton.setBackgroundImage(dashboard_select, for: .normal)
        }
        else
        {
            menuButton.setBackgroundImage(UIImage(named: "dashboardTab"), for: .normal)
        }
    }
    
}
extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
        ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    func resizedImage(newWidth: CGFloat) -> UIImage {
        //let scale = newWidth / self.size.width
        //let newHeight = self.size.height * scale
        let newHeight = newWidth //self.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
