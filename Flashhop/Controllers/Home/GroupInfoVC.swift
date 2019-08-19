//
//  GroupInfoVC.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/10/31.
//

import UIKit

protocol GroupInfoVCDelegate {
    func leaveGroup(event: Event)
}

class GroupInfoVC: UIViewController {

    @IBOutlet weak var lblHopper: UILabel!
    @IBOutlet weak var lblRemain: UILabel!
    @IBOutlet weak var imgMute: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var btnLeaveGroup: UIButton!
    @IBOutlet weak var constReportTop: NSLayoutConstraint!
    
    public var event: Event!
    
    var hoppers:[Hopper] = []
    var mute: Bool = false
    
    var viewAll = false
    var myEvent = false
    var freeEvent = false
    var delegate: GroupInfoVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        lblHopper.text = "\(event.members.count + 1) Hoppers"
        // left time string
        let diff = 7*24*3600 - (Int(Date().timeIntervalSince1970 - event.time().timeIntervalSince1970))
        if diff < 3600 {
            lblRemain.text = "This group will dismiss in \(diff/60) minutes."
        } else if diff < 24*3600 {
            lblRemain.text = "This group will dismiss in \(diff/3600) hours."
        } else {
            lblRemain.text = "This group will dismiss in \(diff/3600/24) days."
        }
        if event.creator.id == me.id {
            btnLeaveGroup.isHidden = true
            constReportTop.constant = 30
        } else {
            btnLeaveGroup.isHidden = false
            constReportTop.constant = 95
        }
        
        myEvent = (event.creator.id == me.id)
        freeEvent = (event.price == 0)
        
        loadHoppers()
    }
    
    func initData() {
        mute = false
        hoppers.removeAll()
        let creator = Hopper()
        creator.uid = event.creator.id
        creator.name = event.creator.first_name
        creator.avatar = event.creator.photo_url
        hoppers.append(creator)
        for member in event.members {
            let one = Hopper()
            one.uid = member.id
            one.name = member.first_name
            one.avatar = member.photo_url
            hoppers.append(one)
        }
        constCollectionHeight.constant = CGFloat((hoppers.count + 1) / 2 * 50)
        collectionView.reloadData()
    }
    
    func loadHoppers() {
        APIManager.readEvent(event_id: "\(event.id)", callback: {(mute, hoppers) in
            self.hoppers = hoppers
            self.mute = (mute == 0)
            if self.mute {
                self.imgMute.image = UIImage(named: "switch_off")
            } else {
                self.imgMute.image = UIImage(named: "switch_on")
            }
            self.constCollectionHeight.constant = CGFloat((hoppers.count + 1) / 2 * 50)
            self.collectionView.reloadData()
        })
    }
    
    @IBAction func onTapLeaveGroup(_ sender: Any) {
        APIManager.leaveEvent(event_id: self.event.id, result: { (value) in
            let dic = value["data"] as! [String:AnyObject]
            self.event = Event(dic: dic)
            self.navigationController?.popViewController(animated: true)
            if self.delegate != nil {
                self.delegate.leaveGroup(event: self.event)
            }
        }, error: { (error) in
            print(error)
        })
    }
    
    @IBAction func onTapReport(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
        vc.report_id = me.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapMuteGroupNotification(_ sender: Any) {
        APIManager.chatMuteEvent(event_id: "\(event!.id)", is_muted: (mute ? "1" : "0"), callback: { result in
            if result {
                self.mute = !self.mute
                if self.mute {
                    self.imgMute.image = UIImage(named: "switch_off")
                } else {
                    self.imgMute.image = UIImage(named: "switch_on")
                }
            }
        })
    }
    
    func updatePaidStatus(hopper: Hopper, index: Int) {
        var nPaid = 0;
        if hopper.nPaid == 0 {
            nPaid = 1
        }
        APIManager.updatePaidStatus(
            user_id: "\(hopper.uid)",
            event_id: "\(event.id)",
            paid: "\(nPaid)",
            is_offline_paid: "1", result: { value in
                self.hoppers[index].nOffline = 1
                self.loadHoppers()
        }, error: { error in
            print(error)
        })
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GroupInfoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width / 2 - 10
        return CGSize(width: width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewAll {
            return hoppers.count
        }
        return self.hoppers.count > 9 ? 10 : self.hoppers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupMemberCell", for: indexPath)
        let btnPhoto = cell.viewWithTag(10) as! PhotoButton
        let lblName = cell.viewWithTag(20) as! UILabel
        let imgCheck = cell.viewWithTag(30) as! UIImageView
        let imgCard = cell.viewWithTag(40) as! UIImageView
        
        let hopper = hoppers[indexPath.row]
        btnPhoto.sd_setImage(with: URL(string: hopper.avatar), for: .normal, completed: nil)
        lblName.text = hopper.name
        imgCard.image = UIImage(named: "ic_checked_card")
        
        if viewAll == false && indexPath.row == 9 {
            cell.contentView.isHidden = true
            lblName.text = "View all"
        } else {
            cell.contentView.isHidden = false
            if freeEvent {
                imgCard.isHidden = true
                imgCheck.isHidden = true
            } else {
                if hopper.nPaid == 1 {
                    if hopper.nOffline == 0 {
                        lblName.textColor = UIColor(rgb: 0x808080)
                    } else {
                        lblName.textColor = UIColor(rgb: 0x363C5A)
                    }
                    if myEvent {
                        imgCard.isHidden = false
                        imgCheck.isHidden = true
                    } else {
                        imgCard.isHidden = true
                        imgCheck.isHidden = false
                        imgCheck.image = UIImage(named: "ic_checked")
                    }
                } else {
                    lblName.textColor = UIColor(rgb: 0x363C5A)
                    if myEvent {
                        imgCard.isHidden = true
                        imgCheck.isHidden = false
                        imgCheck.image = UIImage(named: "ic_unchecked")
                    } else {
                        imgCard.isHidden = true
                        imgCheck.isHidden = true
                    }
                }
            }
            if hopper.uid == hoppers[0].uid {
                lblName.textColor = UIColor(rgb: 0x808080)
                imgCard.isHidden = true
                imgCheck.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewAll == false && indexPath.row == 9 {
            viewAll = true
            self.collectionView.reloadData()
        } else {
            let hopper = hoppers[indexPath.row]
            if event.creator.id == me.id &&
                event.price > 0 &&
                hopper.uid != me.id &&
                (hopper.nOffline == 0 && hopper.nPaid == 1) == false {
                updatePaidStatus(hopper: hopper, index: indexPath.row)
            }
        }
    }
}
