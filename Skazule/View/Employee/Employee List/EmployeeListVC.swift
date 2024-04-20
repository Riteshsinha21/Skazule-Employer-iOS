//
//  EmployeeListVC.swift
//  Skazule
//
//  Created by Chawtech on 13/12/22.
//

import UIKit
//import Alamofire
import MobileCoreServices

class EmployeeListVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var tbleView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var employeeListArr = [EmployeeListStruct]()
    
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    var pickedDocUrl:URL?
    
    var employeeListImportPopUp : EmployeeListImportPopUp!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.customNavigationBar.titleLabel.text = "Employee List"
        //self.customNavigationBar.leftBarButtonItem.isHidden = true
        tbleView.register(UINib(nibName: "EmployeeListTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeListTableCell")
        //self.searchTxtField.returnKeyType = UIReturnKeyType.search
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
        self.getEmployeeListApi()
    }
    
    @IBAction func onTapAddNewEmployeeButton(_ sender: Any) {
        let vc = AddNewEmployeeVC()
        vc.isOpenFrom = "Add"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapImportCSVExcelButton(_ sender: Any) {
        self.showImportPopup()
    }
    func showImportPopup(){
        self.employeeListImportPopUp = EmployeeListImportPopUp(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.employeeListImportPopUp.uploadFileButton.addTarget(self, action: #selector(self.uploadFilePressed), for: .touchUpInside)
        self.employeeListImportPopUp.downloadFileButton.addTarget(self, action: #selector(self.downloadFilePressed), for: .touchUpInside)
        self.view.addSubview(self.employeeListImportPopUp)
    }
    @objc func uploadFilePressed(sender: UIButton) {
        self.employeeListImportPopUp.removeFromSuperview()
        self.openDocument()
    }
    @objc func downloadFilePressed(sender: UIButton) {
        self.employeeListImportPopUp.removeFromSuperview()
        self.downloadAndSaveXLSXFile()
    }
    func checkAndUploadExcelDocument(fileURL: URL) {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            
            if let fileSize = fileAttributes[.size] as? Int {
                let fileSizeInMB = Double(fileSize) / (1024 * 1024) // Convert to MB
                
                if fileSizeInMB <= 5.0 { // 5 MB limit
                    //upload logic here
                    self.uploadExcelDocument(fileURL: fileURL)
                } else {
                    print("File size exceeds 5 MB limit. Cannot upload.")
                }
            }
        } catch {
            print("Error getting file attributes: \(error)")
        }
    }
    func uploadExcelDocument(fileURL: URL) {
        // Perform upload logic here
        print("Uploading \(fileURL.lastPathComponent) to server...")
        self.uploadDocumentsApi()
    }
    
    @IBAction func onTapDownloadButton(_ sender: Any) {
    }
    
    @IBAction func searchBtnClicked(_ sender: Any)
    {
        if searchTxtField.text != ""
        {
            self.getEmployeeListApi()
        }
    }
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        self.currentSearchFieldsText = nil
        self.currentSearchText = sender.text
        self.getEmployeeListApi(searchText: sender.text!)
    }
    func getEmployeeListApi(searchText: String? = nil, searchFields: String? = nil, pageIndex: String? = "")
    {
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullUrl = BASE_URL + PROJECT_URL.GET_EMPLOYEE_LIST_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            
            var param:[String:Any] = [:]
            if (searchStr != "")
            {
                param = ["page": 0,"company_id": companyId, "search":"\(searchStr)"]
                self.currentPageIndex = 0
            }
            else
            {
                param = ["page": "\(self.currentPageIndex)","limit": "10","company_id": companyId, "search":"\(searchStr)"]
            }
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    // For pagination 3
                    self.totalPageIndexCount = json["total_record_count"].intValue
                    if (self.currentPageIndex == 0) {
                        self.employeeListArr.removeAll()
                    }
                    //self.employeeListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        var tag =  json["data"][i]["tag"].stringValue
                        var position =  json["data"][i]["position"].stringValue
                        var timezone_location =  json["data"][i]["timezone_location"].stringValue
                        var hourly_rate =  json["data"][i]["hourly_rate"].stringValue
                        var mobile =  json["data"][i]["mobile"].stringValue
                        var c_code =  json["data"][i]["c_code"].stringValue
                        var timezone_offset =  json["data"][i]["timezone_offset"].stringValue
                        let profile_pic =  json["data"][i]["profile_pic"].stringValue
                        let id =  json["data"][i]["id"].stringValue
                        var shift_name =  json["data"][i]["shift_name"].stringValue
                        let timezone_gmt =  json["data"][i]["timezone_gmt"].stringValue
                        var color_code =  json["data"][i]["color_code"].stringValue
                        var status =  json["data"][i]["status"].stringValue
                        var name =  json["data"][i]["name"].stringValue
                        var role =  json["data"][i]["role"].stringValue
                        var break_duration =  json["data"][i]["break_duration"].stringValue
                        var email =  json["data"][i]["email"].stringValue
                        var check_in =  json["data"][i]["check_in"].stringValue
                        var check_out =  json["data"][i]["check_out"].stringValue
                        var max_work_hour_weekly =  json["data"][i]["max_work_hour_weekly"].stringValue
                        let employee_id =  json["data"][i]["employee_id"].stringValue
                        
                        if tag == ""
                        {
                            tag = "--"
                        }
                        if position == ""
                        {
                            position = "--"
                        }
                        if timezone_location == ""
                        {
                            timezone_location = "--"
                        }
                        if hourly_rate == ""
                        {
                            hourly_rate = "--"
                        }
                        if mobile == ""
                        {
                            mobile = "--"
                        }
                        if c_code == ""
                        {
                            c_code = "--"
                        }
                        if timezone_offset == ""
                        {
                            timezone_offset = "--"
                        }
                        if color_code == ""
                        {
                            color_code = "--"
                        }
                        if status == ""
                        {
                            status = "--"
                        }
                        if name == ""
                        {
                            name = "--"
                        }
                        if role == ""
                        {
                            role = "--"
                        }
                        if break_duration == ""
                        {
                            break_duration = "--"
                        }
                        if email == ""
                        {
                            email = "--"
                        }
                        if check_in == ""
                        {
                            check_in = "--"
                        }
                        if check_out == ""
                        {
                            check_out = "--"
                        }
                        if max_work_hour_weekly == ""
                        {
                            max_work_hour_weekly = "--"
                        }
                        if shift_name == ""
                        {
                            shift_name = "--"
                        }
                        
                        self.employeeListArr.append(EmployeeListStruct.init(tag: tag, position: position, timezone_location: timezone_location, hourly_rate: hourly_rate, mobile: mobile, c_code: c_code, timezone_offset: timezone_offset, profile_pic: profile_pic, id: id, shift_name: shift_name ?? "--", timezone_gmt: timezone_gmt, color_code: color_code, status: status, name: name, role: role, break_duration: break_duration, email: email, check_in: check_in, check_out: check_out, max_work_hour_weekly: max_work_hour_weekly, employee_id: employee_id))
                    }
                }
                else {
                    self.employeeListArr.removeAll()
                    //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    
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
                        //UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
                DispatchQueue.main.async {
                    if self.employeeListArr.count == 0
                    {
                        self.tbleView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    else
                    {
                        self.tbleView.isHidden = false
                        self.emptyView.isHidden = true
                    }
                    self.tbleView.reloadData()
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
    
    @objc func deleteBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.employeeListArr[index]
        let employeeId = info.employee_id
        if employeeId != ""
        {
            self.deleteApiCall(employeeID: employeeId)
        }
    }
    @objc func editBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let vc = AddNewEmployeeVC()
        vc.isOpenFrom = "Edit"
        vc.employeeDetail = self.employeeListArr[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func deleteApiCall(employeeID:String)
    {
        let Alert = UIAlertController(title: "Alert", message: "Are you sure, You want to delete this employee!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteEmployeeApi(employeeId: employeeID)
        }))
        //        Alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { (action: UIAlertAction!) in
        //        }))
        Alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { (action: UIAlertAction!) in
            // Dismiss the alert controller when "Not Now" is tapped
            Alert.dismiss(animated: true, completion: nil)
        }))
        if let presenter = Alert.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        DispatchQueue.main.async {
            self.present(Alert, animated: true, completion: nil)
        }
    }
    func deleteEmployeeApi(employeeId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_COMPANY_EMPLOYEE_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "user_id": userId, "employee_id":employeeId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getEmployeeListApi()
                }
                else
                {
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
                    self.tbleView.reloadData()
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
    
    @IBAction func OnTapBackBtn(_ sender: Any) {
        //        self.navigationController?.popViewController(animated: false)
        let vc = EmployeeVC()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    func urlString(from url: URL?) -> String? {
        // Check if the URL is not nil
        guard let url = url else {
            return nil
        }
        
        // Convert URL to string using absoluteString property
        let urlString = url.absoluteString
        return urlString
    }
    func  uploadDocumentsApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.IMPORT_DOCUMENT_API
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = ["company_id":companyId,"user_id": userId, "file": self.pickedDocUrl ?? ""]
            
            print(param)
            ServerClass.sharedInstance.sendMultipartRequestToServer(urlString: fullUrl, fileName: "file", param, imageUrl: self.pickedDocUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    //self.currentPageIndex = 0
                    self.getEmployeeListApi()
                }
                else
                {
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
                
            }, errorBlock: { (NSError) in
                //                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                UIAlertController.showInfoAlertWithTitle("Alert", message: "The uploaded file format doesn't match the expected format.", buttonTitle: "Okay")
                //                UIAlertController.showInfoAlertWithTitle("Alert", message: NSError.localizedDescription, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
}
extension EmployeeListVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.employeeListArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeListTableCell") as! EmployeeListTableCell
        cell.selectionStyle = .none
        cell.editDeleteBackView.isHidden = false
        let info = self.employeeListArr[indexPath.row]
        cell.nameTextField.text = info.name
        cell.roleTextField.text = info.role
        cell.mobileTextField.text = "Contact Number : \(info.mobile)"
        cell.tagTextField.text = "Tags : \(info.tag)"
        cell.shiftNameTextField.text = "Schedules : \(info.shift_name)"
        //        let checkInTimeStr = gmtToLocal(dateStr: info.check_in)
        //        let checkOutTimeStr = gmtToLocal(dateStr: info.check_out)
        //        cell.shiftNameTextField.text = "Schedules : \(checkInTimeStr ?? "")-\(checkOutTimeStr ?? "")"
        //
        let imageUrl = IMAGE_BASE_URL + info.profile_pic
        cell.employeeProfilePicImgView.setImage(with: imageUrl)
        //cell.employeeProfilePicImgView.sd_setImage(with: URL(string:imageUrl), placeholderImage: #imageLiteral(resourceName: "dummy-user"))
        
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        cell.editBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(editBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let vc = EmployeeDetailVC()
        vc.employeeDetail = self.employeeListArr[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        125
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.employeeListArr.count - 1) {
            if (self.employeeListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getEmployeeListApi()
            }
        }
    }
}
extension EmployeeListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentSearchText = textField.text
        self.currentSearchFieldsText = nil
        self.getEmployeeListApi(searchText: textField.text!)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard range.location == 0 else {
            return true
        }
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
}
extension EmployeeListVC : UIDocumentPickerDelegate {
    func downloadAndSaveXLSXFile() {
        let fullUrlStr = IMAGE_BASE_URL + "public/import/excel_file1.xlsx"
//        guard let url = URL(string: "https://skazulebackend.chawtechsolutions.ch/storage/app/public/import/excel_file1.xlsx") else {
//            print("Invalid URL")
//            return
//        }
        print(fullUrlStr)
        guard let url = URL(string: fullUrlStr) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading file: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentsDirectory.appendingPathComponent("downloadedFormat.xlsx")
                try data.write(to: fileURL)
                print("File saved at: \(fileURL)")
                DispatchQueue.main.async {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        if #available(iOS 14.0, *) {
                            let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL])
                            documentPicker.delegate = self
                            self.present(documentPicker, animated: true, completion: nil)
                        } else {
                            // Fallback on earlier versions
                            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                            self.present(activityViewController, animated: true, completion: nil)
                        }
                    }
                }
            } catch {
                print("Error saving file: \(error)")
            }
        }.resume()
    }
    func openDocument()
    {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }
        // Handle the selected file here
        if (fileURL.pathExtension.lowercased() == "csv") || fileURL.pathExtension.lowercased() == "xlsx" || fileURL.pathExtension.lowercased() == "xls" || fileURL.pathExtension.lowercased() == "xlsxmax"{
            // Handle CSV file or Handle Excel file
            self.pickedDocUrl = fileURL
            print("import result : \(fileURL)")
            // check file size
            let excelFilePath = fileURL
            self.checkAndUploadExcelDocument(fileURL: excelFilePath)
        } else {
            // Unsupported file type
            showMessageAlert(message: "Please import only CSV/Excel")
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}
/*
 func getCurrentMillis()->Int64 {
 return Int64(Date().timeIntervalSince1970 * 1000)
 }
 func downloadAndSaveFile111() {
 // URL of the file you want to download
 let urlString = "https://skazulebackend.chawtechsolutions.ch/storage/app/public/import/excel_file1.xlsx"
 //        let urlString = "https://skazulebackend.chawtechsolutions.ch/storage/app/public/company_doc/F35RTdHt4tgs94pNWQrkilJRfSWRsxZud1Kfpg1B.pdf"
 
 showProgressOnView(self.view)
 let currentTime = getCurrentMillis()
 let urlStrin = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
 let url = URL(string: urlStrin!)
 let fileName = String((url!.lastPathComponent)) as NSString
 let encodec_fileName = fileName.replacingOccurrences(of: " ", with: "")
 // Create destination URL
 let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
 let destinationFileUrl = documentsUrl.appendingPathComponent("\(currentTime) \(encodec_fileName)")
 //Create URL to the source file you want to download
 let fileURL = URL(string: urlStrin!)
 let sessionConfig = URLSessionConfiguration.default
 let session = URLSession(configuration: sessionConfig)
 let request = URLRequest(url:fileURL!)
 let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
 if let tempLocalUrl = tempLocalUrl, error == nil {
 // Success
 DispatchQueue.main.async {
 hideProgressOnView(self.view)
 }
 
 if let statusCode = (response as? HTTPURLResponse)?.statusCode {
 print("Successfully downloaded. Status code: \(statusCode)")
 showMessageAlert(message: "File downloaded and saved successfully")
 }
 
 do {
 try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
 do {
 //Show UIActivityViewController to save the downloaded file
 let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
 for indexx in 0..<contents.count {
 if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
 DispatchQueue.main.async {
 
 let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
 self.present(activityViewController, animated: true, completion: nil)
 }
 }
 }
 }
 catch (let err) {
 print("error: \(err)")
 UIAlertController.showInfoAlertWithTitle("Alert", message: err.localizedDescription, buttonTitle: "Okay")
 hideProgressOnView(self.view)
 // self.displayAlertMessage(messageToDisplay: err.localizedDescription)
 }
 } catch (let writeError) {
 
 hideProgressOnView(self.view)
 print("Error creating a file \(destinationFileUrl) : \(writeError)")
 //  self.displayAlertMessage(messageToDisplay: writeError.localizedDescription)
 
 }
 } else {
 hideProgressOnView(self.view)
 print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
 }
 }
 task.resume()
 }
 
 func downloadAndSaveExcelFile(from url: URL, saveTo saveURL: URL, completion: @escaping (Error?) -> Void) {
 let session = URLSession.shared
 let task = session.dataTask(with: url) { data, response, error in
 if let error = error {
 completion(error)
 return
 }
 
 guard let data = data else {
 completion(nil)
 return
 }
 
 do {
 try data.write(to: saveURL)
 completion(nil)
 } catch {
 completion(error)
 }
 }
 
 task.resume()
 }
 */

//MARK: Method to save document file
//      func downloadAndSaveFile111() {
//          let urlString = "https://skazulebackend.chawtechsolutions.ch/storage/app/public/import/excel_file1.xlsx"
//
//          showProgressOnView(self.view)
//          let currentTime = getCurrentMillis()
//          let urlStrin = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//          let url = URL(string: urlStrin!)
//          let fileName = String((url!.lastPathComponent)) as NSString
//          let encodec_fileName = fileName.replacingOccurrences(of: " ", with: "")
//          // Create destination URL
//          let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
//          let destinationFileUrl = documentsUrl.appendingPathComponent("\(currentTime) \(encodec_fileName)")
//          //Create URL to the source file you want to download
//          let fileURL = URL(string: urlStrin!)
//          let sessionConfig = URLSessionConfiguration.default
//          let session = URLSession(configuration: sessionConfig)
//          let request = URLRequest(url:fileURL!)
//          let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
//              if let tempLocalUrl = tempLocalUrl, error == nil {
//                  // Success
//                  DispatchQueue.main.async {
//                      hideProgressOnView(self.view)
//                  }
//
//                  if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                      print("Successfully downloaded. Status code: \(statusCode)")
//                      if statusCode == 200 {
//                          DispatchQueue.main.async {
//                              showMessageAlert(message: "File downloaded and saved successfully")
//                          }
//                      }
//                  }
//                  do {
//                      try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
//                      do {
//                          //Show UIActivityViewController to save the downloaded file
//  //                        let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//  //                        for indexx in 0..<contents.count {
//  //                            if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
//  //                                DispatchQueue.main.async {
//  //
//  //
//  //                                    let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
//  //                                    viewController.present(activityViewController, animated: true, completion: nil)
//  //                                }
//  //                            }
//  //                        }
//
//                      }
//                      catch (let err) {
//                          print("error: \(err)")
//                          hideProgressOnView(self.view)
//                          showMessageAlert(message: err.localizedDescription)
//                      }
//                  } catch (let writeError) {
//
//                      hideProgressOnView(self.view)
//                      print("Error creating a file \(destinationFileUrl) : \(writeError)")
//                  }
//              } else {
//                  hideProgressOnView(self.view)
//                  print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
//              }
//          }
//          task.resume()
//      }
