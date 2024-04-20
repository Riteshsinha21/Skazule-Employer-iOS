//
//  ViewController.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let vc = SignUpVC()//CreateCompanyScedulerSetupVC() //CreateCompanyScheduledPositionsVC() //CreateCompanyThirdStepVC() //CreateCompanySecondVC() //ForgotPasswordVC()  //SignUpVC() //LoginVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

