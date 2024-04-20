//
//  EmployeeDocumentsVC.swift
//  Skazule
//
//  Created by ChawTech Solutions on 13/12/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class EmployeeDocumentsVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var searchTxf: UITextField!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblBackView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var uploadBtn: UIButton!
    
    var documentsListArr = [DocumentsListStruct]()
    //1 For search
    var currentSearchText: String?
    var currentSearchFieldsText: String?
    
    //Custom View
    var customUploadDocumentsView : CustomUploadDocumentsView!
    var customChooseImgView : CustomChooseImgView!
    
    // For Update Tags
    var isOpenFrom = "Add"
    var documentsId = ""
    var uploadedDocumentURL = ""
    var document = ""
    
    //MARK: Variables
    let imagePicker = UIImagePickerController()
    var pickedImage : UIImage!
    var pickedImageUrl:URL?
    
    // For pagination 1
    var currentPageIndex: Int = 0
    var totalPageIndexCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.customNavigationBar.titleLabel.text = "Documents"
        tblView.register(UINib(nibName: "EmployeeDocumentsTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeDocumentsTableCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        // For pagination 2
        currentPageIndex = 0
        
        self.getDocumentsListApi()
    }
    @IBAction func onClickUploadBtn(_ sender: Any) {
        self.isOpenFrom = "Add"
        self.showCustomUploadDocumentsView()
    }
    func showCustomUploadDocumentsView (){
        self.customUploadDocumentsView = CustomUploadDocumentsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        if self.isOpenFrom == "Edit"
        {
            self.customUploadDocumentsView.documentNameTextField.text = self.document
            self.customUploadDocumentsView.uploadImgNameLbl.text = self.uploadedDocumentURL
            self.customUploadDocumentsView.headerTitleLbl.text = "Update File"
            self.customUploadDocumentsView.uploadButton.setTitle("Update", for: .normal)
        }
        else
        {
            self.customUploadDocumentsView.documentNameTextField.text  = ""
            self.customUploadDocumentsView.headerTitleLbl.text = "Upload File"
            self.customUploadDocumentsView.uploadButton.setTitle("Upload", for: .normal)
        }
        self.customUploadDocumentsView.uploadDocumentsButton.addTarget(self, action: #selector(self.uploadDocsButtonPressed), for: .touchUpInside)
        self.customUploadDocumentsView.uploadButton.addTarget(self, action: #selector(self.uploadButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customUploadDocumentsView)
    }
    @objc func uploadButtonPressed(sender: UIButton) {
        
        if self.customUploadDocumentsView.documentNameTextField.text == ""
        {
            showMessageAlert(message: "Please enter name")
        }
        else
        {
            self.customUploadDocumentsView.removeFromSuperview()
            self.document     = self.customUploadDocumentsView.documentNameTextField.text!
            if isOpenFrom == "Edit"
            {
                self.updateDocumentsApi(documentName: self.document,  documentId: self.documentsId)
            }
            else
            {
                if self.pickedImageUrl == nil
                {
                    showMessageAlert(message: "Please upload documents")
                }
                else
                {
                    self.uploadDocumentsApi(documentName: self.document)
                }
            }
        }
    }
    @objc func uploadDocsButtonPressed(sender: UIButton) {
        self.customChooseImgView = CustomChooseImgView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.customChooseImgView.cameraBtnBackView.isHidden = true
        self.customChooseImgView.fileBtnBackView.isHidden   = false
        self.customChooseImgView.gallaryButton.addTarget(self, action: #selector(self.gallaryButtonPressed), for: .touchUpInside)
        self.customChooseImgView.fileButton.addTarget(self, action: #selector(self.fileButtonPressed), for: .touchUpInside)
        self.view.addSubview(self.customChooseImgView)
    }
    @objc func gallaryButtonPressed(sender: UIButton) {
        self.customChooseImgView.removeFromSuperview()
        self.openGallery()
    }
    @objc func fileButtonPressed(sender: UIButton) {
        self.customChooseImgView.removeFromSuperview()
        self.openDocument()
    }
    @IBAction func searchBtnClicked(_ sender: Any)
    {
        if searchTxf.text != ""
        {
            self.getDocumentsListApi()
        }
    }
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        self.currentSearchFieldsText = nil
        self.currentSearchText = sender.text
        self.getDocumentsListApi(searchText: sender.text!)
    }
    func getDocumentsListApi(searchText: String? = nil, searchFields: String? = nil)
    {
        var  searchStr = ""
        if let text = self.currentSearchText, text.count > 0 {
            searchStr = text
        }
        else if let searchFieldsStr = self.currentSearchFieldsText, searchFieldsStr.count > 0 {
            searchStr = searchFieldsStr
        }
        searchStr = searchStr.trimmingCharacters(in: .whitespacesAndNewlines)
        //        searchStr = searchStr.replacingOccurrences(of: " ", with: "%20")
        let fullUrl = BASE_URL + PROJECT_URL.GET_COMPANY_DOCUMENTS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            //            let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId, "search":"\(searchStr)"]
            
            var param:[String:Any] = [:]
            if (searchStr != "")            {
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
                    if self.currentPageIndex == 0 {
                        self.documentsListArr.removeAll()
                    }
                    //self.documentsListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let document_file =  json["data"][i]["document_file"].stringValue
                        var document_name =  json["data"][i]["document_name"].stringValue
                        var created_at =  json["data"][i]["created_at"].stringValue
                        let id =  json["data"][i]["id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        var uploaded_by =  json["data"][i]["uploaded_by"].stringValue
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
                        
                        self.documentsListArr.append(DocumentsListStruct.init(document_file: document_file, document_name: document_name, created_at: created_at, id: id, status: status, uploaded_by: uploaded_by, file_type: file_type))
                        
                    }
                }
                else {
                    self.documentsListArr.removeAll()
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
                    if self.documentsListArr.count == 0
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
    
    func uploadDocumentsApi(documentName:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.ADD_COMPANY_DOCUMENTS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = ["company_id":companyId,"user_id": userId,"document_name":documentName,"document_file":pickedImageUrl ?? ""]
            
            print(param)
            //            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
            ServerClass.sharedInstance.sendMultipartRequestToServer(urlString: fullUrl, fileName: "document_file", param, imageUrl: pickedImageUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.currentPageIndex = 0
                    self.getDocumentsListApi()
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
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func updateDocumentsApi(documentName:String,documentId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.UPDATE_COMPANY_DOCUMENTS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            //            let param:[String:Any] = ["company_id":companyId,"user_id": userId,"document_name":documentName,"document_file":pickedImageUrl ?? "", "document_id":documentId]
            
            var param = [String:Any]()
            if pickedImageUrl == nil
            {
                param = ["company_id":companyId,"user_id": userId,"document_name":documentName, "document_id":documentId]
            }
            else
            {
                param = ["company_id":companyId,"user_id": userId,"document_name":documentName,"document_file":pickedImageUrl ?? "", "document_id":documentId]
            }
            print(param)
            //            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
            ServerClass.sharedInstance.sendMultipartRequestToServer(urlString: fullUrl, fileName: "document_file", param, imageUrl: pickedImageUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    //self.currentPageIndex = 0
                    self.getDocumentsListApi()
                }
                else {
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
    
    
    @objc func deleteBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.documentsListArr[index]
        let documentId = info.id
        if documentId != ""
        {
            self.deleteApiCall(documentID: documentId)
        }
    }
    @objc func editBtnClicked(sender:UIButton)
    {
        let index = sender.tag
        let info = self.documentsListArr[index]
        let documentId = info.id
        if documentId != ""
        {
            self.isOpenFrom          = "Edit"
            self.documentsId         = documentId
            self.document            = info.document_name
            if info.document_file != ""
            {
                let uploadedDocumentNameArr = info.document_file.split(separator: "/")
                if let lastElement = uploadedDocumentNameArr.last {
                    self.uploadedDocumentURL = String(lastElement)
                }
            }
            self.showCustomUploadDocumentsView()
        }
    }
    
    func deleteApiCall(documentID:String)
    {
        let Alert = UIAlertController(title: "Alert", message: "Are you sure, You want to delete this document!", preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTagApi(documentId: documentID)
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
    
    func deleteTagApi(documentId:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.DELETE_COMPANY_DOCUMENTS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "user_id": userId, "document_id":documentId]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.getDocumentsListApi()
                }
                else
                {
                    // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                    
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

extension EmployeeDocumentsVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.documentsListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeDocumentsTableCell") as! EmployeeDocumentsTableCell
        cell.selectionStyle = .none
        let info = self.documentsListArr[indexPath.row]
        cell.docNameLLbl.text = info.document_name
        cell.uploadedByNameLbl.text = info.uploaded_by
        let createdDate = gmtToLocalWithDate(dateStr: info.created_at)
        cell.createdAtDateLbl.text = createdDate
        //        cell.createdAtDateLbl.text = info.created_at
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        cell.editBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(editBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
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
        let info = self.documentsListArr[indexPath.row]
        let imageDocUrl = IMAGE_BASE_URL + info.document_file
        let webView = WebKitViewController()
        webView.urlStr = imageDocUrl
        webView.headerTitle = "View Document"
        webView.isCommingFrom = "Documents"
        webView.docID = info.id
        self.navigationController?.pushViewController(webView, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    // For pagination 4
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (self.documentsListArr.count - 1) {
            if (self.documentsListArr.count < (totalPageIndexCount ?? 0)) && (currentPageIndex != -1) {
                currentPageIndex = currentPageIndex + 1
                self.getDocumentsListApi()
            }
        }
    }
}
extension EmployeeDocumentsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentSearchText = textField.text
        self.currentSearchFieldsText = nil
        self.getDocumentsListApi(searchText: textField.text!)
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
extension EmployeeDocumentsVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Opening Gallery
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK:- imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:  [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            ///////////////self.profileImg.image = pickedImage
            self.customUploadDocumentsView.uploadStatusIconImgView.image = UIImage(named: "salaryslipgenerated")
            self.customUploadDocumentsView.uploadImgNameLbl.text = "Document fetched successfully!!"
            saveImageDocumentDirectory(usedImage: pickedImage)
        }
        if let imgUrl = getImageUrl()
        {
            pickedImageUrl = imgUrl
        }
        dismiss(animated: true, completion: nil)
    }
}
extension EmployeeDocumentsVC : UIDocumentPickerDelegate{
    
    //    let supportedTypes = [UTType.image, UTType.text, UTType.plainText, UTType.utf8PlainText,    UTType.utf16ExternalPlainText, UTType.utf16PlainText,    UTType.delimitedText, UTType.commaSeparatedText,    UTType.tabSeparatedText, UTType.utf8TabSeparatedText, UTType.rtf,    UTType.pdf, UTType.webArchive, UTType.image, UTType.jpeg,    UTType.tiff, UTType.gif, UTType.png, UTType.bmp, UTType.ico,    UTType.rawImage, UTType.svg, UTType.livePhoto, UTType.movie,    UTType.video, UTType.audio, UTType.quickTimeMovie, UTType.mpeg,    UTType.mpeg2Video, UTType.mpeg2TransportStream, UTType.mp3,    UTType.mpeg4Movie, UTType.mpeg4Audio, UTType.avi, UTType.aiff,    UTType.wav, UTType.midi, UTType.archive, UTType.gzip, UTType.bz2,    UTType.zip, UTType.appleArchive, UTType.spreadsheet, UTType.epub
    //]
    //Android - "pdf", "docx", "xlsx", "doc", "xls", "txt" ,"jpg","jpeg"
    //web - jpeg,png,jpg,ppt,pptx,doc,docx,pdf,xls,xlsxmax,xlsx,csv|max:5048
    
    // Opening Gallery
    func openDocument()
    {
        let types: [String] = [
            String(kUTTypeJPEG),
            String(kUTTypePNG),
            "com.microsoft.word.doc",
            "org.openxmlformats.wordprocessingml.document",
            String(kUTTypeRTF),
            "com.microsoft.powerpoint.​ppt",
            "org.openxmlformats.presentationml.presentation",
            String(kUTTypePlainText),
            "com.microsoft.excel.xls",
            "org.openxmlformats.spreadsheetml.sheet",
            String(kUTTypePDF), String(kUTTypeText),
            String(kUTTypeSpreadsheet)
        ]
        if #available(iOS 14.0, *) {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.text, UTType.plainText, UTType.tiff, UTType.spreadsheet], asCopy: true)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.shouldShowFileExtensions = true
            present(documentPicker, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            // Use this code if your are developing prior iOS 14
            let types: [String] = types
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.shouldShowFileExtensions = true
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let docUrl = urls.first else {
            return
        }
        self.customUploadDocumentsView.uploadStatusIconImgView.image = UIImage(named: "salaryslipgenerated")
        self.customUploadDocumentsView.uploadImgNameLbl.text = "Document fetched successfully!!"
        self.pickedImageUrl = docUrl
        print("import result : \(docUrl)")
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}
