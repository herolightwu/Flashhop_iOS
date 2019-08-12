//
//  Event.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/24.
//

import UIKit
import SDWebImage

enum Currency:Int, CaseIterable {
    case CAD, USD
    var str: String {
        switch self {
        case .CAD:  return "CAD"
        case .USD:  return "USD"
        }
    }
}

class Event: NSObject {
    static let MIN_AGE = 18
    static let MAX_AGE = 99
    
    public var title = ""
    public var date_str = ""
    public var time_str = ""
    public var end_time_str = ""
    public var address = ""
    public var min_members = 4
    public var max_members = 30
    public var min_age = 18
    public var max_age = 99
    public var category: Interest = .party
    public var cover_photo = ""
    public var desc = ""
    public var gender:Gender = .co
    public var is_private = false
    public var allow_invite = false
    public var lat:Double = 0
    public var lng:Double = 0
    public var price:Double = 0
    public var currency:Currency = .CAD
    public var begin_at = 0
    
    public var id = 0
    public var is_liked_by_you = 0
    public var is_pay_later = 0
    public var dislike_id_list:[Int] = []
    public var like_id_list:[Int] = []
    public var creator:FUser = me
    public var members:[FUser] = []
    public var db_id = 0
    
    public func dic_value() -> [String:Any] {
        var param:[String:Any] = [
            "event_title": title,
            "event_date": date_str,
            "event_time": time_str,
            "event_end_time": end_time_str,
            "address": address,
            "min_members": min_members,
            "max_members": max_members,
            "min_age": min_age,
            "max_age": max_age,
            "event_category": category.str,
            "event_description": desc,
            "lat": lat,
            "lng": lng,
            "price": price,
            "currency_code": currency.str,
            "event_begin_at": begin_at,
            "is_pay_later": is_pay_later,
            "db_id": db_id
        ]
        
        var str = ""
        if gender == .co { str = "co" }
        if gender == .male { str = "boy" }
        if gender == .female { str = "girl" }
        param["gender"] = str
        
        var value = 0
        if is_private { value = 1 } else { value = 0 }
        param["is_private"] = value
        
        if allow_invite { value = 1 } else { value = 0 }
        param["allow_invite"] = value
        
        return param
    }
    convenience init(dic:[String:AnyObject]) {
        self.init()
        
        if let id = dic["id"] as? Int { self.id = id }
        if let title = dic["event_title"] { self.title = "\(title)" }
        if let date_str = dic["event_date"] as? String { self.date_str = date_str }
        if let time_str = dic["event_time"] as? String { self.time_str = time_str.uppercased() }
        if let end_time_str = dic["event_end_time"] as? String { self.end_time_str = end_time_str.uppercased() }
        if let address = dic["address"] as? String { self.address = address }
        if let min_members = dic["min_members"] as? Int { self.min_members = min_members }
        if let max_members = dic["max_members"] as? Int { self.max_members = max_members }
        if let min_age = dic["min_age"] as? Int { self.min_age = min_age }
        if let max_age = dic["max_age"] as? Int { self.max_age = max_age }
        if let category = dic["event_category"] as? String {
            for i in Interest.allCases { if category == i.str { self.category = i } }
        }
        if let cover_photo = dic["cover_photo"] as? String { self.cover_photo = cover_photo }
        if let desc = dic["event_description"] as? String { self.desc = desc }
        if let gender = dic["gender"] as? String {
            for g in Gender.allCases { if gender == g.str { self.gender = g } }
        }
        if let is_private = dic["is_private"] as? Bool { self.is_private = is_private }
        if let allow_invite = dic["allow_invite"] as? Bool { self.allow_invite = allow_invite }
        if let lat = dic["lat"] as? Double { self.lat = lat }
        if let lng = dic["lng"] as? Double { self.lng = lng }
        if let price = dic["price"] as? Double { self.price = price }
        if let currency = dic["currency_code"] as? String {
            for c in Currency.allCases { if c.str == currency { self.currency = c } }
        }
        if let begin_at = dic["event_begin_at"] as? Int { self.begin_at = begin_at }
        
        if let like = dic["isLikedByYou"] as? Int { self.is_liked_by_you = like }
        if let is_pay_later = dic["is_pay_later"] as? Int { self.is_pay_later = is_pay_later }
        if let dislikes = dic["dislike_id_list"] as? [Int] { self.dislike_id_list = dislikes }
        if let likes = dic["like_id_list"] as? [Int] { self.like_id_list = likes }
        if let creator = dic["creator"] as? [String:AnyObject] { self.creator = FUser(dic:creator) }
        
        if let members = dic["members"] as? [[String:AnyObject]] {
            for dic in members {
                let user = FUser(dic: dic["user"] as! [String:AnyObject])
                self.members.append(user)                
            }
        }
    }
    
    public func start_end() -> String {
        if end_time_str == "" { return time_str }
        else { return time_str + " - " + end_time_str }
    }
    public func time() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        let str = date_str + " " + time_str
        let date = formatter.date(from: str)
        return date ?? Date()
    }
    public func end_time() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        let str = date_str + " " + end_time_str
        let date = formatter.date(from: str)
        return date ?? time()
    }
    public func set_date(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        date_str = formatter.string(from: date)
        begin_at = Int(date.timeIntervalSince1970)
    }
    public func set_time(_ time: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        time_str = formatter.string(from: time)
    }
    public func set_end_time(_ time: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        end_time_str = formatter.string(from: time)
    }
    public func set_duration(_ dur: Int) {
        let start_date = time()
        let end_date = Calendar.current.date(byAdding: .minute, value: dur, to: start_date)
        if let date = end_date {
            set_end_time(date)
        }
    }
    
    func is_creator(_ user:FUser) -> Bool {
        return creator.id == user.id
    }
    func is_member(_ user:FUser) -> Bool {
        for member in members {
            if member.id == user.id { return true }
        }
        return false
    }
    func members_and_creator() ->[FUser] {
        var users:[FUser] = members
        users.append(creator)
        return users
    }
    func can_invite_friend_by(_ user:FUser) -> Bool {
        if is_creator(user) { return true }    // creator
        if is_member(user) && !is_private { return true }    // member, not private
        return false
    }
    func is_full() -> Bool {
        return members.count + 1 >= max_members
    }
    func friends() -> [FUser] {
        var users:[FUser] = []
        for user in members_and_creator() {
            if user.is_my_friend == 1 {
                users.append(user)
            }
        }
        return users
    }
    
    func saveAsDraft() {
        var dic = dic_value()
        if self.db_id == 0 {
            dic["db_id"] = Int(Date().timeIntervalSince1970)
        } else{
            removeFromDraft()
        }
        var array = UserDefaults.standard.array(forKey: "draft_events") ?? []
        array.append(dic)
        UserDefaults.standard.set(array, forKey: "draft_events")
    }
    func removeFromDraft() {
        var array = UserDefaults.standard.array(forKey: "draft_events") as? [[String:AnyObject]] ?? []
        array = array.filter({ (dic) -> Bool in
            let event = Event(dic: dic)
            return event.db_id != self.db_id
        })
        UserDefaults.standard.set(array, forKey: "draft_events")
    }
}
func draft_events() -> [Event] {
    var events:[Event] = []
    let dicArray = UserDefaults.standard.array(forKey: "draft_events") as? [[String:AnyObject]] ?? []
    for dic in dicArray {
        let event = Event(dic: dic)
        events.append(event)
    }
    return events
}
