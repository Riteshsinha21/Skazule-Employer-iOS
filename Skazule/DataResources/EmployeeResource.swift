//
//  EmployeeDataResource.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

struct EmployeeResource
{
    func getEmployeesByDepartment(employeeRequest: EmployeeRequest, completion: @escaping(_ result : EmployeeResponse?) -> Void)
    {
        let httpUtility = HttpUtility()

//        let employeeEndpoint = "\(ApiEndpoints.employees)?Department=\(employeeRequest.department)&UserId=\(employeeRequest.userId)"
//
//        let requestUrl = URL(string:employeeEndpoint)!
//
//        httpUtility.getApiData(requestUrl: requestUrl, resultType: EmployeeResponse.self) { (employeeApiResponse) in
//
//            _ = completion(employeeApiResponse)
//        }
    }
}
