//
//  EmployeeViewModel.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

struct EmployeeViewModel
{
    func getEmployeesByDepartment(departmentIndex: Int, completion: @escaping(_ result: EmployeeResponse?)-> Void)
    {
        let userId = UserDefaultUtility().getUserId()

        let employeeRequest = EmployeeRequest(userId: userId, department: DepartmentPropertyWrapper(_index: "\(departmentIndex)"))

        let employeeResource = EmployeeResource()

        employeeResource.getEmployeesByDepartment(employeeRequest: employeeRequest) { (employeeApiResponse) in

            _ = completion(employeeApiResponse)

        }
    }
}
