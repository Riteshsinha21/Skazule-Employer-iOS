//
//  EmployeeViewControllerExtension.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation
import UIKit

extension EmployeeViewController : UITableViewDataSource
{
    // MARK: - Table view datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeTableData?.data?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeeCell", for: indexPath) as! EmployeeTableViewCell

        cell.employeeName.text = employeeTableData?.data?[indexPath.row].name
        
        return cell
    }
}
