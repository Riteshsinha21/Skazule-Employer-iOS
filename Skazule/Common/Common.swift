//
//  Common.swift
//  Skazule
//
//  Created by ChawTech Solutions on 03/11/22.
//

import Foundation

struct Constants {
    static let ErrorAlertTitle = "Error"
    static let OkAlertTitle = "Ok"
    static let CancelAlertTitle = "Cancel"
}

var r  = 0.0
var g  = 0.0
var b  = 0.0

// For Notification
var notificationCount = "0"

/*
 //For Staging Mode
 let BASE_URL = "https://skazulebackend.chawtechsolutions.ch/"
 let IMAGE_BASE_URL = "https://skazulebackend.chawtechsolutions.ch/storage/app/"
 */
//For Live Mode
let BASE_URL = "https://api.skazule.com/"
let IMAGE_BASE_URL = "https://api.skazule.com/storage/app/"

struct PROJECT_URL
{
    static let LOGIN_API = "api/employer-login"
    static let SIGNUP_API = "api/register-employer"
    static let FORGOT_PASSWORD_API = "api/forget-password"
    static let VERIFY_OTP_API = "api/forget-password"
    
    static let GET_EMPLOYEE_RANGE_API = "api/get-employee-range"
    static let GET_INDUSTRY_API = "api/get-industries"
    static let CREATE_COMPANY_PROFILE_API = "api/create-company-profile"
    
    static let GET_JOB_POSITIONS_API = "api/get-job-positions"
    static let CREATE_JOB_POSITIONS_API = "api/create-job-position"
    static let SET_COMPANY_POSITIONS_API = "api/set-company-positions"
    
    static let EMPLOYEE_SETUP_API = "api/import-employee-basics" // form data api
    
    static let SCHEDULER_SETUP_API = "api/import-shift-templates" // form data api
    //2week_start_day
    
    static let GET_EMPLOYEE_LIST_API = "api/get-employee-list"
    
    static let GET_COMPANY_POSITIONS_API = "api/get-company-positions" //post
    static let GET_TIMEZONE_API = "api/get-timezone"
    static let GET_COMPANY_SHIFT_API = "api/get-company-shift" //post
    static let GET_COMPANY_TAGS_API = "api/get-company-tags" //post
    static let GET_USER_ROLES_API = "api/get-user-roles"
    static let GET_BENEFITS_API = "api/get-benefits" //post
    static let GET_REPORTING_TO_API = "api/get-reporting-to-data" //post
    //role_id:4
    //company_id:2
    
    static let ADD_EMPLOYEE_API = "api/create-employee" //post
    static let GET_EMPLOYEE_DETAIL_API = "api/get-employee-profile-view" //post //employee_id:204
    
    static let UPDATE_POSITION_API = "api/update-job-position" //post
    static let DELETE_CUSTOM_POSITION_API = "api/delete-job-position" //post
    
    static let ADD_COMPANY_TAGS_API = "api/create-tag" //post
    static let DELETE_COMPANY_TAGS_API = "api/delete-company-tag" //post
    static let UPDATE_COMPANY_TAGS_API = "api/update-company-tag" //post
    
    static let ADD_SHIFT_TEMPLATE_API = "api/create-shift-template" //post
    static let DELETE_SHIFT_TEMPLATE_API = "api/delete-shift-template" //post
    static let UPDATE_SHIFT_TEMPLATE_API = "api/update-shift-template" //post
    
    static let ADD_BENEFITS_API = "api/create-employee-benefit" //post
    static let DELETE_BENEFITS_API = "api/delete-company-benefit" //post
    static let UPDATE_BENEFITS_API = "api/update-company-benefit" //post
    
    static let DELETE_SINGLE_BENEFITS_API = "api/remove-employee-single-benefit" //post
    static let GET_BENEFITS_DETAIL_API = "api/get-employee-benefit-view" //post
    
    
    static let GET_COMPANY_DOCUMENTS_API = "api/company-document-list" //post
    static let ADD_COMPANY_DOCUMENTS_API = "api/create-document" //post
    static let UPDATE_COMPANY_DOCUMENTS_API = "api/update-document" //post
    static let DELETE_COMPANY_DOCUMENTS_API = "api/delete-document" //post
    static let SHARE_COMPANY_DOCUMENTS_API = "api/share-document" //post
    static let SHARE_COMPANY_DOCUMENTS_HISTORY_API = "api/get-document-share-history" //post
    
    static let GET_EMPLOYEE_BENEFITS_API = "api/get-employee-benefit-list-data"
    
    static let GET_EMPLOYEE_BONUS_API = "api/get-employee-bonus-list" //post
    static let ASSIGN_BONUS_API = "api/assign-bonus" //post
    static let APPROVE_BONUS_API = "api/approve-bonus" //post
    static let UPDATE_BONUS_API = "api/assign-bonus" //post
    static let DELETE_BONUS_API = "api/assign-bonus" //post
    
    static let UPDATE_COMPANY_EMPLOYEE_API = "api/update-employee" //post
    static let DELETE_COMPANY_EMPLOYEE_API = "api/delete-employee" //post
    static let GET_EMPLOYEE_EDIT_DETAIL_API = "api/get-employee-edit-data"
    static let UPDATE_EMPLOYEE_API = "api/update-employee"
    
    //***Scheduler Module***
    static let GET_SCHEDULER_DATA_API = "api/get-scheduler-data"
    static let CHECK_EMPLOYEE_AVAILITY_API = "api/check-employee-availability"
    static let ADD_SCHEDULER_API = "api/create-schedule"
    static let UPDATE_SCHEDULER_DATE_API = "api/change-scheduler-date"
    
    static let UPDATE_SCHEDULER_API = "api/update-schedule"
    static let GET_SCHEDULER_EDIT_DETAIL_API = "api/schedule-edit-data"
    
    static let DELETE_SCHEDULE_API = "api/delete-schedule"
    static let ASSIGN_SCHEDULE_API = "api/assign-scheduler-to-employee"
    static let CONFIRM_SCHEDULE_API = "api/confirm-schedule-request"
    
    //***Time Off Request Module***
    static let GET_ALL_LEAVE_REQUST_API = "api/all-leave-request"
    static let GET_PENDING_LEAVE_REQUST_API = "api/pending-leave-request"
    static let VIEW_LEAVE_REQUST_API = "api/view-leave-request"
    static let APPROVE_LEAVE_REQUST_API = "api/approve-leave-request"
    static let REJECT_LEAVE_REQUST_API = "api/reject-leave-request"
    static let GET_LEAVE_TYPE_API = "api/get-leave-types"
    
    //Time Tracking Module
    static let GET_ALL_EMPLOYEE_TIME_TRACKING_LIST_API = "api/get-all-time-track"
    static let GET_EMPLOYEE_TIME_TRACKING_LIST_API = "api/get-employee-tracking"
    static let GET_EDIT_DATA_TIME_TRACKING_API = "api/get-time-track-edit-data"//id:119
    static let UPDATE_TIME_TRACKING_API = "api/update-time-track"
    
    //Dashboard Module
    static let GET_DASHBOARD_DATA_API = "api/employer-dashboard"
    //PROFILE Module
    static let GET_PROFILE_DATA_API = "api/employer-profile"
    static let UPDATE_PROFILE_API = "api/update-employer-profile"
    
    // NOtification Api
    static let GET_NOTIFICATION_API = "api/get-notifications"
    
    // BONUS Module
    static let DELETE_EMPLOYER_BONUS_API = "api/delete-employee-bonus" //post
    static let UPDATE_EMPLOYER_BONUS_API = "api/update-employee-bonus" //post
    
    // Time of request Module
    //static let LEAVE_TYPE_DD_API = "api/leave_type"
    static let LEAVE_TYPE_DD_API = "api/get-leave-types"

    
    //Emlpoyee Module
    static let IMPORT_DOCUMENT_API = "api/import-employee-csv"
    
    //Delete Account
    static let DELETE_ACCOUNT_API = "api/delete-account"
    
}
