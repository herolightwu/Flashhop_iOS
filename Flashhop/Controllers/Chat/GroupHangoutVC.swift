//
//  GroupHangoutVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/14.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class GroupHangoutVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnGroupChat: ColorCheckBox!
    @IBOutlet weak var btnHangout: ColorCheckBox!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblRemain: UILabel!
    
    var database: DatabaseReference!
    var storage: StorageReference!
    
    var events:[Event] = []
    var hangouts:[Hangout] = []
    //var last_messages:[LastMessage] = []
    var last_msgs:[Int:LastMessage] = [:]
    var fevents:[Event] = []    // filtered events by search text
    var fhangouts:[Hangout] = []    // filtered hangouts by search text
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        database = Database.database().reference()
        storage = Storage.storage().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //if DEBUG_MODE {
        //    addTestData()
        //}else{
            loadEvents()
            loadHangouts()
        //}
    }
    func loadEvents() {
        APIManager.getChatGroupEvents { (events) in
            self.events.removeAll()
            self.fevents.removeAll()
            for ev in events {
                let diff = 7*24*3600 - Int(Date().timeIntervalSince1970 - ev.time().timeIntervalSince1970)
                if diff < 0{
                    continue
                }
                if ev.creator.id == me.id {
                    self.events.append(ev)
                    self.fevents.append(ev)
                    continue
                }
                for mem in ev.members {
                    if mem.id == me.id {
                        self.events.append(ev)
                        self.fevents.append(ev)
                        continue
                    }
                }
            }
            //self.events = events
            //self.fevents = events
            self.searchBar.text = ""
            self.tableView.reloadData()
            self.loadLastMsg()
        }
    }
    func loadLastMsg() {
        database.child("last_history").observe(
            .childChanged,
            with: { dataSnapshot in
                if dataSnapshot.value != nil {
                    let dict = dataSnapshot.value as? [String:Any] ?? [:]
                    let lMsg = LastMessage(dict: dict)
                    for oneEv in self.events {
                        let x:Int? = Int(dataSnapshot.key)
                        if x != nil && oneEv.id == x {
                            self.last_msgs[oneEv.id] = lMsg
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        )
        database.child("last_history").observe(
            .childAdded,
            with: { dataSnapshot in
                if dataSnapshot.value != nil {
                    let dict = dataSnapshot.value as? [String:Any] ?? [:]
                    let lMsg = LastMessage(dict: dict)
                    for oneEv in self.events {
                        let x:Int? = Int(dataSnapshot.key)
                        if x != nil && oneEv.id == x {
                            self.last_msgs[oneEv.id] = lMsg
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        )
        
    }
    func loadHangouts() {
        APIManager.hangouts(user_id: me.id) { (hangouts) in
            self.hangouts = hangouts
            self.fhangouts = hangouts
            self.searchBar.text = ""
            self.tableView.reloadData()
        }
    }
    func addTestData() {
        loadEvents()
        for _ in 0...20 {
            let h = Hangout()
            h.name = "test"
            
            let n = arc4random_uniform(3)
            switch n {
            case 0:
                h.type = "heart"
            case 1:
                h.type = "hangout"
            case 2:
                h.type = "poop"
            default:
                h.type = "heart"
            }
            h.count = Int(arc4random_uniform(30))
            
            hangouts.append(h)
        }
        fhangouts = hangouts
        searchBar.text = ""
    }
    @IBAction func onGroupChat(_ sender: ColorCheckBox) {
        btnHangout.isChecked = !sender.isChecked
        self.tableView.reloadData()
    }
    @IBAction func onHangout(_ sender: ColorCheckBox) {
        btnGroupChat.isChecked = !sender.isChecked
        self.tableView.reloadData()
    }
    func cellForGroupChat(_ index: Int) -> UITableViewCell {
        var cell:UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "GroupChatCell")
        }
        
        let event = fevents[index]
        
        let lbMon = cell.viewWithTag(11) as! UILabel
        let lbDay = cell.viewWithTag(12) as! UILabel
        let lbWeekday = cell.viewWithTag(13) as! UILabel
        let lbTitle = cell.viewWithTag(20) as! UILabel
        let lbMsg = cell.viewWithTag(30) as! UILabel
        let vPhotos = cell.viewWithTag(40)!
        let lbLeft = cell.viewWithTag(50) as! UILabel
        let ivBadge = cell.viewWithTag(60) as! UIImageView
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        lbMon.text = formatter.string(from: event.time())
        formatter.dateFormat = "dd"
        lbDay.text = formatter.string(from: event.time())
        formatter.dateFormat = "E"
        lbWeekday.text = formatter.string(from: event.time())
        lbTitle.text = event.title
        
        lbMsg.text = ""
        ivBadge.isHidden = true
        if let msg = last_msgs[event.id] {
            lbMsg.text = msg.msg
            if !msg.likes.contains("\(me.id)") {
                ivBadge.isHidden = false
            }
        }
        
        // left time string
        let diff = 7*24*3600 - Int(Date().timeIntervalSince1970 - event.time().timeIntervalSince1970)
        if diff < 3600 {
            lbLeft.text = "\(diff/60) minutes left"
        }else if diff < 24*3600 {
            lbLeft.text = "\(diff/3600) hours left"
        }else{
            lbLeft.text = "\(diff/3600/24) days left"
        }
        
        // photos
        var n = event.members.count
        if n > 4 { n = 4 }
        var x:CGFloat = 0
        let y = vPhotos.frame.height / 2
        for i in 0...n {
            var user:FUser!
            if i==0 { user = event.creator } else { user = event.members[i-1] }
            var size:CGFloat = 24; if i==0 { size = 30 }
            let photo = PhotoButton(frame: CGRect(x: x, y: y-size*0.66, width: size, height: size))
            photo.sd_setImage(with: URL(string: user.photo_url), for: .normal, completed: nil)
            vPhotos.addSubview(photo)
            
            x += size/2
        }
        return cell
    }
    func cellForHangout(_ index: Int) -> UITableViewCell {
        var cell:UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "HangoutCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "HangoutCell")
        }
        
        let hangout = fhangouts[index]
        let btnPhoto = cell.viewWithTag(10) as! PhotoButton
        let lbName = cell.viewWithTag(20) as! UILabel
        
        if hangout.photo_url != "" { btnPhoto.sd_setImage(with: URL(string: hangout.photo_url), for: .normal, completed: nil) }
        lbName.text = hangout.name
        
        for view in cell.subviews {
            if view.tag == 100 {
                view.removeFromSuperview()
            }
        }
        
        // icons
        var n = hangout.count / 3
        let m = hangout.count % 3
        if n > 5 { n = 5 }
        
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        
        var x = self.view.frame.width - 20 // cell.frame.width - 20
        let y = cell.frame.height / 2
        
        if m != 0 {
            let str = "\(hangout.type)_\(m)"
            let iv = UIImageView(image: UIImage(named: str))
            iv.tag = 100
            iv.sizeToFit()
            let w = iv.frame.width
            let h = iv.frame.height
            iv.frame = CGRect(x: x-w, y: y-h/2, width: w, height: h)
            cell.addSubview(iv)
            
            x -= w + 8
        }
        for _ in 0 ..< n {
            let str = "\(hangout.type)_full"
            let iv = UIImageView(image: UIImage(named: str))
            iv.tag = 100
            iv.sizeToFit()
            let w = iv.frame.width
            let h = iv.frame.height
            iv.frame = CGRect(x: x-w, y: y-h/2, width: w, height: h)
            cell.addSubview(iv)
            
            x -= w + 8
        }
        
        return cell
    }
}
extension GroupHangoutVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fevents.removeAll()
        fhangouts.removeAll()
        if(searchText.count > 0){
            for event in events {
                if event.title.lowercased().contains(searchText.lowercased()) {
                    fevents.append(event)
                }
            }
            for hangout in hangouts {
                if hangout.name.lowercased().contains(searchText.lowercased()) {
                    fhangouts.append(hangout)
                }
            }
        } else{
            fevents.append(contentsOf: events)
            fhangouts.append(contentsOf: hangouts)
        }
        self.tableView.reloadData()
    }
}
extension GroupHangoutVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        if btnGroupChat.isChecked {
            height = 80
        }
        if btnHangout.isChecked {
            height = 50
        }
        return height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if btnGroupChat.isChecked {
            count = fevents.count
        }
        if btnHangout.isChecked {
            count = fhangouts.count
        }
        return count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if btnGroupChat.isChecked {
            cell = cellForGroupChat(indexPath.row)
        }
        if btnHangout.isChecked {
            cell = cellForHangout(indexPath.row)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if btnGroupChat.isChecked {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GroupChatVC") as! GroupChatVC
            vc.event = fevents[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if btnHangout.isChecked {
            
        }
    }
}
