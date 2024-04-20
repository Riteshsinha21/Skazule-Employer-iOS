//
//  CreateCompanySchedulerSetupCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 29/11/22.
//

import UIKit
import APJTextPickerView

protocol CreateCompanySchedulerSetupCellDelegate {
    func onChangeSchedulerSetup(cell: CreateCompanySchedulerSetupCell, shiftName: String, checkIn: String, checkOut: String, breakDuration: String)
}

class CreateCompanySchedulerSetupCell: UITableViewCell {
    
    @IBOutlet weak var employerShiftNameTxtField: UITextField!
    //    @IBOutlet weak var employerCheckInTxtField: UITextField!
    //    @IBOutlet weak var employerCheckOutTxtField: UITextField!
    @IBOutlet weak var employerBreakDurationTxtField: UITextField!
    
    @IBOutlet weak var employerCheckInTxtField: APJTextPickerView!
    @IBOutlet weak var employerCheckOutTxtField: APJTextPickerView!
    
    
    
    var delegate: CreateCompanySchedulerSetupCellDelegate?
    
    var schedulerSetUpDetail: SchedulerSetUpStruct?{
        didSet{
            DispatchQueue.main.async {
                self.employerShiftNameTxtField.text       = self.schedulerSetUpDetail?.shift_name
                self.employerCheckInTxtField.text         = self.schedulerSetUpDetail?.check_in
                self.employerCheckOutTxtField.text        = self.schedulerSetUpDetail?.check_out
                self.employerBreakDurationTxtField.text   = self.schedulerSetUpDetail?.break_duration
            }
        }
    }
    
    @IBAction func onSchedulerSetupChanged(_ sender: UITextField) {
        
        if sender == self.employerShiftNameTxtField
        {
            delegate?.onChangeSchedulerSetup(cell: self, shiftName: sender.text!, checkIn: self.employerCheckInTxtField.text ?? "", checkOut: self.employerCheckOutTxtField.text ?? "", breakDuration: self.employerBreakDurationTxtField.text ?? "")
        }
        else if sender == self.employerCheckInTxtField
        {
            delegate?.onChangeSchedulerSetup(cell: self, shiftName: self.employerShiftNameTxtField.text ?? "", checkIn: sender.text!, checkOut: self.employerCheckOutTxtField.text ?? "", breakDuration: self.employerBreakDurationTxtField.text ?? "")
        }
        else  if sender == self.employerCheckOutTxtField
        {
            delegate?.onChangeSchedulerSetup(cell: self, shiftName: self.employerShiftNameTxtField.text ?? "", checkIn: self.employerShiftNameTxtField.text ?? "", checkOut: sender.text!, breakDuration: self.employerBreakDurationTxtField.text ?? "")
        }
        else  if sender == self.employerBreakDurationTxtField
        {
            delegate?.onChangeSchedulerSetup(cell: self, shiftName: self.employerShiftNameTxtField.text ?? "", checkIn: self.employerCheckInTxtField.text ?? "", checkOut: self.employerCheckOutTxtField.text ?? "", breakDuration: sender.text!)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //Apjextextpicker
        //self.employerCheckInTxtField.dateFormatter.dateFormat = "yyyy-MM-dd"
        self.employerCheckInTxtField.datePicker?.datePickerMode = .time
        self.employerCheckInTxtField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        self.employerCheckInTxtField.dateFormatter.dateFormat = "h:mm a"
        
        //            self.employerCheckInTxtField.datePicker?.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        // self.employerCheckInTxtField.datePicker?.minimumDate = Date()
        
        self.employerCheckOutTxtField.datePicker?.datePickerMode = .time
        self.employerCheckOutTxtField.datePicker?.locale = Locale(identifier: "en_US_POSIX")
        self.employerCheckOutTxtField.dateFormatter.dateFormat = "h:mm a"
        
        
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
