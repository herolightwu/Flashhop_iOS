//
//  Filter.swift
//  Flashhop
//
//  Created by Jinri on 2019/9/23.
//

import UIKit
import Alamofire

class Filter: NSObject {
    public var event_date:[Date] = [
        Date(timeInterval: 0*24*3600, since: Date()),
        Date(timeInterval: 1*24*3600, since: Date()),
        Date(timeInterval: 2*24*3600, since: Date()),
        Date(timeInterval: 3*24*3600, since: Date()),
        Date(timeInterval: 4*24*3600, since: Date()),
        Date(timeInterval: 5*24*3600, since: Date()),
        Date(timeInterval: 6*24*3600, since: Date())
    ]
    public var event_category:[Interest:Bool] = [
        .party:true,
        .eating:true,
        .games:true,
        .sports:true,
        .outdoors:true,
        .spirits:true,
        .dating:true,
        .arts:true,
        .study:true
    ]
    public var min_age: CGFloat = 18
    public var max_age: CGFloat = 99
    public var gender:Gender = .co
    
    enum Option {
        case both, people, event
        var str: String {
            switch self {
            case .both:     return "both"
            case .people:   return "people"
            case .event:    return "event"
            }
        }
    }
    public var option:Option = .both
    public var period = 7
    
    public func event_date_str() -> String {
        var str = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        for date in event_date {
            str += formatter.string(from: date) + ", "
        }
        if str.count != 0 { str = String(str.dropLast()) }
        return str
    }
    public func dic_value() -> Parameters {        
        let param:Parameters = [
            "event_date": event_date_str(),
            "event_category": FUser.interest_str(event_category),
            "min_age": "\(Int(min_age))",
            "max_age": "\(Int(max_age))",
            "gender": gender.str,
            "filter_option": option.str,
            "period": period,
            "current_time": Date().timeIntervalSince1970
        ]
        return param
    }
}
