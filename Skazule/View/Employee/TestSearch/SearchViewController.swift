//
//  SearchViewController.swift
//  Skazule
//
//  Created by ChawTech Solutions on 28/02/23.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var docList:[DocumentsListStruct] = []   //declare an empty array to store Core Data book records
    var searchController:UISearchController!    // instantiate a search bar controller
    var searchResults:[DocumentsListStruct] = []  // declare an empty array to store search bar results
        
    @IBOutlet weak var tblView: UITableView!
    var searchResultsArr = [DocumentsListStruct]()
    var documentsListArr = [DocumentsListStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let dateComponents = Calendar(identifier: .gregorian).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
//        let startOfWeek = Calendar(identifier: .gregorian).date(from: dateComponents)!
//        let startOfWeekNoon = Calendar(identifier: .gregorian).date(bySettingHour: 12, minute: 0, second: 0, of: startOfWeek)!
//        let weekDays = (0...6).map { Calendar(identifier: .gregorian).date(byAdding: .day, value: $0, to: startOfWeekNoon)! }
//        print(weekDays)
//
//        // this will give you all days of the current week starting monday
//        print(Date().daysOfWeek(using: .iso8601)  )
//        // this will give you all days of the current week starting sunday
//        print(Date().daysOfWeek(using: .gregorian))
        
        print(Date().daysOfWeek(using: .gregorian).map(\.ddMMyyyy)) // ["07.06.2020", "08.06.2020", "09.06.2020", "10.06.2020", "11.06.2020", "12.06.2020", "13.06.2020"]
        
        print(Date().daysOfWeek(using: .iso8601).map(\.ddMMyyyy))
        //["27.02.2023", "28.02.2023", "01.03.2023", "02.03.2023", "03.03.2023", "04.03.2023", "05.03.2023"]
        
        
        
        
        
//        //let calendar = Calendar.current
//        let calendar = Calendar(identifier: .iso8601)
//        let currentDate = Date()
//        let currentWeek = calendar.component(.weekOfYear, from: currentDate)
//        print(currentWeek)
        
//        let Monday = 79
//        let Tuesday = 80
//        let Wednesday = 81
//        let Thursday = 82
//        let Friday = 83
//
//
//        let calendar1 = Calendar.current
//        let today = calendar1.startOfDay(for: Date())
//        let dayOfWeek = calendar1.component(.weekday, from: today)
//        let dates = calendar1.range(of: .weekday, in: .weekOfYear, for: today)!
//            .compactMap { calendar1.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }
//            .filter { !calendar1.isDateInWeekend($0) }
//        print(dates)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "eeee' = 'D"
//        for date in dates {
//            print(formatter.string(from: date))
//        }
//        let strings = dates.map { formatter.string(from: $0) }
//        print(strings)

        
        
        
    //    self.getDocumentsListApi()

        
        tblView.register(UINib(nibName: "EmployeeDocumentsTableCell", bundle: Bundle.main), forCellReuseIdentifier: "EmployeeDocumentsTableCell")
        
        
        // Add a Search Bar Programmtically
        searchController = UISearchController(searchResultsController: nil)
        tblView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        // Search Bar options
        searchController.searchBar.placeholder = "Search by Title, Author or Series"
        
        // Search Bar Disappears when tapped, hence the code line below is a MUST
        searchController.hidesNavigationBarDuringPresentation = false
        // Add a colour border for the search bar
        searchController.searchBar.tintColor = UIColor.orange
        let valuee = getAllDaysOfTheCurrentWeek()
        print(valuee)
        
        
    }
    
    func getAllDaysOfTheCurrentWeek() -> [Date] {
        var dates: [Date] = []
        guard let dateInterval = Calendar.current.dateInterval(of: .weekOfYear,
                                                               for: Date()) else {
            return dates
        }
        
        Calendar.current.enumerateDates(startingAfter: dateInterval.start,
                                        matching: DateComponents(hour:0),
                                        matchingPolicy: .nextTime) { date, _, stop in
                guard let date = date else {
                    return
                }
                if date <= dateInterval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
        }
        
        return dates
    }
    
    
    
    
    // BooksTableViewController viewWillAppear()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        // ....
//        // Retrieve Core Data book records
//        let docListContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
//        let bookFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Book")
//        do {
//            if let docListFetchedResults = try docListContext.fetch(docListFetchRequest) as? [Book] {
//                docList = docListFetchedResults
//            } else {
//                print("ELSE if let results = try.. FAILED")
//            }
//        } // end do
//        catch {
//            fatalError("There was an error fetching the list of groups!")
//        }
//        // ...
        
        self.tblView.reloadData()
        
    }
//    // BooksTableViewController.swift numberOfRowsInSection(..)
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        if searchController.isActive {
//            return searchResults.count
//        } else {
//            return docList.count
//        }
//    }
    
//    // BooksTableViewController.swift cellForRowAt(..)
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cellIdentifier = "Cell"
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookTableViewCell
//
//        let book = (searchController.isActive) ? searchResults[(indexPath as NSIndexPath).row] : docList[(indexPath as NSIndexPath).row]
//
//        // Configure the cell..
//    }
    
    
 //   // BooksTableViewController canEditRowAt
    
//    // Override to support conditional editing of the table view. Needed when using Search Bar, so user cannot edit the results of the search
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        if searchController.isActive {
//            return false
//        } else {
//            return true
//        }
//    }
  
    
    func getDocumentsListApi()
    {
        let fullUrl = BASE_URL + PROJECT_URL.GET_COMPANY_DOCUMENTS_API
        if Reachability.isConnectedToNetwork() {
            guard let companyId = UserDefaults.standard.string(forKey: USER_DEFAULTS_KEYS.COMPANY_ID)
            else {
                return
            }
            showProgressOnView(appDelegateInstance.window!)
            let param:[String:Any] = [ "page": "0","limit": "100","company_id": companyId]
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: fullUrl, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["status"].stringValue
                if success  == "1"
                {
                    self.documentsListArr.removeAll()
                    for i in 0..<json["data"].count
                    {
                        let document_file =  json["data"][i]["document_file"].stringValue
                        var document_name =  json["data"][i]["document_name"].stringValue
                        var created_at =  json["data"][i]["created_at"].stringValue
                        let id =  json["data"][i]["id"].stringValue
                        let status =  json["data"][i]["status"].stringValue
                        var uploaded_by =  json["data"][i]["uploaded_by"].stringValue
                        let file_type =  json["data"][i]["file_type"].stringValue
 
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
    
    // Search Bar filter Logic
    func filterContentForSearchText(_ searchText: String) {
        searchResults = self.documentsListArr.filter({ (doc:DocumentsListStruct) -> Bool in
            let titleMatch = doc.document_name.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let uploadedByMatch = doc.uploaded_by.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let CreatedAtMatch = doc.created_at.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return titleMatch != nil || uploadedByMatch != nil || CreatedAtMatch != nil}
        )
    } // end func filterContent
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
            self.tblView.reloadData()  // replace current table view with search results table view
        }
    }
    // End fo Search Bar Logic
    
}
extension SearchViewController : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchController.isActive {
            return searchResults.count
        } else {
            return self.documentsListArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeDocumentsTableCell") as! EmployeeDocumentsTableCell
//        cell.selectionStyle = .none
//        let info = self.documentsListArr[indexPath.row]
//        cell.docNameLLbl.text = info.document_name
//        cell.uploadedByNameLbl.text = info.uploaded_by
//        cell.createdAtDateLbl.text = info.created_at
//        return cell
        
        let cellIdentifier = "EmployeeDocumentsTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EmployeeDocumentsTableCell
        
        let docList = (searchController.isActive) ? searchResults[indexPath.row] : self.documentsListArr[indexPath.row]
        cell.docNameLLbl.text = docList.document_name
        cell.uploadedByNameLbl.text = docList.uploaded_by
        cell.createdAtDateLbl.text = docList.created_at
        
        // Configure the cell..
        
        return cell
    }
    
    // Override to support conditional editing of the table view. Needed when using Search Bar, so user cannot edit the results of the search
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}







//
//
//extension Calendar {
//  func intervalOfWeek(for date: Date) -> DateInterval? {
//    dateInterval(of: .weekOfYear, for: date)
//  }
//
//  func startOfWeek(for date: Date) -> Date? {
//    intervalOfWeek(for: date)?.start
//  }
//
//  func daysWithSameWeekOfYear(as date: Date) -> [Date] {
//    guard let startOfWeek = startOfWeek(for: date) else {
//      return []
//    }
//
//    return (0 ... 6).reduce(into: []) { result, daysToAdd in
//      result.append(Calendar.current.date(byAdding: .day, value: daysToAdd, to: startOfWeek))
//    }
//    .compactMap { $0 }
//  }
//}





//["27.02.2023", "28.02.2023", "01.03.2023", "02.03.2023", "03.03.2023", "04.03.2023", "05.03.2023"]
// Android logic
// private func getWeekDays(){
//            val format: DateFormat = SimpleDateFormat("MM/dd/yyyy")
//            val calendar: Calendar = Calendar.getInstance()
//            calendar.setFirstDayOfWeek(Calendar.MONDAY)
//            calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY)
//
//            val days = arrayOfNulls<String>(7)
//            for (i in 0..6) {
//                days[i] = format.format(calendar.getTime())
//                calendar.add(Calendar.DAY_OF_MONTH, 1)
//            }
//            Log.d("days",""+days)
//  }
