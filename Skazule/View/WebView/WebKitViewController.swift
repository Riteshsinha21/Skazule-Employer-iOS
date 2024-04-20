//
//  WebKitViewController.swift
//  Skazule
//
//  Created by ChawTech Solutions on 23/02/23.
//

import UIKit
import AVFoundation
import WebKit

class WebKitViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var CustomNavigationBar: CustomNavigationBar!
    @IBOutlet weak var webView: WKWebView!
    
    //Custom View
    var customEmployeeListView : CustomEmployeeListDocShareView!
    var selectedEmployeeId = "0"
    
    var urlStr  : String = ""
    var headerTitle:String?
    var isCommingFrom = ""
    var docID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomNavigationBar.titleLabel.text = headerTitle ?? "View Document"
        if isCommingFrom == "Documents"
        {
            self.CustomNavigationBar.customRightBarButton2.isHidden = false
            self.CustomNavigationBar.customRightBarButton2.setBackgroundImage(UIImage.init(named: "share"), for: .normal)
            self.CustomNavigationBar.customRightBarButton2.addTarget(self, action: #selector(onClickShareBtn), for: .touchUpInside)
            /*
             self.CustomNavigationBar.customRightBarButton.isHidden = false
             self.CustomNavigationBar.customRightBarButton.setBackgroundImage(UIImage.init(named: "share_history"), for: .normal)
             self.CustomNavigationBar.customRightBarButton.tintColor = .gray
             self.CustomNavigationBar.customRightBarButton.addTarget(self, action: #selector(onClickShareHistoryBtn), for: .touchUpInside)
             */
        }
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(openNotification(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_KEYS.EMPLOYEE_NAME_ID), object: nil)
        
        //TODO:- check network connection
        if Reachability.isConnectedToNetwork()
        {
            //            showProgressOnView(self.view)
            self.openPdfFile(pdf_path: self.urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        else
        {
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        hideAllProgressOnView(self.view)
    }
    func openPdfFile(pdf_path: String)
    {
        showProgressOnView(self.view)
        let pdfUrl = URL.init(string: pdf_path)
        let req = NSURLRequest(url: pdfUrl!)
        self.webView.load(req as URLRequest)
    }
    @objc func openNotification(_ notification: Notification)
    {
        print(notification.userInfo ?? "")
        
        if let dict = notification.userInfo as NSDictionary? {
            if let employeeId = dict["employeeId"] as? String {
                self.selectedEmployeeId = employeeId
            }
        }
        
        print("&&&&^^^^^^^^^^^^^^%%%%%!@#$\(self.selectedEmployeeId)")
        self.shareDocumentsApi(docId: self.docID, emplyeeIds: self.selectedEmployeeId)
        
    }
    func shareDocumentsApi(docId:String,emplyeeIds:String)
    {
        let fullUrl = BASE_URL + PROJECT_URL.SHARE_COMPANY_DOCUMENTS_API
        if Reachability.isConnectedToNetwork() {
            guard let userId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.EMPLOYER_ID)
            else {return}
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {return}
            
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "company_id": companyId, "user_id": userId,"employee_id":emplyeeIds,"doc_id":docId,"description":""]
            print(param)
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay",viewController: self)
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
    
    @objc func onClickShareBtn(_ sender:UIButton)
    {
        self.customEmployeeListView = CustomEmployeeListDocShareView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(self.customEmployeeListView)
    }
    @objc func onClickShareHistoryBtn(_ sender:UIButton)
    {
        let vc = EmployeeDocumentsShareHistoryVC()
        vc.documentId = self.docID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Webview delegate mathod
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print(#function)
        print("WebView starts")
        //showProgressOnView(self.view)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async
        {
            hideAllProgressOnView(self.view)
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        DispatchQueue.main.async
        {
            hideAllProgressOnView(self.view)
        }
    }
}
