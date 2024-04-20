//
//  SREmployeeModel.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 25/08/23.
//

import Foundation

// MARK: EmployeeListVC
struct EmployeeListStruct
{
    var tag: String = ""
    var position: String = ""
    var timezone_location: String = ""
    var hourly_rate: String = ""
    var mobile: String = ""
    var c_code: String = ""
    var timezone_offset: String = ""
    var profile_pic: String = ""
    var id: String = ""
    var shift_name: String = ""
    var timezone_gmt: String = ""
    var color_code: String = ""
    var status: String = ""
    var name: String = ""
    var role: String = ""
    var break_duration: String = ""
    var email: String = ""
    var check_in: String = ""
    var check_out: String = ""
    var max_work_hour_weekly: String = ""
    var employee_id: String = ""
}

// MARK: AddNewEmployeeVC
struct UserRolesStruct
{
    var id:String = ""
    var role:String = ""
}
struct ReportingStruct
{
    var id:String = ""
    var name:String = ""
    var email:String = ""
    var c_code:String = ""
    var mobile:String = ""
    var profile_pic:String = ""
    var role:String = ""
}
struct CompanyShiftStruct
{
    var id:String = ""
    var shift_name:String = ""
    var check_in:String = ""
    var check_out:String = ""
    var break_duration:String = ""
}
struct CompanyPositionsStruct
{
    var id:String = ""
    var industry_id:String = ""
    var position:String = ""
    var status:String = ""
}
struct CompanyTagsStruct
{
    var id:String = ""
    var tag:String = ""
}
struct BenefitsStruct
{
    var id:String = ""
    var benefit:String = ""
    var description:String = ""
    var premium_pay:String = ""
    var company_pay:String = ""
    var employee_pay:String = ""
    var gross_pay:String = ""
}
struct TimeZoneStruct
{
    var id:String = ""
    var timezone_location:String = ""
    var gmt:String = ""
    var offset:String = ""
}
