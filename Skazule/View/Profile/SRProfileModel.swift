//
//  SRProfileModel.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 25/08/23.
//

import Foundation

// MARK: ProfileVC
struct CompanyProfileStruct
{
    var profile_pic :String = ""
    var time_zone_id :String = ""
    var c_code :String = ""
    var company_id :String = ""
    var emp_range_value :String = ""
    var emp_range :String = ""
    var industry_value :String = ""
    var mobile :String = ""
    var status :String = ""
    var id :String = ""
    var purchase_data_total_count :String = ""
    var email :String = ""
    var company_address :String = ""
    var company_name :String = ""
    var industry :String = ""
    var name :String = ""
    var time_zone_value :String = ""
    var weekOffIdArr : [String]?
    var purchase_data: [PurchaseDataStruct]?
}
struct PurchaseDataStruct
{
    var status :String = ""
    var plan :String = ""
    var expire_at :String = ""
    var transaction_id :String = ""
    var id :String = ""
    var payment_mode :String = ""
    var amount :String = ""
    var purchased_at :String = ""
}
