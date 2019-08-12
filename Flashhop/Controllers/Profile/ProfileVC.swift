//
//  ProfileVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/3.
//

import UIKit
import AMPopTip
import Photos

class ProfileVC: UIViewController {
        
    enum Status {
        case SHOW
        case PREVIEW
        case INVITE
    }
    public var status: Status = .SHOW
    public var my_events:[Event] = []   // for only invite status
    
    public var user:FUser!
    public var photos:[PHAsset] = []
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var btnPhoto: PhotoButton!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var btnAddFriend: UIButton!
    @IBOutlet weak var lbFriends: UILabel!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var photosView: PhotosView!
    @IBOutlet weak var lbAge: UILabel!
    @IBOutlet weak var lbOrganized: UILabel!
    @IBOutlet weak var lbPersonality: UILabel!
    @IBOutlet weak var vTags: UIView!
    @IBOutlet weak var tvFunFacts: UITextView!
    @IBOutlet weak var btnTips: UIButton!
    @IBOutlet weak var btnAction: RoundButton!
    @IBOutlet weak var btnLike: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvFunFacts.textContainerInset = .zero
        tvFunFacts.textContainer.lineFragmentPadding = 0
        
        refresh()
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func refresh() {
        // photo
        if user.photo_url != "" { btnPhoto.sd_setImage(with: URL(string: user.photo_url), for: .normal, completed: nil) }
        
        // name
        lbName.text = user.full_name()
        
        //age
        lbAge.text = "\(user.age())"
        if user.hide_my_age {
            lbAge.text = "Secret"
        }
        
        // Organized
        lbOrganized.text = "\(user.event_count) events"
        
        // tags
        showTags()
        
        // personality
        lbPersonality.text = user.personality_type
        
        // fun facts
        tvFunFacts.text = user.fun_facts
        
        // status
        switch status {
        case .SHOW:
            checkDebit()
            btnAction.setTitle("Edit", for: .normal)
            
            //images
            photosView.set_photos(urls: user.images)
            
            // money pack tip, only at first
            let flag = UserDefaults.standard.bool(forKey: "MONEY_PACK_TIP")
            if flag == false {
                let str = "Update your profile pictures and personal information."
                showTip(text: str, parent: btnTips)
                UserDefaults.standard.set(true, forKey: "MONEY_PACK_TIP")
            }
            
            btnAddFriend.isHidden = true
            lbFriends.isHidden = true
            btnLike.isHidden = true
        case .PREVIEW:
            btnAction.setTitle("Publish", for: .normal)
            if photos.count != 0 { self.photosView.set_photos(photos: photos) }
            else{
                photosView.set_photos(urls: user.images)
            }
            btnAddFriend.isHidden = true
            lbFriends.isHidden = true
            btnLike.isHidden = true
        case .INVITE:
            btnBack.isHidden = true
            lbTitle.isHidden = true
            
            photosView.set_photos(urls: user.images)
            
            constraintTop.constant = 30 // remove top space
            self.view.layoutSubviews()
            
            btnSettings.setImage(UIImage(named: "menu"), for: .normal)
            btnAction.setTitle("Invite", for: .normal)
            
            if user.is_my_friend == 1 {
                btnAddFriend.isHidden = true
                lbFriends.text = "Friends"
            } else if user.is_my_friend == 0 {
                lbFriends.isHidden = true
                btnLike.isHidden = true
            } else{
                btnAddFriend.isHidden = true
                lbFriends.text = "Waiting For Approval"
            }
            let like_title = "What should I do if I like " + user.first_name + "?"
            let title_range = NSMakeRange(0, like_title.count)
            let like_Attr_title = NSMutableAttributedString(string: like_title)
            like_Attr_title.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: title_range)
            like_Attr_title.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], range: title_range)
            btnLike.setAttributedTitle(like_Attr_title, for: .normal)
            if user.is_liked != 0 || !user.is_friendable {
                btnLike.isHidden = true
            }
        }
    }
    func checkDebit() {
        APIManager.getDebitCheck(user_id: me.id, callback: { cards in
            if cards.count > 0 {
                me.is_debit = 1
            } else {
                me.is_debit = 0
            }
        })
    }
    @IBAction func onSettings(_ sender: Any) {
        if status == .INVITE {
            if user.is_my_friend == 1 {
                AlertVC.dotMenu(parent: self.navigationController?.parent, unfriend: {
                    APIManager.removeFromMyFriend(friend_id: self.user.id, result: { (value) in
                        self.user.is_my_friend = 0
                        self.refresh()
                    }, error: { (error) in
                        print(error)
                    })
                }) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                    vc.report_id = self.user.id
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else{  // show, preview
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    @IBAction func onAction(_ sender: Any) {
        switch status {
        case .SHOW: // edit button,
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
            vc.user = user
            vc.preview = { (user, photos) in
                self.user = user
                self.photos = photos
                self.status = .PREVIEW
                self.refresh()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .PREVIEW:
            APIManager.updateUserProfile(photos: photos, user: user, result: { (value) in
                me = FUser(dic: value["data"] as! [String : AnyObject])
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                print(error)
            }
        case .INVITE:
            var events:[Event] = []
            for event in my_events { if !event.is_member(user) { events.append(event) } }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChooseEventVC") as! ChooseEventVC
            vc.title = "Invite \(user.full_name()) to my events"
            vc.events = events
            vc.callback = { event in
                APIManager.inviteFriends(user_ids: [self.user.id], event_id: event.id, result: { (value) in
                    // invited
                }, error: { (error) in
                    print(error)
                })
            }
            vc.modalPresentationStyle = .overCurrentContext
            self.navigationController?.parent?.present(vc, animated: false, completion: nil)
        }
    }
    @IBAction func onTapLike(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LikeFriendVC") as! LikeFriendVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.other = self.user
        self.navigationController?.parent?.present(vc, animated: false, completion: nil)
    }
    @IBAction func onWhatsThis(_ sender: UIButton) {
        let str = "We recommend you to take the test before selecting"
        showLinkTip(text: str, parent: sender)
    }
    @IBAction func onTips(_ sender: UIButton) {
        if status != .INVITE {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TipsVC")
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            if user.is_friendable {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GiveTipVC") as! GiveTipVC
                vc.user = self.user
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @IBAction func onAddFriend(_ sender: UIButton) {
        if user.is_friendable {
            APIManager.addFriend(user_id: user.id, result: { (value) in
                //self.user.is_my_friend = true
                self.refresh()
            }) { (error) in
                print(error)
            }
        }else{
            let str = "Sorry, you need to hangout with \(user.full_name()) first by joining the same event."
            showTip(text: str, parent: sender)
        }
    }
    func showTags() {
        vTags.setNeedsLayout()
        vTags.layoutIfNeeded()
        
        vTags.subviews.forEach({
            if $0.tag != 100 { $0.removeFromSuperview() }
        })
        
        var tags:[String] = []
        var len = user.tags.count
        if len > 3 { len = 3 }
        for i in 0..<len {
            tags.append(user.tags[i])
        }
        
        let x0:CGFloat = 120
        var x:CGFloat = x0
        var y:CGFloat = 0
        let sp:CGFloat = 8
        
        // add tag button
        if status == .INVITE {
            let button = UIButton(frame: CGRect(x: x, y: y, width: 500, height: 100))
            button.setTitle("+Tag the hopper", for: .normal)
            button.setTitleColor(.dark, for: .normal)
            button.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 12)
            button.sizeToFit()
            button.addTarget(self, action: #selector(ProfileVC.addTag(_:)), for: .touchUpInside)
            
            let w = button.frame.width + sp + sp
            let h = button.frame.height// + sp
            
            /*
            if x+w+sp > vTags.frame.size.width {
                x = x0
                y += h + sp
                button.frame = CGRect(x: x, y: y, width: w, height: h)   // move to next line
            }else{
                button.frame = CGRect(x: x, y: y, width: w, height: h)   // resize
            }*/
            button.frame = CGRect(x: x, y: y-2, width: w, height: h)   // resize
            x += w+sp
            vTags.addSubview(button)
        }
        
        // show tags
        for str in tags {
            let label = UILabel(frame: CGRect(x: x, y: y, width: 500, height: 100))
            label.font = UIFont(name: "SourceSansPro-Regular", size: 12)
            label.textColor = UIColor(rgb: 0x363C5A)
            label.layer.borderWidth = 2
            label.layer.borderColor = UIColor(rgb: 0xFFD200).cgColor
            label.textAlignment = .center
            label.text = str
            label.sizeToFit()
            
            let w = label.frame.width + sp + sp // make beautiful
            let h = label.frame.height + sp
            label.layer.cornerRadius = h/2
            if x+w+sp > vTags.frame.size.width {
                x = x0
                y += h + sp
                label.frame = CGRect(x: x, y: y, width: w, height: h)   // move to next line
            }else{
                label.frame = CGRect(x: x, y: y, width: w, height: h)   // resize
            }
            x += w+sp
            vTags.addSubview(label)
        }
    }
    @objc func addTag(_ sender: UIButton) {
        if user.is_friendable {
            AlertVC.addTag(parent: self.navigationController?.parent) { (tag) in
                if tag != "" {
                    APIManager.insert_tag(user_id: self.user.id, tag: tag, result: { (value) in
                        self.user.tags.insert(tag, at: 0)
                        self.showTags()
                    }, error: { (error) in
                        print(error)
                    })
                }
            }
        }
    }
}
