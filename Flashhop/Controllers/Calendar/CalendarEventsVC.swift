//
//  CalendarEventsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/9.
//

import UIKit

class CalendarEventsVC: UIViewController {

    var event_host:[Event] = []
    var event_draft:[Event] = []
    var event_going:[Event] = []
    var event_saved:[Event] = []
    
    @IBOutlet weak var constraintHostingHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintGoingHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintSavedHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewHosting: UITableView!
    @IBOutlet weak var tableViewGoing: UITableView!
    @IBOutlet weak var tableViewSaved: UITableView!
    
    @IBOutlet weak var viewHosting: UIView!
    @IBOutlet weak var viewGoing: UIView!
    @IBOutlet weak var viewSaved: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        constraintHostingHeight.constant = CGFloat(0)
        constraintGoingHeight.constant = CGFloat(0)
        constraintSavedHeight.constant = CGFloat(0)
        
        viewHosting.isHidden = true
        viewGoing.isHidden = true
        viewSaved.isHidden = true
        loadEvents()
    }
    func loadEvents() {
        APIManager.getUpcomingEvents { (events) in
            self.event_host.removeAll()
            self.event_going.removeAll()
            self.event_saved.removeAll()
            self.event_draft = draft_events()
            for e in events {
                if e.creator.id == me.id {
                    self.event_host.append(e)
                }
                if e.is_member(me) {
                    self.event_going.append(e)
                }
                if e.is_liked_by_you == 1 {
                    self.event_saved.append(e)
                }
            }
            self.refresh()
        }
    }
    func refresh() {
        if event_host.count == 0 && event_going.count == 0 && event_saved.count == 0 && event_draft.count == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalendarVC")
            self.navigationController?.pushViewController(vc!, animated: true)
        }else{
            viewHosting.isHidden = (event_host.count + event_draft.count) == 0
            viewGoing.isHidden = event_going.count == 0
            viewSaved.isHidden = event_saved.count == 0
            constraintHostingHeight.constant = CGFloat(100 * (event_host.count + event_draft.count))
                + ((event_host.count + event_draft.count) > 0 ? 60 : 0)
            constraintGoingHeight.constant = CGFloat(100 * event_going.count)
                + (event_going.count > 0 ? 60 : 0)
            constraintSavedHeight.constant = CGFloat(100 * event_saved.count)
                + (event_saved.count > 0 ? 60 : 0)
            
            self.view.layoutSubviews()

            self.tableViewHosting.reloadData()
            self.tableViewGoing.reloadData()
            self.tableViewSaved.reloadData()
        }
    }
    @objc func editHost(_ sender: RoundButton) {
        let index = sender.tag2
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditEventVC") as! EditEventVC
        vc.status = .EDIT
        vc.event = self.event_host[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func cancelHost(_ sender: RoundButton) {
        let ind = sender.tag2
        let ev = self.event_host[ind]
        let t_gap = Date().timeIntervalSince1970 - ev.time().timeIntervalSince1970
        if t_gap < 1800 {
            AlertVC.showMessage(parent: self.navigationController?.parent, text: "Your event is going to start within 30 minutes. You're not able to cancel at the moment.", action_title: "Yes")
            {
            }
        } else {
            AlertVC.showMessage(parent: self.navigationController?.parent, text: "Confirm to cancel the event you’re hosting.", action1_title: "No", action2_title: "Yes", action1: nil)
            {
                let index = sender.tag2
                let event = self.event_host[index]
                
                APIManager.cancelEvent(event_id: event.id) { (success) in
                    if success {
                        self.loadEvents()
                    }
                }
            }
        }
        
    }
    @objc func editDraft(_ sender: RoundButton) {
        let index = sender.tag2
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditEventVC") as! EditEventVC
        vc.status = .EDIT
        vc.event = self.event_draft[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func removeDraft(_ sender: RoundButton) {
        let index = sender.tag2
        let event = self.event_draft[index]
        event.removeFromDraft()
        
        self.event_draft = draft_events()
        refresh()
    }
    func onClickedGoing(_ index: Int) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventVC") as! EventVC
        vc.event = self.event_going[index]
        self.navigationController?.pushViewController(vc, animated: false)
    }
    func onClickedSaved(_ index: Int) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventVC") as! EventVC
        vc.event = self.event_saved[index]
        self.navigationController?.pushViewController(vc, animated: false)
    }
    func hosting_cell(_ index: Int) -> UITableViewCell {
        var cell:UITableViewCell!
        cell = tableViewHosting.dequeueReusableCell(withIdentifier: "EventCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "EventCell")
        }
        
        let ivPhoto = cell.viewWithTag(10) as! UIImageView
        let lbTitle = cell.viewWithTag(20) as! UILabel
        let btnEdit = cell.viewWithTag(30) as! RoundButton; btnEdit.removeTarget(nil, action: nil, for: .allEvents)
        let btnAction = cell.viewWithTag(40) as! RoundButton; btnAction.removeTarget(nil, action: nil, for: .allEvents)
        let lbStatus = cell.viewWithTag(50) as! UILabel
        
        var event:Event!
        if index < event_host.count {
            event = event_host[index]
            
            btnEdit.tag2 = index
            btnEdit.addTarget(self, action:#selector(editHost), for: .touchUpInside)
            
            btnAction.setTitle("Cancel", for: .normal)
            btnAction.tag2 = index
            btnAction.addTarget(self, action:#selector(cancelHost), for: .touchUpInside)
            
            lbStatus.text = "Published"
            lbStatus.textColor = .green
            
        }else{
            event = event_draft[index - event_host.count]
            
            btnEdit.tag2 = index - event_host.count
            btnEdit.addTarget(self, action: #selector(editDraft(_:)), for: .touchUpInside)
            
            btnAction.setTitle("Delete", for: .normal)
            btnAction.tag2 = index - event_host.count
            btnAction.addTarget(self, action: #selector(removeDraft(_:)), for: .touchUpInside)
            
            lbStatus.text = "Draft"
            lbStatus.textColor = .light
        }
        
        makeShadowView(btnEdit)
        makeShadowView(btnAction)
        
        lbTitle.text = event.title
        if event.cover_photo == "" { ivPhoto.image = event.category.cover_image }
        else { ivPhoto.sd_setImage(with: URL(string: event.cover_photo), completed: nil) }
        
        return cell
    }
    func going_cell(_ index: Int) -> UITableViewCell {
        var cell:UITableViewCell!
        cell = tableViewGoing.dequeueReusableCell(withIdentifier: "EventCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "EventCell")
        }
        
        let event = event_going[index]
        
        let lbMon = cell.viewWithTag(11) as! UILabel;
        let lbDay = cell.viewWithTag(12) as! UILabel
        let lbWeekday = cell.viewWithTag(13) as! UILabel
        let lbTitle = cell.viewWithTag(20) as! UILabel
        let lbTime = cell.viewWithTag(30) as! UILabel
        let ivPhoto = cell.viewWithTag(40) as! UIImageView
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        lbMon.text = formatter.string(from: event.time())
        formatter.dateFormat = "dd"
        lbDay.text = formatter.string(from: event.time())
        formatter.dateFormat = "E"
        lbWeekday.text = formatter.string(from: event.time())
        lbTitle.text = event.title
        lbTime.text = event.start_end()
        if event.cover_photo == "" { ivPhoto.image = event.category.cover_image }
        else { ivPhoto.sd_setImage(with: URL(string: event.cover_photo), completed: nil) }
        
        return cell
    }
    func saved_cell(_ index: Int) -> UITableViewCell {
        var cell:UITableViewCell!
        cell = tableViewSaved.dequeueReusableCell(withIdentifier: "EventCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "EventCell")
        }
        
        let event = event_saved[index]
        
        let lbMon = cell.viewWithTag(11) as! UILabel;
        let lbDay = cell.viewWithTag(12) as! UILabel
        let lbWeekday = cell.viewWithTag(13) as! UILabel
        let lbTitle = cell.viewWithTag(20) as! UILabel
        let lbTime = cell.viewWithTag(30) as! UILabel
        let ivPhoto = cell.viewWithTag(40) as! UIImageView
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        lbMon.text = formatter.string(from: event.time())
        formatter.dateFormat = "dd"
        lbDay.text = formatter.string(from: event.time())
        formatter.dateFormat = "E"
        lbWeekday.text = formatter.string(from: event.time())
        lbTitle.text = event.title
        lbTime.text = event.start_end()
        if event.cover_photo == "" { ivPhoto.image = event.category.cover_image }
        else { ivPhoto.sd_setImage(with: URL(string: event.cover_photo), completed: nil) }
        
        return cell
    }
}
extension CalendarEventsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewHosting {
            return event_host.count + event_draft.count
        }
        if tableView == tableViewGoing {
            return event_going.count
        }
        if tableView == tableViewSaved {
            return event_saved.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if tableView == tableViewHosting {
            cell = hosting_cell(indexPath.row)
        }
        if tableView == tableViewGoing {
            cell = going_cell(indexPath.row)
        }
        if tableView == tableViewSaved {
            cell = saved_cell(indexPath.row)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if tableView ==  tableViewHosting {}
        if tableView == tableViewGoing {
            onClickedGoing(indexPath.row)
        }
        if tableView == tableViewSaved {
            onClickedSaved(indexPath.row)
        }
    }
}
