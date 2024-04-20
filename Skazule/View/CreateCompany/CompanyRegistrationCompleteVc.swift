//
//  CompanyRegistrationCompleteVc.swift
//  Skazule
//
//  Created by ChawTech Solutions on 06/12/22.
//

import UIKit

class CompanyRegistrationCompleteVc: UIViewController {

    @IBOutlet weak var topTitleLable: UILabel!
    @IBOutlet weak var goToNextScreenBtn: UIButton!
    var isCommingFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if isCommingFrom == "Add Employee"
        {
            self.topTitleLable.text = "You Have Added Employee Successfully."
            self.goToNextScreenBtn.setTitle("Add More Employees", for: .normal)
        }
        else
        {
            self.topTitleLable.text = "Thanks For Registering Your Company"
            self.goToNextScreenBtn.setTitle("GO TO DASHBOARD", for: .normal)
        }
    }
    func goToDashBoardScreen()
    {
        (sideMenuViewController.rootViewController as! UINavigationController).pushViewController(loadTabBar(), animated: false)
    }
    // MARK: - Go To Dashboard button tapped
    @IBAction func onTapGoToDashboardButton(_ sender: Any) {
        if isCommingFrom == "Add Employee"
        {
            let vc = EmployeeListVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            self.goToDashBoardScreen()
        }
    }
}
