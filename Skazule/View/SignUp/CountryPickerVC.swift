//
//  CountryPickerVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 21/08/23.
//

import Foundation
import UIKit

class Country {
    var countryCode : String?
    var name : String?
    var currencyCode : String?
    var currencySymbol : String?
    var extensionCode : String? // county code like + 91 ...
    var flag : String?
}
class CountryPickerVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.register(UINib(nibName: "CountryPickerCell", bundle: .main), forCellReuseIdentifier: "CountryPickerCell")
        self.searchBar.delegate = self
        
        configuration()
    }
    var list = [Country]()
    var dupList = [Country]()
    func configuration() {
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id)
            
            let locale = NSLocale.init(localeIdentifier: id)
            
            let countryCode = locale.object(forKey: NSLocale.Key.countryCode)
            let currencyCode = locale.object(forKey: NSLocale.Key.currencyCode)
            let currencySymbol = locale.object(forKey: NSLocale.Key.currencySymbol)
            
            if name != nil {
                let model = Country()
                model.name = name
                model.countryCode = countryCode as? String
                model.currencyCode = currencyCode as? String
                model.currencySymbol = currencySymbol as? String
                model.flag = String.flag(for: code)
                model.extensionCode = NSLocale().extensionCode(countryCode: model.countryCode)
                list.append(model)
            }
        }
        
        self.dupList = self.list
        self.tblView.reloadData()
    }
}
extension CountryPickerVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.dupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryPickerCell") as! CountryPickerCell
        //cell.selectionStyle = .none
        cell.textLabel?.text = "\(dupList[indexPath.row].flag!) \(dupList[indexPath.row].name!)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(dupList[indexPath.row].flag!) \(dupList[indexPath.row].name!) +\(dupList[indexPath.row].extensionCode!)")
        selectedCountry = "\(dupList[indexPath.row].flag!) +\(dupList[indexPath.row].extensionCode!)"
        
        let extensionCode = "+\(dupList[indexPath.row].extensionCode!)"
        /*
        UserDefaults.standard.setValue(extensionCode, forKey: USER_DEFAULTS_KEYS.C_CODE)
        UserDefaults.standard.setValue(selectedCountry, forKey: USER_DEFAULTS_KEYS.COUNTRY_CODE)
         */
        let countryCodeDataDict:[String: String] = ["countryCode": selectedCountry,"extensionCode": extensionCode]
        let extensionCodeDataDict:[String: String] = ["extensionCode": extensionCode]
        //Post Notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.COUNTRY_CODE), object: nil, userInfo: countryCodeDataDict)
        //Post Notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EXTENSION_CODE), object: nil, userInfo: extensionCodeDataDict)
        
        self.dismiss(animated: true)
    }
    
}

extension String{
    
    static func flag(for code : String) -> String?{
        func isLowercaseASCIIScalar(_ scalar: Unicode.Scalar) -> Bool {
            
            return scalar.value >= 0x61 && scalar.value <= 0x7A
        }
        func regionalIndicatorSymbol(for scalar :Unicode.Scalar) -> Unicode.Scalar {
            
            precondition(isLowercaseASCIIScalar(scalar))
            return Unicode.Scalar(scalar.value + (0x1F1E6 - 0x61))!
        }
        let lowercasedCode = code.lowercased()
        guard lowercasedCode.count == 2 else { return nil }
        guard lowercasedCode.unicodeScalars.reduce(true, { accum, scalar in
            accum && isLowercaseASCIIScalar(scalar)
        }) else { return nil }
        let incatorSymbols = lowercasedCode.unicodeScalars.map({regionalIndicatorSymbol(for: $0)})
        
        return String(incatorSymbols.map({Character($0)}))
    }
}
//MARK: Find the Country Code
extension NSLocale {
    func extensionCode(countryCode : String?) -> String? {
        let prefixCodes = ["AC" : "247", "AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263", "AQ" : "672", "AX" : "358", "BQ" : "599", "BV": "55"]
        
        let countryDialingCode = prefixCodes[countryCode ?? "IN"] ?? nil
        return countryDialingCode
    }
}
extension CountryPickerVC: UISearchBarDelegate
{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        self.dupList = self.list
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search \(searchText)")
        self.dupList = searchText.isEmpty ? self.list : self.list.filter({ (model) -> Bool in
            
            return model.name!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        self.tblView.reloadData()
    }
    // Implement the UISearchBarDelegate method to handle the "Search" button click
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Perform the search operation here
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
    }
}
