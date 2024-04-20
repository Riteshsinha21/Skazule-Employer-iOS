//
//  UIDevice+Extension.swift
//  LTY_Partner
//
//  Created by CTS on 24/05/23.
//

import Foundation
import UIKit

extension UIDevice {
//    var hasNotch: Bool {
//        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
//        return bottom > 0
//    }
    
    var hasNotch: Bool {
     let bottom = UIApplication.shared.windows.first{ $0.isKeyWindow }?.safeAreaInsets.bottom ?? 0
     return bottom > 0
        }
}
