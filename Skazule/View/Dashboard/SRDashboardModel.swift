//
//  SRDashboardModel.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 25/08/23.
//

import Foundation

// MARK: DashboardVC
struct DashBoardDataStruct{
    var scheduled_hour      : String = ""
    var unfilled_opening    : String = ""
    var totalOnBreak        : String = ""
    var totalCheckedIn      : String = ""
    var unfilled_shift      : String = ""
    var pendingShiftRequest : String = ""
    var employeeOnLeave     : String = ""
    var todaysOpenShift     : [TodayOpenShiftDataStruct]?
}
struct TodayOpenShiftDataStruct{
    var schedule_id         : String = ""
    var check_out           : String = ""
    var position            : String = ""
    var date                : String = ""
    var note                : String = ""
    var break_duration      : String = ""
    var nubmer_of_assigned_opening: String = ""
    var nubmer_of_opening   : String = ""
    var color_code          : String = ""
    var shift_name          : String = ""
    var rest_opening        : String = ""
    var check_in            : String = ""
}

struct NotificationDetailStruct{
    var id            : String = ""
    var company_id    : String = ""
    var user_id       : String = ""
    var type          : String = ""
    var title         : String = ""
    var message       : String = ""
    var from_id       : String = ""
    var redirect_url  : String = ""
    var status        : String = ""
    var created_at    : String = ""
    var updated_at    : String = ""
    var sender_name    : String = ""
    var sender_profile_pic    : String = ""
}
