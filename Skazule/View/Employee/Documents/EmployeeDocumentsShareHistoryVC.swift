//
//  EmployeeDocumentsShareHistoryVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 05/09/23.
//

import UIKit

class EmployeeDocumentsShareHistoryVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var searchTxf: UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblBackView: UIView!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    var documentId = ""
    var documentsHistoryListArr = [DocumentsListStruct]()
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.titleLabel.text = "History"
        self.navigationTitle.text = "History"
        tblView.register(UINib(nibName: "EmployeeDocumentsTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeDocumentsTableCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
        self.getDocumentsHistoryListApi()
    }
    
    @IBAction func onTapBackBtn(_ sender: Any) {
        // Assuming you have a reference to your UINavigationController
        if let navigationController = self.navigationController {
            // Specify the view controller you want to pop to
            for viewController in navigationController.viewControllers {
                if viewController is EmployeeDocumentsVC {
                    // Pop to the specified view controller
                    navigationController.popToViewController(viewController, animated: true)
                    break
                }
            }
        }
    }
    @IBAction func searchBtnClicked(_ sender: Any)
    {
        if searchTxf.text != ""
        {
            self.getDocumentsHistoryListApi()
        }
    }
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        self.currentSearchFieldsText = nil
        self.currentSearchText = sender.text
        self.getDocumentsHistoryListApi(searchText: sender.text!)
    }
    func getDocumentsHistoryListApi(searchText: String? = nil, searchFields: String? = nil)
    {
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fullUrl = BASE_URL + PROJECT_URL.SHARE_COMPANY_DOCUMENTS_HISTORY_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            //            let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId, "search":"\(searchStr)"]
            
            var param:[String:Any] = [:]
            if (searchStr != "")            {
                param = ["page": 0,"company_id": companyId, "search":"\(searchStr)", "document_id":self.documentId]
                self.currentPageIndex = 0
            }
            else
            {
                param = ["page": "\(self.currentPageIndex)","limit": "10","company_id": companyId, "search":"\(searchStr)", "document_id":self.documentId]
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
                    if self.currentPageIndex == 0 {
                        self.documentsHistoryListArr.removeAll()
                    }
                    //self.documentsListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let document_file =  json["data"][i]["document_file"].stringValue
                        var document_name =  json["data"][i]["document_name"].stringValue
                        var created_at =  json["data"][i]["shared_on"].stringValue
                        let id =  json["data"][i]["id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        var uploaded_by =  json["data"][i]["shared_by"].stringValue
                        let file_type =  json["data"][i]["file_type"].stringValue
                        
                        if document_name == ""
                        {
                            document_name = "--"
                        }
                        if created_at == ""
                        {
                            created_at = "--"
                        }
                        if uploaded_by == ""
                        {
                            uploaded_by = "--"
                        }
                        
                        self.documentsHistoryListArr.append(DocumentsListStruct.init(document_file: document_file, document_name: document_name, created_at: created_at, id: id, status: status, uploaded_by: uploaded_by, file_type: file_type))
                    }
                }
                else {
                    self.documentsHistoryListArr.removeAll()
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
                        //                        UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    }
                    else
                    {
                        UIAlertController.showInfoAlertWithTitle("Message", message: errorMsg, buttonTitle: "Okay")
                    }
                }
                DispatchQueue.main.async {
                    if self.documentsHistoryListArr.count == 0
                    {
                        self.tblBackView.isHidden = true
                        self.emptyView.isHidden = false
                    }
                    else
                    {
                        self.tblBackView.isHidden = false
                        self.emptyView.isHidden = true
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

extension EmployeeDocumentsShareHistoryVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.documentsHistoryListArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeDocumentsTableCell") as! EmployeeDocumentsTableCell
        cell.selectionStyle = .none
        cell.deleteBtnBackView.isHidden = true
        cell.sharedByTitleLbl.text = "Shared By"
        cell.sharedOnTitleLbl.text = "Shared On"
        let info = self.documentsHistoryListArr[indexPath.row]
        cell.docNameLLbl.text = info.document_name
        cell.uploadedByNameLbl.text = info.uploaded_by
        let createdDate = gmtToLocalWithDate(dateStr: info.created_at)
        cell.createdAtDateLbl.text = createdDate
        let fileType = info.file_type
        if fileType == "pdf"
        {
            cell.docIconImgView.image = UIImage(named: "pdf")
        }
        else if fileType == "docx"
        {
            cell.docIconImgView.image = UIImage(named: "document")
        }
        else if fileType == "xlsx"
        {
            cell.docIconImgView.image = UIImage(named: "xlsx")
        }
        else if fileType == "doc"
        {
            cell.docIconImgView.image = UIImage(named: "doc")
        }
        else if fileType == "xls"
        {
            cell.docIconImgView.image = UIImage(named: "xls")
        }
        else if fileType == "txt"
        {
            cell.docIconImgView.image = UIImage(named: "txt")
        }
        else if (fileType == "jpeg") || (fileType == "jpg") || (fileType == "png")
        {
            cell.docIconImgView.image = UIImage(named: "image")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.documentsHistoryListArr.count - 1) {
            if (self.documentsHistoryListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getDocumentsHistoryListApi()
            }
        }
    }
}
extension EmployeeDocumentsShareHistoryVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentSearchText = textField.text
        self.currentSearchFieldsText = nil
        self.getDocumentsHistoryListApi(searchText: textField.text!)
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
