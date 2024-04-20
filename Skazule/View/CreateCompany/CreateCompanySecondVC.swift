//
//  CreateCompanySecondVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 22/11/22.
//

import UIKit

class CreateCompanySecondVC: UIViewController {

    @IBOutlet weak var companyNameTxtField: UITextField!
    @IBOutlet weak var companyAddressTxtField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Next button tapped
    @IBAction func onTapNextButton(_ sender: Any) {
        
        if(self.companyNameTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter company name")
        }
        else if(self.companyAddressTxtField.text!.isEmpty)
        {
            showMessageAlert(message: "Please enter company address")
        }
        else
        {
            let vc = CreateCompanyThirdStepVC()
            vc.companyName = self.companyNameTxtField.text!
            vc.companyAddress = self.companyAddressTxtField.text!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
