//
//  CreateCompanyEmployeeSetupCell.swift
//  Skazule
//
//  Created by ChawTech Solutions on 23/11/22.
//

import UIKit

protocol CreateCompanyEmployeeSetupCellDelegate {
    func onChangeEmployeeSetup(cell: CreateCompanyEmployeeSetupCell, fullName: String, email: String, mobileNumber: String)
    //func onChangeEmployeeSetup(cell: CreateCompanyEmployeeSetupCell, fullName: String)
}

class CreateCompanyEmployeeSetupCell: UITableViewCell {
    
    @IBOutlet weak var employeeFullNameTxtField: UITextField!
    @IBOutlet weak var employeeEmailTxtField: UITextField!
    @IBOutlet weak var employeeMobileNumberTxtField: UITextField!
    @IBOutlet weak var countryPickerBtn: UIButton!

    var delegate: CreateCompanyEmployeeSetupCellDelegate?
    var employeeSetUpDetail: EmployeeSetUpStruct?{
        didSet{
            DispatchQueue.main.async {
                //self.desLbl.text = product.name
                //self.quantityTxtField.text = product.quantity
                
                
                self.employeeFullNameTxtField.text       = self.employeeSetUpDetail?.name
                self.employeeEmailTxtField.text         = self.employeeSetUpDetail?.email
                self.employeeMobileNumberTxtField.text   = self.employeeSetUpDetail?.mobile
                
                //                //var info = employeeSetUpDetail
                //                self.employeeSetUpDetail?.name          = self.employeeFullNameTxtField.text ?? ""
                //                self.employeeSetUpDetail?.email         = self.employeeEmailTxtField.text ?? ""
                //                self.employeeSetUpDetail?.mobile        = self.employeeMobileNumberTxtField.text ?? ""
                //                self.employeeSetUpDetail?.c_code        = "+91"
                print(self.employeeSetUpDetail)
                
                
                
            }
        }
    }
    @IBAction func onEmployeeSetupChanged(_ sender: UITextField) {
        
        if sender == self.employeeFullNameTxtField
        {
            delegate?.onChangeEmployeeSetup(cell: self , fullName: sender.text!, email: self.employeeEmailTxtField.text ?? "", mobileNumber: self.employeeMobileNumberTxtField.text  ?? "")
        }
        else if sender == self.employeeEmailTxtField
        {
            delegate?.onChangeEmployeeSetup(cell: self , fullName: self.employeeFullNameTxtField.text  ?? "", email: sender.text!, mobileNumber: self.employeeMobileNumberTxtField.text  ?? "")
        }
        else  if sender == self.employeeMobileNumberTxtField
        {
            delegate?.onChangeEmployeeSetup(cell: self , fullName: self.employeeFullNameTxtField.text  ?? "", email: self.employeeEmailTxtField.text ?? "", mobileNumber: sender.text!)
        }
        //delegate?.onChangeEmployeeSetup(cell: self , fullName: sender.text!)
    }
//    @IBAction func onTapCountryPicker(_ sender: Any) {
//        let vc = CountryPickerVC()
//        present(vc, animated: true)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
