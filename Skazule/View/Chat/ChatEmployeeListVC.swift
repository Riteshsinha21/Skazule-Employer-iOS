//
//  ChatEmployeeListVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 07/06/23.
//

import UIKit

class ChatEmployeeListVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var tblView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        customNavigationBar.titleLabel.text = "Chat Employee List"
        tblView.register(UINib(nibName: "EmployeeTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeTableCell")

    }
}
extension ChatEmployeeListVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 10//self.employeeTimeTrackingListArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTableCell") as! EmployeeTableCell
        cell.selectionStyle = .none
        cell.employeeLeftSideImgView.isHidden = false
        cell.cardView.shadowColor = .systemGray4//.systemBrown
        cell.cardView.backgroundColor = .white
        
//        let info = self.employeeListArr[indexPath.row]
//        cell.titleLbl.text = info.name
//        if info.schedule_status == "1"
//        {
//            cell.assignImgView.isHidden = false
//            cell.employeeCheckBox.isHidden  = true
//        }
//        else
//        {
//            cell.assignImgView.isHidden = true
//            cell.employeeCheckBox.isHidden  = false
//        }
//        if info.checkBoxSelected == true
//        {
//            cell.employeeCheckBox.isSelected = true
//        }
//        else
//        {
//            cell.employeeCheckBox.isSelected = false
//        }
//
//        cell.employeeCheckBox.tag = indexPath.row
//        cell.employeeCheckBox.addTarget(self, action: #selector(employeeCheckBoxBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = ChatVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
