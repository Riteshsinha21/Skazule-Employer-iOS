//
//  ProfileVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 30/05/23.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    // @IBOutlet weak var customNavigationBar: CustomNavigationBarForDrawer!
    
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var employerNameLbl: UILabel!
    @IBOutlet weak var employerPhoneNumberLbl: UILabel!
    @IBOutlet weak var employerEmailLbl: UILabel!
    
    @IBOutlet weak var compInfoCardBackView: CardView!
    @IBOutlet weak var compInfoTopBackView: UIView!
    @IBOutlet weak var compNameLbl: UILabel!
    @IBOutlet weak var compAddressLbl: UILabel!
    @IBOutlet weak var industryLbl: UILabel!
    @IBOutlet weak var noOfEmplyeeLbl: UILabel!
    
    @IBOutlet weak var otherSettingCardBackView: CardView!
    @IBOutlet weak var otherSettingTopBackView: UIView!
    @IBOutlet weak var timezoneLbl: UILabel!
    @IBOutlet weak var weekOffLbl: UILabel!
    
    @IBOutlet weak var subscriptionCardBackView: CardView!
    @IBOutlet weak var subscriptionTopBackView: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    
    var profileArr = [CompanyProfileStruct]()
    var purchaseDataArr = [PurchaseDataStruct]()
    var selectedWeekOffIdsArr = [String]()
    var employerCCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getProfileDetailApi()
        self.tblView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tblView.removeObserver(self, forKeyPath: "contentSize")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"
        {
            if let newValue = change?[.newKey]
            {
                let newsize = newValue as! CGSize
                self.tblViewHeightConstraint.constant = newsize.height
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        compInfoTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        otherSettingTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        subscriptionTopBackView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    func setUI()
    {
        self.customNavigationBar.titleLabel.text = "Profile"
        self.customNavigationBar.customRightBarButton.isHidden = false
        self.customNavigationBar.customRightBarButton.setBackgroundImage(UIImage.init(named: "edit"), for: .normal)
        self.customNavigationBar.customRightBarButton.addTarget(self, action: #selector(onClickEditProfileBtn), for: .touchUpInside)
        tblView.register(UINib(nibName: "ProfilePurchasedListCell", bundle: Bundle.main), forCellReuseIdentifier: "ProfilePurchasedListCell")
    }
    @objc func onClickEditProfileBtn(_ sender:UIButton)
    {
        if profileArr.count > 0
        {
            let vc = UpdateProfileVC()
            vc.profileData = self.profileArr[0]
            vc.alreadySelectedCountryCode = self.employerCCode
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func setProfileDetail()
    {
        let info = self.profileArr[0]
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        self.profilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        self.employerNameLbl.text               = "\(info.name)"
        self.employerPhoneNumberLbl.text        = "\(info.c_code) \(info.mobile)"
        self.employerEmailLbl.text              = "\(info.email)"
        self.compNameLbl.text               = "\(info.company_name)"
        self.compAddressLbl.text            = "\(info.company_address)"
        self.industryLbl.text               = "\(info.industry_value)"
        self.noOfEmplyeeLbl.text            = "\(info.emp_range_value)"
    }
    func getProfileDetailApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_PROFILE_DATA_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId]
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.profileArr.removeAll()
                    
                    let profile_pic =  json["data"]["profile_pic"].stringValue
                    
                    UserDefaults.standard.setValue(profile_pic, forKey: USER_DEFAULTS_KEYS.EMPLOYER_PROFILE_PIC)
                    let employerPhotoDataDict:[String: String] = ["employerPhoto": profile_pic]
                    //Post Notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NOTIFICATION_KEYS.EMPLOYER_PROFILE_PIC), object: nil, userInfo: employerPhotoDataDict)
                    
                    let time_zone_id =  json["data"]["time_zone_id"].stringValue
                    let c_code =  json["data"]["c_code"].stringValue
                    let company_id =  json["data"]["company_id"].stringValue
                    let emp_range_value =  json["data"]["emp_range_value"].stringValue
                    let emp_range =  json["data"]["emp_range"].stringValue
                    let industry_value =  json["data"]["industry_value"].stringValue
                    let mobile =  json["data"]["mobile"].stringValue
                    let status =  json["data"]["status"].stringValue
                    let id =  json["data"]["id"].stringValue
                    let purchase_data_total_count =  json["data"]["purchase_data_total_count"].stringValue
                    let email =  json["data"]["email"].stringValue
                    let company_address =  json["data"]["company_address"].stringValue
                    let company_name =  json["data"]["company_name"].stringValue
                    let industry =  json["data"]["industry"].stringValue
                    let name =  json["data"]["name"].stringValue
                    let week_off =  json["data"]["week_off"].arrayValue
                    let time_zone_value =  json["data"]["time_zone_value"].stringValue
                    
                    var weekOffArray = [String]()
                    if json["data"]["week_off"].count != 0
                    {
                        var weekOffArr = [String]()
                        for item in week_off
                        {
                            weekOffArray.append(item.rawValue as! String)
                        }
                        for i in 0..<json["data"]["week_off"].count
                        {
                            if json["data"]["week_off"][i] == "0"
                            {
                                weekOffArr.append("monday")
                                self.selectedWeekOffIdsArr.append("0")
                            }
                            else if json["data"]["week_off"][i] == "1"
                            {
                                weekOffArr.append("tuesday")
                                self.selectedWeekOffIdsArr.append("1")
                            }
                            else if json["data"]["week_off"][i] == "2"
                            {
                                weekOffArr.append("wednesday")
                                self.selectedWeekOffIdsArr.append("2")
                            }
                            else if json["data"]["week_off"][i] == "3"
                            {
                                weekOffArr.append("thursday")
                                self.selectedWeekOffIdsArr.append("3")
                            }
                            else if json["data"]["week_off"][i] == "4"
                            {
                                weekOffArr.append("friday")
                                self.selectedWeekOffIdsArr.append("4")
                            }
                            else if json["data"]["week_off"][i] == "5"
                            {
                                weekOffArr.append("saturday")
                                self.selectedWeekOffIdsArr.append("5")
                            }
                            else if json["data"]["week_off"][i] == "6"
                            {
                                weekOffArr.append("sunday")
                                self.selectedWeekOffIdsArr.append("6")
                            }
                        }
                        let selectedWeekOffStr = weekOffArr.joined(separator: ",")
                        self.weekOffLbl.text = selectedWeekOffStr
                    }
                    self.timezoneLbl.text = time_zone_value
                    
                    self.purchaseDataArr.removeAll()
                    for i in 0..<json["data"]["purchase_data"].count
                    {
                        let status =  json["data"]["purchase_data"][i]["status"].stringValue
                        let plan =  json["data"]["purchase_data"][i]["plan"].stringValue
                        let expire_at =  json["data"]["purchase_data"][i]["expire_at"].stringValue
                        let transaction_id =  json["data"]["purchase_data"][i]["transaction_id"].stringValue
                        let id =  json["data"]["purchase_data"][i]["id"].stringValue
                        let payment_mode =  json["data"]["purchase_data"][i]["payment_mode"].stringValue
                        let amount =  json["data"]["purchase_data"][i]["amount"].stringValue
                        let purchased_at =  json["data"]["purchase_data"][i]["purchased_at"].stringValue
                        
                        let purchaseDate = gmtToLocalDate(dateStr: purchased_at) ?? ""
                        let expireDate   = gmtToLocalDate(dateStr: expire_at) ?? ""
                        
                        self.purchaseDataArr.append(PurchaseDataStruct.init(status: status, plan: plan, expire_at: expireDate, transaction_id: transaction_id, id: id, payment_mode: payment_mode, amount: amount, purchased_at: purchaseDate))
                    }
                    print(self.purchaseDataArr.count)
                    
                    self.profileArr.append(CompanyProfileStruct.init(profile_pic: profile_pic, time_zone_id: time_zone_id, c_code: c_code, company_id: company_id, emp_range_value: emp_range_value, emp_range: emp_range, industry_value: industry_value, mobile: mobile, status: status, id: id, purchase_data_total_count: purchase_data_total_count, email: email, company_address: company_address, company_name: company_name, industry: industry, name: name,time_zone_value:time_zone_value,weekOffIdArr:weekOffArray, purchase_data: self.purchaseDataArr))
                    
                    DispatchQueue.main.async {
                        //self.setProfileDetail()
                        let imageUrl = IMAGE_BASE_URL + profile_pic
                        self.profilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
                        self.employerNameLbl.text           = "\(name)"
                        self.employerPhoneNumberLbl.text    = "\(c_code) \(mobile)"
                        self.employerEmailLbl.text          = "\(email)"
                        self.employerCCode = "\(c_code)"
                        self.compNameLbl.text               = "\(company_name)"
                        self.compAddressLbl.text            = "\(company_address)"
                        self.industryLbl.text               = "\(industry_value)"
                        self.noOfEmplyeeLbl.text            = "\(emp_range_value)"
                    }
                }
                else {
                    self.purchaseDataArr.removeAll()
                    
                    var errorMsg = ""
                    let errorDict = json["error"].dictionaryValue
                    // enumerate all of the keys and values
                    for (key, value) in errorDict {
                        print("\(key) -> \(value)")
                        for i in 0..<value.count
                        {
                            errorMsg = " \(json["error"][key][i].stringValue)"
                        }
                        print(errorMsg)
                    }
                    if errorMsg == ""
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
                
                DispatchQueue.main.async {
                    if self.purchaseDataArr.count == 0
                    {
                        //self.benefitsCardBackView.isHidden = true
                    }
                    else
                    {
                        //self.benefitsCardBackView.isHidden = false
                    }
                    self.tblView.reloadData()
                }
                
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
}
extension ProfileVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.purchaseDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePurchasedListCell") as! ProfilePurchasedListCell
        cell.selectionStyle = .none
        let info = self.purchaseDataArr[indexPath.row]
        let status = info.status
        if status == "0"
        {
            cell.statusLbl.text = "Pending"
        }
        else if status == "1"
        {
            cell.statusLbl.text = "Success"
        }
        else if status == "2"
        {
            cell.statusLbl.text = "Failed"
        }
        cell.planLbl.text = info.plan
        cell.transactionIdLbl.text = info.transaction_id
        cell.paymenModetLbl.text = info.payment_mode
        cell.amountLbl.text = "\(cuurrencyStr)\(info.amount)"
        cell.purchaseLbl.text = info.purchased_at
        cell.expireDateLbl.text = info.expire_at
        cell.expireDateLbl.text = info.expire_at
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 252
    }
}
