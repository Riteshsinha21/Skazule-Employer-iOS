//
//  EmployeeRequest.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//


import Foundation

@propertyWrapper
struct DepartmentPropertyWrapper {
    private var _value: String
    var wrappedValue: String
    {
        get
        {
            return _value == "0" ? "mobile" : "web"
        }
        set
        {
            _value = newValue
        }
    }

    init(_index: String) {
        _value = _index
    }
}

struct EmployeeRequest
{
    var userId: Int
   @DepartmentPropertyWrapper var department: String
}
