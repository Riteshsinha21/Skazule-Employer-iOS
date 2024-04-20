//
//  CreateCompanyVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 21/11/22.
//

import UIKit

class CreateCompanyVC: UIViewController {
    @IBOutlet weak var companyDesLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.companyDesLbl.text = "Post the work schedule,share your work availability, chat with coworkers,or create a new company \n\n Start by searching business name,address or workplace id"
    }
    
    // MARK: - Create Company button tapped
    @IBAction func onTapCreateCompanyButton(_ sender: Any) {
        let vc = CreateCompanySecondVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Back button tapped
    @IBAction func onTapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
