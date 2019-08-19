//
//  WhatsUpVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/17.
//

import UIKit

class WhatsUpVC: UIViewController {

    @IBOutlet weak var btnFriend: ColorCheckBox!
    @IBOutlet weak var btnMe: ColorCheckBox!
    @IBOutlet weak var tableView: UITableView!
    var bMeVisible = false
    
    var today_alarms:[Alarm] = []
    var yesterday_alarms:[Alarm] = []
    var last7_alarms:[Alarm] = []
    
    var new_alarms:[Alarm] = []
    var earlier_alarms:[Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveWhatsup(_:)), name: .receiveWhatsup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveLiked(_:)), name: .receiveLiked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDisliked(_:)), name: .receiveDisliked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveMetoo(_:)), name: .receiveMetoo, object: nil)
    }
    
    @objc func onReceiveWhatsup(_ notification:Notification){
        loadFriendsData()
        loadMeData()
    }
    
    @objc func onReceiveLiked(_ notification:Notification){
        loadMeData()
    }
    
    @objc func onReceiveDisliked(_ notification:Notification){
        loadMeData()
    }
    
    @objc func onReceiveMetoo(_ notification:Notification){
        loadMeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadFriendsData()
        loadMeData()
    }
    func loadFriendsData() {
        APIManager.getWhatsUpFriends(user_id: me.id) { (today_alarms, yesterday_alarms, last7_alarms) in
            self.today_alarms = today_alarms
            self.yesterday_alarms = yesterday_alarms
            self.last7_alarms = last7_alarms
            self.tableView.reloadData()
        }
    }
    func loadMeData() {
        APIManager.getWhatsUpForMe(user_id: me.id) { (new_alarms, earlier_alarms) in
            self.new_alarms = new_alarms
            self.earlier_alarms = earlier_alarms
            self.tableView.reloadData()
        }
    }
    @IBAction func onClickFriend(_ sender: ColorCheckBox) {
        btnMe.isChecked = !sender.isChecked
        bMeVisible = false
        tableView.reloadData()
        loadFriendsData()
    }
    @IBAction func onClickMe(_ sender: ColorCheckBox) {
        btnFriend.isChecked = !sender.isChecked
        bMeVisible = true
        tableView.reloadData()
        loadMeData()
    }
    func alarmForCell(_ index: Int) -> Alarm {
        var rIndex = index
        if !bMeVisible {
            if today_alarms.count > 0 {
                if rIndex < today_alarms.count + 1 {
                    if rIndex == 0 {
                        return Alarm(label: "Today")
                    } else {
                        return today_alarms[rIndex-1]
                    }
                }
                rIndex = rIndex - (today_alarms.count + 1)
            }
            if yesterday_alarms.count > 0 {
                if rIndex < yesterday_alarms.count + 1 {
                    if rIndex == 0 {
                        return Alarm(label: "Yesterday")
                    } else {
                        return yesterday_alarms[rIndex-1]
                    }
                }
                rIndex = rIndex - (yesterday_alarms.count + 1)
            }
            if last7_alarms.count > 0 {
                if rIndex < last7_alarms.count + 1 {
                    if rIndex == 0 {
                        return Alarm(label: "Last 7 days")
                    } else {
                        return last7_alarms[rIndex-1]
                    }
                }
                rIndex = rIndex - (last7_alarms.count + 1)
            }
        } else {
            if new_alarms.count > 0 {
                if rIndex < new_alarms.count + 1 {
                    if rIndex == 0 {
                        return Alarm(label: "New")
                    } else {
                        return new_alarms[rIndex-1]
                    }
                }
                rIndex = rIndex - (new_alarms.count + 1)
            }
            if earlier_alarms.count > 0 {
                if rIndex < earlier_alarms.count + 1 {
                    if rIndex == 0 {
                        return Alarm(label: "Earlier")
                    } else {
                        return earlier_alarms[rIndex-1]
                    }
                }
                rIndex = rIndex - (earlier_alarms.count + 1)
            }            
        }
        return Alarm()
    }
    
    func showHopperMap(event: Event) {
        let storyboard = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HoppersVC") as! HoppersVC
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showReeditEvent(event: Event) {
        let storyboard = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditEventVC") as! EditEventVC
        vc.status = .EDIT
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func responseRequestFriend(wid: String, responser: String, requester: String, res: String) {
        APIManager.acceptRejectFriendRequest(whatsup_id: wid, responser_id: responser, requester_id: requester, is_accept: res, result: { result in
            self.loadMeData()
        }, error: { error in
        })
    }
    
    func responseSuperLike(wid: String, res: String) {
        APIManager.responseSuperLike(whatsup_id: wid, reply: res, result: { result in
            self.loadMeData()
        }, error: { error in
        })
    }
    
    func responseSuperDislike(wid: String, res: String) {
        APIManager.responseSuperDiss(whatsup_id: wid, reply: res, result: { result in
            self.loadMeData()
        }, error: { error in
        })
    }
    
    @objc func onActionEvent(_ sender: MyButton) {
        let index = sender.tag2
        let alarm = alarmForCell(index)

        let storyboard = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventVC") as! EventVC
        vc.event = alarm.event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onActionPhoto(_ sender: MyButton) {
        let index = sender.tag2
        let alarm = alarmForCell(index)

        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.user = alarm.user
        if alarm.user?.id == me.id {
            vc.status = .PREVIEW
        } else {
            vc.status = .INVITE
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onAction1(_ sender: RoundButton) {
        let index = sender.tag2
        let alarm = alarmForCell(index)
        
        switch alarm.action {
        case "ping_30mins_event":
            showHopperMap(event: alarm.event!)
        case "ping_less_member":
            showReeditEvent(event: alarm.event!)
        case "requested_friend":
            responseRequestFriend(wid: "\(alarm.wId)", responser: "\(me.id)", requester: "\(alarm.uId)", res: "0")
        case "liked":
            responseSuperLike(wid: "\(alarm.wId)", res: "hello_no")
        case "disliked":
            responseSuperDislike(wid: "\(alarm.wId)", res: "whatever")
        default: break
        }
    }
    @objc func onAction2(_ sender: RoundButton) {
        let index = sender.tag2
        let alarm = alarmForCell(index)
        
        switch alarm.action {
        case "requested_friend":
            responseRequestFriend(wid: "\(alarm.wId)", responser: "\(me.id)", requester: "\(alarm.uId)", res: "1")
        case "liked":
            responseSuperLike(wid: "\(alarm.wId)", res: "not_yet")
        case "disliked":
            responseSuperDislike(wid: "\(alarm.wId)", res: "throw_back")
        default: break
        }
    }
    @objc func onAction3(_ sender: RoundButton) {
        let index = sender.tag2
        let alarm = alarmForCell(index)
        
        switch alarm.action {
        case "liked":
            responseSuperLike(wid: "\(alarm.wId)", res: "me_too")
        default: break
        }
    }
}
extension WhatsUpVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        if !bMeVisible {
            num = (today_alarms.count > 0 ? today_alarms.count + 1 : 0) +
                (yesterday_alarms.count > 0 ? yesterday_alarms.count + 1 : 0) +
                (last7_alarms.count > 0 ? last7_alarms.count + 1 : 0)
        }else{
            num = (new_alarms.count > 0 ? new_alarms.count + 1 : 0) +
                (earlier_alarms.count > 0 ? earlier_alarms.count + 1 : 0)
        }
        return num
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let alarm = alarmForCell(indexPath.row)
        
        if !bMeVisible {
            switch alarm.action {
            case "label":
                cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell")
                let lbTitle = cell.viewWithTag(10) as! UILabel
                lbTitle.text = alarm.desc
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell")
                let btnPhoto = cell.viewWithTag(10) as! PhotoButton
                let lbTitle = cell.viewWithTag(20) as! UILabel
                btnPhoto.sd_setImage(with: URL(string: alarm.photo), for: .normal, completed: nil)
                btnPhoto.tag2 = indexPath.row
                btnPhoto.addTarget(self, action:#selector(onActionPhoto(_:)), for: .touchUpInside)
                
                lbTitle.attributedText = alarm.desc.htmlToAttributedString
            }
        } else{
            switch alarm.action {
            case "label":
                cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell")
                let lbTitle = cell.viewWithTag(10) as! UILabel
                lbTitle.text = alarm.desc
            case "requested_friend":
                cell = tableView.dequeueReusableCell(withIdentifier: "PhotoButtonCell")
                let btnPhoto = cell.viewWithTag(10) as! PhotoButton
                let lbDesc = cell.viewWithTag(20) as! UILabel
                let btn1 = cell.viewWithTag(30) as! RoundButton
                let btn2 = cell.viewWithTag(40) as! RoundButton
                let btn3 = cell.viewWithTag(50) as! RoundButton
                
                makeShadowView(btn1)
                makeShadowView(btn2)
                makeShadowView(btn3)
                
                btnPhoto.sd_setImage(with: URL(string: alarm.photo), for: .normal, completed: nil)
                btnPhoto.tag2 = indexPath.row
                btnPhoto.addTarget(self, action:#selector(onActionPhoto(_:)), for: .touchUpInside)
                
                lbDesc.attributedText = alarm.desc.htmlToAttributedString
                
                btn1.bgColor = .white
                btn1.layer.borderColor = UIColor.dark.cgColor
                btn1.layer.borderWidth = 1
                btn1.setTitle("Decline", for: .normal)
                btn1.tag2 = indexPath.row
                btn1.addTarget(self, action:#selector(onAction1(_:)), for: .touchUpInside)
                
                btn2.setTitle("Accept", for: .normal)
                btn2.tag2 = indexPath.row
                btn2.addTarget(self, action: #selector(onAction2(_:)), for: .touchUpInside)
                
                btn3.isHidden = true
                if alarm.is_checked == 1 {
                    btn1.isHidden = true
                    btn2.isHidden = true
                }
            case "liked":
                cell = tableView.dequeueReusableCell(withIdentifier: "PhotoButtonImageCell")
                let btnPhoto = cell.viewWithTag(10) as! PhotoButton
                let lbDesc = cell.viewWithTag(20) as! UILabel
                let ivIcon = cell.viewWithTag(21) as! UIImageView
                let btn1 = cell.viewWithTag(30) as! RoundButton
                let btn2 = cell.viewWithTag(40) as! RoundButton
                let btn3 = cell.viewWithTag(50) as! RoundButton
                
                btnPhoto.sd_setImage(with: URL(string: alarm.photo), for: .normal, completed: nil)
                btnPhoto.tag2 = indexPath.row
                btnPhoto.addTarget(self, action:#selector(onActionPhoto(_:)), for: .touchUpInside)

                lbDesc.attributedText = alarm.desc.htmlToAttributedString
                ivIcon.image = UIImage(named: "heart_full")
                
                btn1.bgColor = .white
                btn1.layer.borderWidth = 1
                btn1.layer.borderColor = UIColor.dark.cgColor
                btn1.setTitle("Hell no", for: .normal)
                btn1.tag2 = indexPath.row
                btn1.addTarget(self, action: #selector(onAction1(_:)), for: .touchUpInside)
                
                btn2.bgColor = .white
                btn2.layer.borderWidth = 1
                btn2.layer.borderColor = UIColor.dark.cgColor
                btn2.setTitle("Not yet", for: .normal)
                btn2.tag2 = indexPath.row
                btn2.addTarget(self, action: #selector(onAction2(_:)), for: .touchUpInside)
                
                btn3.setTitle("Me too", for: .normal)
                btn3.tag2 = indexPath.row
                btn3.addTarget(self, action: #selector(onAction3(_:)), for: .touchUpInside)
                
                if alarm.is_checked == 1 {
                    btn1.isHidden = true
                    btn2.isHidden = true
                    btn3.isHidden = true
                } else{
                    makeShadowView(btn1)
                    makeShadowView(btn2)
                    makeShadowView(btn3)
                }
            case "disliked":
                cell = tableView.dequeueReusableCell(withIdentifier: "PhotoButtonImageCell")
                let btnPhoto = cell.viewWithTag(10) as! PhotoButton
                let lbDesc = cell.viewWithTag(20) as! UILabel
                let ivIcon = cell.viewWithTag(21) as! UIImageView
                let btn1 = cell.viewWithTag(30) as! RoundButton
                let btn2 = cell.viewWithTag(40) as! RoundButton
                let btn3 = cell.viewWithTag(50) as! RoundButton
                
                btnPhoto.sd_setImage(with: URL(string: alarm.photo), for: .normal, completed: nil)
                btnPhoto.tag2 = indexPath.row
                btnPhoto.addTarget(self, action:#selector(onActionPhoto(_:)), for: .touchUpInside)

                lbDesc.attributedText = alarm.desc.htmlToAttributedString
                ivIcon.image = UIImage(named: "poop_full")
                
                btn1.bgColor = .white
                btn1.layer.borderWidth = 1
                btn1.layer.borderColor = UIColor.dark.cgColor
                btn1.setTitle("Whatever", for: .normal)
                btn1.tag2 = indexPath.row
                btn1.addTarget(self, action: #selector(onAction1(_:)), for: .touchUpInside)
                
                btn2.setTitle("Throw back", for: .normal)
                btn2.tag2 = indexPath.row
                btn2.addTarget(self, action: #selector(onAction2(_:)), for: .touchUpInside)
                
                btn3.isHidden = true
                if alarm.is_checked == 1 {
                    btn1.isHidden = true
                    btn2.isHidden = true
                }
                makeShadowView(btn1)
                makeShadowView(btn2)
            case "ping_2hours_event":
                cell = tableView.dequeueReusableCell(withIdentifier: "EventCell")
                let ivPhoto = cell.viewWithTag(10) as! UIImageView
                let btnPhoto = cell.viewWithTag(11) as! RoundButton
                let lbDesc = cell.viewWithTag(20) as! UILabel
                let btn = cell.viewWithTag(30) as! RoundButton
                
                if alarm.event?.cover_photo == "" {
                    ivPhoto.image = alarm.event?.category.cover_image
                }else{
                    ivPhoto.sd_setImage(with: URL(string: alarm.event!.cover_photo), completed: nil)
                }
                btnPhoto.tag2 = indexPath.row
                btnPhoto.addTarget(self, action:#selector(onActionEvent(_:)), for: .touchUpInside)
                
                lbDesc.attributedText = alarm.desc.htmlToAttributedString
                btn.isHidden = true
            case "ping_30mins_event":
                cell = tableView.dequeueReusableCell(withIdentifier: "EventCell")
                let ivPhoto = cell.viewWithTag(10) as! UIImageView
                let btnPhoto = cell.viewWithTag(11) as! RoundButton
                let lbDesc = cell.viewWithTag(20) as! UILabel
                let btn = cell.viewWithTag(30) as! RoundButton
                
                if alarm.event?.cover_photo == "" {
                    ivPhoto.image = alarm.event?.category.cover_image
                }else{
                    ivPhoto.sd_setImage(with: URL(string: alarm.event!.cover_photo), completed: nil)
                }
                btnPhoto.tag2 = indexPath.row
                btnPhoto.addTarget(self, action:#selector(onActionEvent(_:)), for: .touchUpInside)
                
                lbDesc.attributedText = alarm.desc.htmlToAttributedString
                btn.setTitle("Where are my hopppers", for: .normal)
                btn.tag2 = indexPath.row
                btn.addTarget(self, action: #selector(onAction1(_:)), for: .touchUpInside)
                makeShadowView(btn)
            case "ping_less_member":
                cell = tableView.dequeueReusableCell(withIdentifier: "EventCell")
                let ivPhoto = cell.viewWithTag(10) as! UIImageView
                let btnPhoto = cell.viewWithTag(11) as! RoundButton
                let lbDesc = cell.viewWithTag(20) as! UILabel
                let btn = cell.viewWithTag(30) as! RoundButton
                
                if alarm.event?.cover_photo == "" {
                    ivPhoto.image = alarm.event?.category.cover_image
                }else{
                    ivPhoto.sd_setImage(with: URL(string: alarm.event!.cover_photo), completed: nil)
                }
                btnPhoto.tag2 = indexPath.row
                btnPhoto.addTarget(self, action:#selector(onActionEvent(_:)), for: .touchUpInside)
                
                lbDesc.attributedText = alarm.desc.htmlToAttributedString
                btn.setTitle("Re-edit My Event", for: .normal)
                btn.tag2 = indexPath.row
                btn.addTarget(self, action: #selector(onAction1(_:)), for: .touchUpInside)
                makeShadowView(btn)
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell")
                let btnPhoto = cell.viewWithTag(10) as! PhotoButton
                let lbTitle = cell.viewWithTag(20) as! UILabel
                btnPhoto.sd_setImage(with: URL(string: alarm.photo), for: .normal, completed: nil)
                btnPhoto.tag2 = indexPath.row
                btnPhoto.addTarget(self, action:#selector(onActionPhoto(_:)), for: .touchUpInside)
                
                lbTitle.attributedText = alarm.desc.htmlToAttributedString
            }
        }
        
        return cell
    }
}
