//
//  Alarm.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/16.
//

import UIKit

class Alarm: NSObject {
    public var action = ""
    public var wId = 0
    public var uId = 0
    public var name = ""
    public var photo = ""
    public var desc = ""
    public var created_at = ""
    public var event:Event?
    public var user:FUser?
    public var is_checked = 0
    
    convenience init(label:String) {
        self.init()
        
        desc = label
        action = "label"
    }
    
    convenience init(friend_dic: [String:AnyObject]) {
        self.init()
        let dic = friend_dic
        
        action = dic["action"] as? String ?? ""
        let actor = dic["actor_data"] as? [String:AnyObject] ?? [:]
        user = FUser(dic: actor)
        uId = actor["id"] as? Int ?? 0
        name = actor["first_name"] as? String ?? ""
        photo = actor["avatar"] as? String ?? ""
        created_at = dic["created_at"] as? String ?? ""
        if action == "pinned" {
            let gen = actor["gender"] as? String ?? ""
            var self_str = "himself"
            if gen == "female" { self_str = "herself" }
            let sAddr = actor["address"] as? String ?? ""
            desc = "<b>\(name)</b> pinned \(self_str) at <b>\(sAddr)</b>."
        } else if action == "tagged" {
            //A tagged B Z,Z
            let whom_obj = dic["whom_data"] as? [String:AnyObject] ?? [:]
            let b_name = whom_obj["first_name"] as? String ?? ""
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            var sTags = data_obj["tags"] as? String ?? ""
            sTags = "#" + sTags;
            sTags = sTags.replacingOccurrences(of: ", #", with: ",")
            desc = "<b>\(name)</b> tagged <b>\(b_name)</b> \(sTags)."
        } else if action == "join_event" {
            //xxx is joining the event yyy.
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            let eTitle = data_obj["event_title"] as? String ?? ""
            desc = "<b>\(name)</b> is joining the event <b>\(eTitle)</b>."
        } else if action == "host_event" {
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            let eTitle = data_obj["event_title"] as? String ?? ""
            desc = "<b>\(name)</b> is hosting a new event <b>\(eTitle)</b>."
        } else if action == "friend_invite" {
            //xxx invited yyy and 3 more people to zzz
            let whom_obj = dic["whom_data"] as? [String:AnyObject] ?? [:]
            let b_name = whom_obj["first_name"] as? String ?? ""
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            let eTitle = data_obj["event_title"] as? String ?? ""
            desc = "<b>\(name)</b> invited \(b_name) to <b>\(eTitle)</b>."
        }
    }
    
    convenience init(me_dic: [String:AnyObject]) {
        self.init()
        
        let dic = me_dic
        action = dic["action"] as? String  ?? ""
        let actor = dic["actor_data"] as? [String:AnyObject] ?? [:]
        user = FUser(dic: actor)
        if action == "requested_friend" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            is_checked = dic["is_checked"] as? Int ?? 0
            desc = "<b>\(name)</b> has sent you a friend request."
        } else if action == "liked" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            is_checked = dic["is_checked"] as? Int ?? 0
            desc = "<b>\(name)</b> has sent you a Heart."
        } else if action == "disliked" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            is_checked = dic["is_checked"] as? Int ?? 0
            desc = "<b>\(name)</b> has sent you a Poop."
        } else if action == "me_too" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            desc = "<b>\(name)</b> superlikes you too."
        } else if action == "throw_back" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            desc = "<b>\(name)</b> throws back your Poop."
        } else if action == "accept_friend_request" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            desc = "<b>\(name)</b> has become your friend."
        } else if action == "friend_invite" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            let eTitle = data_obj["event_title"] as? String ?? ""
            desc = "<b>\(name)</b> invites you to a nearby event <b>\(eTitle)</b>."
        } else if action == "non_friend_invite" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            let eTitle = data_obj["event_title"] as? String ?? ""
            desc = "<b>\(name)</b> invites you to a nearby event <b>\(eTitle)</b>."
        } else if action == "ping_2hours_event" {
            wId = dic["id"] as? Int ?? 0
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            event = Event(dic: data_obj)
            created_at = dic["created_at"] as? String ?? ""
            desc = "Your event <b>\(event!.title)</b> is going to start in 2 hours."
        } else if action == "ping_30mins_event" {
            wId = dic["id"] as? Int ?? 0
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            event = Event(dic: data_obj)
            created_at = dic["created_at"] as? String ?? ""
            desc = "Your event <b>\(event!.title)</b> is going to start in 30 mins."
        } else if action == "ping_less_member" {
            wId = dic["id"] as? Int ?? 0
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            event = Event(dic: data_obj)
            created_at = dic["created_at"] as? String ?? ""
            desc = "Your event <b>\(event!.title)</b> didn\'t reach minimum number of people and will be cancelled."
        } else if action == "tagged" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            var sTags = data_obj["tags"] as? String ?? ""
            sTags = "#" + sTags;
            sTags = sTags.replacingOccurrences(of: ", #", with: ",")
            desc = "<b>\(name)</b> tagged you \(sTags)."
        } else if action == "tipped" {
            wId = dic["id"] as? Int ?? 0
            uId = actor["id"] as? Int ?? 0
            name = actor["first_name"] as? String ?? ""
            photo = actor["avatar"] as? String ?? ""
            created_at = dic["created_at"] as? String ?? ""
            //let data_obj = dic["data"] as? [String:AnyObject] ?? [:]
            desc = "<b>\(name)</b> tipped you."
        }
    }
}
