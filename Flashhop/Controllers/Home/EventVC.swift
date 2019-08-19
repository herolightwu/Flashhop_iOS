//
//  EventVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/31.
//

import UIKit
import GoogleMaps
import MBCircularProgressBar

class EventVC: UIViewController {
    
    public var event:Event!
    
    @IBOutlet weak var ivCoverPhoto: UIImageView!
    @IBOutlet weak var btnInvite: RoundButton!
    @IBOutlet weak var btnAction: RoundButton!
    @IBOutlet weak var btnGroupChat: RoundButton!
    @IBOutlet weak var btnHoppers: RoundButton!
    @IBOutlet weak var constraintDetailBegin: NSLayoutConstraint!
    @IBOutlet weak var lbMon: UILabel!
    @IBOutlet weak var lbDay: UILabel!
    @IBOutlet weak var lbWeekday: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbDetails: UILabel!
    @IBOutlet weak var vPhotos: UIView!
    @IBOutlet weak var lbDesc: UILabel!
    @IBOutlet weak var vChart: UIView!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var progFemale: MBCircularProgressBarView!
    @IBOutlet weak var progMale: MBCircularProgressBarView!
    @IBOutlet weak var progOther: MBCircularProgressBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapAddress))
        lbAddress.isUserInteractionEnabled = true
        lbAddress.addGestureRecognizer(tap)
        refresh()
    }
    
    @objc func onTapAddress(sender:UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.bMoveCenter = true
        vc.center_location = CLLocationCoordinate2D(latitude: event.lat, longitude: event.lng)
        //present(vc, animated: false, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func refresh() {
        // cover image
        if event.cover_photo == "" { ivCoverPhoto.image = event.category.cover_image }
        else { ivCoverPhoto.sd_setImage(with: URL(string: event.cover_photo), completed: nil) }
        
        // invite button
        btnInvite.isHidden = !event.can_invite_friend_by(me)
        
        // action button
        switch action_type() {
        case 1:// creator, edit
            btnAction.setTitle("Edit", for: .normal)
            btnAction.bgColor = .yellow
            btnAction.fontColor = .dark
        case 2: // member, joining
            btnAction.setTitle("Joining", for: .normal)
            btnAction.bgColor = .dark
            btnAction.fontColor = .yellow
        case 3: // full
            btnAction.setTitle("Full", for: .normal)
            btnAction.bgColor = .light
            btnAction.fontColor = .white
        case 4: // age limit
            btnAction.setTitle("Join", for: .normal)
            btnAction.bgColor = .light
            btnAction.fontColor = .white
        case 5: // free to join
            btnAction.setTitle("Join", for: .normal)
            btnAction.bgColor = .yellow
            btnAction.fontColor = .dark
        case 6: // pay to join
            btnAction.setTitle("Pay to Join", for: .normal)
            btnAction.bgColor = .yellow
            btnAction.fontColor = .dark
        default:
            print("invalid event action type")
        }
        
        if action_type() == 1 || action_type() == 2 {   // Group Chat, Hoppers are available
            btnGroupChat.isHidden = false
            btnHoppers.isHidden = false
            constraintDetailBegin.constant = 84
            self.view.layoutSubviews()
        }else{
            btnGroupChat.isHidden = true
            btnHoppers.isHidden = true
            constraintDetailBegin.constant = 30
            self.view.layoutSubviews()
        }
        
        // hoppper button
        if is_available_hoppers() {
            btnHoppers.bgColor = .yellow
            btnHoppers.fontColor = .dark
        }else{
            btnHoppers.bgColor = .light
            btnHoppers.fontColor = .white
        }
        
        // like,
        if event.is_liked_by_you == 1 { btnLike.setImage(UIImage(named: "heart"), for: .normal) }
        else { btnLike.setImage(UIImage(named: "heart_blank"), for: .normal) }
        
        // Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        lbMon.text = formatter.string(from: event.time())
        formatter.dateFormat = "dd"
        lbDay.text = formatter.string(from: event.time())
        formatter.dateFormat = "E"
        lbWeekday.text = formatter.string(from: event.time())
        
        // Title
        lbTitle.text = event.title
        
        // time
        lbTime.text = event.start_end()
        
        // address
        lbAddress.text = event.address
        //lbAddress.layoutIfNeeded()
        //lbAddress.sizeToFit()
        
        // details
        var strDetails = ""
        strDetails = "Min \(event.min_members), Max \(event.max_members), \(event.members.count + 1) are going, \(event.friends().count) friends"
        lbDetails.text = strDetails
        
        // photos
        vPhotos.subviews.forEach({ $0.removeFromSuperview() })
        var n = event.members.count
        if n > 10 { n = 10 }
        var x:CGFloat = 0
        let y = vPhotos.frame.height / 2
        for i in 0...n {
            var user:FUser!
            if i==0 { user = event.creator } else { user = event.members[i-1] }
            var size:CGFloat = 30; if i==0 { size = 40 }
            let photo = PhotoButton(frame: CGRect(x: x, y: y-size/2, width: size, height: size))
            photo.sd_setImage(with: URL(string: user.photo_url), for: .normal, completed: nil)
            vPhotos.addSubview(photo)
            
            x += size/2
        }
        
        // description
        lbDesc.text = event.desc
        
        // chart
        if event.members.count == 0 || action_type() != 1 {
            vChart.isHidden = true
        } else {
            vChart.isHidden = false
            var male = 0
            var female = 0
            var co = 0
            for one in event.members {
                if one.gender == .male {
                    male = male + 1
                } else if one.gender == .female {
                    female = female + 1
                } else {
                    co = co + 1
                }
            }
            if event.creator.gender == .female {
                female = female + 1
            } else if event.creator.gender == .male {
                male = male + 1
            } else {
                co = co + 1
            }
            let pMale = Double(male * 100) / Double(event.members.count + 1)
            let pFemale = Double(female * 100) / Double(event.members.count + 1)
            let pCo = Double(co * 100) / Double(event.members.count + 1)
            
            UIView.animate(withDuration: 1.0, animations: {
                self.progFemale.progressRotationAngle = 38
                self.progFemale.value = CGFloat(max(0, pFemale - 3))

                self.progOther.progressRotationAngle = CGFloat(38 + pFemale)
                self.progOther.value = CGFloat(max(0, pCo - 3))
                
                self.progMale.progressRotationAngle = CGFloat(38 + pFemale + pCo)
                self.progMale.value = CGFloat(max(0, pMale - 3))
            })
            
            
            lblFemale.text = "\(female)"
            lblMale.text = "\(male)"
        }
        
        self.view.layoutSubviews()
    }
    func action_type() -> Int {
        if event.is_creator(me) { return 1 }    // creator, edit
        if event.is_member(me) { return 2 } // member, joining
        if event.is_full() { return 3 } // full
        if me.age() < event.min_age || event.max_age < me.age() { return 4 }    // age limit
        if event.price == 0 { return 5 }    // free
        return 6    // pay to join
    }
    func is_available_hoppers() -> Bool {
        let now = Date().timeIntervalSince1970
        let start = event.time().timeIntervalSince1970
        if now+30*60 > start {
            return true
        }else{
            return false
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func onInvite(_ sender: RoundButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChooseFriendsVC") as! ChooseFriendsVC        
        vc.modalPresentationStyle = .overCurrentContext
        vc.callback = { friends in
            
        }
        self.navigationController?.parent?.present(vc, animated: false, completion: nil)
    }
    func showPaymentVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentDetailVC") as! PaymentDetailVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
    func showPayConfirmVC() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PayConfirmVC") as! PayConfirmVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.event = event
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
    @IBAction func onAction(_ sender: RoundButton) {
        switch action_type() {
        case 1: // creator, edit
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditEventVC") as! EditEventVC
            vc.status = .EDIT
            vc.event = self.event
            self.navigationController?.pushViewController(vc, animated: true)
        case 2: // member, joining
            AlertVC.showLeaveEvent(parent: self.navigationController?.parent) {
                APIManager.leaveEvent(event_id: self.event.id, result: { (value) in
                    let dic = value["data"] as! [String:AnyObject]
                    self.event = Event(dic: dic)
                    self.refresh()
                }, error: { (error) in
                    print(error)
                })
            }
        case 3: // full
            let str = "This event has reached maximum number of people"
            showTip(text: str, parent: sender)
        case 4: // age limit
            let str = "Oops, you are not within the age range to attend this event."
            showTip(text: str, parent: sender)
        case 5: // free
            APIManager.joinEvent(event_id: event.id, is_invited: false, result: { (value) in
                let eventDic = value["data"] as! [String:AnyObject]
                self.event = Event(dic: eventDic)
                self.refresh()
            }) { (error) in
                print(error)
            }
        case 6: // pay to join
            if event.is_pay_later == 1 {
                showPayConfirmVC()
            } else {
                showPaymentVC()
            }
            break
        default:
            print("invalid action type")
        }
    }
    @IBAction func onGroupChat(_ sender: RoundButton) {
        let storyboard = UIStoryboard.init(name: "Chat", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupChatVC") as! GroupChatVC
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onWhereAreMyHoppers(_ sender: RoundButton) {
        if is_available_hoppers() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HoppersVC") as! HoppersVC
            vc.event = self.event
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let str = "Location pins will unlock 30 minutes prior to the event"
            showTip(text: str, parent: sender)
        }
    }
    @IBAction func onLike(_ sender: UIButton) {
        var is_liked = 0
        if event.is_liked_by_you == 1 {
            is_liked = -1
        }else{
            is_liked = 1
        }
        APIManager.eventLikeDislike(event_id: event.id, is_liked: is_liked, result: { (value) in
            self.event.is_liked_by_you = is_liked
            self.refresh()
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func onShare(_ sender: Any) {
        let title = event.title as AnyObject
        let desc = event.desc as AnyObject
        let image = ivCoverPhoto.image as AnyObject
        let sharedObjects:[AnyObject] = [title, image, desc]
        let vc = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.navigationController?.parent?.view
        
        vc.excludedActivityTypes = []
        self.navigationController?.parent?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onGroupInfo(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupInfoVC") as! GroupInfoVC
        vc.event = event
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventVC: GroupInfoVCDelegate {
    func leaveGroup(event: Event) {
        self.event = event
        refresh()
    }
}

extension EventVC: PaymentDetailDelegate {
    func onTapNext(card:Card) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as! CardDetailVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.event = event
        vc.myCard = card
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
}

extension EventVC: CardDetailDelegate {
    func onTapPay() {
        APIManager.joinEvent(event_id: event.id, is_invited: false, result: { (value) in
            let eventDic = value["data"] as! [String:AnyObject]
            self.event = Event(dic: eventDic)
            self.refresh()
        }) { (error) in
            print(error)
        }
    }
}

extension EventVC: PayConfirmDelegate {
    func onTapLater() {
        APIManager.joinEvent(event_id: event.id, is_invited: false, result: { (value) in
            let eventDic = value["data"] as! [String:AnyObject]
            self.event = Event(dic: eventDic)
            self.refresh()
        }) { (error) in
            print(error)
        }
    }
    
    func onTapContinue() {
        self.showPaymentVC()
    }
}
