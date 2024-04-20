//
//  SREmployerBonusModel.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 25/08/23.
//

import Foundation

// MARK: BonusVC
struct BonusStruct
{
    var id: String = ""
    var role: String = ""
    var color_code: String = ""
    var position: String = ""
    var status: String = ""
    var bonus_amount: String = ""
    var desc: String = ""
    var mobile: String = ""
    var c_code: String = ""
    var employee_name: String = ""
    var employee_id: String = ""
    var profile_pic: String = ""
    var email: String = ""
    var checkBoxStatus = false
    var approvedDate = ""
}

// MARK: AssignBonusVC
struct EmployeeStruct
{
    var profile_pic: String = ""
    var status: String = ""
    var id: String = ""
    var name: String = ""
    var role: String = ""
    var checkBoxSelected : Bool
}
