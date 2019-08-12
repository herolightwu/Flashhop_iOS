//
//  MainVC.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/15.
//

import UIKit
import OneSignal

class MainVC: UITabBarController {
    
    @IBOutlet weak var myTabbar: UITabBar!
    
    var myTabController : UITabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTabController = self
        NotificationCenter.default.addObserver(self, selector: #selector(onOpenChatTab(_:)), name: .openChat, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onOpenWhatsupTab(_:)), name: .openWhatsup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveChat(_:)), name: .receiveChat, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveWhatsup(_:)), name: .receiveWhatsup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveLiked(_:)), name: .receiveLiked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDisliked(_:)), name: .receiveDisliked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveMetoo(_:)), name: .receiveMetoo, object: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Chat" {
            item.image = UIImage(named: "chat_n")?.withRenderingMode(.alwaysOriginal)
        }
        if item.title == "What's up" {
            item.image = UIImage(named: "whatsup_n")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    @objc func onOpenChatTab(_ notification:Notification){
        if myTabController != nil {
            myTabController.selectedIndex = 2
            let chat_item = myTabbar.items![2] as UITabBarItem
            chat_item.image = UIImage(named: "chat_n")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    @objc func onOpenWhatsupTab(_ notification:Notification){
        if myTabController != nil {
            myTabController.selectedIndex = 3
            let chat_item = myTabbar.items![3] as UITabBarItem
            chat_item.image = UIImage(named: "whatsup_n")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    @objc func onReceiveChat(_ notification:Notification){
        let sel_item = myTabbar.selectedItem
        if sel_item?.title != "Chat" {
            let chat_item = myTabbar.items![2] as UITabBarItem
            chat_item.image = UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    @objc func onReceiveWhatsup(_ notification:Notification){
        let sel_item = myTabbar.selectedItem
        if sel_item?.title != "What's up" {
            let chat_item = myTabbar.items![3] as UITabBarItem
            chat_item.image = UIImage(named: "whatsup")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    @objc func onReceiveLiked(_ notification:Notification){
        let noti_obj = notification.userInfo as! [String:String]
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SuperLikeVC") as! SuperLikeVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.avater_url = noti_obj["sender_avatar"]
        vc.username = noti_obj["sender_name"]
        vc.what_id = noti_obj["whatsup_id"]
        self.navigationController?.parent?.present(vc, animated: false, completion: nil)
    }
    
    @objc func onReceiveDisliked(_ notification:Notification){
        let noti_obj = notification.userInfo as! [String:String]
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SuperDissVC") as! SuperDissVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.avater_url = noti_obj["sender_avatar"]
        vc.username = noti_obj["sender_name"]
        vc.what_id = noti_obj["whatsup_id"]
        self.navigationController?.parent?.present(vc, animated: false, completion: nil)
    }
    
    @objc func onReceiveMetoo(_ notification:Notification){
        let noti_obj = notification.userInfo as! [String:String]
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SweetDlgVC") as! SweetDlgVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.username = noti_obj["sender_name"]
        self.navigationController?.parent?.present(vc, animated: false, completion: nil)
    }
}
