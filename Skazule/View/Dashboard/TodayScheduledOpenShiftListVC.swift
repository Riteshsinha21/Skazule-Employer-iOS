//
//  TodayScheduledOpenShiftListVC.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 18/08/23.
//

import UIKit

class TodayScheduledOpenShiftListVC: UIViewController {
    
    @IBOutlet weak var customNavigationBar: CustomNavigationBar!
    @IBOutlet weak var tblView: UITableView!

    var todayOpenShiftArr       = [TodayOpenShiftDataStruct]()
    var todayOpenShiftDetailArr = [OpenScheduleDataStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.titleLabel.text = "Today Open Shift"
        self.tblView.register(UINib(nibName: "TodayOpenShiftCell", bundle: .main), forCellReuseIdentifier: "TodayOpenShiftCell")
        self.tblView.reloadData()
    }
    @objc func viewBtnClicked(sender:UIButton)
    {
        let tag = sender.tag
        let info = self.todayOpenShiftDetailArr[tag]
        let vc = SchedulerDetailVC()
        vc.isCommingFrom   = "Open Shift"
        vc.openShiftDetail = info
        vc.scheduleId      = info.schedule_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TodayScheduledOpenShiftListVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.todayOpenShiftDetailArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayOpenShiftCell") as! TodayOpenShiftCell
        cell.selectionStyle = .none
        //cell.accessoryType = .disclosureIndicator
        let info = self.todayOpenShiftDetailArr[indexPath.row]
        let checkInTimeStr  = gmtToLocal(dateStr: info.check_in)
        let checkOutTimeStr = gmtToLocal(dateStr: info.check_out)
        if (checkInTimeStr != nil) && (checkOutTimeStr != nil){
            cell.scheduleTimeLbl.text = "\(checkInTimeStr!)-\(checkOutTimeStr!)"
        }
        cell.titleLbl.text  = info.position
        
        cell.viewBtn.tag = indexPath.row
        cell.viewBtn.addTarget(self, action: #selector(viewBtnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let info = self.todayOpenShiftDetailArr[indexPath.row]
        let vc = SchedulerDetailVC()
        vc.isCommingFrom   = "Open Shift"
        vc.openShiftDetail = info
        vc.scheduleId      = info.schedule_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        UITableView.automaticDimension
    }
}
