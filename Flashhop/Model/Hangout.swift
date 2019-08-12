//
//  Hangout.swift
//  Flashhop
//
//  Created by Jinri on 2019/10/14.
//

import UIKit

class Hangout: NSObject {
    public var name = ""
    public var photo_url = ""
    public var count = 0
    public var type = ""
    
    convenience init(dic:[String:AnyObject]) {
        self.init()
        
        if let name = dic["userName"] as? String { self.name = name }
        if let str = dic["avatar"] as? String { self.photo_url = str }
        if let n = dic["count"] as? Int { self.count = n }
    }
}
