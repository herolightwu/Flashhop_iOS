//
//  Card.swift
//  Flashhop
//
//  Created by Tiexong Li on 2019/11/4.
//

import Foundation

extension NSObject {
    func decodeBool(coder: NSCoder, forKey: String) -> Bool {
        guard  let result = coder.decodeObject(forKey: forKey) else {
            return false
        }
        return result as! Bool
    }
    
    func decodeString(coder: NSCoder, forKey: String) -> String {
        guard  let result = coder.decodeObject(forKey: forKey) else {
            return ""
        }
        return result as! String
    }
    
    func decodeStringArray(coder: NSCoder, forKey: String) -> [String] {
        guard  let result = coder.decodeObject(forKey: forKey) else {
            return []
        }
        return result as! [String]
    }
    
    func decodeInt(coder: NSCoder, forKey: String) -> Int {
        guard  let result = coder.decodeObject(forKey: forKey) else {
            return 0
        }
        return result as! Int
    }
    
    func decodeDouble(coder: NSCoder, forKey: String) -> Double {
        guard  let result = coder.decodeObject(forKey: forKey) else {
            return 0
        }
        return result as! Double
    }
    
    func decodeInt64(coder: NSCoder, forKey: String) -> Int64 {
        guard  let result = coder.decodeObject(forKey: forKey) else {
            return 0
        }
        return result as! Int64
    }
}


class Card: NSObject, NSCoding {
    
    public var id = ""
    public var card_number = ""
    public var last4 = ""
    public var holder_name = ""
    public var exp_month = ""
    public var exp_year = ""
    public var card_cvc = ""
    public var address_line1 = ""
    public var address_city = ""
    public var address_state = ""
    public var address_postal_code = ""

    func encode(with coder: NSCoder) {
        coder.encode(id as Any, forKey: "id")
        coder.encode(card_number as Any, forKey: "card_number")
        coder.encode(last4 as Any, forKey: "last4")
        coder.encode(holder_name as Any, forKey: "holder_name")
        coder.encode(exp_month as Any, forKey: "exp_month")
        coder.encode(exp_year as Any, forKey: "exp_year")
        coder.encode(card_cvc as Any, forKey: "card_cvc")
        coder.encode(address_line1 as Any, forKey: "address_line1")
        coder.encode(address_city as Any, forKey: "address_city")
        coder.encode(address_state as Any, forKey: "address_state")
        coder.encode(address_postal_code as Any, forKey: "address_postal_code")
    }
    
    required init?(coder: NSCoder) {
        super.init()
        self.id = self.decodeString(coder: coder, forKey: "id")
    }

    override init() {}
    
    init(dic:[String:AnyObject]) {
        id = dic["id"] as? String ?? ""
        last4 = dic["last4"] as? String ?? ""
        card_number = dic["card_number"] as? String ?? ""
        exp_month = dic["exp_month"] as? String ?? ""
        exp_year = dic["exp_year"] as? String ?? ""
        holder_name = dic["holder_name"] as? String ?? ""
        
        let cvc_check = dic["cvc_check"] as? String ?? ""
        card_cvc = cvc_check == "pass" ? "123" : ""
        
        address_city = dic["address_city"] as? String ?? ""
        address_line1 = dic["address_line1"] as? String ?? ""
        address_state = dic["address_state"] as? String ?? ""
        address_postal_code = dic["address_zip"] as? String ?? ""
    }
    
    public static func getMyCard()->Card {
        var result = Card()
        if (UserDefaults.standard.value(forKey: "my_card") != nil) {
            let decodedData = UserDefaults.standard.value(forKey: "my_card") as! [String:AnyObject]
            result = Card(dic: decodedData)
            return result
        }
        return result
    }
    public static func saveMyCard(card:Card) {
        let param:[String:Any] = [
            "id": card.id,
            "last4": card.last4,
            "card_number": card.card_number,
            "holder_name": card.holder_name,
            "exp_month": card.exp_month,
            "exp_year": card.exp_year,
            "cvc_check": card.card_cvc,
            "address_city": card.address_city,
            "address_line1": card.address_line1,
            "address_state": card.address_state,
            "address_zip": card.address_postal_code
        ]
        UserDefaults.standard.set(param, forKey: "my_card")
        UserDefaults.standard.synchronize()
    }
}

