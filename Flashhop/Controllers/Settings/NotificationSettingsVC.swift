//
//  NotificationSettingsVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/2.
//

import UIKit

class NotificationSettingsVC: UIViewController {

    @IBOutlet weak var ivPause: UIImageView!
    @IBOutlet weak var ivMy: UIImageView!
    @IBOutlet weak var ivFriends: UIImageView!
    @IBOutlet weak var ivChats: UIImageView!
    
    var bPause = false
    var bMy = me.push_my_activities
    var bFriends = me.push_friends_activities
    var bChats = me.push_chats
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }
    func refresh() {
        let on = UIImage(named: "switch_on")
        let off = UIImage(named: "switch_off")
        if bPause { ivPause.image = on } else { ivPause.image = off }
        if bMy { ivMy.image = on } else { ivMy.image = off }
        if bFriends { ivFriends.image = on } else { ivFriends.image = off }
        if bChats { ivChats.image = on } else { ivChats.image = off }
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onPauseAll(_ sender: Any) {
        bPause = !bPause
        if bPause {
            bMy = false
            bFriends = false
            bChats = false
        }
        refresh()
    }
    @IBAction func onMyActivities(_ sender: Any) {
        bMy = !bMy
        refresh()
    }
    @IBAction func onFriendsActivities(_ sender: Any) {
        bFriends = !bFriends
        refresh()
    }
    @IBAction func onChats(_ sender: Any) {
        bChats = !bChats
        refresh()
    }
    @IBAction func onSave(_ sender: Any) {
        APIManager.changeNotificationSettings(bMyActivities: bMy, bFriendsActivities: bFriends, bChats: bChats, result: { (value) in
            me = FUser(dic: value["data"] as! [String : AnyObject])
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            print(error)
        }
    }
}
