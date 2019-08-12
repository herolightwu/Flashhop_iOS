//
//  FUser.swift
//  Flashhop
//
//  Created by Jinri on 2019/8/19.
//

import UIKit

enum Gender:Int, CaseIterable {
    case co, male, female
    var str: String {
        switch self {
        case .co:       return "co"
        case .male:     return "male"
        case .female:   return "female"
        }
    }
}
enum Language:Int, CaseIterable {
    case en, fr, cn, es, ja, ko, ar, ru, de, po
    var str: String {
        switch self {
        case .en:   return "en"
        case .fr:   return "fr"
        case .cn:   return "cn"
        case .es:   return "es"
        case .ja:   return "ja"
        case .ko:   return "ko"
        case .ar:   return "ar"
        case .ru:   return "ru"
        case .de:   return "de"
        case .po:   return "po"
        }
    }
}
enum Interest:Int, CaseIterable {
    case party, eating, dating, sports, outdoors, games, study, spirits, arts
    var str: String {
        switch self {
        case .party:    return "party"
        case .eating:   return "eating"
        case .dating:   return "dating"
        case .sports:   return "sports"
        case .outdoors: return "outdoors"
        case .games:    return "games"
        case .study:    return "study"
        case .spirits:  return "spirits"
        case .arts:     return "arts"
        }
    }
    var cover_image: UIImage {
        switch self {
        case .party:        return UIImage(named: "category_party")!
        case .eating:       return UIImage(named: "category_eating")!
        case .dating:       return UIImage(named: "category_dating")!
        case .sports:       return UIImage(named: "category_sports")!
        case .outdoors:     return UIImage(named: "category_outdoors")!
        case .games:        return UIImage(named: "category_games")!
        case .study:        return UIImage(named: "category_study")!
        case .spirits:      return UIImage(named: "category_spirits")!
        case .arts:         return UIImage(named: "category_arts")!
        }
    }
}
class FUser: NSObject {
    public var id = 0
    public var filter = Filter()
    
    public var first_name = ""
    public var second_name = ""
    public var dob = "" // birthday
    public var email = ""
    public var email_verified = false
    public var photo_url = ""
    public var address = ""
    public var created_at = ""
    public var updated_at = ""
    public var event_count = 0
    public var fun_facts = ""
    public var hide_my_age = false
    public var hide_my_location = false
    public var is_active = false
    public var is_active_by_customer = false
    public var lat:Double = 0
    public var lng:Double = 0
    public var personality_type = ""
    public var phone_number = ""
    public var photo_id = 0
    public var push_chats = false
    public var push_friends_activities = false
    public var push_my_activities = false
    public var role_id = 0
    public var social_id = ""
    public var social_image = ""
    public var social_name = ""
    public var last_dob_updated_at = ""
    public var last_gender_updated_at = ""
    public var dob_editable = false
    public var gender_editable = false
    public var tags:[String] = []
    public var images:[String] = []    
    public var gender:Gender = .co
    public var langs:[Language] = []
    public var location_updated_at:TimeInterval = 0
    public var is_my_friend = 0
    public var is_friendable = false
    public var is_debit = 0
    public var is_liked = 0
    
    func full_name() -> String {
        return first_name + " " + second_name
    }
    func langs_string() -> String {
        var strLang = ""
        for i in 0..<langs.count {
            strLang += langs[i].str
            if i != langs.count-1 {
                strLang += ","
            }
        }
        return strLang
    }
    public var interests:[Interest:Bool] = [:]
    func interest_str() -> String {
        return FUser.interest_str(interests)
    }
    class func interest_str(_ interests:[Interest:Bool]) -> String {
        var str = ""
        for (interest, flag) in interests {
            if flag { str += interest.str + "," }
        }
        if str.count != 0 { str = String(str.dropLast()) }
        return str
    }

    override init() {
        
    }
    
    convenience init(dic:[String:AnyObject]) {
        self.init()
        if let id = dic["id"] as? Int { self.id = id }
        
        if let first_name = dic["first_name"] as? String { self.first_name = first_name }
        if let second_name = dic["last_name"] as? String { self.second_name = second_name }
        if let birthday = dic["dob"] as? String { self.dob = birthday }
        if let email = dic["email"] as? String { self.email = email }
        if let email_verified = dic["email_verified"] as? Bool { self.email_verified = email_verified }
        if let photo_url = dic["avatar"] as? String { self.photo_url = photo_url }
        
        let strGender = dic["gender"] as? String
        if strGender == "male" { self.gender = .male }
        else if strGender == "female" { self.gender = .female }
        else { self.gender = .co }
        
        if let strLangs = dic["lang"] as? String {
            for lng in Language.allCases {
                if strLangs.contains(lng.str) { self.langs.append(lng) }
            }
        }
        
        if let strInterests = dic["interests"] as? String {
            for interest in Interest.allCases {
                if strInterests.contains(interest.str) { self.interests[interest] = true }
            }
        }
        
        if let address = dic["address"] as? String { self.address = address }
        if let created_at = dic["created_at"] as? String { self.created_at = created_at }
        if let event_count = dic["event_count"] as? Int { self.event_count = event_count }
        if let fun_facts = dic["fun_facts"] as? String { self.fun_facts = fun_facts }
        if let hide_my_age = dic["hide_my_age"] as? Bool { self.hide_my_age = hide_my_age }
        if let hide_my_location = dic["hide_my_location"] as? Bool { self.hide_my_location = hide_my_location }
        if let is_active = dic["is_active"] as? Bool { self.is_active = is_active }
        if let is_active_by_customer = dic["is_active_by_customer"] as? Bool { self.is_active_by_customer = is_active_by_customer }
        if let lat = dic["lat"] as? Double { self.lat = lat }
        if let lng = dic["lng"] as? Double { self.lng = lng }
        if let personality_type = dic["personality_type"] as? String { self.personality_type = personality_type }
        if let phone_number = dic["phone_number"] as? String { self.phone_number = phone_number }
        if let push_chats = dic["push_chats"] as? Bool { self.push_chats = push_chats }
        if let push_friends_activities = dic["push_friends_activities"] as? Bool { self.push_friends_activities = push_friends_activities }
        if let push_my_activities = dic["push_my_activities"] as? Bool { self.push_my_activities = push_my_activities }
        if let social_id = dic["social_id"] as? String { self.social_id = social_id }
        if let social_image = dic["social_image"] as? String { self.social_image = social_image }
        if let social_name = dic["social_name"] as? String { self.social_name = social_name }
        if let updated_at = dic["updated_at"] as? String { self.updated_at = updated_at }
        if let last_dod_updated_at = dic["last_dob_updated_at"] as? String { self.last_dob_updated_at = last_dod_updated_at }
        if let last_gender_updated_at = dic["last_gender_updated_at"] as? String { self.last_gender_updated_at = last_gender_updated_at }
        if let dob_editable = dic["update_dob_enable"] as? Bool { self.dob_editable = dob_editable }
        if let gender_editable = dic["update_gender_enable"] as? Bool { self.gender_editable = gender_editable }
        if let location_updated_at = dic["location_updated_at"] as? TimeInterval { self.location_updated_at = location_updated_at }
        if let is_my_friend = dic["is_my_friend"] as? Int { self.is_my_friend = is_my_friend }
        if let is_friendable = dic["is_friendable"] as? Bool { self.is_friendable = is_friendable }
        if let is_liked = dic["is_liked"] as? Int { self.is_liked = is_liked }
        
        if let tags = dic["tag_list"] as? [String] {
            for tag in tags { self.tags.append(tag) }
        }
        
        if let images = dic["images"] as? [String] {
            for image in images { self.images.append(image) }
        }
    }
    
    public func birthday() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self.dob)!
    }
    
    func age() ->Int {
        return Calendar.current.dateComponents([.year], from: birthday(), to: Date()).year ?? 0
    }
    
    func viewForPhotoOnMap() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        let iv = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.sd_setImage(with: URL(string: photo_url), completed: nil)
        view.addSubview(iv)
        
        //makeShadowView(iv)
        
        return view
    }
}


