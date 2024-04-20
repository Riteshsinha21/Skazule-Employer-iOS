//
//  SRSchedulerModel.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 25/08/23.
//

import Foundation

// MARK: SchedulerVC
struct CurrentWeekStruct
{
    var date: String = ""
    var month: String = ""
    var year: String = ""
    var day: String = ""
}

struct OpenScheduleDataStruct
{
    var check_out: String = ""
    var check_in: String = ""
    var nubmer_of_opening: String = ""
    var break_duration: String = ""
    var position: String = ""
    var note: String = ""
    var rest_opening: String = ""
    var shift_name: String = ""
    var schedule_id: String = ""
    var nubmer_of_assigned_opening: String = ""
    var date: String = ""
    var color_code: String = ""
    var id: String = ""
    var employee_id: String = ""
    var status: String = ""
}
struct EmployeeScheduleDataStruct
{
    var name: String = ""
    var email: String = ""
    var c_code: String = ""
    var mobile: String = ""
    var employee_id: String = ""
    var profile_pic: String = ""
    var employeeScheduleArr:[OpenScheduleDataStruct]?
    var expanded:Bool!
}

// MARK: SchedulerDetailVC
struct AssignEmployeeListStruct
{
    var schedule_status: String = ""
    var name: String = ""
    var email: String = ""
    var profile_pic: String = ""
    var mobile: String = ""
    var c_code: String = ""
    var employee_id: String = ""
    var checkBoxSelected : Bool
}
